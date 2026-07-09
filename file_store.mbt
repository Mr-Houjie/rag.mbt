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
  store : InMemoryStore
}

pub fn FileStore::new(file_path : String) -> FileStore {
  let store = InMemoryStore::new()
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
                      let chunk = Chunk::new(id, text, metadata).with_embedding(embedding)
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

impl VectorStore for FileStore with add(self : FileStore, new_chunks : Array[Chunk]) -> Unit {
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

impl VectorStore for FileStore with search(self : FileStore, query_embedding : Array[Double], top_k : Int) -> Array[SearchResult] {
  self.store.search(query_embedding, top_k)
}

impl VectorStore for FileStore with clear(self : FileStore) -> Unit {
  self.store.chunks = []
  self.store.embeddings = []
  let _ = fs_remove_file(self.file_path)
}

impl VectorStore for FileStore with count(self : FileStore) -> Int {
  self.store.chunks.length()
}
