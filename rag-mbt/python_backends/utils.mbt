// ============================================================
// python_backends 工具函数
// ============================================================

pub fn read_env(key : String) -> String {
  let os = @python.pyimport("os")
  let environ = os.attr("environ")
  let result = environ.call_method("get", (key, ""))
  result.to_string()
}
