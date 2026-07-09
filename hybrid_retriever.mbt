// ============================================================
// HybridRetriever - MoonBit 原生混合检索器
// 使用 RRF (Reciprocal Rank Fusion) 算法融合多个检索结果
// 公式: score(d) = Σ_i 1 / (k + rank_i(d))
//   - k 通常为 60 (官方推荐)
//   - rank_i(d) 是文档 d 在第 i 个检索器结果中的排名(从 1 开始)
// 优势:不需要校准不同检索器的得分尺度
// ============================================================

/// 混合检索器
/// 内部维护多个检索函数,用 RRF 融合它们的检索结果
pub struct HybridRetriever {
  retrievers : Array[(String, (String, Int) -> Array[SearchResult])]
  rrf_k : Double           // RRF 平滑参数,典型 60
}

/// 创建混合检索器
/// - rrf_k:RRF 平滑常数,默认 60(Cormack et al. 2009 推荐)
pub fn HybridRetriever::new(rrf_k~ : Double = 60.0) -> HybridRetriever {
  { retrievers: [], rrf_k }
}

/// 添加一个具名检索函数
pub fn HybridRetriever::add(
  self : HybridRetriever,
  name : String,
  retrieve_fn : (String, Int) -> Array[SearchResult]
) -> Unit {
  self.retrievers.push((name, retrieve_fn))
}

/// RRF 融合检索
/// 流程:
///   1) 对每个检索函数调用 retrieve,得到排名
///   2) 对每个文档,累加 1/(k+rank)
///   3) 按融合得分降序排序,返回 top_k
pub fn HybridRetriever::retrieve(self : HybridRetriever, query : String, top_k : Int) -> Array[SearchResult] {
  if self.retrievers.length() == 0 {
    return []
  }
  // chunk_id -> (chunk, 累计 RRF 分数)
  let scores : Map[String, (Chunk, Double)] = Map([])
  // 对每个 retriever 检索并累加 RRF 分数
  for entry in self.retrievers {
    let (_name, retrieve_fn) = entry
    let results = retrieve_fn(query, top_k)
    for rank = 0; rank < results.length(); rank = rank + 1 {
      let res = results[rank]
      let rank_1based = (rank + 1).to_double()
      let rrf_score = 1.0 / (self.rrf_k + rank_1based)
      match scores.get(res.chunk.id) {
        Some((chunk, total)) => {
          scores[res.chunk.id] = (chunk, total + rrf_score)
        }
        None => {
          scores[res.chunk.id] = (res.chunk, rrf_score)
        }
      }
    }
  }
  // 把 scores 转为列表
  let fused : Array[(Double, Chunk)] = []
  scores.each(fn(id, pair) {
    let (chunk, score) = pair
    fused.push((score, chunk))
    let _ = id
  })
  // 降序排序
  for i = 0; i < fused.length(); i = i + 1 {
    for j = i + 1; j < fused.length(); j = j + 1 {
      if fused[i].0 < fused[j].0 {
        let tmp = fused[i]
        fused[i] = fused[j]
        fused[j] = tmp
      }
    }
  }
  // 取 top_k
  let k = if top_k < fused.length() { top_k } else { fused.length() }
  let out : Array[SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    out.push(SearchResult::new(fused[i].1, fused[i].0))
  }
  out
}

/// 静态方法:一次性融合多个检索结果(无需创建实例)
/// 适合无状态融合场景
pub fn HybridRetriever::fuse(
  results_list : Array[Array[SearchResult]],
  rrf_k~ : Double = 60.0,
  top_k~ : Int = 10
) -> Array[SearchResult] {
  let scores : Map[String, (Chunk, Double)] = Map([])
  for results in results_list {
    for rank = 0; rank < results.length(); rank = rank + 1 {
      let res = results[rank]
      let rank_1based = (rank + 1).to_double()
      let rrf_score = 1.0 / (rrf_k + rank_1based)
      match scores.get(res.chunk.id) {
        Some((chunk, total)) => {
          scores[res.chunk.id] = (chunk, total + rrf_score)
        }
        None => {
          scores[res.chunk.id] = (res.chunk, rrf_score)
        }
      }
    }
  }
  let fused : Array[(Double, Chunk)] = []
  scores.each(fn(id, pair) {
    let (chunk, score) = pair
    fused.push((score, chunk))
    let _ = id
  })
  for i = 0; i < fused.length(); i = i + 1 {
    for j = i + 1; j < fused.length(); j = j + 1 {
      if fused[i].0 < fused[j].0 {
        let tmp = fused[i]
        fused[i] = fused[j]
        fused[j] = tmp
      }
    }
  }
  let k = if top_k < fused.length() { top_k } else { fused.length() }
  let out : Array[SearchResult] = []
  for i = 0; i < k; i = i + 1 {
    out.push(SearchResult::new(fused[i].1, fused[i].0))
  }
  out
}
