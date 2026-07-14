// ============================================================
// FileStore - 文件持久化向量存储
// 基于 InMemoryStore + JSON 文件持久化（native target 专用）
// ============================================================

// C FFI 声明（参见 file_io.c）
#owned(path)
pub extern "C" fn fs_read_all(path : String) -> String = "fs_read_all"

#owned(path)
#owned(data)
pub extern "C" fn fs_write_all(path : String, data : String) -> Int = "fs_write_all"

#owned(path)
pub extern "C" fn fs_remove_file(path : String) -> Int = "fs_remove_file"

#owned(path)
extern "C" fn fs_ensure_dir(path : String) -> Int = "fs_ensure_dir"

// 从 stdin 读取一行(用于交互式命令行),prompt 为提示符
#owned(prompt)
pub extern "C" fn fs_read_line(prompt : String) -> String = "fs_read_line"

// 辅助：读取文件内容
fn read_file(path : String) -> String? {
  let content = fs_read_all(path)
  if content == "" {
    None
  } else {
    Some(content)
  }
}

// 辅助：写入文件
fn write_file(path : String, content : String) -> Bool {
  fs_write_all(path, content) > 0
}

struct FileStore {
  file_path : String
  mut store : @ragmbt.InMemoryStore
}

pub fn FileStore::new(file_path : String) -> FileStore {
  let store = @ragmbt.InMemoryStore::new()
  let fs = { file_path, store }
  fs._load_from_file()
  fs
}

// 序列化所有数据为 JSON 字符串
fn FileStore::_serialize(self : FileStore) -> String {
  let items : Array[Json] = []
  let n = self.store.chunks.length()
  for i = 0; i < n; i = i + 1 {
    let chunk = self.store.chunks[i]
    let embedding = self.store.embeddings[i]
    let item = Json::object({
      "id": Json::string(chunk.id),
      "text": Json::string(chunk.text),
      "metadata": {
        let meta_map : Map[String, Json] = Map([])
        chunk.metadata.each(fn(k, v) { meta_map[k] = Json::string(v) })
        Json::object(meta_map)
      },
      "embedding": Json::array(embedding.map(fn(d) { Json::number(d) })),
    })
    items.push(item)
  }
  let root = Json::object({"chunks": Json::array(items)})
  root.stringify()
}

// 从 JSON 反序列化加载到内存
fn FileStore::_load_from_file(self : FileStore) -> Unit {
  match read_file(self.file_path) {
    None => ()
    Some(content) => {
      try {
        let json = @json.parse(content)
        match json {
          Json::Object(obj) => match obj["chunks"] {
            Json::Array(items) => {
              for item in items {
                match item {
                  Json::Object(chunk_obj) => {
                    let id = match chunk_obj["id"] {
                      Json::String(s) => s
                      _ => continue
                    }
                    let text = match chunk_obj["text"] {
                      Json::String(s) => s
                      _ => continue
                    }
                    let metadata : Map[String, String] = match chunk_obj["metadata"] {
                      Json::Object(m) => {
                        let mm : Map[String, String] = Map([])
                        m.each(fn(k, v) {
                          match v {
                            Json::String(s) => mm[k] = s
                            _ => ()
                          }
                        })
                        mm
                      }
                      _ => Map([])
                    }
                    let embedding = match chunk_obj["embedding"] {
                      Json::Array(arr) => {
                        let emb : Array[Double] = []
                        for v in arr {
                          match v {
                            Json::Number(d, ..) => emb.push(d)
                            _ => ()
                          }
                        }
                        emb
                      }
                      _ => continue
                    }
                    if embedding.length() > 0 {
                      let chunk = @ragmbt.Chunk::new(id, text, metadata).with_embedding(embedding)
                      self.store.chunks.push(chunk)
                      self.store.embeddings.push(embedding)
                    }
                  }
                  _ => continue
                }
              }
            }
            _ => ()
          }
          _ => ()
        }
      } catch {
        _ => ()
      }
    }
  }
}

// 持久化到文件
fn FileStore::_save_to_file(self : FileStore) -> Unit {
  // 确保父目录存在
  let path = self.file_path
  let mut last_slash = -1
  let path_len = path.length()
  for i = 0; i < path_len; i = i + 1 {
    if path[i] == '/' {
      last_slash = i
    }
  }
  if last_slash >= 0 {
    let dir = path[0:last_slash].to_string()
    let _ = fs_ensure_dir(dir)
  }
  let json_str = self._serialize()
  let _ = write_file(path, json_str)
}

// 本地余弦相似度(避免跨包调用 trait 方法)
fn file_cosine_sim(a : Array[Double], b : Array[Double]) -> Double {
  let dim = a.length()
  let mut dot = 0.0
  let mut norm_a = 0.0
  let mut norm_b = 0.0
  for i = 0; i < dim; i = i + 1 {
    dot = dot + a[i] * b[i]
    norm_a = norm_a + a[i] * a[i]
    norm_b = norm_b + b[i] * b[i]
  }
  if norm_a == 0.0 || norm_b == 0.0 {
    return 0.0
  }
  dot / (norm_a.sqrt() * norm_b.sqrt())
}

pub fn FileStore::add(self : FileStore, new_chunks : Array[@ragmbt.Chunk]) -> Unit {
  for chunk in new_chunks {
    match chunk.embedding {
      Some(emb) => {
        self.store.chunks.push(chunk)
        self.store.embeddings.push(emb)
      }
      None => continue
    }
  }
  self._save_to_file()
}

pub fn FileStore::search(self : FileStore, query_embedding : Array[Double], top_k : Int) -> Array[@ragmbt.SearchResult] {
  let scores : Array[(Double, Int)] = []
  let n = self.store.embeddings.length()
  for i = 0; i < n; i = i + 1 {
    let score = file_cosine_sim(query_embedding, self.store.embeddings[i])
    scores.push((score, i))
  }
  // 简单冒泡排序(降序)
  for i = 0; i < scores.length(); i = i + 1 {
    for j = i + 1; j < scores.length(); j = j + 1 {
      if scores[i].0 < scores[j].0 {
        let tmp = scores[i]
        scores[i] = scores[j]
        scores[j] = tmp
      }
    }
  }
  // 取 top_k
  let k = if top_k < scores.length() { top_k } else { scores.length() }
  let results : Array[@ragmbt.SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    let idx = scores[i].1
    results.push(@ragmbt.SearchResult::new(self.store.chunks[idx], scores[i].0))
  }
  results
}

pub fn FileStore::clear(self : FileStore) -> Unit {
  self.store = @ragmbt.InMemoryStore::new()
  let _ = fs_remove_file(self.file_path)
}

pub fn FileStore::count(self : FileStore) -> Int {
  self.store.chunks.length()
}
