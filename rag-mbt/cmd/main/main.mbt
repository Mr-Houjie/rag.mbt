fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🚀 rag-mbt: RAG 2阶段6模块演示       ║")
  println("║    MoonBit 原生 RAG 库 (无 Python/API)  ║")
  println("║    Embedder: TF-IDF (MoonBit 原生)      ║")
  println("║    Retriever: 向量检索 (cosine)         ║")
  println("║    Generator: MockGenerator             ║")
  println("╚══════════════════════════════════════════╝\n")

  // ============================================================
  // 模式 1:纯原生 TF-IDF Pipeline(默认,无需 Python/API)
  // ============================================================
  println(">>> 启动纯原生 TF-IDF Pipeline...\n")
  let rag = @ragmbt.Builder::native_tfidf(data_dir="rag_data").build()

  rag.describe()
  println("✅ Pipeline 构建完成\n")

  // 清空旧数据,重新构建索引
  rag.index("")

  // 检索 + 生成
  let query1 = "什么是 MoonBit？"
  println("─".repeat(50))
  println("  💬 \{query1}")
  println("─".repeat(50))
  let r1 = rag.query(query1, top_k=3)
  println("📝 结果:\n\{r1.answer}")

  let query2 = "RAG 的工作原理是什么？"
  println("\n" + "─".repeat(50))
  println("  💬 \{query2}")
  println("─".repeat(50))
  let r2 = rag.query(query2, top_k=3)
  println("📝 结果:\n\{r2.answer}")

  let query3 = "向量数据库在 RAG 中的作用是什么？"
  println("\n" + "─".repeat(50))
  println("  💬 \{query3}")
  println("─".repeat(50))
  let r3 = rag.query(query3, top_k=3)
  println("📝 结果:\n\{r3.answer}")

  println("\n╔══════════════════════════════════════════╗")
  println("║  ✅ rag-mbt 纯原生端到端验证通过!         ║")
  println("╚══════════════════════════════════════════╝\n")

  // ============================================================
  // 演示 BM25 关键词检索(独立模块,纯 MoonBit 原生)
  // ============================================================
  println("╔══════════════════════════════════════════╗")
  println("║  📖 BM25 关键词检索演示 (MoonBit 原生)   ║")
  println("╚══════════════════════════════════════════╝\n")

  let bm25 = @ragmbt.BM25Retriever::new()
  let docs = @ragmbt.load_static_docs()
  let meta = @ragmbt.make_meta([])
  // 把每个文档作为一个 chunk
  let bm25_chunks : Array[@ragmbt.Chunk] = []
  for i = 0; i < docs.length(); i = i + 1 {
    let chunk = @ragmbt.Chunk::new("bm25_chunk_\{i}", docs[i].content, meta)
    bm25_chunks.push(chunk)
  }
  bm25.add_documents(bm25_chunks)
  println("已索引 \{bm25.count()} 个文档到 BM25\n")

  let bm25_query = "MoonBit 编译"
  println("🔍 BM25 查询: \{bm25_query}")
  let bm25_results = bm25.retrieve(bm25_query, 2)
  for i = 0; i < bm25_results.length(); i = i + 1 {
    println("  [结果 \{i + 1}] score=\{bm25_results[i].score}")
    let preview = bm25_results[i].chunk.text
    let preview_len = if preview.length() > 60 { 60 } else { preview.length() }
    let preview_str = preview[0:preview_len].to_string()
    println("  \{preview_str}...")
    println("")
  }

  // ============================================================
  // 演示 HybridRetriever (RRF 融合)
  // ============================================================
  println("╔══════════════════════════════════════════╗")
  println("║  🔀 HybridRetriever (RRF 融合) 演示      ║")
  println("╚══════════════════════════════════════════╝\n")

  // 创建两个独立的检索器,都索引同样的文档
  let bm25_a = @ragmbt.BM25Retriever::new()
  bm25_a.add_documents(bm25_chunks)
  let bm25_b = @ragmbt.BM25Retriever::new(k1=2.0, b=0.5)  // 不同参数
  bm25_b.add_documents(bm25_chunks)

  let hybrid = @ragmbt.HybridRetriever::new()
  hybrid.add("BM25-default", fn(q : String, k : Int) {
    bm25_a.retrieve(q, k)
  })
  hybrid.add("BM25-tuned", fn(q : String, k : Int) {
    bm25_b.retrieve(q, k)
  })

  let hybrid_query = "向量数据库"
  println("🔍 Hybrid 查询: \{hybrid_query}")
  let hybrid_results = hybrid.retrieve(hybrid_query, 3)
  for i = 0; i < hybrid_results.length(); i = i + 1 {
    println("  [结果 \{i + 1}] rrf_score=\{hybrid_results[i].score}")
    let preview = hybrid_results[i].chunk.text
    let preview_len = if preview.length() > 60 { 60 } else { preview.length() }
    let preview_str = preview[0:preview_len].to_string()
    println("  \{preview_str}...")
    println("")
  }

  println("╔══════════════════════════════════════════╗")
  println("║  ✅ 所有原生模块演示完成!                 ║")
  println("╚══════════════════════════════════════════╝\n")
}
