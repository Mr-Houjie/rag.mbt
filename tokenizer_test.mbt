// ============================================================
// Tokenizer 测试 - MoonBit 原生中英文分词器
// ============================================================

test "Tokenizer::new 默认参数" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("hello world")
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
}

test "Tokenizer 英文分词" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("MoonBit is a programming language")
  // "is", "a" 是停用词,被过滤
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], "moonbit")
  assert_eq(tokens[1], "programming")
  assert_eq(tokens[2], "language")
}

test "Tokenizer 转小写" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("HELLO World")
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
}

test "Tokenizer 不转小写" {
  let tok = Tokenizer::new(lower=false)
  let tokens = tok.tokenize("Hello World")
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], "Hello")
  assert_eq(tokens[1], "World")
}

test "Tokenizer 中文按字符切分" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("你好世界")
  // 中文字符逐个切分,且 "了/在/和/的" 等是停用词
  assert_eq(tokens.length(), 4)
  assert_eq(tokens[0], "你")
  assert_eq(tokens[1], "好")
  assert_eq(tokens[2], "世")
  assert_eq(tokens[3], "界")
}

test "Tokenizer 中英文混合" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("RAG 检索增强生成")
  // "RAG" + 中文字符(无停用词)
  assert_eq(tokens[0], "rag")
  assert_eq(tokens[1], "检")
  assert_eq(tokens[2], "索")
  assert_eq(tokens[3], "增")
  assert_eq(tokens[4], "强")
  assert_eq(tokens[5], "生")
  assert_eq(tokens[6], "成")
}

test "Tokenizer 停用词过滤" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("the quick brown fox jumps over the lazy dog")
  // "the" 是停用词(出现 2 次),"over" 不在默认停用词表
  // 非停用词:quick, brown, fox, jumps, over, lazy, dog (7 个)
  assert_eq(tokens.length(), 7)
  assert_eq(tokens[0], "quick")
  assert_eq(tokens[1], "brown")
  assert_eq(tokens[2], "fox")
  assert_eq(tokens[3], "jumps")
  assert_eq(tokens[4], "over")
  assert_eq(tokens[5], "lazy")
  assert_eq(tokens[6], "dog")
}

test "Tokenizer 中文停用词过滤" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("我在这里")
  // "我" 非停用词,"在","这"(此) 是停用词
  // 检查 "我" 保留
  let has_wo = tokens.contains("我")
  assert_eq(has_wo, true)
}

test "Tokenizer 标点分隔" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("hello,world.foo;bar")
  assert_eq(tokens.length(), 4)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
  assert_eq(tokens[2], "foo")
  assert_eq(tokens[3], "bar")
}

test "Tokenizer 空文本" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("")
  assert_eq(tokens.length(), 0)
}

test "Tokenizer 仅空白符" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("   \t\n  ")
  assert_eq(tokens.length(), 0)
}

test "Tokenizer 仅标点" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize(",.;!?")
  assert_eq(tokens.length(), 0)
}

test "Tokenizer min_token_len 参数" {
  let tok = Tokenizer::new(min_token_len=3)
  let tokens = tok.tokenize("a ab abc abcd")
  // 长度 < 3 的 token 被过滤
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], "abc")
  assert_eq(tokens[1], "abcd")
}

test "Tokenizer 不过滤停用词" {
  let tok = Tokenizer::new(filter_stopwords=false)
  let tokens = tok.tokenize("the quick fox")
  // 不过滤停用词
  assert_eq(tokens.length(), 3)
  assert_eq(tokens[0], "the")
  assert_eq(tokens[1], "quick")
  assert_eq(tokens[2], "fox")
}

test "Tokenizer::add_stopword 自定义停用词" {
  let tok = Tokenizer::new()
  tok.add_stopword("moonbit")
  let tokens = tok.tokenize("moonbit is great")
  // "moonbit" 被自定义加入停用词,"is" 是默认停用词
  assert_eq(tokens.length(), 1)
  assert_eq(tokens[0], "great")
}

test "Tokenizer 数字 token" {
  let tok = Tokenizer::new()
  let tokens = tok.tokenize("version 2 0 1 0")
  assert_eq(tokens[0], "version")
  assert_eq(tokens[1], "2")
  assert_eq(tokens[2], "0")
  assert_eq(tokens[3], "1")
}

test "tokenize_default 便捷函数" {
  let tokens = tokenize_default("Hello World")
  assert_eq(tokens.length(), 2)
  assert_eq(tokens[0], "hello")
  assert_eq(tokens[1], "world")
}

// ============================================================
// 工具函数测试
// ============================================================

test "is_cjk_code 中文范围" {
  assert_eq(is_cjk_code(0x4E00), true)  // 一
  assert_eq(is_cjk_code(0x9FFF), true)  // 上限
  assert_eq(is_cjk_code(0x4DFF), false) // 下限外
  assert_eq(is_cjk_code(0xA000), false) // 上限外
  assert_eq(is_cjk_code(0x0041), false) // 'A'
}

test "is_alnum_code 字母数字" {
  assert_eq(is_alnum_code(0x41), true)  // 'A'
  assert_eq(is_alnum_code(0x5A), true)  // 'Z'
  assert_eq(is_alnum_code(0x61), true)  // 'a'
  assert_eq(is_alnum_code(0x7A), true)  // 'z'
  assert_eq(is_alnum_code(0x30), true)  // '0'
  assert_eq(is_alnum_code(0x39), true)  // '9'
  assert_eq(is_alnum_code(0x20), false) // 空格
  assert_eq(is_alnum_code(0x4E00), false) // 中文
}

test "is_alpha_code 字母" {
  assert_eq(is_alpha_code(0x41), true)
  assert_eq(is_alpha_code(0x7A), true)
  assert_eq(is_alpha_code(0x30), false) // '0' 不是字母
  assert_eq(is_alpha_code(0x4E00), false)
}

test "is_separator_code 分隔符" {
  assert_eq(is_separator_code(0x20), true)  // space
  assert_eq(is_separator_code(0x2C), true)  // ,
  assert_eq(is_separator_code(0x2E), true)  // .
  assert_eq(is_separator_code(0x41), false) // 'A'
  assert_eq(is_separator_code(0x4E00), false)
}

test "to_lower_code 大写转小写" {
  assert_eq(to_lower_code(0x41), 0x61)  // 'A' -> 'a'
  assert_eq(to_lower_code(0x5A), 0x7A)  // 'Z' -> 'z'
  assert_eq(to_lower_code(0x61), 0x61)  // 'a' 不变
  assert_eq(to_lower_code(0x30), 0x30)  // '0' 不变
  assert_eq(to_lower_code(0x4E00), 0x4E00) // 中文不变
}

test "code_to_string 转换" {
  assert_eq(code_to_string(0x41), "A")
  assert_eq(code_to_string(0x61), "a")
  assert_eq(code_to_string(0x30), "0")
}

test "to_lower_string 字符串转小写" {
  assert_eq(to_lower_string("Hello"), "hello")
  assert_eq(to_lower_string("WORLD"), "world")
  assert_eq(to_lower_string("MixedCase"), "mixedcase")
  assert_eq(to_lower_string("123ABC"), "123abc")
}
