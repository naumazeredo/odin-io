package io

import "core:fmt"
import "core:os"
import "core:strings"

// @Incomplete: print pointers
// @Incomplete: solve float dumb stuff
// @Todo: change Odin core to escape % (\%)

_print_f64_dumb :: proc(builder: ^strings.Builder, v: f64, digits: uint = 6) {
  vv := v;
  integral : uint = auto_cast vv;

  strings.write_uint(builder, integral);
  strings.write_byte(builder, '.');

  for i in 1..digits {
    vv -= cast(f64)integral;
    vv *= 10.0;
    integral = auto_cast vv;
    strings.write_uint(builder, integral);
  }
}

print :: proc(format: string, args: ..any) {
  builder := strings.make_builder();
  defer strings.destroy_builder(&builder);

  args_index := 0;

  for b in format {
    if b == '%' {
      if args_index >= len(args) {
        os.write_string(context.stderr, "[ERROR] Too few arguments in print\n");
        return;
      }

      arg := args[args_index];

      switch arg.id {
        case int:    strings.write_i64(&builder, cast(i64)arg.(int));
        case i8 :    strings.write_i64(&builder, cast(i64)arg.(i8));
        case i16:    strings.write_i64(&builder, cast(i64)arg.(i16));
        case i32:    strings.write_i64(&builder, cast(i64)arg.(i32));
        case i64:    strings.write_i64(&builder, cast(i64)arg.(i64));

        case uint:   strings.write_u64(&builder, cast(u64)arg.(uint));
        case u8 :    strings.write_u64(&builder, cast(u64)arg.(u8));
        case u16:    strings.write_u64(&builder, cast(u64)arg.(u16));
        case u32:    strings.write_u64(&builder, cast(u64)arg.(u32));
        case u64:    strings.write_u64(&builder, cast(u64)arg.(u64));

        case f32:    _print_f64_dumb(&builder, cast(f64)arg.(f32));
        case f64:    _print_f64_dumb(&builder, arg.(f64));

        case string: strings.write_string(&builder, arg.(string));

        //case rawptr: strings.write_u64(&builder, cast(u64)(cast(uintptr)arg.(rawptr)));

        case:        strings.write_string(&builder, "<error>");
      }

      args_index += 1;

    } else {
      strings.write_rune(&builder, b);
    }
  }

  if args_index < len(args) {
    os.write_string(context.stderr, "[WARNING] Too many arguments in print\n");
  }

  os.write_string(context.stdout, strings.to_string(builder));
}
