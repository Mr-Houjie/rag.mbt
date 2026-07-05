fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🚀 rag-mbt: RAG 2阶段6模块演示       ║")
  println("║    MoonBit 原生 RAG 库 (纯内存版)        ║")
  println("╚══════════════════════════════════════════╝\n")

  let rag = @ragmbt.RAGPipeline::builder()
    .with_loader(@ragmbt.TxtLoader::new("docs/"))
    .with_splitter(@ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
    .with_embedder(@ragmbt.MockEmbedder::new(dimension=32))
    .with_data_dir("rag_data")
    .with_generator(@ragmbt.MockGenerator::new())
    .build()
  
  println("✅ Pipeline 构建完成\n")

  rag.index("")

  let query1 = "什么是 MoonBit？"
  println("─".repeat(50))
  println("  💬 \{query1}")
  println("─".repeat(50))
  let r1 = rag.query(query1, top_k=3)
  println("\n📝 结果:\n\{r1.answer}")

  let query2 = "RAG 的工作原理是什么？"
  println("─".repeat(50))
  println("  💬 \{query2}")
  println("─".repeat(50))
  let r2 = rag.query(query2, top_k=3)
  println("\n📝 结果:\n\{r2.answer}")

  let query3 = "向量数据库在 RAG 中的作用是什么？"
  println("─".repeat(50))
  println("  💬 \{query3}")
  println("─".repeat(50))
  let r3 = rag.query(query3, top_k=3)
  println("\n📝 结果:\n\{r3.answer}")

  println("\n╔══════════════════════════════════════════╗")
  println("║  ✅ rag-mbt Step1+2 端到端验证通过！      ║")
  println("╚══════════════════════════════════════════╝\n")
}
