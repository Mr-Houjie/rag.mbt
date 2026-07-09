// ============================================================
// OpenAI Backend - 通过 subprocess 调用 Python openai 库
// ============================================================

struct OpenAiGenerator {
  api_key : String
  model : String
  system_prompt : String
  base_url : String
}

pub fn OpenAiGenerator::new(api_key : String, model~ : String = "deepseek-chat", system_prompt~ : String = "你是一个基于检索增强生成的 AI 助手。请根据提供的上下文资料回答用户问题。如果上下文中没有相关信息，请如实说明。", base_url~ : String = "https://api.deepseek.com") -> OpenAiGenerator {
  { api_key, model, system_prompt, base_url, }
}

/// 调用 Python 脚本生成回答
fn OpenAiGenerator::run_python_generate(self : OpenAiGenerator, query : String, context_text : String) -> String {
  let script = "import sys, json\n" +
    "from openai import OpenAI\n" +
    "# 用分隔符分割参数\n" +
    "data = sys.stdin.read()\n" +
    "parts = data.split('___PARAM_SEP___')\n" +
    "api_key = parts[0]\n" +
    "base_url = parts[1]\n" +
    "model = parts[2]\n" +
    "system_prompt = parts[3]\n" +
    "user_content = parts[4]\n" +
    "client = OpenAI(api_key=api_key, base_url=base_url)\n" +
    "response = client.chat.completions.create(\n" +
    "    model=model,\n" +
    "    messages=[\n" +
    "        {'role': 'system', 'content': system_prompt},\n" +
    "        {'role': 'user', 'content': user_content}\n" +
    "    ]\n" +
    ")\n" +
    "print(response.choices[0].message.content)\n"

  // 用分隔符分割参数
  let input = self.api_key + "___PARAM_SEP___" + self.base_url + "___PARAM_SEP___" + self.model + "___PARAM_SEP___" + self.system_prompt + "___PARAM_SEP___" + "参考资料：\n" + context_text + "\n问题：" + query

  let result = run_python_script("/opt/homebrew/bin/python3.13", script, input)
  result
}

impl Generator for OpenAiGenerator with generate(self : OpenAiGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  let mut context_text = ""
  for i = 0; i < context.length(); i = i + 1 {
    context_text = context_text + "[来源 " + (i + 1).to_string() + "] " + context[i].text + "\n"
  }

  let answer = self.run_python_generate(query, context_text)

  if answer.length() == 0 {
    GenerationResult::new("Error: 生成回答失败", context)
  } else {
    GenerationResult::new(answer, context)
  }
}