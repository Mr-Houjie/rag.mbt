// ============================================================
// OpenAI Backend - OpenAI API 实现（直接在 ragmbt 包中）
// 需要: C 编译器 + pip install openai + OPENAI_API_KEY
// ============================================================

struct OpenAiEmbedder {
  api_key : String
  model : String
}

pub fn OpenAiEmbedder::new(api_key : String, model~ : String = "text-embedding-3-small") -> OpenAiEmbedder {
  { api_key, model, }
}

impl Embedder for OpenAiEmbedder with embed_documents(self : OpenAiEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  // 初始化 Python
  @python.init_py()
  
  let openai = @python.pyimport("openai").unwrap()
  
  // 创建 OpenAI 客户端 - 使用更简单的 Python 代码
  let code = "
import openai
client = openai.OpenAI(api_key='\{self.api_key}')
response = client.embeddings.create(model='\{self.model}', input=[])
"
  
  // 使用 exec 方式可能更简单
  // 但由于 Kaida-Amethyst/python 包的限制，我们需要直接使用对象
  
  try {
    match openai.get_attr("OpenAI") {
      None => {
        println("Error: OpenAI class not found")
        []
      }
      Some(@python.PyObjectEnum::PyCallable(openai_class)) => {
        // 构造参数 - 使用 PyTuple
        let args = @python.PyTuple::new(0)
        let kwargs = @python.PyDict::new()
        kwargs.set("api_key", @python.PyString::from(self.api_key))
        
        // 调用 OpenAI() 构造函数
        match openai_class.invoke(args~, kwargs~) {
          None => {
            println("Error: Failed to create OpenAI client")
            []
          }
          Some(client_enum) => {
            // 获取 PyObject 以便调用 get_attr
            let client_obj = match client_enum {
              @python.PyObjectEnum::PyClass(obj) => obj
              @python.PyObjectEnum::PyCallable(c) => c.obj()
              @python.PyObjectEnum::PyDict(d) => d.obj()
              @python.PyObjectEnum::PyList(l) => l.obj()
              @python.PyObjectEnum::PyModule(m) => m.obj()
              @python.PyObjectEnum::PyString(s) => s.obj()
              @python.PyObjectEnum::PyTuple(t) => t.obj()
              @python.PyObjectEnum::PyInteger(i) => i.obj()
              @python.PyObjectEnum::PyFloat(f) => f.obj()
              @python.PyObjectEnum::PyBool(b) => b.obj()
            }
            
            // 获取 embeddings.create 方法
            match client_obj.get_attr("embeddings") {
              None => {
                println("Error: embeddings attribute not found")
                []
              }
              Some(embeddings_enum) => {
                let embeddings_obj = match embeddings_enum {
                  @python.PyObjectEnum::PyClass(obj) => obj
                  _ => {
                    println("Error: embeddings is not an object")
                    return []
                  }
                }
                
                match embeddings_obj.get_attr("create") {
                  None => {
                    println("Error: create method not found")
                    []
                  }
                  Some(@python.PyObjectEnum::PyCallable(create_func)) => {
                    // 构造 texts 列表
                    let py_texts = @python.PyList::new()
                    for text in texts {
                      py_texts.append(@python.PyString::from(text))
                    }
                    
                    // 构造参数
                    let args2 = @python.PyTuple::new(0)
                    let kwargs2 = @python.PyDict::new()
                    kwargs2.set("model", @python.PyString::from(self.model))
                    kwargs2.set("input", py_texts)
                    
                    // 调用 create 方法
                    match create_func.invoke(args2~, kwargs2~) {
                      None => {
                        println("Error: Failed to call create")
                        []
                      }
                      Some(response_enum) => {
                        let response_obj = match response_enum {
                          @python.PyObjectEnum::PyClass(obj) => obj
                          _ => {
                            println("Error: response is not an object")
                            return []
                          }
                        }
                        
                        // 获取 response.data 属性
                        match response_obj.get_attr("data") {
                          None => {
                            println("Error: data attribute not found")
                            []
                          }
                          Some(@python.PyObjectEnum::PyList(data_list)) => {
                            // 提取 embeddings
                            let embeddings : Array[Array[Double]] = []
                            for i = 0; i < data_list.len(); i = i + 1 {
                              match data_list.get(i) {
                                None => continue
                                Some(item_enum) => {
                                  let item_obj = match item_enum {
                                    @python.PyObjectEnum::PyClass(obj) => obj
                                    _ => continue
                                  }
                                  match item_obj.get_attr("embedding") {
                                    None => continue
                                    Some(@python.PyObjectEnum::PyList(emb_list)) => {
                                      let emb : Array[Double] = []
                                      for j = 0; j < emb_list.len(); j = j + 1 {
                                        match emb_list.get(j) {
                                          None => continue
                                          Some(@python.PyObjectEnum::PyFloat(f)) => emb.push(f.to_double())
                                          Some(@python.PyObjectEnum::PyInteger(n)) => emb.push(n.to_double())
                                          _ => continue
                                        }
                                      }
                                      embeddings.push(emb)
                                    }
                                    _ => continue
                                  }
                                }
                              }
                            }
                            embeddings
                          }
                          _ => []
                        }
                      }
                    }
                  }
                  _ => []
                }
              }
            }
          }
        }
      }
      _ => []
    }
  } catch {
    _ => {
      println("Error: Exception during OpenAI call")
      []
    }
  }
}

