# rag-mbt

> 基于 MoonBit 的 RAG（检索增强生成）库 —— 2 阶段 6 模块完整封装

[![License: Apache-2.0](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.20260608+- purple.svg)](https://www.moonbitlang.com/)

## 项目简介

`rag-mbt` 是一个使用 [MoonBit](https://www.moonbitlang.com/) 语言原生实现的 RAG 库，将检索增强生成流程拆解为 **2 个阶段、6 个核心模块**，通过 Trait 系统提供可插拔的组件架构。

- **阶段一（索引构建）**：加载 → 切分 → 嵌入 → 存储
- **阶段二（检索生成）**：检索 → 生成

## 功能特性

- **MoonBit 原生实现**：核心逻辑全部用 MoonBit 编写，通过 C FFI 实现文件 I/O
- **6 大可插拔 Trait**：`DocumentLoader` / `TextSplitter` / `Embedder` / `VectorStore` / `Retriever` / `Generator`
- **本地嵌入模型**：集成 `bge-small-zh`，无需 API 调用即可生成 512 维语义向量
- **LLM 接入**：通过 OpenAI 兼容 API 调用 DeepSeek、OpenAI 等模型生成回答
- **文件持久化**：基于 JSON 的 `FileStore`，向量数据重启不丢失
- **Builder 模式**：使用 `RAGPipeline::builder()` 流式编排组件

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
| `DocumentLoader` | 从文件系统加载文档 | `TxtLoader` |
| `TextSplitter` | 将文档切分为文本块 | `SimpleSplitter` |
| `Embedder` | 将文本转为向量 | `LocalEmbedder` (bge-small-zh) / `MockEmbedder` |
| `VectorStore` | 存储向量并支持相似度搜索 | `FileStore` (JSON 持久化) |
| `Retriever` | 根据查询检索相关文档 | `FileRetriever` |
| `Generator` | 基于上下文生成回答 | `OpenAiGenerator` (DeepSeek/OpenAI) |

## 目录结构

```
rag-mbt/
├── cmd/main/
│   ├── main.mbt              # 可运行示例入口
│   └── moon.pkg.json
├── docs/                     # 示例知识库（txt 文档）
│   ├── moonbit.txt
│   ├── rag.txt
│   └── vector_db.txt
├── file_io.c                 # C FFI（文件 I/O + subprocess）
├── types.mbt                 # 核心数据类型
├── traits.mbt                # 6 大 Trait 定义
├── loader.mbt                # TxtLoader 实现
├── splitter.mbt              # SimpleSplitter 实现
├── embedder.mbt              # MockEmbedder（演示用）
├── local_embedder.mbt        # LocalEmbedder（bge-small-zh 本地模型）
├── store.mbt                 # InMemoryStore + cosine_sim
├── file_store.mbt            # FileStore（JSON 持久化）
├── retriever.mbt             # SimpleRetriever
├── file_retriever.mbt        # FileRetriever
├── generator.mbt             # MockGenerator（演示用）
├── openai_backend.mbt        # OpenAiGenerator（DeepSeek/OpenAI API）
├── pipeline.mbt              # RAGPipeline Builder 编排
├── moon.mod.json             # 模块配置
└── moon.pkg.json             # 包配置
```

## 环境要求

| 依赖 | 版本 | 用途 |
|------|------|------|
| [MoonBit](https://www.moonbitlang.com/) | ≥ 0.1.20260608 | 编译器 |
| Python | ≥ 3.13 | 嵌入模型 / LLM 调用 |
| [sentence-transformers](https://sbert.net/) | latest | 本地嵌入模型 |
| [openai](https://pypi.org/project/openai/) | latest | LLM API 调用 |

## 快速开始

### 1. 安装 MoonBit

```bash
# 使用官方安装脚本
curl -fsSL https://cli.moonbitlang.com/install/unix.sh | bash

# 验证
moon version
```

### 2. 安装 Python 依赖

```bash
# 安装 Python 3.13+（推荐使用 Homebrew）
brew install python@3.13

# 安装 Python 库
pip3.13 install sentence-transformers openai
```

### 3. 下载嵌入模型（首次运行自动下载，也可手动下载）

```bash
export HF_ENDPOINT=https://hf-mirror.com  # 国内镜像加速
python3.13 -c "
from sentence_transformers import SentenceTransformer
SentenceTransformer('BAAI/bge-small-zh')
"
```

### 4. 配置 API Key

在项目根目录创建 `config.json`（已被 .gitignore 忽略）：

```json
{
  "api_key": "your-api-key-here",
  "base_url": "https://api.deepseek.com",
  "embedding_model": "deepseek-embedding",
  "chat_model": "deepseek-chat"
}
```

> 支持 OpenAI 兼容的任何 API，如 DeepSeek、Moonshot、通义千问等。

### 5. 构建并运行

```bash
cd rag-mbt
moon build --target native cmd/main
moon run --target native cmd/main
```

## 使用示例

### 基础用法

```moonbit
let rag = @ragmbt.RAGPipeline::builder()
  .with_loader(@ragmbt.TxtLoader::new("docs/"))
  .with_splitter(@ragmbt.SimpleSplitter::new(chunk_size=200, chunk_overlap=30))
  .with_embedder(@ragmbt.LocalEmbedder::new())                    // 本地 bge-small-zh
  .with_data_dir("rag_data")                                     // 向量持久化目录
  .with_generator(@ragmbt.OpenAiGenerator::new(api_key, base_url=base_url))  // DeepSeek API
  .build()

// 阶段一：构建索引
rag.index("")

// 阶段二：检索 + 生成
let result = rag.query("什么是 MoonBit？", top_k=3)
println(result.answer)
```

### 使用 Mock 组件（无需 API，用于演示）

```moonbit
let rag = @ragmbt.RAGPipeline::builder()
  .with_loader(@ragmbt.TxtLoader::new("docs/"))
  .with_splitter(@ragmbt.SimpleSplitter::new())
  .with_embedder(@ragmbt.MockEmbedder::new(dimension=32))   // 哈希向量
  .with_data_dir("rag_data")
  .with_generator(@ragmbt.MockGenerator::new())              // 拼接上下文
  .build()
```

### 自定义组件

实现任意 Trait 即可替换组件：

```moonbit
// 自定义 Embedder
struct MyEmbedder {
  api_key : String
}

impl Embedder for MyEmbedder with embed_documents(self : MyEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  // 你的实现
}

impl Embedder for MyEmbedder with embed_query(self : MyEmbedder, query : String) -> Array[Double] {
  // 你的实现
}
```

## 运行效果

```
╔══════════════════════════════════════════╗
║    🚀 rag-mbt: RAG 2阶段6模块演示       ║
║    MoonBit 原生 RAG 库                  ║
║    Embedder: bge-small-zh (本地)        ║
║    Generator: DeepSeek API              ║
╚══════════════════════════════════════════╝

✅ Pipeline 构建完成

📚 阶段一：构建索引
  [1/4] 加载文档... ✅ 加载了 5 个文档
  [2/4] 切分文档... ✅ 切分为 5 个块
  [3/4] 生成向量嵌入... ✅ 生成了 5 个嵌入向量（维度=512）
  [4/4] 存储到向量数据库... ✅ 已存储 5 个向量

🔍 阶段二：检索 + 生成
  [5/6] 检索相关文档... ✅ 检索到 3 条相关结果
    [来源 1] score=0.8372  MoonBit 是一种专为 WebAssembly...
    [来源 2] score=0.8176  MoonBit 支持多后端编译...
    [来源 3] score=0.7980  MoonBit 的 trait 系统支持特设多态...

  [6/6] 生成回答... ✅ 生成完成

📝 结果:
MoonBit 是一种专为 WebAssembly 设计的现代编程语言，由 IDEA 研究院张宏波团队开发...
```

## 技术实现

### Python 互操作

项目通过 C FFI 的 `popen()` 子进程方式调用 Python，避免原生 FFI 的内存问题：

1. MoonBit 构造 Python 脚本和输入数据
2. C FFI 启动 Python 子进程执行脚本
3. Python 通过 stdin 接收输入，stdout 返回 JSON 结果
4. MoonBit 解析 JSON 获取结果

### 向量持久化

`FileStore` 将向量数据以 JSON 格式持久化到 `rag_data/vectors.json`，重启后自动加载。

## 配置说明

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `chunk_size` | 500 | 文本切分块大小 |
| `chunk_overlap` | 50 | 切分重叠长度 |
| `top_k` | 3 | 检索返回的文档数 |
| `model_name` | `BAAI/bge-small-zh` | 本地嵌入模型 |
| `data_dir` | `rag_data` | 向量存储目录 |

## 许可证

[MIT](LICENSE)
