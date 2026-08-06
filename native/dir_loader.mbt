// ============================================================
// DirLoader - 从目录加载真实 txt 文件（native C FFI）
// 替代根包的 TxtLoader（其返回硬编码示例文档）
// ============================================================

/// 列出目录下所有 .txt 文件名（每行一个）
#owned(dir)
pub extern "C" fn fs_list_txt_files(dir : String) -> String = "fs_list_txt_files"

/// 读取整个文件内容
#owned(path)
pub extern "C" fn fs_read_all_file(path : String) -> String = "fs_read_all"

/// 从目录加载所有 .txt 文件为 Document
pub fn load_docs_from_dir(dir : String) -> Array[@ragmbt.Document] {
  let file_list = fs_list_txt_files(dir)
  if file_list.length() == 0 {
    println("⚠️  目录 '\{dir}' 中没有找到 .txt 文件，回退到内置示例文档")
    return @ragmbt.load_static_docs()
  }
  let names = file_list.split("\n")
  let docs : Array[@ragmbt.Document] = []
  for name_view in names {
    let name = name_view.to_string()
    if name.length() == 0 {
      continue
    }
    let full_path = if dir.has_suffix("/") {
      dir + name
    } else {
      dir + "/" + name
    }
    let content = fs_read_all_file(full_path)
    if content.length() > 0 {
      docs.push(@ragmbt.Document::new(content, @ragmbt.make_meta([("source", name)])))
    } else {
      println("⚠️  跳过空文件或读取失败: '\{name}'")
    }
  }
  if docs.length() == 0 {
    println("⚠️  目录 '\{dir}' 中没有可用的文档内容，回退到内置示例文档")
    return @ragmbt.load_static_docs()
  }
  docs
}
