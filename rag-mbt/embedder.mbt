// ============================================================
// MockEmbedder - 哈希向量嵌入器（演示用）
// ============================================================

struct MockEmbedder {
  dimension : Int
}

pub fn MockEmbedder::new(dimension~ : Int = 32) -> MockEmbedder {
  { dimension, }
}

fn MockEmbedder::text_to_vector(self : MockEmbedder, text : String) -> Array[Double] {
  let dim = self.dimension
  let vec = Array::makei(dim, fn(_val) { 0.0 })
  let bytes = text.to_bytes()
  for j = 0; j < bytes.length(); j = j + 1 {
    let idx = (bytes[j].to_int() * 7 + j * 13) % dim
    let val = bytes[j].to_double() / 255.0
    vec[idx] = vec[idx] + val
  }
  // L2 归一化
  let mut norm = 0.0
  for k = 0; k < dim; k = k + 1 {
    norm = norm + vec[k] * vec[k]
  }
  if norm > 0.0 {
    let scale = 1.0 / norm.sqrt()
    for k = 0; k < dim; k = k + 1 {
      vec[k] = vec[k] * scale
    }
  }
  vec
}

impl Embedder for MockEmbedder with embed_documents(self : MockEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  let embeddings : Array[Array[Double]] = []
  for text in texts {
    embeddings.push(self.text_to_vector(text))
  }
  embeddings
}

impl Embedder for MockEmbedder with embed_query(self : MockEmbedder, query : String) -> Array[Double] {
  self.text_to_vector(query)
}
