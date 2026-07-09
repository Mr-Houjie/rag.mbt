// ============================================================
// TfidfEmbedder - MoonBit 原生 TF-IDF 嵌入器
// 用 TF-IDF 算法生成稀疏向量并映射到稠密向量空间
// 不依赖任何外部模型/Python,完全 MoonBit 原生
// ============================================================

/// TF-IDF 嵌入器
/// - 维护一个词汇表(vocabulary: token -> index)
/// - 维护文档频率(df: token -> 出现该 token 的文档数)
/// - 已训练文档数 N 用于 IDF 计算
pub struct TfidfEmbedder {
  tokenizer : Tokenizer
  vocabulary : Map[String, Int]        // token -> 向量维度索引
  df : Map[String, Int]                // token -> 文档频率
  mut n_docs : Int                     // 已训练文档数
  mut dim : Int                        // 当前向量维度
  // TF-IDF 参数
  k1 : Double                          // IDF 平滑参数(类似 BM25),默认 0.5 (smooth_idf)
  normalize : Bool                     // 是否 L2 归一化
}

/// 默认参数创建 TF-IDF Embedder
pub fn TfidfEmbedder::new(
  tokenizer~ : Tokenizer = Tokenizer::new(),
  normalize~ : Bool = true
) -> TfidfEmbedder {
  {
    tokenizer,
    vocabulary: Map([]),
    df: Map([]),
    n_docs: 0,
    dim: 0,
    k1: 1.0,
    normalize,
  }
}

/// 用一批文档训练词汇表(更新 vocabulary / df / n_docs / dim)
pub fn TfidfEmbedder::fit(self : TfidfEmbedder, texts : Array[String]) -> Unit {
  for text in texts {
    self.n_docs = self.n_docs + 1
    let tokens = self.tokenizer.tokenize(text)
    // 同一文档内同一 token 只计一次 DF
    let seen : Map[String, Unit] = Map([])
    for tok in tokens {
      match seen.get(tok) {
        Some(_) => continue
        None => {
          seen[tok] = ()
          match self.df.get(tok) {
            Some(c) => self.df[tok] = c + 1
            None => self.df[tok] = 1
          }
        }
      }
      // 注册到词汇表
      match self.vocabulary.get(tok) {
        Some(_) => ()
        None => {
          self.vocabulary[tok] = self.dim
          self.dim = self.dim + 1
        }
      }
    }
  }
}

/// 计算单个文本的 TF-IDF 稠密向量
/// 公式: tfidf(t, d) = tf(t, d) * idf(t)
///   - tf(t, d) = count(t in d) / total_tokens(d)  (归一化 TF)
///   - idf(t) = ln((1 + N) / (1 + df(t))) + 1      (smooth idf, sklearn 风格)
pub fn TfidfEmbedder::transform(self : TfidfEmbedder, text : String) -> Array[Double] {
  // 维度为 0 时返回空向量
  if self.dim == 0 {
    return []
  }
  let vec = Array::make(self.dim, 0.0)
  let tokens = self.tokenizer.tokenize(text)
  if tokens.length() == 0 {
    return vec
  }
  // 统计 TF
  let tf : Map[String, Int] = Map([])
  for tok in tokens {
    match tf.get(tok) {
      Some(c) => tf[tok] = c + 1
      None => tf[tok] = 1
    }
  }
  let total = tokens.length().to_double()
  // 计算 TF-IDF
  tf.each(fn(tok, count) {
    match self.vocabulary.get(tok) {
      Some(idx) => {
        let tf_val = count.to_double() / total
        let idf_val = self._idf(tok)
        vec[idx] = tf_val * idf_val
      }
      None => ()
    }
  })
  // L2 归一化
  if self.normalize {
    let mut norm = 0.0
    for i = 0; i < self.dim; i = i + 1 {
      norm = norm + vec[i] * vec[i]
    }
    if norm > 0.0 {
      let scale = 1.0 / norm.sqrt()
      for i = 0; i < self.dim; i = i + 1 {
        vec[i] = vec[i] * scale
      }
    }
  }
  vec
}

/// 批量转换
pub fn TfidfEmbedder::transform_batch(self : TfidfEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for text in texts {
    result.push(self.transform(text))
  }
  result
}

/// IDF 计算: ln((1 + N) / (1 + df)) + 1
fn TfidfEmbedder::_idf(self : TfidfEmbedder, token : String) -> Double {
  let df_val = match self.df.get(token) {
    Some(c) => c
    None => 0
  }
  let n = self.n_docs.to_double()
  let ratio = (1.0 + n) / (1.0 + df_val.to_double())
  _ln(ratio) + 1.0
}

/// 自然对数(自实现,因为 MoonBit Double 没有 log 方法)
/// 算法:把 x 分解为 m * 2^e,m 归一到 [1,2),用 atanh 泰勒级数
///   ln(m) = 2 * (z + z^3/3 + z^5/5 + ...),其中 z = (m-1)/(m+1)
///   ln(x) = ln(m) + e * ln(2)
pub fn _ln(x : Double) -> Double {
  if x <= 0.0 {
    return -1000000000000.0
  }
  let mut y = x
  let mut e = 0
  // 把 y 规范化到 [1, 2) 范围
  while y > 2.0 {
    y = y / 2.0
    e = e + 1
  }
  while y < 1.0 {
    y = y * 2.0
    e = e - 1
  }
  // atanh 级数
  let z = (y - 1.0) / (y + 1.0)
  let z2 = z * z
  let mut sum = z
  let mut term = z
  let mut i = 1
  let eps = 0.000000000000001  // 1e-15
  while i < 60 {
    term = term * z2
    i = i + 2
    let inc = term / i.to_double()
    sum = sum + inc
    if inc < eps && inc > 0.0 - eps {
      break
    }
  }
  let ln_y = 2.0 * sum
  // ln(2) ≈ 0.6931471805599453
  ln_y + e.to_double() * 0.6931471805599453
}

/// 一次性 fit + transform (便捷函数)
pub fn TfidfEmbedder::fit_transform(self : TfidfEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  self.fit(texts)
  self.transform_batch(texts)
}

// ============================================================
// 实现 Embedder trait
// ============================================================

pub fn TfidfEmbedder::embed_documents(self : TfidfEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  // 如果词汇表为空,先 fit
  if self.dim == 0 {
    self.fit(texts)
  }
  self.transform_batch(texts)
}

impl Embedder for TfidfEmbedder with embed_documents(self : TfidfEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  self.embed_documents(texts)
}

pub fn TfidfEmbedder::embed_query(self : TfidfEmbedder, query : String) -> Array[Double] {
  // query 不更新词汇表,只 transform
  // 如果词汇表为空,先用 query 自身 fit
  if self.dim == 0 {
    self.fit([query])
  }
  self.transform(query)
}

impl Embedder for TfidfEmbedder with embed_query(self : TfidfEmbedder, query : String) -> Array[Double] {
  self.embed_query(query)
}

/// 获取当前词汇表大小
pub fn TfidfEmbedder::vocabulary_size(self : TfidfEmbedder) -> Int {
  self.dim
}

/// 获取已训练文档数
pub fn TfidfEmbedder::document_count(self : TfidfEmbedder) -> Int {
  self.n_docs
}
