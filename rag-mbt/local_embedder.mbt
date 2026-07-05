// ============================================================
// LocalEmbedder - 本地向量嵌入模型 (bge-small-zh)
// 使用 sentence-transformers Python 库，无需 API 调用
// ============================================================

struct LocalEmbedder {
  model_name : String
}

pub fn LocalEmbedder::new(model_name~ : String = "BAAI/bge-small-zh") -> LocalEmbedder {
  { model_name, }
}

impl Embedder for LocalEmbedder with embed_documents(self : LocalEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  @python.init_py()
  
  let st = @python.pyimport("sentence_transformers").unwrap()
  
  try {
    match st.get_attr("SentenceTransformer") {
      None => {
        println("Error: SentenceTransformer class not found")
        []
      }
      Some(@python.PyObjectEnum::PyCallable(st_class)) => {
        let args = @python.PyTuple::new(1)
        args.set(0, @python.PyString::from(self.model_name))
        
        match st_class.invoke(args?=Some(args), kwargs?=None) {
          None => {
            println("Error: Failed to create SentenceTransformer model")
            []
          }
          Some(model_enum) => {
            let model_obj = match model_enum {
              @python.PyObjectEnum::PyClass(obj) => obj
              _ => return []
            }
            
            // 创建 Python 列表
            let py_texts = @python.PyList::new()
            for i = 0; i < texts.length(); i = i + 1 {
              py_texts.append(@python.PyString::from(texts[i]))
            }
            
            // 调用 encode 方法
            match model_obj.get_attr("encode") {
              None => {
                println("Error: encode method not found")
                []
              }
              Some(@python.PyObjectEnum::PyCallable(encode_func)) => {
                let encode_args = @python.PyTuple::new(1)
                encode_args.set(0, py_texts)
                
                match encode_func.invoke(args?=Some(encode_args), kwargs?=None) {
                  None => {
                    println("Error: Failed to encode texts")
                    []
                  }
                  Some(result_enum) => {
                    self.extract_embeddings(result_enum)
                  }
                }
              }
              _ => []
            }
          }
        }
      }
      _ => []
    }
  } catch {
    _ => {
      println("Error: Exception during local embedding")
      []
    }
  }
}

fn LocalEmbedder::extract_embeddings(self : LocalEmbedder, result_enum : @python.PyObjectEnum) -> Array[Array[Double]] {
  try {
    // sentence-transformers 返回 numpy array
    match result_enum {
      @python.PyObjectEnum::PyClass(result_obj) => {
        match result_obj.get_attr("tolist") {
          None => []
          Some(@python.PyObjectEnum::PyCallable(tolist_func)) => {
            match tolist_func.invoke(args?=None, kwargs?=None) {
              None => []
              Some(list_enum) => {
                match list_enum {
                  @python.PyObjectEnum::PyList(embeddings_list) => {
                    let result : Array[Array[Double]] = []
                    for i = 0; i < embeddings_list.len(); i = i + 1 {
                      match embeddings_list.get(i) {
                        None => continue
                        Some(inner_enum) => {
                          match inner_enum {
                            @python.PyObjectEnum::PyList(inner_list) => {
                              let emb : Array[Double] = []
                              for j = 0; j < inner_list.len(); j = j + 1 {
                                match inner_list.get(j) {
                                  None => continue
                                  Some(@python.PyObjectEnum::PyFloat(f)) => emb.push(f.to_double())
                                  Some(@python.PyObjectEnum::PyInteger(n)) => emb.push(n.to_double())
                                  _ => continue
                                }
                              }
                              result.push(emb)
                            }
                            _ => continue
                          }
                        }
                      }
                    }
                    result
                  }
                  _ => []
                }
              }
            }
          }
          _ => []  // 处理其他 PyObjectEnum 类型
        }
      }
      @python.PyObjectEnum::PyList(embeddings_list) => {
        // 直接是列表格式
        let result : Array[Array[Double]] = []
        for i = 0; i < embeddings_list.len(); i = i + 1 {
          match embeddings_list.get(i) {
            None => continue
            Some(inner_enum) => {
              match inner_enum {
                @python.PyObjectEnum::PyList(inner_list) => {
                  let emb : Array[Double] = []
                  for j = 0; j < inner_list.len(); j = j + 1 {
                    match inner_list.get(j) {
                      None => continue
                      Some(@python.PyObjectEnum::PyFloat(f)) => emb.push(f.to_double())
                      Some(@python.PyObjectEnum::PyInteger(n)) => emb.push(n.to_double())
                      _ => continue
                    }
                  }
                  result.push(emb)
                }
                _ => continue
              }
            }
          }
        }
        result
      }
      _ => []
    }
  } catch {
    _ => []
  }
}

impl Embedder for LocalEmbedder with embed_query(self : LocalEmbedder, query : String) -> Array[Double] {
  let embeddings = self.embed_documents([query])
  if embeddings.length() > 0 {
    embeddings[0]
  } else {
    []
  }
}