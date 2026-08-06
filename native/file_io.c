// file_io.c - MoonBit native FFI 文件 I/O
#include "moonbit.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>

// UTF-16 (MoonBit string) 转 UTF-8 C string
static char* mb_to_cstr(moonbit_string_t ms) {
  int32_t len = Moonbit_array_length(ms);
  // UTF-8 最多 4 字节 per 字符，分配足够空间
  char* cstr = (char*)malloc(len * 4 + 1);
  int j = 0;
  for (int i = 0; i < len; i++) {
    uint16_t c = ms[i];
    if (c < 0x80) {
      cstr[j++] = (char)c;
    } else if (c < 0x800) {
      cstr[j++] = (char)(0xC0 | (c >> 6));
      cstr[j++] = (char)(0x80 | (c & 0x3F));
    } else {
      cstr[j++] = (char)(0xE0 | (c >> 12));
      cstr[j++] = (char)(0x80 | ((c >> 6) & 0x3F));
      cstr[j++] = (char)(0x80 | (c & 0x3F));
    }
  }
  cstr[j] = '\0';
  return cstr;
}

// UTF-8 C string 转 UTF-16 MoonBit string
static moonbit_string_t cstr_to_mb(const char* cstr, int32_t len) {
  // 先计算 UTF-16 字符数
  int32_t utf16_len = 0;
  int i = 0;
  while (i < len) {
    unsigned char c = (unsigned char)cstr[i];
    if (c < 0x80) {
      i++;
    } else if (c < 0xC0) {
      i += 2;
    } else if (c < 0xE0) {
      i += 2;
    } else if (c < 0xF0) {
      i += 3;
    } else {
      i += 4;
    }
    utf16_len++;
  }

  moonbit_string_t ms = moonbit_make_string(utf16_len, 0);
  int j = 0;
  i = 0;
  while (i < len && j < utf16_len) {
    unsigned char c = (unsigned char)cstr[i];
    if (c < 0x80) {
      ms[j++] = (uint16_t)c;
      i++;
    } else if (c < 0xC0) {
      // 无效的 UTF-8 序列
      ms[j++] = (uint16_t)'?';
      i++;
    } else if (c < 0xE0) {
      uint16_t ch = ((c & 0x1F) << 6) | ((unsigned char)cstr[i+1] & 0x3F);
      ms[j++] = ch;
      i += 2;
    } else if (c < 0xF0) {
      uint16_t ch = ((c & 0x0F) << 12) | (((unsigned char)cstr[i+1] & 0x3F) << 6) | ((unsigned char)cstr[i+2] & 0x3F);
      ms[j++] = ch;
      i += 3;
    } else {
      // 4字节 UTF-8 (emoji等)，简化处理
      ms[j++] = (uint16_t)'?';
      i += 4;
    }
  }
  return ms;
}

// 读取整个文件，返回内容（MoonBit string），失败返回空字符串
moonbit_string_t fs_read_all(moonbit_string_t path) {
  char* c_path = mb_to_cstr(path);
  FILE* f = fopen(c_path, "rb");
  free(c_path);
  if (!f) {
    return moonbit_make_string(0, 0);
  }
  fseek(f, 0, SEEK_END);
  long size = ftell(f);
  fseek(f, 0, SEEK_SET);
  if (size <= 0) {
    fclose(f);
    return moonbit_make_string(0, 0);
  }
  char* buf = (char*)malloc(size + 1);
  size_t read = fread(buf, 1, size, f);
  fclose(f);
  buf[read] = '\0';
  moonbit_string_t result = cstr_to_mb(buf, (int32_t)read);
  free(buf);
  return result;
}

// 写入文件，返回写入字节数
int32_t fs_write_all(moonbit_string_t path, moonbit_string_t data) {
  char* c_path = mb_to_cstr(path);
  FILE* f = fopen(c_path, "wb");
  free(c_path);
  if (!f) return 0;
  // 转换为 UTF-8 再写入（支持中文,之前只写 ASCII 导致中文丢失）
  char* c_data = mb_to_cstr(data);
  size_t data_len = strlen(c_data);
  size_t written = fwrite(c_data, 1, data_len, f);
  free(c_data);
  fclose(f);
  return (int32_t)written;
}

// 检查文件是否存在
int32_t fs_exists(moonbit_string_t path) {
  char* c_path = mb_to_cstr(path);
  FILE* f = fopen(c_path, "rb");
  free(c_path);
  if (f) {
    fclose(f);
    return 1;
  }
  return 0;
}

// 删除文件
int32_t fs_remove_file(moonbit_string_t path) {
  char* c_path = mb_to_cstr(path);
  int result = remove(c_path);
  free(c_path);
  return result == 0 ? 1 : 0;
}

