// ============================================================
// 六大 Trait（阶段一4个 + 阶段二2个）
// ============================================================

pub trait DocumentLoader {
  load(self : Self, path : String) -> Array[Document]
}

pub trait TextSplitter {
  split(self : Self, docs : Array[Document]) -> Array[Chunk]
}

pub trait Embedder {
  embed_documents(self : Self, texts : Array[String]) -> Array[Array[Double]]
  embed_query(self : Self, query : String) -> Array[Double]
}

pub trait VectorStore {
  add(self : Self, chunks : Array[Chunk]) -> Unit
  search(self : Self, query_embedding : Array[Double], top_k : Int) -> Array[SearchResult]
  clear(self : Self) -> Unit
  count(self : Self) -> Int
}

pub trait Retriever {
  retrieve(self : Self, query : String, top_k : Int) -> Array[SearchResult]
}

pub trait Generator {
  generate(self : Self, query : String, context : Array[Chunk]) -> GenerationResult
}
