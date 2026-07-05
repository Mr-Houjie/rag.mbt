// ============================================================
// InMemoryStore + cosine_sim 测试
// ============================================================

test "cosine_sim 相同向量相似度为1" {
  let sim = cosine_sim([1.0, 0.0, 0.0], [1.0, 0.0, 0.0])
  assert_eq(sim > 0.999, true)
}

test "cosine_sim 正交向量相似度为0" {
  let sim = cosine_sim([1.0, 0.0], [0.0, 1.0])
  assert_eq(sim < 0.001, true)
}

test "cosine_sim 相反向量相似度为-1" {
  let sim = cosine_sim([1.0, 0.0], [-1.0, 0.0])
  assert_eq(sim < -0.999, true)
}

test "cosine_sim 零向量返回0" {
  let sim = cosine_sim([0.0, 0.0], [1.0, 0.0])
  assert_eq(sim == 0.0, true)
}

test "cosine_sim 相似向量相似度在0-1之间" {
  let sim = cosine_sim([1.0, 0.0], [0.9, 0.1])
  assert_eq(sim > 0.9, true)
  assert_eq(sim < 1.0, true)
}
