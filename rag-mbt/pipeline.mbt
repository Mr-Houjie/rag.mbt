// ============================================================
// RAGPipeline - Builder 模式编排
// ============================================================

struct RAGPipeline {
  loader : TxtLoader
  splitter : SimpleSplitter
  embedder : LocalEmbedder
  store : FileStore
  retriever : FileRetriever
  generator : OpenAiGenerator
}

// ============================================================
// Builder
// ============================================================

struct Builder {
  loader : TxtLoader?
  splitter : SimpleSplitter?
  embedder : LocalEmbedder?
  store : FileStore?
  data_dir : String?
  generator : OpenAiGenerator?
}

pub fn RAGPipeline::builder() -> Builder {
  { loader: None, splitter: None, embedder: None, store: None, data_dir: None, generator: None }
}

pub fn Builder::with_loader(self : Builder, loader : TxtLoader) -> Builder {
  { ..self, loader: Some(loader) }
}

pub fn Builder::with_splitter(self : Builder, splitter : SimpleSplitter) -> Builder {
  { ..self, splitter: Some(splitter) }
}

pub fn Builder::with_embedder(self : Builder, embedder : LocalEmbedder) -> Builder {
  { ..self, embedder: Some(embedder) }
}

pub fn Builder::with_store(self : Builder, store : FileStore) -> Builder {
  { ..self, store: Some(store) }
}

pub fn Builder::with_data_dir(self : Builder, dir : String) -> Builder {
  { ..self, data_dir: Some(dir) }
}

pub fn Builder::with_generator(self : Builder, generator : OpenAiGenerator) -> Builder {
  { ..self, generator: Some(generator) }
}

pub fn Builder::build(self : Builder) -> RAGPipeline {
  let loader = match self.loader {
    Some(l) => l
    None => abort("❌ loader 未配置")
  }
  let splitter = match self.splitter {
    Some(s) => s
    None => abort("❌ splitter 未配置")
  }
  let embedder = match self.embedder {
    Some(e) => e
    None => abort("❌ embedder 未配置")
  }
  let store = match self.store {
    Some(s) => s
    None => {
      let dir = match self.data_dir {
        Some(d) => d
        None => "rag_data"
      }
      let store_path = "\{dir}/vectors.json"
      FileStore::new(store_path)
    }
  }
  let generator = match self.generator {
    Some(g) => g
    None => abort("❌ generator 未配置")
  }
  let retriever = FileRetriever::new(embedder, store)
  { loader, splitter, embedder, store, retriever, generator }
}

// ============================================================
// 阶段一：索引构建
// ============================================================

pub fn RAGPipeline::index(self : RAGPipeline, path : String) -> Unit {
  println("\n═══════════════════════════════════════")
  println("  📚 阶段一：构建索引")
  println("═══════════════════════════════════════\n")
  
  println("[1/4] 加载文档...")
  let docs = self.loader.load(path)
  println("  ✅ 加载了 \{docs.length()} 个文档")
  
  println("[2/4] 切分文档...")
  let chunks = self.splitter.split(docs)
  println("  ✅ 切分为 \{chunks.length()} 个块")
  
  println("[3/4] 生成向量嵌入...")
  let texts : Array[String] = []
  for c in chunks {
    texts.push(c.text)
  }
  let embeddings = self.embedder.embed_documents(texts)
  println("  ✅ 生成了 \{embeddings.length()} 个嵌入向量（维度=\{embeddings[0].length()}）")
  
  // 将 embedding 回填到 chunk
  let chunks_with_emb : Array[Chunk] = []
  for i = 0; i < chunks.length(); i = i + 1 {
    chunks_with_emb.push(chunks[i].with_embedding(embeddings[i]))
  }
  
  println("[4/4] 存储到向量数据库...")
  self.store.add(chunks_with_emb)
  println("  ✅ 已存储 \{self.store.count()} 个向量\n")
  
  println("✅ 索引构建完成！\n")
}

// ============================================================
// 阶段二：检索 + 生成
// ============================================================

pub fn RAGPipeline::query(self : RAGPipeline, query : String, top_k~ : Int = 3) -> GenerationResult {
  println("\n═══════════════════════════════════════")
  println("  🔍 阶段二：检索 + 生成")
  println("═══════════════════════════════════════\n")
  
  println("[5/6] 检索相关文档...")
  let results = self.retriever.retrieve(query, top_k)
  println("  ✅ 检索到 \{results.length()} 条相关结果")
  
  println("[6/6] 生成回答...")
  let sources : Array[Chunk] = []
  for r in results {
    sources.push(r.chunk)
  }
  let result = self.generator.generate(query, sources)
  println("  ✅ 生成完成\n")
  
  result
}
