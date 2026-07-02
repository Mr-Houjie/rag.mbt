class $PanicError extends Error {}
function $panic() {
  throw new $PanicError();
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function $compare_int(a, b) {
  return (a >= b) - (a <= b);
}
const _M0FPB12random__seed = () => {
  if (globalThis.crypto?.getRandomValues) {
    const array = new Uint32Array(1);
    globalThis.crypto.getRandomValues(array);
    return array[0] | 0; // Convert to signed 32
  } else {
    return Math.floor(Math.random() * 0x100000000) | 0; // Fallback to Math.random
  }
};
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function $bound_check(arr, index) {
  if (index < 0 || index >= arr.length) throw new Error("Index out of bounds");
}
function $makebytes(a, b) {
  const arr = new Uint8Array(a);
  if (b !== 0) {
    arr.fill(b);
  }
  return arr;
}
const _M0MPB7JSArray4push = (arr, val) => { arr.push(val); };
function $make_array_len_and_init(a, b) {
  const arr = new Array(a);
  arr.fill(b);
  return arr;
}
function _M0TPB3MapGssE(param0, param1, param2, param3, param4, param5, param6) {
  this.entries = param0;
  this.size = param1;
  this.capacity = param2;
  this.capacity_mask = param3;
  this.grow_at = param4;
  this.head = param5;
  this.tail = param6;
}
function _M0TPB5EntryGssE(param0, param1, param2, param3, param4, param5) {
  this.prev = param0;
  this.next = param1;
  this.psl = param2;
  this.hash = param3;
  this.key = param4;
  this.value = param5;
}
function _M0TP24user9rag_2dmbt8Document(param0, param1) {
  this.content = param0;
  this.metadata = param1;
}
function _M0TP24user9rag_2dmbt5Chunk(param0, param1, param2, param3) {
  this.id = param0;
  this.text = param1;
  this.metadata = param2;
  this.embedding = param3;
}
function _M0DTPC16option6OptionGRPB5ArrayGdEE4None() {}
_M0DTPC16option6OptionGRPB5ArrayGdEE4None.prototype.$tag = 0;
const _M0DTPC16option6OptionGRPB5ArrayGdEE4None__ = new _M0DTPC16option6OptionGRPB5ArrayGdEE4None();
function _M0DTPC16option6OptionGRPB5ArrayGdEE4Some(param0) {
  this._0 = param0;
}
_M0DTPC16option6OptionGRPB5ArrayGdEE4Some.prototype.$tag = 1;
function _M0TP24user9rag_2dmbt12SearchResult(param0, param1) {
  this.chunk = param0;
  this.score = param1;
}
function _M0TP24user9rag_2dmbt16GenerationResult(param0, param1) {
  this.answer = param0;
  this.sources = param1;
}
function _M0TPB9ArrayViewGUssEE(param0, param1, param2) {
  this.buf = param0;
  this.start = param1;
  this.end = param2;
}
function _M0TP24user9rag_2dmbt13InMemoryStore(param0, param1) {
  this.chunks = param0;
  this.embeddings = param1;
}
function _M0TPB8MutLocalGdE(param0) {
  this.val = param0;
}
function _M0TP24user9rag_2dmbt14SimpleSplitter(param0, param1) {
  this.chunk_size = param0;
  this.chunk_overlap = param1;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function _M0TP24user9rag_2dmbt15SimpleRetriever(param0, param1) {
  this.embedder = param0;
  this.store = param1;
}
function _M0TP24user9rag_2dmbt7Builder(param0, param1, param2, param3, param4) {
  this.loader = param0;
  this.splitter = param1;
  this.embedder = param2;
  this.store = param3;
  this.generator = param4;
}
function _M0TP24user9rag_2dmbt11RAGPipeline(param0, param1, param2, param3, param4, param5) {
  this.loader = param0;
  this.splitter = param1;
  this.embedder = param2;
  this.store = param3;
  this.retriever = param4;
  this.generator = param5;
}
function _M0TPB8MutLocalGsE(param0) {
  this.val = param0;
}
function _M0TP24user9rag_2dmbt9TxtLoader(param0) {
  this.base_path = param0;
}
function _M0TP24user9rag_2dmbt13MockGenerator(param0) {
  this.prefix = param0;
}
function _M0TP24user9rag_2dmbt12MockEmbedder(param0) {
  this.dimension = param0;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
const _M0FPB4seed = _M0FPB12random__seed();
function _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE(msg) {
  return $panic();
}
function _M0FPB4rotl(x, r) {
  return x << r | (x >>> (32 - r | 0) | 0);
}
function _M0FPB13consume4__acc(acc, input) {
  return Math.imul(_M0FPB4rotl((acc >>> 0) + ((Math.imul(input, -1028477379) | 0) >>> 0) | 0, 17), 668265263) | 0;
}
function _M0MPB13StringBuilder13write__objectGsE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGsE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return new _M0TPB13StringBuilder("");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return _M0IP016_24default__implPB7Compare6op__geGkE(self, 56320) && _M0IP016_24default__implPB7Compare6op__leGkE(self, 57343);
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0IPC16uint166UInt16PB7Compare7compare(self, that) {
  return $compare_int(self, that);
}
function _M0IP016_24default__implPB7Compare6op__leGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) <= 0;
}
function _M0IP016_24default__implPB7Compare6op__geGkE(x, y) {
  return _M0IPC16uint166UInt16PB7Compare7compare(x, y) >= 0;
}
function _M0FPB14avalanche__acc(acc) {
  let acc$2 = acc;
  acc$2 = acc$2 ^ (acc$2 >>> 15 | 0);
  acc$2 = Math.imul(acc$2, -2048144777) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 13 | 0);
  acc$2 = Math.imul(acc$2, -1028477379) | 0;
  acc$2 = acc$2 ^ (acc$2 >>> 16 | 0);
  return acc$2;
}
function _M0FPB13finalize__acc(acc) {
  return _M0FPB14avalanche__acc(acc);
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String11sub_2einner(self, start, end) {
  const len = self.length;
  let end$2;
  if (end === undefined) {
    end$2 = len;
  } else {
    const _Some = end;
    const _end = _Some;
    end$2 = _end < 0 ? len + _end | 0 : _end;
  }
  const start$2 = start < 0 ? len + start | 0 : start;
  if (start$2 >= 0 && (start$2 <= end$2 && end$2 <= len)) {
    if (start$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start$2))) {
      } else {
        $panic();
      }
    }
    if (end$2 < len) {
      if (!_M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(end$2))) {
      } else {
        $panic();
      }
    }
    return new _M0TPC16string10StringView(self, start$2, end$2);
  } else {
    return $panic();
  }
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String11sub_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGsE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC16string6StringPB4Show10to__string(self));
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC15array5Array5makeiGdE(length, f) {
  if (length <= 0) {
    return [];
  } else {
    const array = new Array(length);
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < length) {
        array[i] = f(i);
        _tmp = i + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    return array;
  }
}
function _M0MPC14uint4UInt8to__byte(self) {
  return self & 255;
}
function _M0MPC15array10FixedArray18blit__from__string(self, bytes_offset, str, str_offset, length) {
  const e1 = (bytes_offset + (Math.imul(length, 2) | 0) | 0) - 1 | 0;
  const e2 = (str_offset + length | 0) - 1 | 0;
  const len1 = self.length;
  const len2 = str.length;
  if (length >= 0 && (bytes_offset >= 0 && (e1 < len1 && (str_offset >= 0 && e2 < len2)))) {
    const end_str_offset = str_offset + length | 0;
    let _tmp = str_offset;
    let _tmp$2 = bytes_offset;
    while (true) {
      const i = _tmp;
      const j = _tmp$2;
      if (i < end_str_offset) {
        const c = str.charCodeAt(i);
        $bound_check(self, j);
        self[j] = _M0MPC14uint4UInt8to__byte(c & 255);
        const _tmp$3 = j + 1 | 0;
        $bound_check(self, _tmp$3);
        self[_tmp$3] = _M0MPC14uint4UInt8to__byte(c >>> 8 | 0);
        _tmp = i + 1 | 0;
        _tmp$2 = j + 2 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    $panic();
    return;
  }
}
function _M0IPC14byte4BytePB7Default7default() {
  return 0;
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0MPC15array9ArrayView6lengthGUssEE(self) {
  return self.end - self.start | 0;
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC16string6String6repeat(self, n) {
  if (n < 0) {
    return _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("negative repeat count");
  } else {
    if (n === 0) {
      return "";
    } else {
      if (n === 1) {
        return self;
      } else {
        const len = self.length;
        const total = Math.imul(len, n) | 0;
        let _tmp;
        if (len === 0) {
          _tmp = true;
        } else {
          if (n === 0) {
            $panic();
          }
          _tmp = (total / n | 0) === len;
        }
        if (_tmp) {
          const buf = _M0MPB13StringBuilder21StringBuilder_2einner(total);
          const str = _M0IPC16string6StringPB4Show10to__string(self);
          let _tmp$2 = 0;
          while (true) {
            const _ = _tmp$2;
            if (_ < n) {
              _M0IPB13StringBuilderPB6Logger13write__string(buf, str);
              _tmp$2 = _ + 1 | 0;
              continue;
            } else {
              break;
            }
          }
          return _M0MPB13StringBuilder10to__string(buf);
        } else {
          return _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("repeat result too large");
        }
      }
    }
  }
}
function _M0MPC15array5Array4pushGsE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC15array5Array4pushGRPB5ArrayGdEE(self, value) {
  _M0MPB7JSArray4push(self, value);
}
function _M0MPC16string6String9to__bytes(self) {
  const array = $makebytes(Math.imul(self.length, 2) | 0, _M0IPC14byte4BytePB7Default7default());
  _M0MPC15array10FixedArray18blit__from__string(array, 0, self, 0, self.length);
  return array;
}
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0MPC16option6Option6unwrapGRPB5EntryGssEE(self) {
  if (self === undefined) {
    return $panic();
  } else {
    const _Some = self;
    return _Some;
  }
}
function _M0FPB21calc__grow__threshold(capacity) {
  if (16 === 0) {
    $panic();
  }
  return (Math.imul(capacity, 13) | 0) / 16 | 0;
}
function _M0MPC13int3Int20next__power__of__two(self) {
  if (self >= 0) {
    if (self <= 1) {
      return 1;
    }
    if (self > 1073741824) {
      return 1073741824;
    }
    return (2147483647 >> (Math.clz32(self - 1 | 0) - 1 | 0)) + 1 | 0;
  } else {
    return $panic();
  }
}
function _M0FPB8new__mapGssE(capacity) {
  const capacity$2 = _M0MPC13int3Int20next__power__of__two(capacity);
  const _bind = capacity$2 - 1 | 0;
  const _bind$2 = _M0FPB21calc__grow__threshold(capacity$2);
  const _bind$3 = $make_array_len_and_init(capacity$2, undefined);
  const _bind$4 = undefined;
  return new _M0TPB3MapGssE(_bind$3, 0, capacity$2, _bind, _bind$2, _bind$4, -1);
}
function _M0FPB21capacity__for__length(length) {
  let capacity = _M0MPC13int3Int20next__power__of__two(length);
  if (length > _M0FPB21calc__grow__threshold(capacity)) {
    capacity = Math.imul(capacity, 2) | 0;
  }
  return capacity;
}
function _M0MPC13int3Int3max(self, other) {
  return self > other ? self : other;
}
function _M0MPB3Map20add__entry__to__tailGssE(self, idx, entry) {
  const _bind = self.tail;
  if (_bind === -1) {
    self.head = entry;
  } else {
    const _tmp = self.entries;
    $bound_check(_tmp, _bind);
    _M0MPC16option6Option6unwrapGRPB5EntryGssEE(_tmp[_bind]).next = entry;
  }
  self.tail = idx;
  const _tmp = self.entries;
  $bound_check(_tmp, idx);
  _tmp[idx] = entry;
  self.size = self.size + 1 | 0;
}
function _M0MPB3Map10set__entryGssE(self, entry, new_idx) {
  const _tmp = self.entries;
  $bound_check(_tmp, new_idx);
  _tmp[new_idx] = entry;
  const _bind = entry.next;
  if (_bind === undefined) {
    self.tail = new_idx;
    return;
  } else {
    const _Some = _bind;
    const _next = _Some;
    _next.prev = new_idx;
    return;
  }
}
function _M0MPB3Map10push__awayGssE(self, idx, entry) {
  let _tmp = entry.psl + 1 | 0;
  let _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
  let _tmp$3 = entry;
  while (true) {
    const psl = _tmp;
    const idx$2 = _tmp$2;
    const entry$2 = _tmp$3;
    const _tmp$4 = self.entries;
    $bound_check(_tmp$4, idx$2);
    const _bind = _tmp$4[idx$2];
    if (_bind === undefined) {
      entry$2.psl = psl;
      _M0MPB3Map10set__entryGssE(self, entry$2, idx$2);
      return;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (psl > _curr_entry.psl) {
        entry$2.psl = psl;
        _M0MPB3Map10set__entryGssE(self, entry$2, idx$2);
        _tmp = _curr_entry.psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        _tmp$3 = _curr_entry;
        continue;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx$2 + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map20rehash__place__entryGssE(self, outer) {
  const hash = outer.hash;
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      outer.psl = psl;
      outer.prev = self.tail;
      _M0MPB3Map20add__entry__to__tailGssE(self, idx, outer);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr = _Some;
      if (psl > _curr.psl) {
        _M0MPB3Map10push__awayGssE(self, idx, _curr);
        outer.psl = psl;
        outer.prev = self.tail;
        _M0MPB3Map20add__entry__to__tailGssE(self, idx, outer);
        return undefined;
      } else {
        _tmp = psl + 1 | 0;
        _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
        continue;
      }
    }
  }
}
function _M0MPB3Map4growGssE(self) {
  const old_head = self.head;
  const new_capacity = self.capacity << 1;
  self.entries = $make_array_len_and_init(new_capacity, undefined);
  self.capacity = new_capacity;
  self.capacity_mask = new_capacity - 1 | 0;
  self.grow_at = _M0FPB21calc__grow__threshold(self.capacity);
  self.size = 0;
  self.head = undefined;
  self.tail = -1;
  let _tmp = old_head;
  while (true) {
    const x = _tmp;
    if (x === undefined) {
      return;
    } else {
      const _Some = x;
      const _e = _Some;
      const next_in_chain = _e.next;
      _e.next = undefined;
      _M0MPB3Map20rehash__place__entryGssE(self, _e);
      _tmp = next_in_chain;
      continue;
    }
  }
}
function _M0MPB3Map15set__with__hashGssE(self, key, value, hash) {
  let _tmp = 0;
  let _tmp$2 = hash & self.capacity_mask;
  while (true) {
    const psl = _tmp;
    const idx = _tmp$2;
    const _tmp$3 = self.entries;
    $bound_check(_tmp$3, idx);
    const _bind = _tmp$3[idx];
    if (_bind === undefined) {
      if (self.size >= self.grow_at) {
        _M0MPB3Map4growGssE(self);
        _tmp = 0;
        _tmp$2 = hash & self.capacity_mask;
        continue;
      }
      const _bind$2 = self.tail;
      const _bind$3 = undefined;
      const entry = new _M0TPB5EntryGssE(_bind$2, _bind$3, psl, hash, key, value);
      _M0MPB3Map20add__entry__to__tailGssE(self, idx, entry);
      return undefined;
    } else {
      const _Some = _bind;
      const _curr_entry = _Some;
      if (_curr_entry.hash === hash && _curr_entry.key === key) {
        _curr_entry.value = value;
        return undefined;
      }
      if (psl > _curr_entry.psl) {
        if (self.size >= self.grow_at) {
          _M0MPB3Map4growGssE(self);
          _tmp = 0;
          _tmp$2 = hash & self.capacity_mask;
          continue;
        }
        _M0MPB3Map10push__awayGssE(self, idx, _curr_entry);
        const _bind$2 = self.tail;
        const _bind$3 = undefined;
        const entry = new _M0TPB5EntryGssE(_bind$2, _bind$3, psl, hash, key, value);
        _M0MPB3Map20add__entry__to__tailGssE(self, idx, entry);
        return undefined;
      }
      _tmp = psl + 1 | 0;
      _tmp$2 = (idx + 1 | 0) & self.capacity_mask;
      continue;
    }
  }
}
function _M0MPB3Map3setGssE(self, key, value) {
  _M0MPB3Map15set__with__hashGssE(self, key, value, _M0IPC16string6StringPB4Hash4hash(key));
}
function _M0MPB3Map3MapGssE(arr, capacity) {
  const length = _M0MPC15array9ArrayView6lengthGUssEE(arr);
  let capacity$2;
  if (capacity === undefined) {
    capacity$2 = length === 0 ? 8 : _M0FPB21capacity__for__length(length);
  } else {
    const _Some = capacity;
    const _capacity = _Some;
    capacity$2 = _M0MPC13int3Int3max(_capacity, _M0FPB21capacity__for__length(length));
  }
  const m = _M0FPB8new__mapGssE(capacity$2);
  const _bind = arr.end - arr.start | 0;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const e = arr.buf[arr.start + _ | 0];
      _M0MPB3Map3setGssE(m, e._0, e._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MPC14byte4Byte10to__double(self) {
  return self + 0;
}
function _M0IPC16string6StringPB4Hash4hash(self) {
  let acc = (_M0FPB4seed >>> 0) + (374761393 >>> 0) | 0;
  const _bind = self.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < _bind) {
      acc = (acc >>> 0) + (4 >>> 0) | 0;
      const v = self.charCodeAt(i);
      acc = _M0FPB13consume4__acc(acc, v);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return _M0FPB13finalize__acc(acc);
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0MPC15array5Array2atGRPB5ArrayGdEE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    return self[index];
  } else {
    return $panic();
  }
}
function _M0MPC15array5Array3setGdE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGUdiEE(self, index, value) {
  const len = self.length;
  if (index >= 0 && index < len) {
    $bound_check(self, index);
    self[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MP24user9rag_2dmbt8Document3new(content, metadata) {
  return new _M0TP24user9rag_2dmbt8Document(content, metadata);
}
function _M0MP24user9rag_2dmbt5Chunk3new(id, text, metadata) {
  return new _M0TP24user9rag_2dmbt5Chunk(id, text, metadata, _M0DTPC16option6OptionGRPB5ArrayGdEE4None__);
}
function _M0MP24user9rag_2dmbt5Chunk15with__embedding(self, emb) {
  return new _M0TP24user9rag_2dmbt5Chunk(self.id, self.text, self.metadata, new _M0DTPC16option6OptionGRPB5ArrayGdEE4Some(emb));
}
function _M0MP24user9rag_2dmbt12SearchResult3new(chunk, score) {
  return new _M0TP24user9rag_2dmbt12SearchResult(chunk, score);
}
function _M0MP24user9rag_2dmbt16GenerationResult3new(answer, sources) {
  return new _M0TP24user9rag_2dmbt16GenerationResult(answer, sources);
}
function _M0FP24user9rag_2dmbt10make__meta(pairs) {
  const _bind = [];
  const m = _M0MPB3Map3MapGssE(new _M0TPB9ArrayViewGUssEE(_bind, 0, 0), undefined);
  const _bind$2 = pairs.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind$2) {
      const pair = pairs[_];
      _M0MPB3Map3setGssE(m, pair._0, pair._1);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return m;
}
function _M0MP24user9rag_2dmbt13InMemoryStore3new() {
  return new _M0TP24user9rag_2dmbt13InMemoryStore([], []);
}
function _M0FP24user9rag_2dmbt11cosine__sim(a, b) {
  const dim = a.length;
  const dot = new _M0TPB8MutLocalGdE(0);
  const norm_a = new _M0TPB8MutLocalGdE(0);
  const norm_b = new _M0TPB8MutLocalGdE(0);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < dim) {
      dot.val = dot.val + _M0MPC15array5Array2atGdE(a, i) * _M0MPC15array5Array2atGdE(b, i);
      norm_a.val = norm_a.val + _M0MPC15array5Array2atGdE(a, i) * _M0MPC15array5Array2atGdE(a, i);
      norm_b.val = norm_b.val + _M0MPC15array5Array2atGdE(b, i) * _M0MPC15array5Array2atGdE(b, i);
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (norm_a.val === 0 || norm_b.val === 0) {
    return 0;
  }
  return dot.val / (Math.sqrt(norm_a.val) * Math.sqrt(norm_b.val));
}
function _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore3add(self, new_chunks) {
  const _bind = new_chunks.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const chunk = new_chunks[_];
      _L: {
        let emb;
        _L$2: {
          const _bind$2 = chunk.embedding;
          if (_bind$2.$tag === 1) {
            const _Some = _bind$2;
            const _emb = _Some._0;
            emb = _emb;
            break _L$2;
          } else {
            break _L;
          }
        }
        _M0MPC15array5Array4pushGsE(self.chunks, chunk);
        _M0MPC15array5Array4pushGRPB5ArrayGdEE(self.embeddings, emb);
        break _L;
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      return;
    }
  }
}
function _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore6search(self, query_embedding, top_k) {
  const scores = [];
  const n = self.embeddings.length;
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < n) {
      const score = _M0FP24user9rag_2dmbt11cosine__sim(query_embedding, _M0MPC15array5Array2atGRPB5ArrayGdEE(self.embeddings, i));
      _M0MPC15array5Array4pushGsE(scores, { _0: score, _1: i });
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < scores.length) {
      let _tmp$3 = i + 1 | 0;
      while (true) {
        const j = _tmp$3;
        if (j < scores.length) {
          if (_M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, i)._0 < _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, j)._0) {
            const tmp = _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, i);
            _M0MPC15array5Array3setGUdiEE(scores, i, _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, j));
            _M0MPC15array5Array3setGUdiEE(scores, j, tmp);
          }
          _tmp$3 = j + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const k = top_k < scores.length ? top_k : scores.length;
  const results = [];
  let _tmp$3 = 0;
  while (true) {
    const i = _tmp$3;
    if (i < k) {
      const idx = _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, i)._1;
      _M0MPC15array5Array4pushGsE(results, _M0MP24user9rag_2dmbt12SearchResult3new(_M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(self.chunks, idx), _M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(scores, i)._0));
      _tmp$3 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return results;
}
function _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore5count(self) {
  return self.chunks.length;
}
function _M0MP24user9rag_2dmbt14SimpleSplitter11new_2einner(chunk_size, chunk_overlap) {
  return new _M0TP24user9rag_2dmbt14SimpleSplitter(chunk_size, chunk_overlap);
}
function _M0MP24user9rag_2dmbt14SimpleSplitter11split__text(self, text) {
  const len = text.length;
  const step = self.chunk_size - self.chunk_overlap | 0;
  if (step <= 0) {
    return [text];
  }
  const i = new _M0TPB8MutLocalGiE(0);
  const chunks = [];
  while (true) {
    if (i.val < len) {
      const end = (i.val + self.chunk_size | 0) > len ? len : i.val + self.chunk_size | 0;
      const chunk = _M0MPC16string10StringView9to__owned(_M0MPC16string6String11sub_2einner(text, i.val, end));
      _M0MPC15array5Array4pushGsE(chunks, chunk);
      i.val = i.val + step | 0;
      continue;
    } else {
      break;
    }
  }
  return chunks;
}
function _M0IP24user9rag_2dmbt14SimpleSplitterP24user9rag_2dmbt12TextSplitter5split(self, docs) {
  const chunk_id = new _M0TPB8MutLocalGiE(0);
  const all_chunks = [];
  const _bind = docs.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const doc = docs[_];
      const texts = _M0MP24user9rag_2dmbt14SimpleSplitter11split__text(self, doc.content);
      const _bind$2 = texts.length;
      let _tmp$2 = 0;
      while (true) {
        const _$2 = _tmp$2;
        if (_$2 < _bind$2) {
          const text = texts[_$2];
          const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(6);
          _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "chunk_");
          _M0MPB13StringBuilder13write__objectGiE(_string_builder, chunk_id.val);
          const id = _M0MPB13StringBuilder10to__string(_string_builder);
          const chunk = _M0MP24user9rag_2dmbt5Chunk3new(id, text, doc.metadata);
          _M0MPC15array5Array4pushGsE(all_chunks, chunk);
          chunk_id.val = chunk_id.val + 1 | 0;
          _tmp$2 = _$2 + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return all_chunks;
}
function _M0MP24user9rag_2dmbt15SimpleRetriever3new(embedder, store) {
  return new _M0TP24user9rag_2dmbt15SimpleRetriever(embedder, store);
}
function _M0MP24user9rag_2dmbt12MockEmbedder16text__to__vector(self, text) {
  const dim = self.dimension;
  const vec = _M0MPC15array5Array5makeiGdE(dim, (_val) => 0);
  const bytes = _M0MPC16string6String9to__bytes(text);
  let _tmp = 0;
  while (true) {
    const j = _tmp;
    if (j < bytes.length) {
      $bound_check(bytes, j);
      if (dim === 0) {
        $panic();
      }
      const idx = ((Math.imul(bytes[j], 7) | 0) + (Math.imul(j, 13) | 0) | 0) % dim | 0;
      $bound_check(bytes, j);
      const val = _M0MPC14byte4Byte10to__double(bytes[j]) / 255;
      _M0MPC15array5Array3setGdE(vec, idx, _M0MPC15array5Array2atGdE(vec, idx) + val);
      _tmp = j + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const norm = new _M0TPB8MutLocalGdE(0);
  let _tmp$2 = 0;
  while (true) {
    const k = _tmp$2;
    if (k < dim) {
      norm.val = norm.val + _M0MPC15array5Array2atGdE(vec, k) * _M0MPC15array5Array2atGdE(vec, k);
      _tmp$2 = k + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (norm.val > 0) {
    const scale = 1 / Math.sqrt(norm.val);
    let _tmp$3 = 0;
    while (true) {
      const k = _tmp$3;
      if (k < dim) {
        _M0MPC15array5Array3setGdE(vec, k, _M0MPC15array5Array2atGdE(vec, k) * scale);
        _tmp$3 = k + 1 | 0;
        continue;
      } else {
        break;
      }
    }
  }
  return vec;
}
function _M0IP24user9rag_2dmbt12MockEmbedderP24user9rag_2dmbt8Embedder12embed__query(self, query) {
  return _M0MP24user9rag_2dmbt12MockEmbedder16text__to__vector(self, query);
}
function _M0IP24user9rag_2dmbt15SimpleRetrieverP24user9rag_2dmbt9Retriever8retrieve(self, query, top_k) {
  const query_emb = _M0IP24user9rag_2dmbt12MockEmbedderP24user9rag_2dmbt8Embedder12embed__query(self.embedder, query);
  return _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore6search(self.store, query_emb, top_k);
}
function _M0MP24user9rag_2dmbt11RAGPipeline7builder() {
  return new _M0TP24user9rag_2dmbt7Builder(undefined, undefined, undefined, undefined, undefined);
}
function _M0MP24user9rag_2dmbt7Builder12with__loader(self, loader) {
  return new _M0TP24user9rag_2dmbt7Builder(loader, self.splitter, self.embedder, self.store, self.generator);
}
function _M0MP24user9rag_2dmbt7Builder14with__splitter(self, splitter) {
  return new _M0TP24user9rag_2dmbt7Builder(self.loader, splitter, self.embedder, self.store, self.generator);
}
function _M0MP24user9rag_2dmbt7Builder14with__embedder(self, embedder) {
  return new _M0TP24user9rag_2dmbt7Builder(self.loader, self.splitter, embedder, self.store, self.generator);
}
function _M0MP24user9rag_2dmbt7Builder11with__store(self, store) {
  return new _M0TP24user9rag_2dmbt7Builder(self.loader, self.splitter, self.embedder, store, self.generator);
}
function _M0MP24user9rag_2dmbt7Builder15with__generator(self, generator) {
  return new _M0TP24user9rag_2dmbt7Builder(self.loader, self.splitter, self.embedder, self.store, generator);
}
function _M0MP24user9rag_2dmbt7Builder5build(self) {
  let loader;
  const _bind = self.loader;
  if (_bind === undefined) {
    loader = _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("❌ loader 未配置");
  } else {
    const _Some = _bind;
    const _l = _Some;
    loader = _l;
  }
  let splitter;
  const _bind$2 = self.splitter;
  if (_bind$2 === undefined) {
    splitter = _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("❌ splitter 未配置");
  } else {
    const _Some = _bind$2;
    const _s = _Some;
    splitter = _s;
  }
  let embedder;
  const _bind$3 = self.embedder;
  if (_bind$3 === undefined) {
    embedder = _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("❌ embedder 未配置");
  } else {
    const _Some = _bind$3;
    const _e = _Some;
    embedder = _e;
  }
  let store;
  const _bind$4 = self.store;
  if (_bind$4 === undefined) {
    store = _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("❌ store 未配置");
  } else {
    const _Some = _bind$4;
    const _s = _Some;
    store = _s;
  }
  let generator;
  const _bind$5 = self.generator;
  if (_bind$5 === undefined) {
    generator = _M0FPC15abort5abortGRP24user9rag_2dmbt9TxtLoaderE("❌ generator 未配置");
  } else {
    const _Some = _bind$5;
    const _g = _Some;
    generator = _g;
  }
  const retriever = _M0MP24user9rag_2dmbt15SimpleRetriever3new(embedder, store);
  return new _M0TP24user9rag_2dmbt11RAGPipeline(loader, splitter, embedder, store, retriever, generator);
}
function _M0FP24user9rag_2dmbt18load__static__docs() {
  return [_M0MP24user9rag_2dmbt8Document3new("MoonBit 是一种专为 WebAssembly 设计的现代编程语言。它由 IDEA 研究院的张宏波团队开发。\nMoonBit 结合了 Rust 的表达式能力和 Go 的简洁性，提供强大的类型系统、模式匹配和泛型。\nMoonBit 编译速度极快，生成的 Wasm 体积非常小，适合云计算和边缘计算场景。", _M0FP24user9rag_2dmbt10make__meta([{ _0: "source", _1: "moonbit_intro.txt" }, { _0: "topic", _1: "language" }])), _M0MP24user9rag_2dmbt8Document3new("RAG（检索增强生成）是一种结合信息检索和文本生成的 AI 技术架构。\n它的核心思想是：在 LLM 生成回答之前，先从知识库中检索相关文档，\n然后将检索结果作为上下文提供给 LLM，从而生成更准确、更可靠的回答。\nRAG 有效解决了 LLM 的幻觉问题和知识截止问题。", _M0FP24user9rag_2dmbt10make__meta([{ _0: "source", _1: "rag_intro.txt" }, { _0: "topic", _1: "ai" }])), _M0MP24user9rag_2dmbt8Document3new("MoonBit 支持多后端编译：WebAssembly、JavaScript 和 Native。\n通过 python.mbt 库，MoonBit 可以无缝调用 Python 生态中的任何库，\n包括 langchain、numpy、pandas 等。\nMoonBit 的构建系统 moon 也非常快，626 个包只需要 1.06 秒编译。", _M0FP24user9rag_2dmbt10make__meta([{ _0: "source", _1: "moonbit_advanced.txt" }, { _0: "topic", _1: "language" }])), _M0MP24user9rag_2dmbt8Document3new("向量数据库是 RAG 系统的核心组件之一。它负责存储文档的向量嵌入，\n并提供高效的相似度搜索能力。常见的向量数据库包括 FAISS、Chroma、Milvus 等。\nMoonBit 的 rag-mbt 库目前提供内存存储实现，后续将支持 FAISS 等外部存储。", _M0FP24user9rag_2dmbt10make__meta([{ _0: "source", _1: "vector_db.txt" }, { _0: "topic", _1: "ai" }])), _M0MP24user9rag_2dmbt8Document3new("MoonBit 的 trait 系统支持特设多态。\n通过 trait，我们可以在 rag-mbt 中定义统一的接口：\nDocumentLoader、TextSplitter、Embedder、VectorStore、Retriever、Generator。\n用户只需要实现这些 trait，就可以任意替换 RAG 流水线中的任意组件。", _M0FP24user9rag_2dmbt10make__meta([{ _0: "source", _1: "moonbit_traits.txt" }, { _0: "topic", _1: "language" }]))];
}
function _M0IP24user9rag_2dmbt9TxtLoaderP24user9rag_2dmbt14DocumentLoader4load(self, path) {
  return _M0FP24user9rag_2dmbt18load__static__docs();
}
function _M0IP24user9rag_2dmbt12MockEmbedderP24user9rag_2dmbt8Embedder16embed__documents(self, texts) {
  const embeddings = [];
  const _bind = texts.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const text = texts[_];
      _M0MPC15array5Array4pushGRPB5ArrayGdEE(embeddings, _M0MP24user9rag_2dmbt12MockEmbedder16text__to__vector(self, text));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return embeddings;
}
function _M0MP24user9rag_2dmbt11RAGPipeline5index(self, path) {
  _M0FPB7printlnGsE("\n═══════════════════════════════════════");
  _M0FPB7printlnGsE("  📚 阶段一：构建索引");
  _M0FPB7printlnGsE("═══════════════════════════════════════\n");
  _M0FPB7printlnGsE("[1/4] 加载文档...");
  const docs = _M0IP24user9rag_2dmbt9TxtLoaderP24user9rag_2dmbt14DocumentLoader4load(self.loader, path);
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(26);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "  ✅ 加载了 ");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, docs.length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " 个文档");
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder));
  _M0FPB7printlnGsE("[2/4] 切分文档...");
  const chunks = _M0IP24user9rag_2dmbt14SimpleSplitterP24user9rag_2dmbt12TextSplitter5split(self.splitter, docs);
  const _string_builder$2 = _M0MPB13StringBuilder21StringBuilder_2einner(23);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$2, "  ✅ 切分为 ");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$2, chunks.length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$2, " 个块");
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$2));
  _M0FPB7printlnGsE("[3/4] 生成向量嵌入...");
  const texts = [];
  const _bind = chunks.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const c = chunks[_];
      _M0MPC15array5Array4pushGsE(texts, c.text);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const embeddings = _M0IP24user9rag_2dmbt12MockEmbedderP24user9rag_2dmbt8Embedder16embed__documents(self.embedder, texts);
  const _string_builder$3 = _M0MPB13StringBuilder21StringBuilder_2einner(45);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, "  ✅ 生成了 ");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$3, embeddings.length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, " 个嵌入向量（维度=");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$3, _M0MPC15array5Array2atGRPB5ArrayGdEE(embeddings, 0).length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, "）");
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$3));
  const chunks_with_emb = [];
  let _tmp$2 = 0;
  while (true) {
    const i = _tmp$2;
    if (i < chunks.length) {
      _M0MPC15array5Array4pushGsE(chunks_with_emb, _M0MP24user9rag_2dmbt5Chunk15with__embedding(_M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(chunks, i), _M0MPC15array5Array2atGRPB5ArrayGdEE(embeddings, i)));
      _tmp$2 = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  _M0FPB7printlnGsE("[4/4] 存储到向量数据库...");
  _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore3add(self.store, chunks_with_emb);
  const _string_builder$4 = _M0MPB13StringBuilder21StringBuilder_2einner(27);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$4, "  ✅ 已存储 ");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder$4, _M0IP24user9rag_2dmbt13InMemoryStoreP24user9rag_2dmbt11VectorStore5count(self.store));
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$4, " 个向量\n");
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$4));
  _M0FPB7printlnGsE("✅ 索引构建完成！\n");
}
function _M0IP24user9rag_2dmbt13MockGeneratorP24user9rag_2dmbt9Generator8generate(self, query, context) {
  const answer = new _M0TPB8MutLocalGsE(self.prefix);
  let _tmp = 0;
  while (true) {
    const i = _tmp;
    if (i < context.length) {
      answer.val = `${answer.val}[来源 ${_M0MPC13int3Int18to__string_2einner(i + 1 | 0, 10)}] ${_M0MPC15array5Array2atGRP24user9rag_2dmbt5ChunkE(context, i).text}\n\n`;
      _tmp = i + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  answer.val = `${answer.val}---\n问题: ${query}\n\n(以上为检索到的相关上下文，后续将由 LLM 生成最终答案)`;
  return _M0MP24user9rag_2dmbt16GenerationResult3new(answer.val, context);
}
function _M0MP24user9rag_2dmbt11RAGPipeline13query_2einner(self, query, top_k) {
  _M0FPB7printlnGsE("\n═══════════════════════════════════════");
  _M0FPB7printlnGsE("  🔍 阶段二：检索 + 生成");
  _M0FPB7printlnGsE("═══════════════════════════════════════\n");
  _M0FPB7printlnGsE("[5/6] 检索相关文档...");
  const results = _M0IP24user9rag_2dmbt15SimpleRetrieverP24user9rag_2dmbt9Retriever8retrieve(self.retriever, query, top_k);
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(32);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "  ✅ 检索到 ");
  _M0MPB13StringBuilder13write__objectGiE(_string_builder, results.length);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, " 条相关结果");
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder));
  _M0FPB7printlnGsE("[6/6] 生成回答...");
  const sources = [];
  const _bind = results.length;
  let _tmp = 0;
  while (true) {
    const _ = _tmp;
    if (_ < _bind) {
      const r = results[_];
      _M0MPC15array5Array4pushGsE(sources, r.chunk);
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const result = _M0IP24user9rag_2dmbt13MockGeneratorP24user9rag_2dmbt9Generator8generate(self.generator, query, sources);
  _M0FPB7printlnGsE("  ✅ 生成完成\n");
  return result;
}
function _M0MP24user9rag_2dmbt9TxtLoader3new(path) {
  return new _M0TP24user9rag_2dmbt9TxtLoader(path);
}
function _M0MP24user9rag_2dmbt13MockGenerator11new_2einner(prefix) {
  return new _M0TP24user9rag_2dmbt13MockGenerator(prefix);
}
function _M0MP24user9rag_2dmbt12MockEmbedder11new_2einner(dimension) {
  return new _M0TP24user9rag_2dmbt12MockEmbedder(dimension);
}
(() => {
  _M0FPB7printlnGsE("\n");
  _M0FPB7printlnGsE("╔══════════════════════════════════════════╗");
  _M0FPB7printlnGsE("║    🚀 rag-mbt: RAG 2阶段6模块演示       ║");
  _M0FPB7printlnGsE("║    MoonBit 原生 RAG 库 (纯内存版)        ║");
  _M0FPB7printlnGsE("╚══════════════════════════════════════════╝\n");
  const rag = _M0MP24user9rag_2dmbt7Builder5build(_M0MP24user9rag_2dmbt7Builder15with__generator(_M0MP24user9rag_2dmbt7Builder11with__store(_M0MP24user9rag_2dmbt7Builder14with__embedder(_M0MP24user9rag_2dmbt7Builder14with__splitter(_M0MP24user9rag_2dmbt7Builder12with__loader(_M0MP24user9rag_2dmbt11RAGPipeline7builder(), _M0MP24user9rag_2dmbt9TxtLoader3new("docs/")), _M0MP24user9rag_2dmbt14SimpleSplitter11new_2einner(200, 30)), _M0MP24user9rag_2dmbt12MockEmbedder11new_2einner(32)), _M0MP24user9rag_2dmbt13InMemoryStore3new()), _M0MP24user9rag_2dmbt13MockGenerator11new_2einner("基于以下资料回答：\n\n")));
  _M0FPB7printlnGsE("✅ Pipeline 构建完成\n");
  _M0MP24user9rag_2dmbt11RAGPipeline5index(rag, "");
  const query1 = "什么是 MoonBit？";
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(7);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "  💬 ");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder, query1);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder));
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const r1 = _M0MP24user9rag_2dmbt11RAGPipeline13query_2einner(rag, query1, 3);
  const _string_builder$2 = _M0MPB13StringBuilder21StringBuilder_2einner(14);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$2, "\n📝 结果:\n");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$2, r1.answer);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$2));
  const query2 = "RAG 的工作原理是什么？";
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const _string_builder$3 = _M0MPB13StringBuilder21StringBuilder_2einner(7);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$3, "  💬 ");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$3, query2);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$3));
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const r2 = _M0MP24user9rag_2dmbt11RAGPipeline13query_2einner(rag, query2, 3);
  const _string_builder$4 = _M0MPB13StringBuilder21StringBuilder_2einner(14);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$4, "\n📝 结果:\n");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$4, r2.answer);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$4));
  const query3 = "向量数据库在 RAG 中的作用是什么？";
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const _string_builder$5 = _M0MPB13StringBuilder21StringBuilder_2einner(7);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$5, "  💬 ");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$5, query3);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$5));
  _M0FPB7printlnGsE(_M0MPC16string6String6repeat("─", 50));
  const r3 = _M0MP24user9rag_2dmbt11RAGPipeline13query_2einner(rag, query3, 3);
  const _string_builder$6 = _M0MPB13StringBuilder21StringBuilder_2einner(14);
  _M0IPB13StringBuilderPB6Logger13write__string(_string_builder$6, "\n📝 结果:\n");
  _M0MPB13StringBuilder13write__objectGsE(_string_builder$6, r3.answer);
  _M0FPB7printlnGsE(_M0MPB13StringBuilder10to__string(_string_builder$6));
  _M0FPB7printlnGsE("\n╔══════════════════════════════════════════╗");
  _M0FPB7printlnGsE("║  ✅ rag-mbt Step1+2 端到端验证通过！      ║");
  _M0FPB7printlnGsE("╚══════════════════════════════════════════╝\n");
})();
//# sourceMappingURL=main.js.map
