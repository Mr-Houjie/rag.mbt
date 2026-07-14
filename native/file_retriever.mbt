// ============================================================
// FileRetriever - 组合 Embedder + FileStore
// ============================================================

struct FileRetriever {
  embedder : LocalEmbedder
  store : FileStore
}

pub fn FileRetriever::new(embedder : LocalEmbedder, store : FileStore) -> FileRetriever {
  { embedder, store, }
}

pub fn FileRetriever::retrieve(self : FileRetriever, query : String, top_k : Int) -> Array[@ragmbt.SearchResult] {
  let query_emb = self.embedder.embed_query(query)
  self.store.search(query_emb, top_k)
}
