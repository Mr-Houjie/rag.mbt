// ============================================================
// TxtLoader - 静态文档加载器（演示用）
// ============================================================

struct TxtLoader {
  base_path : String
}

pub fn TxtLoader::new(path : String) -> TxtLoader {
  { base_path: path, }
}

pub fn load_static_docs() -> Array[Document] {
  let docs = [
    Document::new(
      "MoonBit 是一种专为 WebAssembly 设计的现代编程语言。它由 IDEA 研究院的张宏波团队开发。\nMoonBit 结合了 Rust 的表达式能力和 Go 的简洁性，提供强大的类型系统、模式匹配和泛型。\nMoonBit 编译速度极快，生成的 Wasm 体积非常小，适合云计算和边缘计算场景。",
      make_meta([("source", "moonbit_intro.txt"), ("topic", "language")])
    ),
    Document::new(
      "RAG（检索增强生成）是一种结合信息检索和文本生成的 AI 技术架构。\n它的核心思想是：在 LLM 生成回答之前，先从知识库中检索相关文档，\n然后将检索结果作为上下文提供给 LLM，从而生成更准确、更可靠的回答。\nRAG 有效解决了 LLM 的幻觉问题和知识截止问题。",
      make_meta([("source", "rag_intro.txt"), ("topic", "ai")])
    ),
    Document::new(
      "MoonBit 支持多后端编译：WebAssembly、JavaScript 和 Native。\n通过 python.mbt 库，MoonBit 可以无缝调用 Python 生态中的任何库，\n包括 langchain、numpy、pandas 等。\nMoonBit 的构建系统 moon 也非常快，626 个包只需要 1.06 秒编译。",
      make_meta([("source", "moonbit_advanced.txt"), ("topic", "language")])
    ),
    Document::new(
      "向量数据库是 RAG 系统的核心组件之一。它负责存储文档的向量嵌入，\n并提供高效的相似度搜索能力。常见的向量数据库包括 FAISS、Chroma、Milvus 等。\nMoonBit 的 rag-mbt 库目前提供内存存储实现，后续将支持 FAISS 等外部存储。",
      make_meta([("source", "vector_db.txt"), ("topic", "ai")])
    ),
    Document::new(
      "MoonBit 的 trait 系统支持特设多态。\n通过 trait，我们可以在 rag-mbt 中定义统一的接口：\nDocumentLoader、TextSplitter、Embedder、VectorStore、Retriever、Generator。\n用户只需要实现这些 trait，就可以任意替换 RAG 流水线中的任意组件。",
      make_meta([("source", "moonbit_traits.txt"), ("topic", "language")])
    ),
  ]
  docs
}

impl DocumentLoader for TxtLoader with load(self : TxtLoader, path : String) -> Array[Document] {
  let _ = path
  load_static_docs()
}
