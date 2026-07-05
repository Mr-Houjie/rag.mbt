// ============================================================
// MockGenerator - 拼接上下文生成器（演示用）
// ============================================================

struct MockGenerator {
  prefix : String
}

pub fn MockGenerator::new(prefix~ : String = "基于以下资料回答：\n\n") -> MockGenerator {
  { prefix, }
}

pub fn MockGenerator::do_generate(self : MockGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  self.generate(query, context)
}

impl Generator for MockGenerator with generate(self : MockGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  let mut answer = self.prefix
  
  for i = 0; i < context.length(); i = i + 1 {
    answer = answer + "[来源 " + (i + 1).to_string() + "] " + context[i].text + "\n\n"
  }
  
  answer = answer + "---\n问题: " + query + "\n\n(以上为检索到的相关上下文，后续将由 LLM 生成最终答案)"
  
  GenerationResult::new(answer, context)
}
