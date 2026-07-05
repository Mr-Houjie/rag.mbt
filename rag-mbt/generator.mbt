// ============================================================
// MockGenerator - 抽取式回答生成器(演示用)
//
// 不是真正的 LLM,而是基于检索结果的抽取式回答:
//   - 无结果时提示无法回答
//   - 有结果时取相关度最高的文档作为主要答案
//   - 其余文档作为补充资料列出摘要
// ============================================================

struct MockGenerator {
  prefix : String
}

pub fn MockGenerator::new(prefix~ : String = "") -> MockGenerator {
  { prefix, }
}

pub fn MockGenerator::do_generate(self : MockGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  self.generate(query, context)
}

impl Generator for MockGenerator with generate(self : MockGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  // 无检索结果
  if context.length() == 0 {
    let answer = "抱歉,未检索到与「" + query + "」相关的资料,无法回答。"
    return GenerationResult::new(answer, context)
  }

  // 抽取式回答:相关度最高的文档作为主要答案
  let top = context[0]
  let mut answer = "根据检索到的资料,与「" + query + "」最相关的内容是:\n\n"
  answer = answer + "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
  answer = answer + top.text + "\n"
  answer = answer + "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"

  // 其余相关资料作为补充(只显示摘要)
  if context.length() > 1 {
    answer = answer + "\n📚 其他相关资料:\n"
    for i = 1; i < context.length(); i = i + 1 {
      let text = context[i].text
      let text_len = text.length()
      let preview_len = if text_len > 80 { 80 } else { text_len }
      let preview = text[0:preview_len].to_string()
      let suffix = if text_len > 80 { "..." } else { "" }
      answer = answer + "  [\{i + 1}] " + preview + suffix + "\n"
    }
  }

  answer = answer + "\n💡 提示:此为 Mock 抽取式回答。接入 LLM 后,将基于上述资料生成自然语言答案。"
  GenerationResult::new(answer, context)
}