impl Embedder for OpenAiEmbedder with embed_query(self : OpenAiEmbedder, query : String) -> Array[Double] {
  let embeddings = self.embed_documents([query])
  if embeddings.length() > 0 {
    embeddings[0]
  } else {
    []
  }
}

struct OpenAiGenerator {
  api_key : String
  model : String
  system_prompt : String
}

pub fn OpenAiGenerator::new(api_key : String, model~ : String = "gpt-4o-mini", system_prompt~ : String = "你是一个基于检索增强生成的 AI 助手。请根据提供的上下文资料回答用户问题。如果上下文中没有相关信息，请如实说明。") -> OpenAiGenerator {
  { api_key, model, system_prompt, }
}

impl Generator for OpenAiGenerator with generate(self : OpenAiGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  // 构建上下文文本
  let mut context_text = ""
  for i = 0; i < context.length(); i = i + 1 {
    context_text = context_text + "[来源 " + (i + 1).to_string() + "] " + context[i].text + "\n"
  }
  
  // 初始化 Python
  @python.init_py()
  
  let openai = @python.pyimport("openai").unwrap()
  
  try {
    match openai.get_attr("OpenAI") {
      None => {
        println("Error: OpenAI class not found")
        GenerationResult::new("Error: OpenAI class not found", context)
      }
      Some(@python.PyObjectEnum::PyCallable(openai_class)) => {
        // 构造参数
        let args = @python.PyTuple::new(0)
        let kwargs = @python.PyDict::new()
        kwargs.set("api_key", @python.PyString::from(self.api_key))
        
        // 调用 OpenAI() 构造函数
        match openai_class.invoke(args~, kwargs~) {
          None => {
            println("Error: Failed to create OpenAI client")
            GenerationResult::new("Error: Failed to create OpenAI client", context)
          }
          Some(client_enum) => {
            let client_obj = match client_enum {
              @python.PyObjectEnum::PyClass(obj) => obj
              _ => {
                println("Error: client is not an object")
                return GenerationResult::new("Error: client is not an object", context)
              }
            }
            
            // 获取 chat.completions.create
            match client_obj.get_attr("chat") {
              None => {
                println("Error: chat attribute not found")
                GenerationResult::new("Error: chat attribute not found", context)
              }
              Some(chat_enum) => {
                let chat_obj = match chat_enum {
                  @python.PyObjectEnum::PyClass(obj) => obj
                  _ => {
                    println("Error: chat is not an object")
                    return GenerationResult::new("Error: chat is not an object", context)
                  }
                }
                
                match chat_obj.get_attr("completions") {
                  None => {
                    println("Error: completions attribute not found")
                    GenerationResult::new("Error: completions attribute not found", context)
                  }
                  Some(completions_enum) => {
                    let completions_obj = match completions_enum {
                      @python.PyObjectEnum::PyClass(obj) => obj
                      _ => {
                        println("Error: completions is not an object")
                        return GenerationResult::new("Error: completions is not an object", context)
                      }
                    }
                    
                    match completions_obj.get_attr("create") {
                      None => {
                        println("Error: create method not found")
                        GenerationResult::new("Error: create method not found", context)
                      }
                      Some(@python.PyObjectEnum::PyCallable(create_func)) => {
                        // 构造 messages 列表
                        let py_messages = @python.PyList::new()
                        
                        // system message
                        let sys_msg = @python.PyDict::new()
                        sys_msg.set("role", @python.PyString::from("system"))
                        sys_msg.set("content", @python.PyString::from(self.system_prompt))
                        py_messages.append(sys_msg)
                        
                        // user message
                        let user_content = "参考资料：\n" + context_text + "\n问题：" + query
                        let user_msg = @python.PyDict::new()
                        user_msg.set("role", @python.PyString::from("user"))
                        user_msg.set("content", @python.PyString::from(user_content))
                        py_messages.append(user_msg)
                        
                        // 构造参数
                        let args2 = @python.PyTuple::new(0)
                        let kwargs2 = @python.PyDict::new()
                        kwargs2.set("model", @python.PyString::from(self.model))
                        kwargs2.set("messages", py_messages)
                        
                        // 调用 create 方法
                        match create_func.invoke(args2~, kwargs2~) {
                          None => {
                            println("Error: Failed to call create")
                            GenerationResult::new("Error: Failed to call create", context)
                          }
                          Some(response_enum) => {
                            let response_obj = match response_enum {
                              @python.PyObjectEnum::PyClass(obj) => obj
                              _ => {
                                println("Error: response is not an object")
                                return GenerationResult::new("Error: response is not an object", context)
                              }
                            }
                            
                            // 获取 response.choices[0].message.content
                            match response_obj.get_attr("choices") {
                              None => {
                                println("Error: choices attribute not found")
                                GenerationResult::new("Error: choices attribute not found", context)
                              }
                              Some(@python.PyObjectEnum::PyList(choices_list)) => {
                                match choices_list.get(0) {
                                  None => {
                                    println("Error: choices[0] not found")
                                    GenerationResult::new("Error: choices[0] not found", context)
                                  }
                                  Some(choice_enum) => {
                                    let choice_obj = match choice_enum {
                                      @python.PyObjectEnum::PyClass(obj) => obj
                                      _ => {
                                        println("Error: choice is not an object")
                                        return GenerationResult::new("Error: choice is not an object", context)
                                      }
                                    }
                                    match choice_obj.get_attr("message") {
                                      None => {
                                        println("Error: message attribute not found")
                                        GenerationResult::new("Error: message attribute not found", context)
                                      }
                                      Some(message_enum) => {
                                        let message_obj = match message_enum {
                                          @python.PyObjectEnum::PyClass(obj) => obj
                                          _ => {
                                            println("Error: message is not an object")
                                            return GenerationResult::new("Error: message is not an object", context)
                                          }
                                        }
                                        match message_obj.get_attr("content") {
                                          None => {
                                            println("Error: content attribute not found")
                                            GenerationResult::new("Error: content attribute not found", context)
                                          }
                                          Some(@python.PyObjectEnum::PyString(content)) => {
                                            GenerationResult::new(content.to_string(), context)
                                          }
                                          _ => {
                                            println("Error: content is not a string")
                                            GenerationResult::new("Error: content is not a string", context)
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              _ => {
                                println("Error: choices is not a list")
                                GenerationResult::new("Error: choices is not a list", context)
                              }
                            }
                          }
                        }
                      }
                      _ => {
                        println("Error: create is not callable")
                        GenerationResult::new("Error: create is not callable", context)
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      _ => {
        println("Error: OpenAI is not a callable")
        GenerationResult::new("Error: OpenAI is not a callable", context)
      }
    }
  } catch {
    _ => {
      println("Error: Exception during OpenAI call")
      GenerationResult::new("Error: Exception during OpenAI call", context)
    }
  }
}

// 简化版：使用 Python C API 直接调用（辅助函数）
fn py_call_openai_embed(api_key : String, model : String, texts : Array[String]) -> Array[Array[Double]] {
  @python.init_py()
  
  let openai_module = @python.pyimport("openai").unwrap()
  
  // 创建 Python 代码字符串
  let code = "
client = openai.OpenAI(api_key='\{api_key}')
texts_list = []
"
  
  // ... 这个方法可能更简单，但需要更多的 Python 绑定支持
  
  // 目前先返回空数组，后续可以优化
  []
}

fn py_call_openai_chat(api_key : String, model : String, messages : Array[(String, String)]) -> String {
  @python.init_py()
  
  // ... 同样需要更多支持
  
  "Not implemented yet"
}