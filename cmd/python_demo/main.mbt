// ============================================================
// rag-mbt 原生 Pipeline 演示
// 使用 TF-IDF 嵌入器 + FileStore 持久化
// 运行: moon run --target native cmd/python_demo
// ============================================================

fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🚀 rag-mbt: 原生 Pipeline 演示       ║")
  println("║    Embedder: TF-IDF (MoonBit 原生)      ║")
  println("║    Store: FileStore (文件持久化)        ║")
  println("║    Generator: MockGenerator             ║")
  println("╚══════════════════════════════════════════╝\n")

  // 使用 native 包中的 native_tfidf 构建函数
  let rag = @ragnative.native_tfidf(data_dir="rag_data_demo").build()
  rag.describe()
  println("✅ Pipeline 构建完成\n")

  // 阶段一：构建索引
  println(">>> 索引文档中...\n")
  rag.index("")
  println("✅ 索引完成\n")

  // 阶段二：查询演示
  let queries = [
    "什么是 MoonBit？",
    "RAG 的工作原理是什么？",
  ]

  for query in queries {
    println("─".repeat(50))
    println("  💬 \{query}")
    println("─".repeat(50))
    let r = rag.query(query, top_k=3)
    println("\n📝 回答:\n\{r.answer}\n")
  }

  println("╔══════════════════════════════════════════╗")
  println("║  ✅ rag-mbt 原生 Pipeline 演示完成！     ║")
  println("╚══════════════════════════════════════════╝\n")
}
