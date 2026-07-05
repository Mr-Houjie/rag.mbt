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
    "data = json.loads(sys.stdin.read())\n" +
    "client = OpenAI(api_key=data['api_key'], base_url=data['base_url'])\n" +
    "response = client.chat.completions.create(\n" +
    "    model=data['model'],\n" +
    "    messages=[\n" +
    "        {'role': 'system', 'content': data['system_prompt']},\n" +
    "        {'role': 'user', 'content': data['user_content']}\n" +
    "    ]\n" +
    ")\n" +
    "print(response.choices[0].message.content)\n"

  // 构造 JSON 输入
  let json_input = "{\"api_key\": \"" + self.api_key + "\", \"base_url\": \"" + self.base_url + "\", \"model\": \"" + self.model + "\", \"system_prompt\": \"" + self.system_prompt + "\", \"user_content\": \"参考资料：\\n" + context_text + "\\n问题：" + query + "\"}"

  let result = run_python_script("python3", script, json_input)
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