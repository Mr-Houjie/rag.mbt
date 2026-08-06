# rag-mbt

> 基于 MoonBit 的 RAG（检索增强生成）库 —— 2 阶段 6 模块完整封装

[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.20260608+-purple.svg)](https://www.moonbitlang.com/)
[![mooncakes.io](https://img.shields.io/badge/mooncakes.io-houjie%2Frag--mbt-blue)](https://mooncakes.io/packages/houjie/rag-mbt)
[![CI](https://github.com/Mr-Houjie/rag.mbt/actions/workflows/ci.yml/badge.svg)](https://github.com/Mr-Houjie/rag.mbt/actions/workflows/ci.yml)

## 项目简介

`rag-mbt` 是一个使用 [MoonBit](https://www.moonbitlang.com/) 语言原生实现的 RAG 库，将检索增强生成流程拆解为 **2 个阶段、6 个核心模块**，通过 Trait 系统提供可插拔的组件架构。

- **阶段一（索引构建）**：加载 → 切分 → 嵌入 → 存储
- **阶段二（检索生成）**：检索 → 生成

**包结构**：仓库包含两个包

| 包 | 路径 | 目标 | 说明 |
|----|------|------|------|
| `houjie/rag-mbt` | 根目录 | wasm-gc / native | 纯 MoonBit 核心库，可发布到 mooncakes.io |
| `houjie/rag-mbt/native` | `native/` | native | C FFI + Python 扩展（真实文件加载、bge 本地嵌入、OpenAI API） |

## 功能特性

- **MoonBit 原生实现**：核心算法（TF-IDF / BM25 / IVF / Hybrid RRF）全部用 MoonBit 编写
- **6 大可插拔 Trait**：`DocumentLoader` / `TextSplitter` / `Embedder` / `VectorStore` / `Retriever` / `Generator`
- **多种检索算法**：BM25 稀疏检索、TF-IDF 向量检索、IVF 聚类加速、Hybrid 混合检索（RRF 融合）
- **真实文件加载**（native）：从 `docs/` 目录读取真实 `.txt` 文档，而非硬编码示例
- **本地嵌入模型**（native）：集成 `BAAI/bge-small-zh`，无需 API 调用即可生成 512 维语义向量
- **LLM 接入**（native）：通过 OpenAI 兼容 API 调用 DeepSeek、OpenAI 等模型生成回答
- **文件持久化**（native）：基于 JSON 的 `FileStore`，向量数据重启不丢失

## 架构设计

```
┌─────────────────────────────────────────────────────────┐
│                     RAGPipeline                         │
│                                                         │
│  ┌──────── 阶段一：构建索引 ────────┐  ┌── 阶段二：检索生成 ──┐│
│  │                                 │  │                      ││
│  │  DocumentLoader ──┐            │  │   Retriever          ││
│  │                   ↓            │  │      ↓                ││
│  │  TextSplitter ──→ Chunks       │  │  VectorStore.search   ││
│  │                      ↓          │  │      ↓                ││
│  │  Embedder ──→ Embeddings        │  │  Generator.generate   ││
│  │                      ↓          │  │      ↓                ││
│  │  VectorStore.add ──→ Store      │  │  GenerationResult    ││
│  │                                 │  │                      ││
│  └─────────────────────────────────┘  └──────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### 6 大核心 Trait

| Trait | 职责 | 默认实现 |
|-------|------|---------|
| `DocumentLoader` | 从文件系统加载文档 | `TxtLoader` / `load_docs_from_dir`（native 真实文件） |
| `TextSplitter` | 将文档切分为文本块 | `SimpleSplitter` |
| `Embedder` | 将文本转为向量 | `TfidfEmbedder`（原生）/ `LocalEmbedder` bge-small-zh（native） |
| `VectorStore` | 存储向量并支持相似度搜索 | `InMemoryStore` / `FileStore`（native JSON 持久化） |
| `Retriever` | 根据查询检索相关文档 | `BM25Retriever` / `HybridRetriever` / `IVFStore` |
| `Generator` | 基于上下文生成回答 | `MockGenerator`（抽取式）/ `OpenAiGenerator`（native） |

## 目录结构

```
rag.mbt/
├── cmd/
│   ├── main/                   # 交互式问答入口（native）
│   └── python_demo/            # Python 交互演示（native）
├── docs/                       # 示例知识库（真实 txt 文档）
│   ├── moonbit.txt
│   ├── rag.txt
│   └── vector_db.txt
├── native/                     # native 扩展包（C FFI + Python）
│   ├── file_io.c               # C FFI：文件 I/O + subprocess + 目录遍历
│   ├── dir_loader.mbt          # 从 docs/ 加载真实 txt 文件
│   ├── file_store.mbt          # FileStore（JSON 持久化）
│   ├── local_embedder.mbt      # LocalEmbedder（bge-small-zh 本地模型）
│   ├── openai_backend.mbt      # OpenAiGenerator（DeepSeek/OpenAI API）
│   ├── file_retriever.mbt      # FileRetriever
│   └── pipeline.mbt            # native 构建辅助函数
├── types.mbt                   # 核心数据类型
├── traits.mbt                  # 6 大 Trait 定义
├── loader.mbt                  # TxtLoader（内置示例文档）
├── splitter.mbt                # SimpleSplitter
├── embedder.mbt                # MockEmbedder（哈希向量）
├── tfidf_embedder.mbt          # TfidfEmbedder（原生 TF-IDF）
├── tokenizer.mbt               # 中文分词器
├── bm25_retriever.mbt          # BM25Retriever
├── hybrid_retriever.mbt        # HybridRetriever（RRF 融合）
├── ivf_index.mbt               # IVFIndex / IVFStore
├── store.mbt                   # InMemoryStore + cosine_sim
├── retriever.mbt               # SimpleRetriever
├── generator.mbt               # MockGenerator（演示用）
├── pipeline.mbt                # RAGPipeline Builder 编排
├── moon.mod.json               # 模块配置
├── moon.pkg.json               # 包配置
└── .github/workflows/ci.yml    # CI（check + build + test）
```

## 环境要求

| 依赖 | 版本 | 用途 |
|------|------|------|
| [MoonBit](https://www.moonbitlang.com/) | ≥ 0.1.20260608 | 编译器 |
| Python | ≥ 3.13 | 本地嵌入模型 / LLM 调用（仅 native 扩展需要） |
| [sentence-transformers](https://sbert.net/) | latest | 本地嵌入模型（仅 native 扩展需要） |
| [openai](https://pypi.org/project/openai/) | latest | LLM API 调用（仅 native 扩展需要） |

> 纯 MoonBit 核心库（TF-IDF / BM25 / IVF）**无需 Python**，可运行在 wasm-gc 与 native 目标。

## 快速开始

### 1. 安装 MoonBit

```bash
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash
moon version
```

### 2. 在 MoonBit 项目中引入核心库

```bash
moon add houjie/rag-mbt
moon install
```

### 3. （可选）运行仓库内 native 演示

clone 本仓库后，运行交互式问答（纯 MoonBit 原生，无需 Python/API）：

```bash
moon run --target native cmd/main
```

运行 Python 演示（TF-IDF 原生 + FileStore 持久化）：

```bash
moon run --target native cmd/python_demo
```

### 4. （可选）配置 native 扩展：安装 Python 依赖

```bash
pip3 install sentence-transformers openai
```

### 5. （可选）配置 API Key

在项目根目录创建 `config.json`（已被 .gitignore 忽略）：

```json
{
  "api_key": "your-api-key-here",
  "base_url": "https://api.deepseek.com",
  "chat_model": "deepseek-chat"
}
```

## 使用示例

### 纯原生 Pipeline（TF-IDF，无需 Python/API）

```moonbit
let rag = @ragnative.native_tfidf(data_dir="rag_data").build()

rag.index("")                       // 阶段一：加载 docs/ → 切分 → 嵌入 → 存储
let result = rag.query("什么是 MoonBit？", top_k=3)  // 阶段二：检索 + 生成
println(result.answer)
```

> `@ragnative` 是 native 扩展包（`houjie/rag-mbt/native`），提供 `native_tfidf` / `native_mock` 两个开箱即用的构建函数。

### 纯原生 Pipeline（BM25，无需 Python/API）

```moonbit
let rag = @ragnative.native_mock(data_dir="rag_data").build()
rag.index("")
let result = rag.query("RAG 的原理是什么？", top_k=3)
println(result.answer)
```

### 完整自定义（核心库 + native 组件）

在仓库内（可访问 `native/` 包）通过 Builder 自由组合组件：

```moonbit
// 1. 基础组件：TxtLoader + SimpleSplitter + TfidfEmbedder
let embedder = @ragmbt.TfidfEmbedder::new()
let b = @ragmbt.RAGPipeline::builder()
let b = @ragmbt.Builder::with_loader(b, @ragmbt.TxtLoader::new("docs/"))
let b = @ragmbt.Builder::with_splitter(b, @ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
let b = @ragmbt.Builder::with_tfidf_embedder(b, embedder)

// 2. native 组件注入：FileStore（JSON 持久化）
let store = @ragnative.FileStore::new("rag_data/vectors.json")
let b = @ragnative.with_file_store(b, store)
// 检索函数：TF-IDF 查询向量 + FileStore 搜索
let b = @ragmbt.Builder::with_retrieve_fn(b, fn(query : String, top_k : Int) {
  store.search(embedder.embed_query(query), top_k)
})

// 3. 构建并运行
let rag = b.build()
rag.index("")
let result = rag.query("什么是 MoonBit？", top_k=3)
```

### 使用 Mock 组件（无需 Python/API）

```moonbit
let rag = @ragnative.native_mock(data_dir="rag_data").build()
```

### 自定义组件

核心库所有组件均为 `pub struct` + 公开构造函数，可直接组合：

```moonbit
// 自定义 Embedder：实现 embed_documents / embed_query 两个函数
fn my_embed_documents(self : MyEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  // 你的实现
}
fn my_embed_query(self : MyEmbedder, query : String) -> Array[Double] {
  // 你的实现
}
```

## 运行效果

```
╔══════════════════════════════════════════╗
║    🚀 rag-mbt: 交互式 RAG 问答           ║
║    MoonBit 原生 RAG 库 (无 Python/API)   ║
║    Embedder: TF-IDF (MoonBit 原生)       ║
║    Generator: MockGenerator              ║
╚══════════════════════════════════════════╝

✅ Pipeline 构建完成

📚 阶段一：构建索引
  [1/4] 加载文档... ✅ 加载了 3 个文档（docs/ 真实文件）
  [2/4] 切分文档... ✅ 切分为 3 个块
  [3/4] 生成向量嵌入... ✅ 生成了 3 个嵌入向量（维度=134）
  [4/4] 存储到向量数据库... ✅ 已存储 3 个向量

🔍 阶段二：检索 + 生成
  [5/6] 检索相关文档... ✅ 检索到 3 条相关结果
  [6/6] 生成回答... ✅ 生成完成
```

## 技术实现

### Python 互操作（native 扩展）

项目通过 C FFI 的 `popen()` 子进程方式调用 Python，避免原生 FFI 的内存问题：

1. MoonBit 构造 Python 脚本和输入数据
2. C FFI 启动 Python 子进程执行脚本
3. Python 通过 stdin 接收输入，stdout 返回 JSON 结果
4. MoonBit 解析 JSON 获取结果

### 真实文件加载（native 扩展）

`dir_loader.mbt` 通过 C FFI 的 `fs_list_txt_files` 遍历目录、`fs_read_all` 读取文件内容，
将 `docs/` 下的真实 `.txt` 文档加载为 `Document`。目录无文件时自动回退到内置示例文档。

### 向量持久化

`FileStore` 将向量数据以 JSON 格式持久化到 `rag_data/vectors.json`，重启后自动加载。

## 配置说明

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `chunk_size` | 200（demo）/ 500（默认） | 文本切分块大小 |
| `chunk_overlap` | 30（demo）/ 50（默认） | 切分重叠长度 |
| `top_k` | 3 | 检索返回的文档数 |
| `model_name` | `BAAI/bge-small-zh` | 本地嵌入模型（native） |
| `data_dir` | `rag_data` | 向量存储目录 |

## 测试与 CI

- 135 个单元测试覆盖：Tokenizer、TF-IDF、BM25、IVF、Hybrid、Store、Splitter、类型等
- GitHub Actions CI：安装 MoonBit → `moon check`（native + wasm-gc）→ `moon build` → `moon test`

## 许可证

[MIT](LICENSE)
