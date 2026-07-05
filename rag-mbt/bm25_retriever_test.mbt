// ============================================================
// BM25Retriever 测试 - MoonBit 原生 BM25 关键词检索器
// ============================================================

test "BM25Retriever::new 默认参数" {
  let r = BM25Retriever::new()
  assert_eq(r.count(), 0)
}

test "BM25Retriever::add_documents 索引" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "hello world", meta),
    Chunk::new("c2", "moonbit language", meta),
    Chunk::new("c3", "rag retrieval", meta),
  ])
  assert_eq(r.count(), 3)
}

test "BM25Retriever::count 累加" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  assert_eq(r.count(), 0)
  r.add_documents([Chunk::new("c1", "a", meta)])
  assert_eq(r.count(), 1)
  r.add_documents([Chunk::new("c2", "b", meta)])
  assert_eq(r.count(), 2)
}

test "BM25Retriever::retrieve 基本检索" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit is a programming language", meta),
    Chunk::new("c2", "python is also a programming language", meta),
    Chunk::new("c3", "the quick brown fox", meta),
  ])
  let results = r.retrieve("moonbit programming", 2)
  assert_eq(results.length() >= 1, true)
  // c1 应该排第一(包含 moonbit 和 programming)
  assert_eq(results[0].chunk.id, "c1")
}

test "BM25Retriever::retrieve 排序" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit moonbit moonbit", meta),  // moonbit 出现 3 次
    Chunk::new("c2", "moonbit", meta),                   // moonbit 出现 1 次
    Chunk::new("c3", "other content", meta),             // 无 moonbit
  ])
  let results = r.retrieve("moonbit", 2)
  assert_eq(results.length(), 2)
  // score 降序,c1 应排第一
  assert_eq(results[0].chunk.id, "c1")
  assert_eq(results[1].chunk.id, "c2")
  assert_eq(results[0].score > results[1].score, true)
}

test "BM25Retriever::retrieve top_k 限制" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit language", meta),
    Chunk::new("c2", "moonbit compiler", meta),
    Chunk::new("c3", "moonbit runtime", meta),
  ])
  let results = r.retrieve("moonbit", 2)
  assert_eq(results.length(), 2)
}

test "BM25Retriever::retrieve top_k 超过结果数" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit", meta),
  ])
  let results = r.retrieve("moonbit", 10)
  assert_eq(results.length(), 1)
}

test "BM25Retriever::retrieve 无匹配返回空" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "hello world", meta),
    Chunk::new("c2", "foo bar", meta),
  ])
  let results = r.retrieve("nonexistent", 5)
  assert_eq(results.length(), 0)
}

test "BM25Retriever::retrieve 未训练返回空" {
  let r = BM25Retriever::new()
  let results = r.retrieve("anything", 5)
  assert_eq(results.length(), 0)
}

test "BM25Retriever::retrieve 空查询返回空" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([Chunk::new("c1", "hello world", meta)])
  let results = r.retrieve("", 5)
  assert_eq(results.length(), 0)
}

test "BM25Retriever::retrieve 仅停用词查询" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([Chunk::new("c1", "hello world", meta)])
  // "the" "a" 是停用词,分词后为空
  let results = r.retrieve("the a", 5)
  assert_eq(results.length(), 0)
}

test "BM25Retriever::score 单文档得分" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit programming language", meta),
  ])
  let s = r.score("moonbit", 0)
  // 包含 moonbit,得分应大于 0
  assert_eq(s > 0.0, true)
}

test "BM25Retriever::score 无匹配 token 得分为 0" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "hello world", meta),
  ])
  let s = r.score("moonbit", 0)
  assert_eq(s, 0.0)
}

test "BM25Retriever::score 越界索引返回 0" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([Chunk::new("c1", "hello", meta)])
  assert_eq(r.score("hello", -1), 0.0)
  assert_eq(r.score("hello", 99), 0.0)
}

test "BM25Retriever 自定义 k1 b 参数" {
  let r = BM25Retriever::new(k1=2.0, b=0.5)
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit programming", meta),
    Chunk::new("c2", "moonbit language", meta),
  ])
  let results = r.retrieve("moonbit", 2)
  assert_eq(results.length(), 2)
}

test "BM25Retriever::clear 清空" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "hello world", meta),
    Chunk::new("c2", "foo bar", meta),
  ])
  assert_eq(r.count(), 2)
  r.clear()
  assert_eq(r.count(), 0)
  // 清空后检索返回空
  let results = r.retrieve("hello", 5)
  assert_eq(results.length(), 0)
}

test "BM25Retriever 中文检索" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "月兔编程语言", meta),
    Chunk::new("c2", "月兔是一种新语言", meta),
    Chunk::new("c3", "其他内容", meta),
  ])
  let results = r.retrieve("月兔", 2)
  assert_eq(results.length() >= 1, true)
  assert_eq(results[0].chunk.id, "c1")
}

test "BM25Retriever 实现 Retriever trait" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([Chunk::new("c1", "moonbit language", meta)])
  // BM25Retriever 有自己的 retrieve 方法(trait 实现委托给自身方法)
  let results = r.retrieve("moonbit", 1)
  assert_eq(results.length(), 1)
}

test "BM25Retriever 多次 add_documents 累积" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([Chunk::new("c1", "hello", meta)])
  r.add_documents([Chunk::new("c2", "world", meta)])
  r.add_documents([Chunk::new("c3", "foo", meta)])
  assert_eq(r.count(), 3)
  let results = r.retrieve("hello", 3)
  assert_eq(results.length() >= 1, true)
}

test "BM25Retriever 检索结果 score 降序" {
  let r = BM25Retriever::new()
  let meta = make_meta([])
  r.add_documents([
    Chunk::new("c1", "moonbit moonbit", meta),
    Chunk::new("c2", "moonbit", meta),
    Chunk::new("c3", "moonbit moonbit moonbit", meta),
  ])
  let results = r.retrieve("moonbit", 3)
  // 验证 score 单调递减
  for i = 0; i < results.length() - 1; i = i + 1 {
    assert_eq(results[i].score >= results[i + 1].score, true)
  }
}
