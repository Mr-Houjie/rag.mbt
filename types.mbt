// ============================================================
// 核心数据类型
// ============================================================

pub struct Document {
  content : String
  metadata : Map[String, String]
}

pub struct Chunk {
  pub id : String
  pub text : String
  pub metadata : Map[String, String]
  pub embedding : Array[Double]?
}

pub struct SearchResult {
  chunk : Chunk
  score : Double
}

pub struct GenerationResult {
  answer : String
  sources : Array[Chunk]
}

// ============================================================
// 辅助函数
// ============================================================

pub fn Document::new(content : String, metadata : Map[String, String]) -> Document {
  { content, metadata }
}

pub fn Chunk::new(id : String, text : String, metadata : Map[String, String]) -> Chunk {
  { id, text, metadata, embedding : None }
}

pub fn Chunk::with_embedding(self : Chunk, emb : Array[Double]) -> Chunk {
  { ..self, embedding: Some(emb) }
}

pub fn SearchResult::new(chunk : Chunk, score : Double) -> SearchResult {
  { chunk, score }
}

pub fn GenerationResult::new(answer : String, sources : Array[Chunk]) -> GenerationResult {
  { answer, sources }
}

pub fn make_meta(pairs : Array[(String, String)]) -> Map[String, String] {
  let m : Map[String, String] = Map([])
  for pair in pairs {
    m[pair.0] = pair.1
  }
  m
}
