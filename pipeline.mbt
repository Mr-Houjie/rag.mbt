// ============================================================
// RAGPipeline - 通用 RAG 流水线(Builder 模式 + 闭包注入)
//
// 设计:用闭包字段替代具体类型字段,任何实现 Trait 的组件都可注入
//   - load_fn : (String) -> Array[Document]
//   - split_fn : (Array[Document]) -> Array[Chunk]
//   - embed_docs_fn : (Array[String]) -> Array[Array[Double]]
//   - embed_query_fn : (String) -> Array[Double]
//   - store_add_fn : (Array[Chunk]) -> Unit
//   - store_search_fn : (Array[Double], Int) -> Array[SearchResult]
//   - store_count_fn : () -> Int
//   - retrieve_fn : (String, Int) -> Array[SearchResult]
//   - generate_fn : (String, Array[Chunk]) -> GenerationResult
// ============================================================

pub struct RAGPipeline {
  // 阶段一:索引构建
  load_fn : (String) -> Array[Document]
  split_fn : (Array[Document]) -> Array[Chunk]
  embed_docs_fn : (Array[String]) -> Array[Array[Double]]
  embed_query_fn : (String) -> Array[Double]
  store_add_fn : (Array[Chunk]) -> Unit
  store_count_fn : () -> Int
  // 阶段二:检索生成
  retrieve_fn : (String, Int) -> Array[SearchResult]
  generate_fn : (String, Array[Chunk]) -> GenerationResult
  // 元信息(用于打印)
  embedder_label : String
  generator_label : String
}

// ============================================================
// Builder
// ============================================================

pub struct Builder {
  load_fn : ((String) -> Array[Document])?
  split_fn : ((Array[Document]) -> Array[Chunk])?
  embed_docs_fn : ((Array[String]) -> Array[Array[Double]])?
  embed_query_fn : ((String) -> Array[Double])?
  store_add_fn : ((Array[Chunk]) -> Unit)?
  store_count_fn : (() -> Int)?
  retrieve_fn : ((String, Int) -> Array[SearchResult])?
  generate_fn : ((String, Array[Chunk]) -> GenerationResult)?
  embedder_label : String
  generator_label : String
}

pub fn RAGPipeline::builder() -> Builder {
  {
    load_fn: None,
    split_fn: None,
    embed_docs_fn: None,
    embed_query_fn: None,
    store_add_fn: None,
    store_count_fn: None,
    retrieve_fn: None,
    generate_fn: None,
    embedder_label: "Unknown",
    generator_label: "Unknown",
  }
}

// ============================================================
// 通用 with_* 方法(直接注入闭包)
// ============================================================

pub fn Builder::with_load_fn(self : Builder, f : (String) -> Array[Document]) -> Builder {
  { ..self, load_fn: Some(f) }
}

pub fn Builder::with_split_fn(self : Builder, f : (Array[Document]) -> Array[Chunk]) -> Builder {
  { ..self, split_fn: Some(f) }
}

pub fn Builder::with_embed_fns(
  self : Builder,
  embed_docs : (Array[String]) -> Array[Array[Double]],
  embed_query : (String) -> Array[Double],
  label~ : String = "Custom"
) -> Builder {
  { ..self, embed_docs_fn: Some(embed_docs), embed_query_fn: Some(embed_query), embedder_label: label }
}

pub fn Builder::with_store_fns(
  self : Builder,
  add~ : (Array[Chunk]) -> Unit,
  count~ : () -> Int,
) -> Builder {
  { ..self, store_add_fn: Some(add), store_count_fn: Some(count) }
}

pub fn Builder::with_retrieve_fn(self : Builder, f : (String, Int) -> Array[SearchResult]) -> Builder {
  { ..self, retrieve_fn: Some(f) }
}

pub fn Builder::with_generate_fn(
  self : Builder,
  f : (String, Array[Chunk]) -> GenerationResult,
  label~ : String = "Custom"
) -> Builder {
  { ..self, generate_fn: Some(f), generator_label: label }
}

// ============================================================
// 适配具体类型的 with_* 方法
// ============================================================

/// 注入 TxtLoader
pub fn Builder::with_loader(self : Builder, loader : TxtLoader) -> Builder {
  { ..self, load_fn: Some(fn(path : String) {
    loader.load(path)
  }) }
}

/// 注入 SimpleSplitter
pub fn Builder::with_splitter(self : Builder, splitter : SimpleSplitter) -> Builder {
  { ..self, split_fn: Some(fn(docs : Array[Document]) {
    splitter.split(docs)
  }) }
}

/// 注入任意 Embedder(通过具体类型 + Trait 调用)
/// 由于 MoonBit trait 不能直接作为字段类型,这里提供常见 Embedder 的便捷方法
pub fn Builder::with_mock_embedder(self : Builder, embedder : MockEmbedder) -> Builder {
  { ..self,
    embed_docs_fn: Some(fn(texts : Array[String]) {
      embedder.embed_documents(texts)
    }),
    embed_query_fn: Some(fn(query : String) {
      embedder.embed_query(query)
    }),
    embedder_label: "MockEmbedder"
  }
}

pub fn Builder::with_tfidf_embedder(self : Builder, embedder : TfidfEmbedder) -> Builder {
  { ..self,
    embed_docs_fn: Some(fn(texts : Array[String]) {
      embedder.embed_documents(texts)
    }),
    embed_query_fn: Some(fn(query : String) {
      embedder.embed_query(query)
    }),
    embedder_label: "TfidfEmbedder(原生)"
  }
}

