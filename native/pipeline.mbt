// ============================================================
// native/pipeline.mbt - 构建辅助函数(使用闭包注入 native 组件)
//
// 设计: 使用普通函数而非扩展方法,接受 Builder 并返回 Builder
//   由于 MoonBit 不允许跨包添加扩展方法或实现 trait,
//   native 组件通过闭包注入到 Builder 中.
// ============================================================

/// 注入 LocalEmbedder
pub fn with_local_embedder(builder : @ragmbt.Builder, embedder : LocalEmbedder) -> @ragmbt.Builder {
  @ragmbt.Builder::with_embed_fns(builder,
    fn(texts : Array[String]) {
      embedder.embed_documents(texts)
    },
    fn(query : String) {
      embedder.embed_query(query)
    },
    label="LocalEmbedder(bge-small-zh)"
  )
}

/// 注入 FileStore
pub fn with_file_store(builder : @ragmbt.Builder, store : FileStore) -> @ragmbt.Builder {
  @ragmbt.Builder::with_store_fns(builder,
    add=fn(chunks : Array[@ragmbt.Chunk]) {
      store.add(chunks)
    },
    count=fn() {
      store.count()
    }
  )
}

/// 注入 FileRetriever
pub fn with_file_retriever(builder : @ragmbt.Builder, retriever : FileRetriever) -> @ragmbt.Builder {
  @ragmbt.Builder::with_retrieve_fn(builder, fn(query : String, top_k : Int) {
    retriever.retrieve(query, top_k)
  })
}

/// 注入 OpenAiGenerator
pub fn with_openai_generator(builder : @ragmbt.Builder, gen : OpenAiGenerator) -> @ragmbt.Builder {
  @ragmbt.Builder::with_generate_fn(builder,
    fn(query : String, ctx : Array[@ragmbt.Chunk]) {
      gen.generate(query, ctx)
    },
    label="OpenAiGenerator"
  )
}

/// 便捷方法：配置数据目录(创建一个 FileStore 并注入)
pub fn with_data_dir(builder : @ragmbt.Builder, dir : String) -> @ragmbt.Builder {
  let store_path = "\{dir}/vectors.json"
  let store = FileStore::new(store_path)
  with_file_store(builder, store)
}

/// 创建纯原生 Pipeline(无需 Python/API)
pub fn native_mock(data_dir~ : String = "rag_data") -> @ragmbt.Builder {
  let dir = data_dir
  let store_path = "\{dir}/vectors.json"
  let store = FileStore::new(store_path)
  let bm25 = @ragmbt.BM25Retriever::new()
  let b = @ragmbt.RAGPipeline::builder()
  let b = @ragmbt.Builder::with_loader(b, @ragmbt.TxtLoader::new("docs/"))
  let b = @ragmbt.Builder::with_splitter(b, @ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
  let b = @ragmbt.Builder::with_mock_embedder(b, @ragmbt.MockEmbedder::new(dimension=64))
  let b = @ragmbt.Builder::with_store_fns(b,
    add=fn(chunks : Array[@ragmbt.Chunk]) {
      store.add(chunks)
      @ragmbt.BM25Retriever::add_documents(bm25, chunks)
    },
    count=fn() {
      store.count()
    }
  )
  let b = @ragmbt.Builder::with_bm25_retriever(b, bm25)
  @ragmbt.Builder::with_mock_generator(b, @ragmbt.MockGenerator::new())
}

/// 创建 TF-IDF 原生 Pipeline(无需 Python/API)
pub fn native_tfidf(data_dir~ : String = "rag_data") -> @ragmbt.Builder {
  let dir = data_dir
  let store_path = "\{dir}/vectors.json"
  // 清理旧数据
  let _ = fs_remove_file(store_path)
  let store = FileStore::new(store_path)
  let embedder = @ragmbt.TfidfEmbedder::new()
  let b = @ragmbt.RAGPipeline::builder()
  let b = @ragmbt.Builder::with_loader(b, @ragmbt.TxtLoader::new("docs/"))
  let b = @ragmbt.Builder::with_splitter(b, @ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
  let b = @ragmbt.Builder::with_tfidf_embedder(b, embedder)
  let b = @ragmbt.Builder::with_store_fns(b,
    add=fn(chunks : Array[@ragmbt.Chunk]) {
      store.add(chunks)
    },
    count=fn() {
      store.count()
    }
  )
  let b = @ragmbt.Builder::with_retrieve_fn(b, fn(query : String, top_k : Int) {
    let q_emb = embedder.embed_query(query)
    store.search(q_emb, top_k)
  })
  @ragmbt.Builder::with_mock_generator(b, @ragmbt.MockGenerator::new())
}
