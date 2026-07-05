// ============================================================
// SimpleSplitter - 固定长度 + overlapping 切分器
// ============================================================

struct SimpleSplitter {
  chunk_size : Int
  chunk_overlap : Int
}

pub fn SimpleSplitter::new(chunk_size~ : Int = 500, chunk_overlap~ : Int = 50) -> SimpleSplitter {
  { chunk_size, chunk_overlap }
}

fn SimpleSplitter::split_text(self : SimpleSplitter, text : String) -> Array[String] {
  let len = text.length()
  let step = self.chunk_size - self.chunk_overlap
  if step <= 0 {
    return [text]
  }
  let mut i = 0
  let chunks : Array[String] = []
  while i < len {
    let end = if i + self.chunk_size > len { len } else { i + self.chunk_size }
    let chunk = text[i:end].to_owned()
    chunks.push(chunk)
    i = i + step
  }
  chunks
}

pub fn SimpleSplitter::do_split(self : SimpleSplitter, docs : Array[Document]) -> Array[Chunk] {
  self.split(docs)
}

impl TextSplitter for SimpleSplitter with split(self : SimpleSplitter, docs : Array[Document]) -> Array[Chunk] {
  let mut chunk_id = 0
  let all_chunks : Array[Chunk] = []
  for doc in docs {
    let texts = self.split_text(doc.content)
    for text in texts {
      let id = "chunk_\{chunk_id}"
      let chunk = Chunk::new(id, text, doc.metadata)
      all_chunks.push(chunk)
      chunk_id = chunk_id + 1
    }
  }
  all_chunks
}
