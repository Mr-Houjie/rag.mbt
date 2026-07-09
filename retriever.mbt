// ============================================================
// SimpleRetriever - 组合 Embedder + Store
// ============================================================

struct SimpleRetriever {
  embedder : MockEmbedder
  store : InMemoryStore
}

pub fn SimpleRetriever::new(embedder : MockEmbedder, store : InMemoryStore) -> SimpleRetriever {
  { embedder, store, }
}

impl Retriever for SimpleRetriever with retrieve(self : SimpleRetriever, query : String, top_k : Int) -> Array[SearchResult] {
  let query_emb = self.embedder.embed_query(query)
  self.store.search(query_emb, top_k)
}
