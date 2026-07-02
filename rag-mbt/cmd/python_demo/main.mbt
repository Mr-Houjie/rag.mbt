// ============================================================
// rag-mbt Python 后端演示
// 需要: C 编译器 + pip install openai + OPENAI_API_KEY
// 运行: moon run cmd/python_demo
// ============================================================

fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🤖 rag-mbt: OpenAI 后端演示          ║")
  println("║    需要 C 编译器 + Python + openai      ║")
  println("╚══════════════════════════════════════════╝\n")

  // 从环境变量或硬编码读取 API key
  let api_key = @pybackends.read_env("OPENAI_API_KEY")
  if api_key == "" {
    println("❌ 请设置环境变量 OPENAI_API_KEY")
    println("   PowerShell: $env:OPENAI_API_KEY='sk-...'")
    println("   CMD: set OPENAI_API_KEY=sk-...\n")
    return
  }

  println("✅ 检测到 OPENAI_API_KEY\n")

  let rag = @ragmbt.RAGPipeline::builder()
    .with_loader(@ragmbt.TxtLoader::new("docs/"))
    .with_splitter(@ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
    .with_embedder(@pybackends.OpenAiEmbedder::new(api_key))
    .with_store(@ragmbt.InMemoryStore::new())
    .with_generator(@pybackends.OpenAiGenerator::new(api_key))
    .build()
  
  println("✅ Pipeline 构建完成 (使用 OpenAI 后端)\n")

  // 阶段一：构建索引
  rag.index("")

  // 阶段二：真实 LLM 生成
  let query1 = "什么是 MoonBit？"
  println("─".repeat(50))
  println("  💬 \{query1}")
  println("─".repeat(50))
  let r1 = rag.query(query1, top_k=3)
  println("\n📝 AI 回答:\n\{r1.answer}\n")

  let query2 = "RAG 的工作原理是什么？"
  println("─".repeat(50))
  println("  💬 \{query2}")
  println("─".repeat(50))
  let r2 = rag.query(query2, top_k=3)
  println("\n📝 AI 回答:\n\{r2.answer}\n")

  println("╔══════════════════════════════════════════╗")
  println("║  ✅ rag-mbt + OpenAI 后端演示完成！      ║")
  println("╚══════════════════════════════════════════╝\n")
}
