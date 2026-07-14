// ============================================================
// MockGenerator 测试
// ============================================================

test "MockGenerator::new 默认前缀" {
  let gen = MockGenerator::new()
  let meta = make_meta([])
  let chunk = Chunk::new("c1", "context text", meta)
  let result = gen.do_generate("question?", [chunk])
  assert_eq(result.answer.contains("根据检索到的资料"), true)
  assert_eq(result.answer.contains("context text"), true)
  assert_eq(result.answer.contains("question?"), true)
}

test "MockGenerator::new 自定义前缀" {
  let gen = MockGenerator::new(prefix="参考资料:\n")
  let meta = make_meta([])
  let chunk = Chunk::new("c1", "hello", meta)
  let result = gen.do_generate("q", [chunk])
  assert_eq(result.answer.contains("hello"), true)
}

test "MockGenerator 生成结果包含来源" {
  let gen = MockGenerator::new()
  let meta = make_meta([])
  let chunks = [
    Chunk::new("c1", "source1", meta),
    Chunk::new("c2", "source2", meta),
  ]
  let result = gen.do_generate("query", chunks)
  assert_eq(result.sources.length(), 2)
  assert_eq(result.answer.contains("source1"), true)
  assert_eq(result.answer.contains("source2"), true)
}

test "MockGenerator 空上下文" {
  let gen = MockGenerator::new()
  let result = gen.do_generate("question?", [])
  assert_eq(result.answer.contains("question?"), true)
  assert_eq(result.sources.length(), 0)
}