// 确保目录存在
int32_t fs_ensure_dir(moonbit_string_t path) {
  char* c_path = mb_to_cstr(path);
  int result = mkdir(c_path, 0755);
  free(c_path);
  return result == 0 || errno == EEXIST ? 1 : 0;
}

// 执行 Python 脚本，通过 stdin 传输入，返回 stdout
moonbit_string_t run_python_script(moonbit_string_t cmd, moonbit_string_t script, moonbit_string_t input) {
  char* c_cmd = mb_to_cstr(cmd);
  char* c_script = mb_to_cstr(script);
  char* c_input = mb_to_cstr(input);

  // 写 script 到临时文件
  FILE* script_tmp = tmpfile();
  if (!script_tmp) {
    free(c_cmd); free(c_script); free(c_input);
    return moonbit_make_string(0, 0);
  }
  fputs(c_script, script_tmp);
  fflush(script_tmp);
  rewind(script_tmp);

  // 写 input 到临时文件
  FILE* input_tmp = tmpfile();
  if (!input_tmp) {
    fclose(script_tmp);
    free(c_cmd); free(c_script); free(c_input);
    return moonbit_make_string(0, 0);
  }
  fputs(c_input, input_tmp);
  fflush(input_tmp);
  rewind(input_tmp);

  // 构造命令：python3 /dev/fd/SCRIPT_FD < /dev/fd/INPUT_FD
  char command[512];
  snprintf(command, sizeof(command), "%s /dev/fd/%d < /dev/fd/%d",
           c_cmd, fileno(script_tmp), fileno(input_tmp));

  FILE* output_pipe = popen(command, "r");
  if (!output_pipe) {
    fclose(input_tmp);
    fclose(script_tmp);
    free(c_cmd); free(c_script); free(c_input);
    return moonbit_make_string(0, 0);
  }

  // 读取输出
  char* output = NULL;
  size_t output_size = 0;
  size_t output_cap = 0;
  char buf[4096];
  size_t n;
  while ((n = fread(buf, 1, sizeof(buf), output_pipe)) > 0) {
    if (output_size + n > output_cap) {
      output_cap = (output_size + n) * 2;
      output = (char*)realloc(output, output_cap);
    }
    memcpy(output + output_size, buf, n);
    output_size += n;
  }
  pclose(output_pipe);

  fclose(input_tmp);
  fclose(script_tmp);
  free(c_cmd); free(c_script); free(c_input);

  if (!output || output_size == 0) {
    if (output) free(output);
    return moonbit_make_string(0, 0);
  }

  moonbit_string_t result = cstr_to_mb(output, (int32_t)output_size);
  free(output);
  return result;
}

// 列出目录下所有 .txt 文件，返回文件名列表（每行一个，不含目录前缀）
// 目录不存在或为空时返回空字符串
#include <dirent.h>
moonbit_string_t fs_list_txt_files(moonbit_string_t path) {
  char* c_path = mb_to_cstr(path);
  DIR* dir = opendir(c_path);
  free(c_path);
  if (!dir) {
    return moonbit_make_string(0, 0);
  }
  char* result = NULL;
  size_t len = 0, cap = 0;
  struct dirent* entry;
  while ((entry = readdir(dir)) != NULL) {
    const char* name = entry->d_name;
    size_t name_len = strlen(name);
    // 只收集 .txt 文件
    if (name_len < 4 || strcmp(name + name_len - 4, ".txt") != 0) {
      continue;
    }
    if (len + name_len + 1 > cap) {
      cap = (len + name_len + 1) * 2 + 16;
      result = (char*)realloc(result, cap);
    }
    memcpy(result + len, name, name_len);
    len += name_len;
    result[len++] = '\n';
  }
  closedir(dir);
  if (!result || len == 0) {
    if (result) free(result);
    return moonbit_make_string(0, 0);
  }
  result[len] = '\0';
  moonbit_string_t ms = cstr_to_mb(result, (int32_t)len);
  free(result);
  return ms;
}

// 从 stdin 读取一行(去掉末尾换行符),EOF 或读取失败返回空字符串
// prompt 参数会先打印到 stdout(不换行),用于交互式提示符
moonbit_string_t fs_read_line(moonbit_string_t prompt) {
  char* p = mb_to_cstr(prompt);
  fputs(p, stdout);
  free(p);
  fflush(stdout);
  char buf[4096];
  if (fgets(buf, sizeof(buf), stdin) == NULL) {
    return moonbit_make_string(0, 0);
  }
  // 去掉末尾换行符
  int len = strlen(buf);
  while (len > 0 && (buf[len-1] == '\n' || buf[len-1] == '\r')) {
    buf[--len] = '\0';
  }
  return cstr_to_mb(buf, len);
}
