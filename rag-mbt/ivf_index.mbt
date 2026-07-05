// ============================================================
// IVFIndex - MoonBit 原生 IVF (Inverted File) 向量索引
// 实现 k-means 聚类 + 倒排文件索引,替代线性扫描
// 检索复杂度从 O(N*D) 降为 O(nprobe * N/nlist * D)
// ============================================================

/// IVF 索引参数
pub struct IVFConfig {
  nlist : Int       // 聚类中心数,典型 sqrt(N)
  nprobe : Int      // 检索时探测的簇数,典型 1~nlist
  kmeans_iters : Int // k-means 迭代次数
}

pub fn IVFConfig::new(
  nlist~ : Int = 16,
  nprobe~ : Int = 4,
  kmeans_iters~ : Int = 5
) -> IVFConfig {
  { nlist, nprobe, kmeans_iters }
}

/// IVF 索引
/// 维护:
///   - 所有 chunks
///   - 聚类中心 centroids : Array[Array[Double]]
///   - 倒排表 inverted_lists : Array[Array[Int]]  (每个簇存 chunk 索引)
pub struct IVFIndex {
  config : IVFConfig
  mut chunks : Array[Chunk]
  mut embeddings : Array[Array[Double]]
  mut centroids : Array[Array[Double]]         // nlist 个中心
  mut inverted_lists : Array[Array[Int]]       // 每个簇包含的 chunk 索引
  mut trained : Bool
  mut dim : Int
}

/// 创建 IVF 索引
pub fn IVFIndex::new(
  config~ : IVFConfig = IVFConfig::new()
) -> IVFIndex {
  {
    config,
    chunks: [],
    embeddings: [],
    centroids: [],
    inverted_lists: [],
    trained: false,
    dim: 0,
  }
}

/// 训练索引:用 k-means 聚类生成 centroids
pub fn IVFIndex::train(self : IVFIndex, chunks : Array[Chunk]) -> Unit {
  // 把带 embedding 的 chunks 加入
  for chunk in chunks {
    match chunk.embedding {
      Some(emb) => {
        if self.dim == 0 {
          self.dim = emb.length()
        }
        self.chunks.push(chunk)
        self.embeddings.push(emb)
      }
      None => continue
    }
  }
  if self.embeddings.length() == 0 {
    self.trained = false
    return
  }
  // 调整 nlist(不能超过样本数)
  let nlist = if self.config.nlist > self.embeddings.length() {
    self.embeddings.length()
  } else {
    self.config.nlist
  }
  if nlist == 0 {
    self.trained = false
    return
  }
  // 1) 初始化中心:均匀采样前 nlist 个向量
  self.centroids = []
  for i = 0; i < nlist; i = i + 1 {
    self.centroids.push(self.embeddings[i])
  }
  // 2) k-means 迭代
  for _iter = 0; _iter < self.config.kmeans_iters; _iter = _iter + 1 {
    // 分配每个向量到最近的中心
    let assignments : Array[Int] = Array::make(self.embeddings.length(), 0)
    for i = 0; i < self.embeddings.length(); i = i + 1 {
      assignments[i] = self._nearest_centroid(self.embeddings[i])
    }
    // 重新计算中心
    let new_centroids : Array[Array[Double]] = []
    let counts : Array[Int] = Array::make(nlist, 0)
    // 初始化 new_centroids 为 0 向量
    for c = 0; c < nlist; c = c + 1 {
      new_centroids.push(Array::make(self.dim, 0.0))
    }
    // 累加
    for i = 0; i < self.embeddings.length(); i = i + 1 {
      let c = assignments[i]
      counts[c] = counts[c] + 1
      for d = 0; d < self.dim; d = d + 1 {
        new_centroids[c][d] = new_centroids[c][d] + self.embeddings[i][d]
      }
    }
    // 求平均(空簇保留旧中心)
    for c = 0; c < nlist; c = c + 1 {
      if counts[c] > 0 {
        for d = 0; d < self.dim; d = d + 1 {
          new_centroids[c][d] = new_centroids[c][d] / counts[c].to_double()
        }
        self.centroids[c] = new_centroids[c]
      }
    }
  }
  // 3) 构建倒排表
  self.inverted_lists = []
  for c = 0; c < nlist; c = c + 1 {
    self.inverted_lists.push([])
  }
  for i = 0; i < self.embeddings.length(); i = i + 1 {
    let c = self._nearest_centroid(self.embeddings[i])
    self.inverted_lists[c].push(i)
  }
  self.trained = true
}

/// 找到向量最近的中心索引
fn IVFIndex::_nearest_centroid(self : IVFIndex, vec : Array[Double]) -> Int {
  let mut best_idx = 0
  let mut best_sim = cosine_sim(vec, self.centroids[0])
  for c = 1; c < self.centroids.length(); c = c + 1 {
    let sim = cosine_sim(vec, self.centroids[c])
    if sim > best_sim {
      best_sim = sim
      best_idx = c
    }
  }
  best_idx
}

