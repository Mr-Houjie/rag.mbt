// ============================================================
// 核心数据类型测试
// ============================================================

test "Document::new 创建文档" {
  let meta = make_meta([("source", "test.txt"), ("topic", "unit")])
  let doc = Document::new("hello world", meta)
  assert_eq(doc.content, "hello world")
  assert_eq(doc.metadata["source"], "test.txt")
  assert_eq(doc.metadata["topic"], "unit")
}

test "Chunk::new 创建块" {
  let meta = make_meta([("source", "doc1")])
  let chunk = Chunk::new("chunk_0", "test text", meta)
  assert_eq(chunk.id, "chunk_0")
  assert_eq(chunk.text, "test text")
  assert_eq(chunk.metadata["source"], "doc1")
  assert_eq(chunk.embedding.is_empty(), true)
}

test "Chunk::with_embedding 设置嵌入向量" {
  let meta = make_meta([])
  let chunk = Chunk::new("chunk_0", "text", meta)
  let emb = [0.1, 0.2, 0.3]
  let chunk_with_emb = chunk.with_embedding(emb)
  assert_eq(chunk_with_emb.embedding.is_empty(), false)
  assert_eq(chunk_with_emb.embedding.unwrap().length(), 3)
  assert_eq(chunk_with_emb.embedding.unwrap()[0], 0.1)
}

test "SearchResult::new 创建搜索结果" {
  let meta = make_meta([])
  let chunk = Chunk::new("c1", "text", meta)
  let result = SearchResult::new(chunk, 0.95)
  assert_eq(result.score, 0.95)
  assert_eq(result.chunk.id, "c1")
}

test "GenerationResult::new 创建生成结果" {
  let meta = make_meta([])
  let chunk = Chunk::new("c1", "source text", meta)
  let result = GenerationResult::new("answer", [chunk])
  assert_eq(result.answer, "answer")
  assert_eq(result.sources.length(), 1)
  assert_eq(result.sources[0].text, "source text")
}

test "make_meta 创建元数据" {
  let meta = make_meta([("key1", "val1"), ("key2", "val2")])
  assert_eq(meta["key1"], "val1")
  assert_eq(meta["key2"], "val2")
  assert_eq(meta.length(), 2)
}
