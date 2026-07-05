// ============================================================
// BM25Retriever - MoonBit 原生 BM25 关键词检索器
// 经典 BM25 算法实现,完全 MoonBit 原生,不依赖向量嵌入
// 公式: score(q, d) = Σ_t IDF(t) * (tf(t,d) * (k1+1)) / (tf(t,d) + k1*(1 - b + b*dl/avgdl))
// ============================================================

/// BM25 检索器
pub struct BM25Retriever {
  tokenizer : Tokenizer
  mut chunks : Array[Chunk]                         // 已索引的文档块
  mut doc_tokens : Array[Array[String]]             // 每个文档的 token 列表
  mut doc_len : Array[Int]                          // 每个文档长度
  mut df : Map[String, Int]                         // 词项文档频率
  mut avgdl : Double                            // 平均文档长度
  // BM25 参数
  k1 : Double                                   // 词频饱和参数,典型 1.2~2.0
  b : Double                                    // 长度归一化参数,典型 0.75
  mut fitted : Bool                             // 是否已建立索引
}

/// 默认参数创建 BM25 检索器
/// k1=1.5, b=0.75 是经典默认值
pub fn BM25Retriever::new(
  tokenizer~ : Tokenizer = Tokenizer::new(),
  k1~ : Double = 1.5,
  b~ : Double = 0.75
) -> BM25Retriever {
  {
    tokenizer,
    chunks: [],
    doc_tokens: [],
    doc_len: [],
    df: Map([]),
    avgdl: 0.0,
    k1,
    b,
    fitted: false,
  }
}

/// 索引一批 chunks
pub fn BM25Retriever::add_documents(self : BM25Retriever, new_chunks : Array[Chunk]) -> Unit {
  for chunk in new_chunks {
    let tokens = self.tokenizer.tokenize(chunk.text)
    self.chunks.push(chunk)
    self.doc_tokens.push(tokens)
    self.doc_len.push(tokens.length())
    // 更新 DF(同一文档内同一 token 只计一次)
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
    }
  }
  // 重新计算 avgdl
  self._update_avgdl()
  self.fitted = true
}

/// 更新平均文档长度
fn BM25Retriever::_update_avgdl(self : BM25Retriever) -> Unit {
  let n = self.doc_len.length()
  if n == 0 {
    self.avgdl = 0.0
    return
  }
  let mut total = 0
  for i = 0; i < n; i = i + 1 {
    total = total + self.doc_len[i]
  }
  self.avgdl = total.to_double() / n.to_double()
}

/// 计算 BM25 单 token 对单文档的得分
/// IDF(t) = ln(1 + (N - df + 0.5) / (df + 0.5))   (BM25 风格 IDF)
fn BM25Retriever::_idf(self : BM25Retriever, token : String) -> Double {
  let n = self.chunks.length().to_double()
  let df_val = match self.df.get(token) {
    Some(c) => c.to_double()
    None => 0.0
  }
  // BM25 IDF,带平滑
  let ratio = (n - df_val + 0.5) / (df_val + 0.5)
  _ln(1.0 + ratio)
}

/// 统计 token 在文档中的词频
fn BM25Retriever::_tf_in_doc(self : BM25Retriever, doc_idx : Int, token : String) -> Int {
  let tokens = self.doc_tokens[doc_idx]
  let mut count = 0
  for tok in tokens {
    if tok == token {
      count = count + 1
    }
  }
  count
}

/// 计算查询与指定文档的 BM25 得分
pub fn BM25Retriever::score(self : BM25Retriever, query : String, doc_idx : Int) -> Double {
  if doc_idx < 0 || doc_idx >= self.chunks.length() {
    return 0.0
  }
  let q_tokens = self.tokenizer.tokenize(query)
  if q_tokens.length() == 0 {
    return 0.0
  }
  // 去重 query token
  let q_unique : Map[String, Unit] = Map([])
  for t in q_tokens {
    q_unique[t] = ()
  }
  let dl = self.doc_len[doc_idx].to_double()
  let mut score = 0.0
  q_unique.each(fn(tok, _) {
    let tf = self._tf_in_doc(doc_idx, tok).to_double()
    if tf == 0.0 {
      return  // 跳过文档中不存在的 token
    }
    let idf = self._idf(tok)
    let denom = tf + self.k1 * (1.0 - self.b + self.b * (dl / self.avgdl))
    let s = idf * (tf * (self.k1 + 1.0)) / denom
    score = score + s
  })
  score
}

/// 检索 top_k 最相关的文档
pub fn BM25Retriever::retrieve(self : BM25Retriever, query : String, top_k : Int) -> Array[SearchResult] {
  if !self.fitted || self.chunks.length() == 0 {
    return []
  }
  let n = self.chunks.length()
  // 计算所有文档得分
  let scores : Array[(Double, Int)] = []
  for i = 0; i < n; i = i + 1 {
    let s = self.score(query, i)
    if s > 0.0 {
      scores.push((s, i))
    }
  }
  // 降序排序(简单冒泡,n 不大时可用)
  for i = 0; i < scores.length(); i = i + 1 {
    for j = i + 1; j < scores.length(); j = j + 1 {
      if scores[i].0 < scores[j].0 {
        let tmp = scores[i]
        scores[i] = scores[j]
        scores[j] = tmp
      }
    }
  }
  // 取 top_k
  let k = if top_k < scores.length() { top_k } else { scores.length() }
  let results : Array[SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    let idx = scores[i].1
    results.push(SearchResult::new(self.chunks[idx], scores[i].0))
  }
  results
}

/// 已索引文档数
pub fn BM25Retriever::count(self : BM25Retriever) -> Int {
  self.chunks.length()
}

/// 清空索引
pub fn BM25Retriever::clear(self : BM25Retriever) -> Unit {
  self.chunks = []
  self.doc_tokens = []
  self.doc_len = []
  self.df = Map([])
  self.avgdl = 0.0
  self.fitted = false
}

// ============================================================
// 实现 Retriever trait
// ============================================================

impl Retriever for BM25Retriever with retrieve(self : BM25Retriever, query : String, top_k : Int) -> Array[SearchResult] {
  self.retrieve(query, top_k)
}
