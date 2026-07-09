// ============================================================
// MockEmbedder 测试
// ============================================================

test "MockEmbedder::new 默认维度" {
  let emb = MockEmbedder::new()
  let vec = emb.text_to_vector("test")
  assert_eq(vec.length(), 32)
}

test "MockEmbedder::new 自定义维度" {
  let emb = MockEmbedder::new(dimension=64)
  let vec = emb.text_to_vector("test")
  assert_eq(vec.length(), 64)
}

test "MockEmbedder::text_to_vector 生成向量" {
  let emb = MockEmbedder::new(dimension=16)
  let vec = emb.text_to_vector("hello")
  assert_eq(vec.length(), 16)
}

test "MockEmbedder 相同文本生成相同向量" {
  let emb = MockEmbedder::new(dimension=32)
  let vec1 = emb.text_to_vector("hello")
  let vec2 = emb.text_to_vector("hello")
  assert_eq(vec1.length(), vec2.length())
  for i = 0; i < vec1.length(); i = i + 1 {
    assert_eq(vec1[i], vec2[i])
  }
}

test "MockEmbedder 不同文本生成不同向量" {
  let emb = MockEmbedder::new(dimension=32)
  let vec1 = emb.text_to_vector("hello")
  let vec2 = emb.text_to_vector("world")
  let mut has_diff = false
  for i = 0; i < vec1.length(); i = i + 1 {
    if vec1[i] != vec2[i] {
      has_diff = true
      break
    }
  }
  assert_eq(has_diff, true)
}

test "MockEmbedder 向量已归一化（L2 范数=1）" {
  let emb = MockEmbedder::new(dimension=32)
  let vec = emb.text_to_vector("test text")
  let mut norm = 0.0
  for i = 0; i < vec.length(); i = i + 1 {
    norm = norm + vec[i] * vec[i]
  }
  let norm_val = norm.sqrt()
  assert_eq(norm_val > 0.99, true)
  assert_eq(norm_val < 1.01, true)
}

test "MockEmbedder 空文本生成零向量" {
  let emb = MockEmbedder::new(dimension=16)
  let vec = emb.text_to_vector("")
  let mut is_zero = true
  for i = 0; i < vec.length(); i = i + 1 {
    if vec[i] != 0.0 {
      is_zero = false
      break
    }
  }
  assert_eq(is_zero, true)
}
