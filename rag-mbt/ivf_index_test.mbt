// ============================================================
// IVFIndex 测试 - MoonBit 原生 IVF (Inverted File) 向量索引
// ============================================================

test "IVFConfig::new 默认参数" {
  let cfg = IVFConfig::new()
  assert_eq(cfg.nlist, 16)
  assert_eq(cfg.nprobe, 4)
  assert_eq(cfg.kmeans_iters, 5)
}

test "IVFConfig::new 自定义参数" {
  let cfg = IVFConfig::new(nlist=8, nprobe=2, kmeans_iters=10)
  assert_eq(cfg.nlist, 8)
  assert_eq(cfg.nprobe, 2)
  assert_eq(cfg.kmeans_iters, 10)
}

test "IVFIndex::new 默认创建" {
  let idx = IVFIndex::new()
  assert_eq(idx.count(), 0)
  assert_eq(idx.nlist(), 0)
  assert_eq(idx.is_trained(), false)
}

test "IVFIndex::new 自定义 config" {
  let cfg = IVFConfig::new(nlist=4, nprobe=2, kmeans_iters=3)
  let idx = IVFIndex::new(config=cfg)
  assert_eq(idx.is_trained(), false)
}

test "IVFIndex::train 训练" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  let chunks = [
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0, 0.0]),
    Chunk::new("c3", "t3", meta).with_embedding([0.9, 0.1, 0.0]),
    Chunk::new("c4", "t4", meta).with_embedding([0.1, 0.9, 0.0]),
  ]
  idx.train(chunks)
  assert_eq(idx.is_trained(), true)
  assert_eq(idx.count(), 4)
  // nlist 不能超过样本数;此处 nlist=2,样本=4,所以 nlist=2
  assert_eq(idx.nlist(), 2)
}

test "IVFIndex::train nlist 超过样本数" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=10, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  let chunks = [
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
  ]
  idx.train(chunks)
  // nlist 应被截断为样本数
  assert_eq(idx.nlist(), 2)
  assert_eq(idx.is_trained(), true)
}

test "IVFIndex::train 空 chunks" {
  let idx = IVFIndex::new()
  idx.train([])
  assert_eq(idx.is_trained(), false)
  assert_eq(idx.count(), 0)
}

test "IVFIndex::train 无 embedding 的 chunk 被跳过" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  let chunks = [
    Chunk::new("c1", "t1", meta),  // 无 embedding
    Chunk::new("c2", "t2", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c3", "t3", meta).with_embedding([0.0, 1.0]),
  ]
  idx.train(chunks)
  // 只有 2 个有 embedding 的 chunk 被索引
  assert_eq(idx.count(), 2)
}

test "IVFIndex::search 基本检索" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0, 0.0]),
    Chunk::new("c3", "t3", meta).with_embedding([0.9, 0.1, 0.0]),
    Chunk::new("c4", "t4", meta).with_embedding([0.1, 0.9, 0.0]),
  ])
  // 查询接近 c1
  let results = idx.search([1.0, 0.0, 0.0], 2)
  assert_eq(results.length() >= 1, true)
  assert_eq(results[0].chunk.id, "c1")
}

test "IVFIndex::search top_k 限制" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.9, 0.1]),
    Chunk::new("c3", "t3", meta).with_embedding([0.8, 0.2]),
    Chunk::new("c4", "t4", meta).with_embedding([0.0, 1.0]),
  ])
  let results = idx.search([1.0, 0.0], 2)
  assert_eq(results.length(), 2)
}

test "IVFIndex::search 未训练返回空" {
  let idx = IVFIndex::new()
  let results = idx.search([1.0, 0.0], 5)
  assert_eq(results.length(), 0)
}

test "IVFIndex::search score 降序" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.9, 0.1]),
    Chunk::new("c3", "t3", meta).with_embedding([0.5, 0.5]),
  ])
  let results = idx.search([1.0, 0.0], 3)
  for i = 0; i < results.length() - 1; i = i + 1 {
    assert_eq(results[i].score >= results[i + 1].score, true)
  }
}

test "IVFIndex::clear 清空" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
  ])
  assert_eq(idx.count(), 2)
  assert_eq(idx.is_trained(), true)
  idx.clear()
  assert_eq(idx.count(), 0)
  assert_eq(idx.nlist(), 0)
  assert_eq(idx.is_trained(), false)
}

test "IVFIndex::count 已索引数" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
    Chunk::new("c3", "t3", meta).with_embedding([1.0, 1.0]),
  ])
  assert_eq(idx.count(), 3)
}

test "IVFIndex::nlist 聚类中心数" {
  let idx = IVFIndex::new(config=IVFConfig::new(nlist=3, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  idx.train([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
    Chunk::new("c3", "t3", meta).with_embedding([1.0, 1.0]),
    Chunk::new("c4", "t4", meta).with_embedding([0.5, 0.5]),
  ])
  assert_eq(idx.nlist(), 3)
}

// ============================================================
// IVFStore (实现 VectorStore trait) 测试
// ============================================================

test "IVFStore::new 默认创建" {
  let store : IVFStore = IVFStore::new()
  assert_eq(store.count(), 0)
}

test "IVFStore::new 自定义 config" {
  let cfg = IVFConfig::new(nlist=4, nprobe=2, kmeans_iters=3)
  let store : IVFStore = IVFStore::new(config=cfg)
  assert_eq(store.count(), 0)
}

test "IVFStore::add 累积 chunks" {
  let store : IVFStore = IVFStore::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  // 累积少于 nlist*2 = 4 时不会触发训练
  store.add([Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0])])
  store.add([Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0])])
  assert_eq(store.count(), 2)
}

test "IVFStore::search 触发训练" {
  let store : IVFStore = IVFStore::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  store.add([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
  ])
  // search 时会触发 _retrain
  let results = store.search([1.0, 0.0], 2)
  assert_eq(results.length() >= 1, true)
  assert_eq(results[0].chunk.id, "c1")
}

test "IVFStore::add 超阈值自动训练" {
  let store : IVFStore = IVFStore::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  // nlist*2 = 4,达到阈值会自动训练
  store.add([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
    Chunk::new("c3", "t3", meta).with_embedding([0.9, 0.1]),
    Chunk::new("c4", "t4", meta).with_embedding([0.1, 0.9]),
  ])
  assert_eq(store.count(), 4)
}

test "IVFStore::clear 清空" {
  let store : IVFStore = IVFStore::new(config=IVFConfig::new(nlist=2, nprobe=1, kmeans_iters=3))
  let meta = make_meta([])
  store.add([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
  ])
  assert_eq(store.count(), 2)
  store.clear()
  assert_eq(store.count(), 0)
}

test "IVFStore 实现 VectorStore trait" {
  let store : IVFStore = IVFStore::new(config=IVFConfig::new(nlist=2, nprobe=2, kmeans_iters=5))
  let meta = make_meta([])
  // 通过具体类型调用 trait 方法
  store.add([
    Chunk::new("c1", "t1", meta).with_embedding([1.0, 0.0]),
    Chunk::new("c2", "t2", meta).with_embedding([0.0, 1.0]),
  ])
  assert_eq(store.count(), 2)
  let results = store.search([1.0, 0.0], 1)
  assert_eq(results.length(), 1)
}

test "IVFStore::search 未添加数据返回空" {
  let store : IVFStore = IVFStore::new()
  let results = store.search([1.0, 0.0], 5)
  assert_eq(results.length(), 0)
}