/// 注入 IVFStore
pub fn Builder::with_ivf_store(self : Builder, store : IVFStore) -> Builder {
  { ..self,
    store_add_fn: Some(fn(chunks : Array[Chunk]) {
      store.add(chunks)
    }),
    store_count_fn: Some(fn() {
      store.count()
    })
  }
}

/// 注入 BM25Retriever
pub fn Builder::with_bm25_retriever(self : Builder, retriever : BM25Retriever) -> Builder {
  { ..self,
    retrieve_fn: Some(fn(query : String, top_k : Int) {
      retriever.retrieve(query, top_k)
    })
  }
}

/// 注入 HybridRetriever
pub fn Builder::with_hybrid_retriever(self : Builder, retriever : HybridRetriever) -> Builder {
  { ..self,
    retrieve_fn: Some(fn(query : String, top_k : Int) {
      retriever.retrieve(query, top_k)
    })
  }
}

/// 注入 MockGenerator
pub fn Builder::with_mock_generator(self : Builder, gen : MockGenerator) -> Builder {
  { ..self,
    generate_fn: Some(fn(query : String, ctx : Array[Chunk]) {
      gen.generate(query, ctx)
    }),
    generator_label: "MockGenerator"
  }
}

// ============================================================
// 构建
// ============================================================

pub fn Builder::build(self : Builder) -> RAGPipeline {
  let load_fn = match self.load_fn {
    Some(f) => f
    None => abort("❌ loader 未配置")
  }
  let split_fn = match self.split_fn {
    Some(f) => f
    None => abort("❌ splitter 未配置")
  }
  let embed_docs_fn = match self.embed_docs_fn {
    Some(f) => f
    None => abort("❌ embedder 未配置")
  }
  let embed_query_fn = match self.embed_query_fn {
    Some(f) => f
    None => abort("❌ embedder (query) 未配置")
  }
  let store_add_fn = match self.store_add_fn {
    Some(f) => f
    None => abort("❌ store 未配置")
  }
  let store_count_fn = match self.store_count_fn {
    Some(f) => f
    None => abort("❌ store (count) 未配置")
  }
  let retrieve_fn = match self.retrieve_fn {
    Some(f) => f
    None => abort("❌ retriever 未配置")
  }
  let generate_fn = match self.generate_fn {
    Some(f) => f
    None => abort("❌ generator 未配置")
  }
  {
    load_fn,
    split_fn,
    embed_docs_fn,
    embed_query_fn,
    store_add_fn,
    store_count_fn,
    retrieve_fn,
    generate_fn,
    embedder_label: self.embedder_label,
    generator_label: self.generator_label,
  }
}

// ============================================================
// 阶段一:索引构建
// ============================================================

pub fn RAGPipeline::index(self : RAGPipeline, path : String) -> Unit {
  println("\n═══════════════════════════════════════")
  println("  📚 阶段一:构建索引")
  println("═══════════════════════════════════════\n")

  println("[1/4] 加载文档...")
  let docs = (self.load_fn)(path)
  println("  ✅ 加载了 \{docs.length()} 个文档")

  println("[2/4] 切分文档...")
  let chunks = (self.split_fn)(docs)
  println("  ✅ 切分为 \{chunks.length()} 个块")

  println("[3/4] 生成向量嵌入...")
  let texts : Array[String] = []
  for c in chunks {
    texts.push(c.text)
  }
  let embeddings = (self.embed_docs_fn)(texts)
  let dim_str = if embeddings.length() > 0 {
    embeddings[0].length().to_string()
  } else {
    "0"
  }
  println("  ✅ 生成了 \{embeddings.length()} 个嵌入向量(维度=\{dim_str})")

  // 将 embedding 回填到 chunk
  let chunks_with_emb : Array[Chunk] = []
  for i = 0; i < chunks.length(); i = i + 1 {
    chunks_with_emb.push(chunks[i].with_embedding(embeddings[i]))
  }

  println("[4/4] 存储到向量数据库...")
  (self.store_add_fn)(chunks_with_emb)
  println("  ✅ 已存储 \{(self.store_count_fn)()} 个向量\n")

  println("✅ 索引构建完成!\n")
}

// ============================================================
// 阶段二:检索 + 生成
// ============================================================

pub fn RAGPipeline::query(self : RAGPipeline, query : String, top_k~ : Int = 3) -> GenerationResult {
  println("\n═══════════════════════════════════════")
  println("  🔍 阶段二:检索 + 生成")
  println("═══════════════════════════════════════\n")

  println("[5/6] 检索相关文档...")
  let results = (self.retrieve_fn)(query, top_k)
  println("  ✅ 检索到 \{results.length()} 条相关结果")

  // 打印检索到的内容(只显示预览,完整内容由 Generator 输出)
  for i = 0; i < results.length(); i = i + 1 {
    let text = results[i].chunk.text
    let text_len = text.length()
    let preview_len = if text_len > 60 { 60 } else { text_len }
    let preview = text[0:preview_len].to_string()
    let suffix = if text_len > 60 { "..." } else { "" }
    println("  [来源 \{i + 1}] score=\{results[i].score}  | \{preview}\{suffix}")
  }

  println("[6/6] 生成回答...")
  let sources : Array[Chunk] = []
  for r in results {
    // 将 score 添加到 metadata
    r.chunk.metadata["score"] = r.score.to_string()
    sources.push(r.chunk)
  }
  let result = (self.generate_fn)(query, sources)
  println("  ✅ 生成完成\n")

  result
}

/// 打印 Pipeline 配置信息
pub fn RAGPipeline::describe(self : RAGPipeline) -> Unit {
  println("Pipeline 配置:")
  println("  Embedder: \{self.embedder_label}")
  println("  Generator: \{self.generator_label}")
}
