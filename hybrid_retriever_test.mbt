// ============================================================
// HybridRetriever 测试 - MoonBit 原生混合检索器 (RRF 融合)
// ============================================================

test "HybridRetriever::new 默认创建" {
  let r = HybridRetriever::new()
  // 空检索器列表,retrieve 返回空
  let results = r.retrieve("hello", 5)
  assert_eq(results.length(), 0)
}

test "HybridRetriever::new 自定义 rrf_k" {
  let r = HybridRetriever::new(rrf_k=30.0)
  let meta = make_meta([])
  r.add("retriever1", fn(_q, _k) {
    [SearchResult::new(Chunk::new("c1", "text", meta), 1.0)]
  })
  let results = r.retrieve("query", 5)
  assert_eq(results.length(), 1)
}

test "HybridRetriever::add 添加检索器" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  r.add("r1", fn(_q, _k) {
    [SearchResult::new(Chunk::new("c1", "text", meta), 0.5)]
  })
  let results = r.retrieve("query", 5)
  assert_eq(results.length(), 1)
}

test "HybridRetriever::retrieve 单检索器" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  r.add("only", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "text1", meta), 0.9),
      SearchResult::new(Chunk::new("c2", "text2", meta), 0.5),
    ]
  })
  let results = r.retrieve("query", 5)
  assert_eq(results.length(), 2)
  // 单检索器 RRF 排序保持原顺序
  assert_eq(results[0].chunk.id, "c1")
  assert_eq(results[1].chunk.id, "c2")
}

test "HybridRetriever::retrieve 多检索器融合" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  // 两个检索器都返回相同文档,但顺序不同
  r.add("r1", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
      SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
    ]
  })
  r.add("r2", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c2", "t2", meta), 0.8),
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.4),
    ]
  })
  let results = r.retrieve("query", 5)
  // 两个文档都被两个检索器返回,融合后都有得分
  assert_eq(results.length(), 2)
  // c2 在 r1 排第 2(1/(60+2)),在 r2 排第 1(1/(60+1)),总分高
  // c1 在 r1 排第 1,在 r2 排第 2,总分相同(都是 1/61 + 1/62)
  // 实际上 c1 和 c2 总分相同(都是 1/61 + 1/62),顺序可能不稳定
  // 但都有非零分数
  assert_eq(results[0].score > 0.0, true)
  assert_eq(results[1].score > 0.0, true)
}

test "HybridRetriever::retrieve 共识排序" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  // 两个检索器都把 c1 排第一 -> c1 应排第一
  r.add("r1", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
      SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
    ]
  })
  r.add("r2", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.8),
      SearchResult::new(Chunk::new("c3", "t3", meta), 0.4),
    ]
  })
  let results = r.retrieve("query", 5)
  // c1 在两个检索器都排第 1,RRF 总分最高
  assert_eq(results[0].chunk.id, "c1")
}

test "HybridRetriever::retrieve top_k 限制" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  r.add("r1", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
      SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
      SearchResult::new(Chunk::new("c3", "t3", meta), 0.3),
    ]
  })
  let results = r.retrieve("query", 2)
  assert_eq(results.length(), 2)
}

test "HybridRetriever::retrieve 空检索器返回空" {
  let r = HybridRetriever::new()
  let results = r.retrieve("query", 5)
  assert_eq(results.length(), 0)
}

test "HybridRetriever::retrieve 检索器返回空" {
  let r = HybridRetriever::new()
  r.add("empty", fn(_q, _k) { [] })
  let results = r.retrieve("query", 5)
  assert_eq(results.length(), 0)
}

test "HybridRetriever::retrieve score 降序" {
  let r = HybridRetriever::new()
  let meta = make_meta([])
  r.add("r1", fn(_q, _k) {
    [
      SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
      SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
      SearchResult::new(Chunk::new("c3", "t3", meta), 0.3),
    ]
  })
  let results = r.retrieve("query", 5)
  for i = 0; i < results.length() - 1; i = i + 1 {
    assert_eq(results[i].score >= results[i + 1].score, true)
  }
}

test "HybridRetriever RRF 分数计算" {
  let r = HybridRetriever::new(rrf_k=60.0)
  let meta = make_meta([])
  r.add("r1", fn(_q, _k) {
    [SearchResult::new(Chunk::new("c1", "t1", meta), 0.9)]
  })
  let results = r.retrieve("query", 5)
  // 单检索器单结果,RRF 分数 = 1/(60+1) = 1/61
  let expected = 1.0 / 61.0
  assert_eq(results[0].score > expected - 0.0001, true)
  assert_eq(results[0].score < expected + 0.0001, true)
}

// ============================================================
// HybridRetriever::fuse 静态方法测试
// ============================================================

