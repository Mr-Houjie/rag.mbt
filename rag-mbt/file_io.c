// file_io.c - MoonBit native FFI 文件 I/O
#include "moonbit.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

// UTF-16 (MoonBit string) 转 C string
static char* mb_to_cstr(moonbit_string_t ms) {
  int32_t len = Moonbit_array_length(ms);
  char* cstr = (char*)malloc(len + 1);
  for (int i = 0; i < len; i++) {
    cstr[i] = (ms[i] < 0x80) ? (char)ms[i] : '?';
  }
  cstr[len] = '\0';
  return cstr;
}

// C string 转 MoonBit string (UTF-16)
static moonbit_string_t cstr_to_mb(const char* cstr, int32_t len) {
  moonbit_string_t ms = moonbit_make_string(len, 0);
  for (int i = 0; i < len; i++) {
    ms[i] = (uint16_t)(unsigned char)cstr[i];
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
  int32_t len = Moonbit_array_length(data);
  FILE* f = fopen(c_path, "wb");
  free(c_path);
  if (!f) return 0;
  // 逐字符写入（MoonBit string 是 UTF-16）
  size_t written = 0;
  for (int i = 0; i < len; i++) {
    if (data[i] < 0x80) {
      fputc(data[i], f);
      written++;
    }
  }
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
