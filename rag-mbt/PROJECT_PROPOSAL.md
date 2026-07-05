# 2026 MoonBit 国产基础软件开源大赛 项目申报书

## 一、项目名称与 GitHub 仓库

- **项目名称**：rag.mbt（基于 MoonBit 的 RAG 检索增强生成库）
- **GitHub 仓库**：https://github.com/Mr-Houjie/rag.mbt
- **许可证**：MIT ｜ **语言**：MoonBit ≥ 0.1.20260608

## 二、项目简介

`rag.mbt` 是一个使用 MoonBit 语言原生实现的 RAG（检索增强生成）库，将 RAG 流程拆解为 **2 阶段 6 模块**，通过 Trait 系统提供可插拔的组件架构，为 MoonBit 生态提供开箱即用的 LLM 应用基础设施。

- **阶段一（索引构建）**：加载 → 切分 → 嵌入 → 存储
- **阶段二（检索生成）**：检索 → 生成

核心特色：MoonBit 原生实现、Builder 模式编排、集成 BAAI/bge-small-zh 本地嵌入模型、支持 DeepSeek/OpenAI 兼容 API、JSON 文件持久化。

## 三、项目方向与适用场景

**大赛方向归属**：对应大赛"**应用生态**"方向（可展示、可复用的生态项目），同时契合赛事重点鼓励的"**AI Agent 工程化开发**"细分方向。RAG 是 AI Agent 的核心外部知识能力，本项目为 MoonBit 生态补齐了这一关键基础设施。

**定位**：MoonBit 生态的 LLM 应用开发基础库，填补 MoonBit 在 RAG / 向量检索方向的空白。

**适用场景**：
- 企业知识库问答与文档检索
- AI Agent 的外部知识记忆
- 垂直领域（法律/医疗/技术文档）精准问答
- RAG 算法教学与研究平台

## 四、核心功能

1. **6 大可插拔 Trait**：DocumentLoader、TextSplitter、Embedder、VectorStore、Retriever、Generator
2. **默认实现**：TxtLoader、SimpleSplitter、LocalEmbedder（bge-small-zh）、FileStore（JSON 持久化）、FileRetriever、OpenAiGenerator
3. **Pipeline 编排**：`RAGPipeline::builder()` 流式组装组件
4. **向量持久化**：余弦相似度搜索 + JSON 文件存储
5. **多语言互操作**：C FFI 文件 I/O + Python 子进程调用嵌入模型与 LLM
6. **工程化**：单元测试 + GitHub Actions CI

## 五、项目性质

**原创实现**（非移植）。代码 100% 由作者独立编写，架构思想借鉴 LangChain 与 LlamaIndex 的设计范式（属公开方法论参考，非代码复制）。

**原创工程工作**：基于 MoonBit Trait 系统的接口设计、MoonBit ↔ C FFI 文件 I/O 封装、MoonBit ↔ Python 子进程通信协议、FileStore 持久化方案、Builder 模式的 MoonBit 实现。

**外部依赖**：BAAI/bge-small-zh（MIT）、sentence-transformers（Apache-2.0）、openai SDK（MIT），均遵守相应许可证。