test "HybridRetriever::fuse 基本融合" {
  let meta = make_meta([])
  let list1 = [
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
  ]
  let list2 = [
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.8),
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.4),
  ]
  let results = HybridRetriever::fuse([list1, list2])
  assert_eq(results.length(), 2)
}

test "HybridRetriever::fuse 空列表" {
  let results = HybridRetriever::fuse([])
  assert_eq(results.length(), 0)
}

test "HybridRetriever::fuse 单列表" {
  let meta = make_meta([])
  let list = [
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
  ]
  let results = HybridRetriever::fuse([list])
  assert_eq(results.length(), 2)
  assert_eq(results[0].chunk.id, "c1")
}

test "HybridRetriever::fuse 自定义 rrf_k" {
  let meta = make_meta([])
  let list = [SearchResult::new(Chunk::new("c1", "t1", meta), 0.9)]
  let results = HybridRetriever::fuse([list], rrf_k=30.0)
  // rrf_k=30,rank=1,score = 1/(30+1) = 1/31
  let expected = 1.0 / 31.0
  assert_eq(results[0].score > expected - 0.0001, true)
  assert_eq(results[0].score < expected + 0.0001, true)
}

test "HybridRetriever::fuse top_k 限制" {
  let meta = make_meta([])
  let list = [
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
    SearchResult::new(Chunk::new("c3", "t3", meta), 0.3),
  ]
  let results = HybridRetriever::fuse([list], top_k=2)
  assert_eq(results.length(), 2)
}

test "HybridRetriever::fuse 共识提升分数" {
  let meta = make_meta([])
  // c1 在两个列表都排第一 -> 总分 = 2 * 1/61
  let list1 = [
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.9),
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.5),
  ]
  let list2 = [
    SearchResult::new(Chunk::new("c1", "t1", meta), 0.8),
    SearchResult::new(Chunk::new("c2", "t2", meta), 0.4),
  ]
  let results = HybridRetriever::fuse([list1, list2])
  // c1 应排第一(共识)
  assert_eq(results[0].chunk.id, "c1")
  // c1 的分数 = 2 * 1/(60+1) = 2/61
  let expected = 2.0 / 61.0
  assert_eq(results[0].score > expected - 0.0001, true)
  assert_eq(results[0].score < expected + 0.0001, true)
}

test "HybridRetriever::fuse 不同 chunk id 不混淆" {
  let meta = make_meta([])
  let list1 = [
    SearchResult::new(Chunk::new("c1", "text1", meta), 0.9),
  ]
  let list2 = [
    SearchResult::new(Chunk::new("c2", "text2", meta), 0.8),
  ]
  let results = HybridRetriever::fuse([list1, list2])
  // c1 和 c2 各被一个列表返回一次,分数相同(都是 1/61)
  assert_eq(results.length(), 2)
  assert_eq(results[0].score > 0.0, true)
  assert_eq(results[1].score > 0.0, true)
}

test "HybridRetriever 集成 BM25" {
  // 测试 HybridRetriever 与 BM25Retriever 集成
  let bm25 = BM25Retriever::new()
  let meta = make_meta([])
  bm25.add_documents([
    Chunk::new("c1", "moonbit programming language", meta),
    Chunk::new("c2", "python programming language", meta),
    Chunk::new("c3", "rag retrieval augmented", meta),
  ])
  let hybrid = HybridRetriever::new()
  hybrid.add("bm25", fn(q, k) { bm25.retrieve(q, k) })
  let results = hybrid.retrieve("moonbit", 2)
  assert_eq(results.length() >= 1, true)
  assert_eq(results[0].chunk.id, "c1")
}

test "HybridRetriever 集成 BM25 + IVF" {
  // 测试 HybridRetriever 集成两个不同类型的检索器
  let bm25 = BM25Retriever::new()
  let ivf = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  let chunks = [
    Chunk::new("c1", "moonbit programming", meta),
    Chunk::new("c2", "python language", meta),
  ]
  bm25.add_documents(chunks)
  // 用 TF-IDF 简单嵌入
  let emb = TfidfEmbedder::new()
  emb.fit(["moonbit programming", "python language"])
  let embedded_chunks = [
    Chunk::new("c1", "moonbit programming", meta).with_embedding(emb.transform("moonbit programming")),
    Chunk::new("c2", "python language", meta).with_embedding(emb.transform("python language")),
  ]
  ivf.train(embedded_chunks)
  let hybrid = HybridRetriever::new()
  hybrid.add("bm25", fn(q, k) { bm25.retrieve(q, k) })
  hybrid.add("ivf", fn(q, k) {
    let qv = emb.transform(q)
    ivf.search(qv, k)
  })
  let results = hybrid.retrieve("moonbit", 2)
  assert_eq(results.length() >= 1, true)
}
