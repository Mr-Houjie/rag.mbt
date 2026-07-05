fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🚀 rag-mbt: 交互式 RAG 问答           ║")
  println("║    MoonBit 原生 RAG 库 (无 Python/API)   ║")
  println("║    Embedder: TF-IDF (MoonBit 原生)       ║")
  println("║    Generator: MockGenerator              ║")
  println("╚══════════════════════════════════════════╝\n")

  // ============================================================
  // 构建 RAG pipeline(纯原生 TF-IDF,无需 Python/API)
  // ============================================================
  let rag = @ragmbt.Builder::native_tfidf(data_dir="rag_data").build()
  rag.describe()
  println("✅ Pipeline 构建完成\n")

  // 索引静态文档
  println(">>> 索引文档中...\n")
  rag.index("")
  println("✅ 索引完成\n")

  // ============================================================
  // 交互式问答循环
  // ============================================================
  println("────────────────────────────────────────────────")
  println("  💬 交互式问答已启动")
  println("  • 输入你的问题,按回车提交")
  println("  • 输入 exit / quit / 退出 退出程序")
  println("  • 直接按回车(空行)也可退出")
  println("────────────────────────────────────────────────\n")

  while true {
    let line = @ragmbt.fs_read_line("❯ ")
    // 空字符串(EOF 或空行)、exit/quit/退出 → 退出
    if line == "" || line == "exit" || line == "quit" || line == "退出" {
      break
    }
    // 检索 + 生成
    let r = rag.query(line, top_k=3)
    println("\n📝 答案:")
    println("─".repeat(50))
    println(r.answer)
    println("─".repeat(50))
    println("📚 来源文档数: \{r.sources.length()}")
    // 显示检索到的文档预览
    for i = 0; i < r.sources.length(); i = i + 1 {
      let preview = r.sources[i].text
      let preview_len = if preview.length() > 80 { 80 } else { preview.length() }
      let preview_str = preview[0:preview_len].to_string()
      println("  [\{i + 1}] \{preview_str}...")
    }
    println("\n")
  }

  println("\n╔══════════════════════════════════════════╗")
  println("║  👋 再见!感谢使用 rag-mbt               ║")
  println("╚══════════════════════════════════════════╝\n")
}
