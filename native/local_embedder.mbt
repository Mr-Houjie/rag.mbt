// ============================================================
// LocalEmbedder - 本地向量嵌入模型 (bge-small-zh)
// 使用 sentence-transformers Python 库，无需 API 调用
// ============================================================

struct LocalEmbedder {
  model_name : String
}

pub fn LocalEmbedder::new(model_name~ : String = "BAAI/bge-small-zh") -> LocalEmbedder {
  { model_name, }
}

/// 用 Python 脚本一次性完成加载+编码，返回 JSON 字符串
fn LocalEmbedder::run_python_encode(self : LocalEmbedder, texts : Array[String]) -> String {
  // 构造 Python 脚本，通过 stdin 传参
  let script = "import sys, json, os\n" +
    "os.environ['HF_HUB_OFFLINE'] = '1'\n" +
    "from sentence_transformers import SentenceTransformer\n" +
    "model = SentenceTransformer('" + self.model_name + "')\n" +
    "# 用特殊分隔符分割文本\n" +
    "data = sys.stdin.read()\n" +
    "texts = data.split('___TEXT_SEP___')\n" +
    "embs = model.encode(texts)\n" +
    "result = [[float(x) for x in emb] for emb in embs]\n" +
    "print(json.dumps(result))\n"

  // 用特殊分隔符分割文本（不会出现在正常文档中）
  let mut input = ""
  for i = 0; i < texts.length(); i = i + 1 {
    if i > 0 {
      input = input + "___TEXT_SEP___"
    }
    input = input + texts[i]
  }

  let result = run_python_script("/opt/homebrew/bin/python3.13", script, input)
  result
}

/// 用 C FFI 执行 Python 脚本并返回 stdout
#owned(cmd)
#owned(script)
#owned(input)
extern "C" fn run_python_script(cmd : String, script : String, input : String) -> String = "run_python_script"

pub fn LocalEmbedder::embed_documents(self : LocalEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  let output = self.run_python_encode(texts)
  if output.length() == 0 {
    println("Error: Python script returned empty output")
    return []
  }

  // 解析 JSON 输出 [[0.1, 0.2, ...], [0.3, 0.4, ...]]
  parse_embeddings_json(output)
}

pub fn LocalEmbedder::embed_query(self : LocalEmbedder, query : String) -> Array[Double] {
  let embeddings = self.embed_documents([query])
  if embeddings.length() > 0 {
    embeddings[0]
  } else {
    []
  }
}

/// 简单的 JSON 嵌套数组解析
fn parse_embeddings_json(json : String) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  let mut i = 0
  let n = json.length()

  // 找到第一个 '['
  while i < n && json[i] != '[' {
    i = i + 1
  }
  if i >= n {
    return result
  }
  i = i + 1  // 跳过外层 '['

  // 解析每个内层数组
  while i < n {
    // 跳过空白和逗号
    while i < n && (json[i] == ' ' || json[i] == ',' || json[i] == '\n' || json[i] == '\r' || json[i] == '\t') {
      i = i + 1
    }
    if i >= n || json[i] == ']' {
      break
    }

    if json[i] == '[' {
      i = i + 1  // 跳过内层 '['
      let emb : Array[Double] = []

      // 解析内层数组的数字
      while i < n && json[i] != ']' {
        // 跳过空白和逗号
        while i < n && (json[i] == ' ' || json[i] == ',' || json[i] == '\n' || json[i] == '\r' || json[i] == '\t') {
          i = i + 1
        }
        if i >= n || json[i] == ']' {
          break
        }

        // 解析一个数字
        let (num, next_i) = parse_number(json, i)
        if next_i > i {
          emb.push(num)
          i = next_i
        } else {
          i = i + 1  // 跳过无法解析的字符
        }
      }

      if i < n && json[i] == ']' {
        i = i + 1  // 跳过内层 ']'
      }
      result.push(emb)
    } else {
      i = i + 1
    }
  }

  result
}

/// 从 JSON 字符串中解析一个数字
fn parse_number(s : String, start : Int) -> (Double, Int) {
  let mut i = start
  let n = s.length()

  // 跳过前导空白
  while i < n && s[i] == ' ' {
    i = i + 1
  }

  if i >= n {
    return (0.0, start)
  }

  // 检查特殊值
  if s[i] == 'n' {
    // null
    return (0.0, i + 4)
  }

  let num_start = i

  // 负号
  if i < n && s[i] == '-' {
    i = i + 1
  }

  // 整数部分
  while i < n && s[i] >= '0' && s[i] <= '9' {
    i = i + 1
  }

  // 小数部分
  if i < n && s[i] == '.' {
    i = i + 1
    while i < n && s[i] >= '0' && s[i] <= '9' {
      i = i + 1
    }
  }

  // 指数部分
  if i < n && (s[i] == 'e' || s[i] == 'E') {
    i = i + 1
    if i < n && (s[i] == '+' || s[i] == '-') {
      i = i + 1
    }
    while i < n && s[i] >= '0' && s[i] <= '9' {
      i = i + 1
    }
  }

  if i > num_start {
    let num_str = s[num_start:i].to_owned()
    try {
      let d = @strconv.parse_double(num_str)
      (d, i)
    } catch {
      _ => (0.0, start)
    }
  } else {
    (0.0, start)
  }
}
