// ============================================================
// TfidfEmbedder 测试 - MoonBit 原生 TF-IDF 嵌入器
// ============================================================

test "TfidfEmbedder::new 默认创建" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  assert_eq(emb.vocabulary_size(), 0)
  assert_eq(emb.document_count(), 0)
}

test "TfidfEmbedder::fit 训练词汇表" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit([
    "hello world",
    "hello moonbit",
    "world of moonbit",
  ])
  // 训练 3 个文档
  assert_eq(emb.document_count(), 3)
  // 词汇表应包含:hello, world, moonbit, of (注意 "of" 是停用词被过滤)
  // 实际:hello, world, moonbit
  assert_eq(emb.vocabulary_size() >= 3, true)
}

test "TfidfEmbedder::transform 向量维度" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world", "hello moonbit"])
  let vec = emb.transform("hello world")
  // 向量维度等于词汇表大小
  assert_eq(vec.length(), emb.vocabulary_size())
  assert_eq(vec.length() > 0, true)
}

test "TfidfEmbedder transform 未训练返回空" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  let vec = emb.transform("hello")
  assert_eq(vec.length(), 0)
}

test "TfidfEmbedder 相同文本相同向量" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world", "hello moonbit", "world of moonbit"])
  let v1 = emb.transform("hello world")
  let v2 = emb.transform("hello world")
  assert_eq(v1.length(), v2.length())
  for i = 0; i < v1.length(); i = i + 1 {
    assert_eq(v1[i], v2[i])
  }
}

test "TfidfEmbedder 不同文本不同向量" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world", "hello moonbit", "world of moonbit"])
  let v1 = emb.transform("hello world")
  let v2 = emb.transform("moonbit world")
  let mut has_diff = false
  for i = 0; i < v1.length(); i = i + 1 {
    if v1[i] != v2[i] {
      has_diff = true
      break
    }
  }
  assert_eq(has_diff, true)
}

test "TfidfEmbedder L2 归一化" {
  let emb : TfidfEmbedder = TfidfEmbedder::new(normalize=true)
  emb.fit(["hello world", "moonbit language", "rag retrieval"])
  let vec = emb.transform("hello world")
  // L2 范数应接近 1
  let mut norm = 0.0
  for i = 0; i < vec.length(); i = i + 1 {
    norm = norm + vec[i] * vec[i]
  }
  let norm_val = norm.sqrt()
  assert_eq(norm_val > 0.99, true)
  assert_eq(norm_val < 1.01, true)
}

test "TfidfEmbedder 不归一化" {
  let emb : TfidfEmbedder = TfidfEmbedder::new(normalize=false)
  emb.fit(["hello world", "moonbit language", "rag retrieval"])
  let vec = emb.transform("hello world")
  // 不归一化,范数不一定为 1(但可能恰好为 1)
  let mut norm = 0.0
  for i = 0; i < vec.length(); i = i + 1 {
    norm = norm + vec[i] * vec[i]
  }
  // 至少有一个非零分量
  let mut has_nonzero = false
  for i = 0; i < vec.length(); i = i + 1 {
    if vec[i] != 0.0 {
      has_nonzero = true
      break
    }
  }
  assert_eq(has_nonzero, true)
}

test "TfidfEmbedder::transform_batch 批量转换" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world", "moonbit lang"])
  let vecs = emb.transform_batch(["hello world", "moonbit lang"])
  assert_eq(vecs.length(), 2)
  assert_eq(vecs[0].length(), emb.vocabulary_size())
  assert_eq(vecs[1].length(), emb.vocabulary_size())
}

test "TfidfEmbedder::fit_transform 一次性" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  let vecs = emb.fit_transform(["hello world", "moonbit lang"])
  assert_eq(vecs.length(), 2)
  assert_eq(emb.document_count(), 2)
  assert_eq(emb.vocabulary_size() > 0, true)
}

test "TfidfEmbedder 空文本 transform" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world", "moonbit lang"])
  let vec = emb.transform("")
  // 维度正确,但全为 0
  assert_eq(vec.length(), emb.vocabulary_size())
  let mut is_zero = true
  for i = 0; i < vec.length(); i = i + 1 {
    if vec[i] != 0.0 {
      is_zero = false
      break
    }
  }
  assert_eq(is_zero, true)
}

test "TfidfEmbedder 未登录词" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit(["hello world"])
  // "unknown" 不在词汇表中
  let vec = emb.transform("unknown words")
  // 维度仍等于词汇表大小
  assert_eq(vec.length(), emb.vocabulary_size())
}

test "TfidfEmbedder 实现 Embedder trait - embed_documents" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  let vecs = emb.embed_documents(["hello world", "moonbit lang"])
  // embed_documents 在词汇表为空时自动 fit
  assert_eq(vecs.length(), 2)
  assert_eq(emb.vocabulary_size() > 0, true)
}

test "TfidfEmbedder 实现 Embedder trait - embed_query" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  let vec = emb.embed_query("hello world")
  // 词汇表为空时用 query 自身 fit
  assert_eq(vec.length() > 0, true)
}

test "TfidfEmbedder 词汇表大小递增" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  assert_eq(emb.vocabulary_size(), 0)
  emb.fit(["hello world"])
  let size1 = emb.vocabulary_size()
  emb.fit(["foo bar"])  // 添加新词
  let size2 = emb.vocabulary_size()
  assert_eq(size2 >= size1, true)
}

test "TfidfEmbedder 中文文本" {
  let emb : TfidfEmbedder = TfidfEmbedder::new()
  emb.fit([
    "你好世界",
    "你好月亮",
    "世界你好",
  ])
  assert_eq(emb.vocabulary_size() > 0, true)
  let vec = emb.transform("你好")
  assert_eq(vec.length(), emb.vocabulary_size())
}

// ============================================================
// _ln 函数测试(自实现自然对数)
// ============================================================

test "_ln 正数计算" {
  // ln(1) = 0
  let r1 = _ln(1.0)
  assert_eq(r1 > -0.0001, true)
  assert_eq(r1 < 0.0001, true)
  // ln(2) ≈ 0.693
  let r2 = _ln(2.0)
  assert_eq(r2 > 0.69, true)
  assert_eq(r2 < 0.70, true)
  // ln(e) = 1,但 MoonBit 没有 M_E,用 2.718281828
  let r3 = _ln(2.718281828)
  assert_eq(r3 > 0.99, true)
  assert_eq(r3 < 1.01, true)
}

test "_ln 非正数返回极小值" {
  let r0 = _ln(0.0)
  assert_eq(r0 < -1000000.0, true)
  let rneg = _ln(-1.0)
  assert_eq(rneg < -1000000.0, true)
}

test "_ln 大数" {
  // ln(1024) = ln(2^10) = 10 * ln(2) ≈ 6.93
  let r = _ln(1024.0)
  assert_eq(r > 6.9, true)
  assert_eq(r < 7.0, true)
}

test "_ln 小数" {
  // ln(0.5) = -ln(2) ≈ -0.693
  let r = _ln(0.5)
  assert_eq(r > -0.70, true)
  assert_eq(r < -0.69, true)
}
