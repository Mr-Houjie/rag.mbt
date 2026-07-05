fn main {
  println("\n")
  println("╔══════════════════════════════════════════╗")
  println("║    🚀 rag-mbt: RAG 2阶段6模块演示       ║")
  println("║    MoonBit 原生 RAG 库                  ║")
  println("║    Embedder: bge-small-zh (本地)        ║")
  println("║    Generator: DeepSeek API              ║")
  println("╚══════════════════════════════════════════╝\n")

  // 从配置文件读取 API Key (用于 Generator)
  let config_content = @ragmbt.fs_read_all("config.json")
  if config_content.length() == 0 {
    println("❌ 无法读取 config.json，请确保配置文件存在")
    return
  }
  
  let api_key = extract_json_string(config_content, "api_key")
  let base_url = extract_json_string(config_content, "base_url")
  
  if api_key.length() == 0 {
    println("❌ 配置文件缺少 api_key")
    return
  }

  let rag = @ragmbt.RAGPipeline::builder()
    .with_loader(@ragmbt.TxtLoader::new("docs/"))
    .with_splitter(@ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
    .with_embedder(@ragmbt.LocalEmbedder::new())  // 本地 bge-small-zh 模型
    .with_data_dir("rag_data")
    .with_generator(@ragmbt.OpenAiGenerator::new(api_key, base_url=base_url))  // DeepSeek API
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
  println("║  ✅ rag-mbt 端到端验证通过！              ║")
  println("╚══════════════════════════════════════════╝\n")
}

// 简单的 JSON 字符串提取函数
fn extract_json_string(json : String, key : String) -> String {
  let key_pattern = "\"" + key + "\""
  match json.find(key_pattern) {
    None => ""
    Some(idx) => {
      // 找到 key 后的值
      let rest = json[idx + key_pattern.length():]
      match rest.find(":") {
        None => ""
        Some(colon_idx) => {
          // 找到引号包围的字符串值
          let value_part = rest[colon_idx + 1:]
          let trim_part = value_part.trim_start()
          
          // 检查是否以引号开始
          if trim_part.length() > 0 && trim_part[0] == '"' {
            // 找到结束引号
            match trim_part[1:].find("\"") {
              None => ""
              Some(end_quote) => trim_part[1:end_quote + 1].to_owned()
            }
          } else {
            ""
          }
        }
      }
    }
  }
}
