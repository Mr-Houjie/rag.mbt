// ============================================================
// OpenAI Backend - OpenAI API 实现
// 需要: pip install openai + API Key
// ============================================================

struct OpenAiEmbedder {
  api_key : String
  model : String
  base_url : String
}

pub fn OpenAiEmbedder::new(api_key : String, model~ : String = "deepseek-embedding", base_url~ : String = "https://api.deepseek.com") -> OpenAiEmbedder {
  { api_key, model, base_url, }
}

impl Embedder for OpenAiEmbedder with embed_documents(self : OpenAiEmbedder, texts : Array[String]) -> Array[Array[Double]] {
  @python.init_py()
  
  let openai = @python.pyimport("openai").unwrap()
  
  try {
    match openai.get_attr("OpenAI") {
      None => {
        println("Error: OpenAI class not found")
        []
      }
      Some(@python.PyObjectEnum::PyCallable(openai_class)) => {
        let args = @python.PyTuple::new(0)
        let kwargs = @python.PyDict::new()
        kwargs.set("api_key", @python.PyString::from(self.api_key))
        kwargs.set("base_url", @python.PyString::from(self.base_url))
        
        match openai_class.invoke(args~, kwargs~) {
          None => {
            println("Error: Failed to create OpenAI client")
            []
          }
          Some(client_enum) => {
            let client_obj = self.py_obj_from_enum(client_enum)
            
            match client_obj.get_attr("embeddings") {
              None => {
                println("Error: embeddings attribute not found")
                []
              }
              Some(embeddings_enum) => {
                let embeddings_obj = self.py_class_from_enum(embeddings_enum)
                
                match embeddings_obj.get_attr("create") {
                  None => {
                    println("Error: create method not found")
                    []
                  }
                  Some(@python.PyObjectEnum::PyCallable(create_func)) => {
                    let py_texts = @python.PyList::new()
                    for i = 0; i < texts.length(); i = i + 1 {
                      py_texts.append(@python.PyString::from(texts[i]))
                    }
                    
                    let args = @python.PyTuple::new(0)
                    let kwargs = @python.PyDict::new()
                    kwargs.set("model", @python.PyString::from(self.model))
                    kwargs.set("input", py_texts)
                    
                    match create_func.invoke(args?=Some(args), kwargs?=Some(kwargs)) {
                      None => {
                        println("Error: Failed to call create")
                        []
                      }
                      Some(response_enum) => {
                        let response_obj = self.py_class_from_enum(response_enum)
                        self.extract_embeddings(response_obj)
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

fn OpenAiEmbedder::py_obj_from_enum(self : OpenAiEmbedder, enum_val : @python.PyObjectEnum) -> @python.PyObject {
  match enum_val {
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
}

fn OpenAiEmbedder::py_class_from_enum(self : OpenAiEmbedder, enum_val : @python.PyObjectEnum) -> @python.PyObject {
  match enum_val {
    @python.PyObjectEnum::PyClass(obj) => obj
    _ => abort("Expected PyClass")
  }
}

fn OpenAiEmbedder::extract_embeddings(self : OpenAiEmbedder, response_obj : @python.PyObject) -> Array[Array[Double]] {
  match response_obj.get_attr("data") {
    None => []
    Some(@python.PyObjectEnum::PyList(data_list)) => {
      let embeddings : Array[Array[Double]] = []
      for i = 0; i < data_list.len(); i = i + 1 {
        match data_list.get(i) {
          None => continue
          Some(item_enum) => {
            let item_obj = self.py_class_from_enum(item_enum)
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

impl Embedder for OpenAiEmbedder with embed_query(self : OpenAiEmbedder, query : String) -> Array[Double] {
  let embeddings = self.embed_documents([query])
  if embeddings.length() > 0 {
    embeddings[0]
  } else {
    []
  }
}

// ============================================================
// OpenAI Generator
// ============================================================

struct OpenAiGenerator {
  api_key : String
  model : String
  system_prompt : String
  base_url : String
}

pub fn OpenAiGenerator::new(api_key : String, model~ : String = "deepseek-chat", system_prompt~ : String = "你是一个基于检索增强生成的 AI 助手。请根据提供的上下文资料回答用户问题。如果上下文中没有相关信息，请如实说明。", base_url~ : String = "https://api.deepseek.com") -> OpenAiGenerator {
  { api_key, model, system_prompt, base_url, }
}

impl Generator for OpenAiGenerator with generate(self : OpenAiGenerator, query : String, context : Array[Chunk]) -> GenerationResult {
  let mut context_text = ""
  for i = 0; i < context.length(); i = i + 1 {
    context_text = context_text + "[来源 " + (i + 1).to_string() + "] " + context[i].text + "\n"
  }
  
  @python.init_py()
  
  let openai = @python.pyimport("openai").unwrap()
  
  try {
    match openai.get_attr("OpenAI") {
      None => GenerationResult::new("Error: OpenAI class not found", context)
      Some(@python.PyObjectEnum::PyCallable(openai_class)) => {
        let args = @python.PyTuple::new(0)
        let kwargs = @python.PyDict::new()
        kwargs.set("api_key", @python.PyString::from(self.api_key))
        kwargs.set("base_url", @python.PyString::from(self.base_url))
        
        match openai_class.invoke(args~, kwargs~) {
          None => GenerationResult::new("Error: Failed to create OpenAI client", context)
          Some(client_enum) => {
            let client_obj = match client_enum {
              @python.PyObjectEnum::PyClass(obj) => obj
              _ => return GenerationResult::new("Error: client is not an object", context)
            }
            
            match client_obj.get_attr("chat") {
              None => GenerationResult::new("Error: chat not found", context)
              Some(chat_enum) => {
                let chat_obj = match chat_enum {
                  @python.PyObjectEnum::PyClass(obj) => obj
                  _ => return GenerationResult::new("Error: chat is not an object", context)
                }
                
                match chat_obj.get_attr("completions") {
                  None => GenerationResult::new("Error: completions not found", context)
                  Some(completions_enum) => {
                    let completions_obj = match completions_enum {
                      @python.PyObjectEnum::PyClass(obj) => obj
                      _ => return GenerationResult::new("Error: completions is not an object", context)
                    }
                    
                    match completions_obj.get_attr("create") {
                      None => GenerationResult::new("Error: create not found", context)
                      Some(@python.PyObjectEnum::PyCallable(create_func)) => {
                        let py_messages = @python.PyList::new()
                        
                        let sys_msg = @python.PyDict::new()
                        sys_msg.set("role", @python.PyString::from("system"))
                        sys_msg.set("content", @python.PyString::from(self.system_prompt))
                        py_messages.append(sys_msg)
                        
                        let user_content = "参考资料：\n" + context_text + "\n问题：" + query
                        let user_msg = @python.PyDict::new()
                        user_msg.set("role", @python.PyString::from("user"))
                        user_msg.set("content", @python.PyString::from(user_content))
                        py_messages.append(user_msg)
                        
                        let args2 = @python.PyTuple::new(0)
                        let kwargs2 = @python.PyDict::new()
                        kwargs2.set("model", @python.PyString::from(self.model))
                        kwargs2.set("messages", py_messages)
                        
                        match create_func.invoke(args?=Some(args2), kwargs?=Some(kwargs2)) {
                          None => GenerationResult::new("Error: Failed to call create", context)
                          Some(response_enum) => {
                            let response_obj = match response_enum {
                              @python.PyObjectEnum::PyClass(obj) => obj
                              _ => return GenerationResult::new("Error: response is not an object", context)
                            }
                            self.extract_content(response_obj, context)
                          }
                        }
                      }
                      _ => GenerationResult::new("Error: create is not callable", context)
                    }
                  }
                }
              }
            }
          }
        }
      }
      _ => GenerationResult::new("Error: OpenAI is not callable", context)
    }
  } catch {
    _ => GenerationResult::new("Error: Exception during OpenAI call", context)
  }
}

fn OpenAiGenerator::extract_content(self : OpenAiGenerator, response_obj : @python.PyObject, context : Array[Chunk]) -> GenerationResult {
  match response_obj.get_attr("choices") {
    None => GenerationResult::new("Error: choices not found", context)
    Some(@python.PyObjectEnum::PyList(choices_list)) => {
      match choices_list.get(0) {
        None => GenerationResult::new("Error: choices[0] not found", context)
        Some(choice_enum) => {
          let choice_obj = match choice_enum {
            @python.PyObjectEnum::PyClass(obj) => obj
            _ => return GenerationResult::new("Error: choice is not an object", context)
          }
          match choice_obj.get_attr("message") {
            None => GenerationResult::new("Error: message not found", context)
            Some(message_enum) => {
              let message_obj = match message_enum {
                @python.PyObjectEnum::PyClass(obj) => obj
                _ => return GenerationResult::new("Error: message is not an object", context)
              }
              match message_obj.get_attr("content") {
                None => GenerationResult::new("Error: content not found", context)
                Some(@python.PyObjectEnum::PyString(content)) => GenerationResult::new(content.to_string(), context)
                _ => GenerationResult::new("Error: content is not a string", context)
              }
            }
          }
        }
      }
    }
    _ => GenerationResult::new("Error: choices is not a list", context)
  }
}