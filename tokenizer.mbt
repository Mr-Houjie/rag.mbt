// ============================================================
// Tokenizer - MoonBit 原生中英文分词器
// 英文按空格/标点切分,中文按字符切分,统一转小写并过滤停用词
// ============================================================

/// 通用分词器
pub struct Tokenizer {
  lower : Bool               // 是否转小写
  filter_stopwords : Bool    // 是否过滤停用词
  min_token_len : Int        // 最短 token 长度
  stopwords : Map[String, Unit]
}

/// 默认中英文停用词表
let default_stopwords : Array[String] = [
  // 英文
  "the", "a", "an", "and", "or", "but", "if", "then", "of", "to", "in",
  "on", "at", "by", "for", "with", "as", "is", "are", "was", "were",
  "be", "been", "being", "have", "has", "had", "do", "does", "did",
  "will", "would", "could", "should", "may", "might", "this", "that",
  "these", "those", "it", "its", "they", "them", "their", "we", "us",
  "our", "you", "your", "he", "him", "his", "she", "her", "i", "me", "my",
  // 中文常见虚词
  "的", "了", "是", "在", "和", "也", "与", "或", "但", "若", "则",
  "于", "之", "其", "此", "彼", "为", "以", "及", "等", "可", "能",
  "对", "由", "从", "至", "向", "上", "下", "中", "内", "外",
]

pub fn Tokenizer::new(
  lower~ : Bool = true,
  filter_stopwords~ : Bool = true,
  min_token_len~ : Int = 1
) -> Tokenizer {
  let sw : Map[String, Unit] = Map([])
  for w in default_stopwords {
    sw[w] = ()
  }
  { lower, filter_stopwords, min_token_len, stopwords: sw }
}

/// 添加自定义停用词
pub fn Tokenizer::add_stopword(self : Tokenizer, word : String) -> Unit {
  self.stopwords[word] = ()
}

/// 判断 code unit 是否为中文(CJK 统一汉字范围 U+4E00 ~ U+9FFF)
pub fn is_cjk_code(code : Int) -> Bool {
  code >= 0x4E00 && code <= 0x9FFF
}

/// 判断 code unit 是否为 ASCII 字母或数字
pub fn is_alnum_code(code : Int) -> Bool {
  (code >= 0x61 && code <= 0x7A) ||  // a-z
  (code >= 0x41 && code <= 0x5A) ||  // A-Z
  (code >= 0x30 && code <= 0x39)     // 0-9
}

/// 判断 code unit 是否为 ASCII 字母
pub fn is_alpha_code(code : Int) -> Bool {
  (code >= 0x61 && code <= 0x7A) || (code >= 0x41 && code <= 0x5A)
}

/// 判断 code unit 是否为空白或分隔符
pub fn is_separator_code(code : Int) -> Bool {
  code == 0x20 ||  // space
  code == 0x09 ||  // \t
  code == 0x0A ||  // \n
  code == 0x0D ||  // \r
  code == 0x2C ||  // ,
  code == 0x2E ||  // .
  code == 0x21 ||  // !
  code == 0x3F ||  // ?
  code == 0x3B ||  // ;
  code == 0x3A ||  // :
  code == 0x28 ||  // (
  code == 0x29 ||  // )
  code == 0x5B ||  // [
  code == 0x5D ||  // ]
  code == 0x7B ||  // {
  code == 0x7D ||  // }
  code == 0x22 ||  // "
  code == 0x27 ||  // '
  code == 0x2F ||  // /
  code == 0x5C ||  // backslash
  code == 0x2D ||  // -
  code == 0x5F ||  // _
  code == 0x7C ||  // |
  code == 0x7E ||  // ~
  code == 0x60 ||  // `
  code == 0x2B ||  // +
  code == 0x3D ||  // =
  code == 0x2A ||  // *
  code == 0x26 ||  // &
  code == 0x5E ||  // ^
  code == 0x25 ||  // %
  code == 0x24 ||  // $
  code == 0x23 ||  // #
  code == 0x40 ||  // @
  code == 0x3C ||  // <
  code == 0x3E      // >
}

/// ASCII 字母转小写 code unit(其他字符不变)
pub fn to_lower_code(code : Int) -> Int {
  if code >= 0x41 && code <= 0x5A {
    code + 32
  } else {
    code
  }
}

/// 将单个 code unit 转为字符串
pub fn code_to_string(code : Int) -> String {
  // 用 Char::from_int 然后 to_string
  Char::from_int(code).to_string()
}

/// 将字符串转小写(仅 ASCII 字母)
pub fn to_lower_string(s : String) -> String {
  let buf : Array[Int] = []
  for i = 0; i < s.length(); i = i + 1 {
    buf.push(to_lower_code(s[i].to_int()))
  }
  let mut result = ""
  for code in buf {
    result = result + code_to_string(code)
  }
  result
}

/// 对文本进行分词,返回 token 数组
pub fn Tokenizer::tokenize(self : Tokenizer, text : String) -> Array[String] {
  let tokens : Array[String] = []
  let n = text.length()
  let mut i = 0
  let mut buf : Array[Int] = []

  // 持续读取字符
  while i < n {
    let code = text[i].to_int()
    // 1) 分隔符:刷新当前 buffer
    if is_separator_code(code) {
      flush_buffer(buf, tokens, self)
      buf = []
      i = i + 1
      continue
    }
    // 2) 中文字符:作为独立 token,先刷新英文 buffer
    if is_cjk_code(code) {
      flush_buffer(buf, tokens, self)
      buf = []
      let tok_code = if self.lower { to_lower_code(code) } else { code }
      let tok = code_to_string(tok_code)
      if self._keep(tok) {
        tokens.push(tok)
      }
      i = i + 1
      continue
    }
    // 3) ASCII 字母数字:加入 buffer
    if is_alnum_code(code) {
      buf.push(code)
      i = i + 1
      continue
    }
    // 4) 其他字符:刷新 buffer,跳过
    flush_buffer(buf, tokens, self)
    buf = []
    i = i + 1
  }
  // 末尾刷新
  flush_buffer(buf, tokens, self)
  tokens
}

/// 把 buffer 中的 code unit 拼成 token 加入 tokens
fn flush_buffer(buf : Array[Int], tokens : Array[String], self : Tokenizer) -> Unit {
  if buf.length() == 0 {
    return
  }
  let mut s = ""
  for code in buf {
    let c = if self.lower { to_lower_code(code) } else { code }
    s = s + code_to_string(c)
  }
  if self._keep(s) {
    tokens.push(s)
  }
}

/// 判断 token 是否保留(长度+停用词过滤)
fn Tokenizer::_keep(self : Tokenizer, tok : String) -> Bool {
  if tok.length() < self.min_token_len {
    return false
  }
  if self.filter_stopwords {
    match self.stopwords.get(tok) {
      Some(_) => return false
      None => ()
    }
  }
  true
}

/// 便捷函数:默认配置分词
pub fn tokenize_default(text : String) -> Array[String] {
  let tok = Tokenizer::new()
  tok.tokenize(text)
}
