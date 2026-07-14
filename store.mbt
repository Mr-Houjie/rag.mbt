// ============================================================
// InMemoryStore - 内存向量存储（余弦相似度）
// ============================================================

pub struct InMemoryStore {
  pub mut chunks : Array[Chunk]
  pub mut embeddings : Array[Array[Double]]
}

pub fn InMemoryStore::new() -> InMemoryStore {
  { chunks: [], embeddings: [] }
}

// 余弦相似度
pub fn cosine_sim(a : Array[Double], b : Array[Double]) -> Double {
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

impl VectorStore for InMemoryStore with add(self : InMemoryStore, new_chunks : Array[Chunk]) -> Unit {
  for chunk in new_chunks {
    match chunk.embedding {
      Some(emb) => {
        self.chunks.push(chunk)
        self.embeddings.push(emb)
      }
      None => continue
    }
  }
}

impl VectorStore for InMemoryStore with search(self : InMemoryStore, query_embedding : Array[Double], top_k : Int) -> Array[SearchResult] {
  let scores : Array[(Double, Int)] = []
  let n = self.embeddings.length()
  for i = 0; i < n; i = i + 1 {
    let score = cosine_sim(query_embedding, self.embeddings[i])
    scores.push((score, i))
  }
  // 简单冒泡排序（降序）
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
  let results : Array[SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    let idx = scores[i].1
    results.push(SearchResult::new(self.chunks[idx], scores[i].0))
  }
  results
}

impl VectorStore for InMemoryStore with clear(self : InMemoryStore) -> Unit {
  self.chunks = []
  self.embeddings = []
}

impl VectorStore for InMemoryStore with count(self : InMemoryStore) -> Int {
  self.chunks.length()
}
