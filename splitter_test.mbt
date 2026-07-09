// ============================================================
// SimpleSplitter 测试
// ============================================================

test "SimpleSplitter::new 默认参数" {
  let splitter = SimpleSplitter::new()
  let doc = Document::new("short text", make_meta([]))
  let chunks = splitter.do_split([doc])
  assert_eq(chunks.length() >= 1, true)
}

test "SimpleSplitter::new 自定义参数" {
  let splitter = SimpleSplitter::new(chunk_size=100, chunk_overlap=20)
  let doc = Document::new("hello world", make_meta([]))
  let chunks = splitter.do_split([doc])
  assert_eq(chunks.length(), 1)
  assert_eq(chunks[0].text, "hello world")
}

test "SimpleSplitter 长文本切分" {
  let splitter = SimpleSplitter::new(chunk_size=10, chunk_overlap=2)
  let long_text = "abcdefghijklmnopqrstuvwxyz0123456789"
  let doc = Document::new(long_text, make_meta([]))
  let chunks = splitter.do_split([doc])
  assert_eq(chunks.length() > 1, true)
  for i = 0; i < chunks.length(); i = i + 1 {
    assert_eq(chunks[i].text.length() <= 10, true)
  }
}

test "SimpleSplitter 多文档切分" {
  let splitter = SimpleSplitter::new(chunk_size=500, chunk_overlap=50)
  let docs = [
    Document::new("doc1 content", make_meta([("id", "1")])),
    Document::new("doc2 content", make_meta([("id", "2")])),
    Document::new("doc3 content", make_meta([("id", "3")])),
  ]
  let chunks = splitter.do_split(docs)
  assert_eq(chunks.length(), 3)
  assert_eq(chunks[0].metadata["id"], "1")
  assert_eq(chunks[1].metadata["id"], "2")
  assert_eq(chunks[2].metadata["id"], "3")
}

test "SimpleSplitter chunk id 递增" {
  let splitter = SimpleSplitter::new(chunk_size=500, chunk_overlap=50)
  let docs = [
    Document::new("doc1", make_meta([])),
    Document::new("doc2", make_meta([])),
  ]
  let chunks = splitter.do_split(docs)
  assert_eq(chunks[0].id, "chunk_0")
  assert_eq(chunks[1].id, "chunk_1")
}

test "SimpleSplitter 空文档" {
  let splitter = SimpleSplitter::new(chunk_size=100, chunk_overlap=20)
  let doc = Document::new("", make_meta([]))
  let chunks = splitter.do_split([doc])
  // 空文本不产生块
  assert_eq(chunks.length(), 0)
}