/// 找到 query 最近的 nprobe 个中心,返回索引数组
fn IVFIndex::_nearest_probes(self : IVFIndex, query : Array[Double]) -> Array[Int] {
  let n = self.centroids.length()
  let sims : Array[(Double, Int)] = []
  for c = 0; c < n; c = c + 1 {
    sims.push((cosine_sim(query, self.centroids[c]), c))
  }
  // 降序排序
  for i = 0; i < sims.length(); i = i + 1 {
    for j = i + 1; j < sims.length(); j = j + 1 {
      if sims[i].0 < sims[j].0 {
        let tmp = sims[i]
        sims[i] = sims[j]
        sims[j] = tmp
      }
    }
  }
  let nprobe = if self.config.nprobe > sims.length() {
    sims.length()
  } else {
    self.config.nprobe
  }
  let result : Array[Int] = []
  for i = 0; i < nprobe; i = i + 1 {
    result.push(sims[i].1)
  }
  result
}

/// 检索 top_k 最相似的 chunks
pub fn IVFIndex::search(self : IVFIndex, query : Array[Double], top_k : Int) -> Array[SearchResult] {
  if !self.trained || self.chunks.length() == 0 {
    return []
  }
  // 1) 找最近 nprobe 个簇
  let probe_clusters = self._nearest_probes(query)
  // 2) 在这些簇内线性搜索
  let candidates : Array[(Double, Int)] = []
  for cluster_idx in probe_clusters {
    let list = self.inverted_lists[cluster_idx]
    for chunk_idx in list {
      let sim = cosine_sim(query, self.embeddings[chunk_idx])
      candidates.push((sim, chunk_idx))
    }
  }
  // 3) 降序排序,取 top_k
  for i = 0; i < candidates.length(); i = i + 1 {
    for j = i + 1; j < candidates.length(); j = j + 1 {
      if candidates[i].0 < candidates[j].0 {
        let tmp = candidates[i]
        candidates[i] = candidates[j]
        candidates[j] = tmp
      }
    }
  }
  let k = if top_k < candidates.length() { top_k } else { candidates.length() }
  let results : Array[SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    let idx = candidates[i].1
    results.push(SearchResult::new(self.chunks[idx], candidates[i].0))
  }
  results
}

/// 已索引的向量数
pub fn IVFIndex::count(self : IVFIndex) -> Int {
  self.chunks.length()
}

/// 聚类中心数
pub fn IVFIndex::nlist(self : IVFIndex) -> Int {
  self.centroids.length()
}

/// 清空索引
pub fn IVFIndex::clear(self : IVFIndex) -> Unit {
  self.chunks = []
  self.embeddings = []
  self.centroids = []
  self.inverted_lists = []
  self.trained = false
  self.dim = 0
}

/// 是否已训练
pub fn IVFIndex::is_trained(self : IVFIndex) -> Bool {
  self.trained
}

// ============================================================
// IVFStore - 把 IVFIndex 包装为 VectorStore 实现
// ============================================================

pub struct IVFStore {
  index : IVFIndex
  mut pending : Array[Chunk]   // 训练前累积的 chunks
  mut trained : Bool
}

pub fn IVFStore::new(
  config~ : IVFConfig = IVFConfig::new()
) -> IVFStore {
  { index: IVFIndex::new(config=config), pending: [], trained: false }
}

/// 添加 chunks:未训练时累积,达到一定数量后自动训练
pub fn IVFStore::add(self : IVFStore, new_chunks : Array[Chunk]) -> Unit {
  for chunk in new_chunks {
    self.pending.push(chunk)
  }
  // 当累积超过 nlist*2 时重新训练
  let threshold = self.index.config.nlist * 2
  if self.pending.length() >= threshold {
    self._retrain()
  }
}

impl VectorStore for IVFStore with add(self : IVFStore, new_chunks : Array[Chunk]) -> Unit {
  self.add(new_chunks)
}

fn IVFStore::_retrain(self : IVFStore) -> Unit {
  // 合并已有索引中的 chunks + pending
  let all_chunks : Array[Chunk] = []
  for c in self.index.chunks {
    all_chunks.push(c)
  }
  for c in self.pending {
    all_chunks.push(c)
  }
  self.index.clear()
  self.index.train(all_chunks)
  self.pending = []
  self.trained = true
}

pub fn IVFStore::search(self : IVFStore, query_embedding : Array[Double], top_k : Int) -> Array[SearchResult] {
  // 如果有未训练的 pending,先合并训练
  if self.pending.length() > 0 {
    self._retrain()
  }
  if !self.trained {
    return []
  }
  self.index.search(query_embedding, top_k)
}

impl VectorStore for IVFStore with search(self : IVFStore, query_embedding : Array[Double], top_k : Int) -> Array[SearchResult] {
  self.search(query_embedding, top_k)
}

pub fn IVFStore::clear(self : IVFStore) -> Unit {
  self.index.clear()
  self.pending = []
  self.trained = false
}

impl VectorStore for IVFStore with clear(self : IVFStore) -> Unit {
  self.clear()
}

pub fn IVFStore::count(self : IVFStore) -> Int {
  self.index.count() + self.pending.length()
}

impl VectorStore for IVFStore with count(self : IVFStore) -> Int {
  self.count()
}
