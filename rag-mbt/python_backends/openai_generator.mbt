// ============================================================
// OpenAiGenerator - OpenAI Chat Completion API (native only)
// 需要: C 编译器 + pip install openai
// ============================================================

struct OpenAiGenerator {
  api_key : String
  model : String
  system_prompt : String
}

pub fn OpenAiGenerator::new(api_key : String, model~ : String = "gpt-4o-mini", system_prompt~ : String = "你是一个基于检索增强生成的 AI 助手。请根据提供的上下文资料回答用户问题。如果上下文中没有相关信息，请如实说明。") -> OpenAiGenerator {
  { api_key, model, system_prompt, }
}

impl @ragmbt.Generator for OpenAiGenerator with generate(self : OpenAiGenerator, query : String, context : Array[@ragmbt.Chunk]) -> @ragmbt.GenerationResult {
  // 构建上下文文本
  let mut context_text = ""
  for i = 0; i < context.length(); i = i + 1 {
    context_text = context_text + "[来源 " + (i + 1).to_string() + "] " + context[i].text + "\n"
  }
  
  // 调用 OpenAI
  let openai = @python.pyimport("openai")
  let client = openai.attr("OpenAI").call((
    @python.kwargs([("api_key", self.api_key)]),
  ))
  
  let py_messages = @python.list(2)
  
  let sys_msg = @python.dict([
    ("role", "system"),
    ("content", self.system_prompt),
  ])
  py_messages.call_method("append", (sys_msg,))
  
  let user_content = "参考资料：\n" + context_text + "\n问题：" + query
  let user_msg = @python.dict([
    ("role", "user"),
    ("content", user_content),
  ])
  py_messages.call_method("append", (user_msg,))
  
  let response = client.attr("chat").attr("completions").attr("create").call((
    @python.kwargs([
      ("model", self.model),
      ("messages", py_messages),
    ]),
  ))
  
  let answer = response.attr("choices")
    .call_method("__getitem__", (0,))
    .attr("message")
    .attr("content")
    .to_string()
  
  @ragmbt.GenerationResult::new(answer, context)
}
