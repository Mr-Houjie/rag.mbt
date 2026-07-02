// ============================================================
// OpenAiEmbedder - OpenAI Embedding API (native only)
// 需要: C 编译器 + pip install openai
// ============================================================

struct OpenAiEmbedder {
  api_key : String
  model : String
}

pub fn OpenAiEmbedder::new(api_key : String, model~ : String = "text-embedding-3-small") -> OpenAiEmbedder {
  { api_key, model, }
}

impl @ragmbt.Embedder for OpenAiEmbedder with embed_documents(self : OpenAiEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  let openai = @python.pyimport("openai")
  let client = openai.attr("OpenAI").call((
    @python.kwargs([("api_key", self.api_key)]),
  ))
  
  let py_texts = @python.list(texts.length())
  for text in texts {
    py_texts.call_method("append", (text,))
  }
  
  let response = client.attr("embeddings").attr("create").call((
    @python.kwargs([
      ("model", self.model),
      ("input", py_texts),
    ]),
  ))
  
  let data = response.attr("data")
  let embeddings : Array[Array[Double]] = []
  for i = 0; i < data.call_method("__len__", ()); i = i + 1 {
    let py_emb = data.call_method("__getitem__", (i,)).attr("embedding")
    let dim = py_emb.call_method("__len__", ())
    let emb : Array[Double] = []
    for j = 0; j < dim; j = j + 1 {
      emb.push(py_emb.call_method("__getitem__", (j,)).to_double())
    }
    embeddings.push(emb)
  }
  embeddings
}

impl @ragmbt.Embedder for OpenAiEmbedder with embed_query(self : OpenAiEmbedder, query : String) -> Array[Double] {
  let embeddings = self.embed_documents([query])
  embeddings[0]
}
