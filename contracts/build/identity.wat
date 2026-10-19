(module
 (type $0 (func (param i32 i32) (result i32)))
 (type $1 (func (param i32) (result i32)))
 (type $2 (func))
 (type $3 (func (param i32 i32)))
 (type $4 (func (param i32 i32 i32 i32)))
 (type $5 (func (param i32 i32 i32)))
 (type $6 (func (param i32 i32) (result i64)))
 (type $7 (func (param i32)))
 (type $8 (func (result i32)))
 (type $9 (func (param i64) (result i32)))
 (type $10 (func (param i32 i64)))
 (type $11 (func (param i32 i64) (result i32)))
 (type $12 (func (param i32 i32 i32) (result i32)))
 (type $13 (func (result i64)))
 (import "env" "abort" (func $~lib/builtins/abort (param i32 i32 i32 i32)))
 (import "env" "revert" (func $assembly/sdk/_revert (param i32 i32)))
 (import "env" "emit" (func $assembly/sdk/_emit (param i32 i32 i32 i32)))
 (import "env" "caller" (func $assembly/sdk/_caller (param i32)))
 (import "env" "storage_delete" (func $assembly/sdk/_storage_delete (param i32 i32)))
 (import "env" "storage_write" (func $assembly/sdk/_storage_write (param i32 i32 i32 i32)))
 (import "env" "storage_read" (func $assembly/sdk/_storage_read (param i32 i32 i32) (result i32)))
 (import "env" "storage_len" (func $assembly/sdk/_storage_len (param i32 i32) (result i32)))
 (import "env" "output" (func $assembly/sdk/_output (param i32 i32)))
 (import "env" "input_read" (func $assembly/sdk/_input_read (param i32)))
 (import "env" "input_len" (func $assembly/sdk/_input_len (result i32)))
 (import "env" "height" (func $assembly/sdk/_height (result i64)))
 (global $~lib/rt/stub/offset (mut i32) (i32.const 0))
 (memory $0 1)
 (data $0 (i32.const 1036) "\1c")
 (data $0.1 (i32.const 1048) "\02\00\00\00\06\00\00\00i\00d\00:")
 (data $1 (i32.const 1068) "<")
 (data $1.1 (i32.const 1080) "\02\00\00\00(\00\00\00A\00l\00l\00o\00c\00a\00t\00i\00o\00n\00 \00t\00o\00o\00 \00l\00a\00r\00g\00e")
 (data $2 (i32.const 1132) "<")
 (data $2.1 (i32.const 1144) "\02\00\00\00\1e\00\00\00~\00l\00i\00b\00/\00r\00t\00/\00s\00t\00u\00b\00.\00t\00s")
 (data $3 (i32.const 1196) "<")
 (data $3.1 (i32.const 1208) "\02\00\00\00$\00\00\00U\00n\00p\00a\00i\00r\00e\00d\00 \00s\00u\00r\00r\00o\00g\00a\00t\00e")
 (data $4 (i32.const 1260) ",")
 (data $4.1 (i32.const 1272) "\02\00\00\00\1c\00\00\00~\00l\00i\00b\00/\00s\00t\00r\00i\00n\00g\00.\00t\00s")
 (data $5 (i32.const 1308) "<")
 (data $5.1 (i32.const 1320) "\02\00\00\00$\00\00\00I\00n\00d\00e\00x\00 \00o\00u\00t\00 \00o\00f\00 \00r\00a\00n\00g\00e")
 (data $6 (i32.const 1372) "<")
 (data $6.1 (i32.const 1384) "\02\00\00\00$\00\00\00~\00l\00i\00b\00/\00t\00y\00p\00e\00d\00a\00r\00r\00a\00y\00.\00t\00s")
 (data $7 (i32.const 1436) ",")
 (data $7.1 (i32.const 1448) "\02\00\00\00\1c\00\00\00I\00n\00v\00a\00l\00i\00d\00 \00l\00e\00n\00g\00t\00h")
 (data $8 (i32.const 1484) "<")
 (data $8.1 (i32.const 1496) "\02\00\00\00&\00\00\00~\00l\00i\00b\00/\00a\00r\00r\00a\00y\00b\00u\00f\00f\00e\00r\00.\00t\00s")
 (data $9 (i32.const 1548) "\1c")
 (data $9.1 (i32.const 1560) "\02\00\00\00\08\00\00\00c\00l\00m\00:")
 (data $10 (i32.const 1580) "\1c")
 (data $10.1 (i32.const 1592) "\02\00\00\00\n\00\00\00o\00w\00n\00e\00r")
 (data $11 (i32.const 1612) "\1c")
 (data $11.1 (i32.const 1624) "\02\00\00\00\08\00\00\00a\00g\00t\00:")
 (data $12 (i32.const 1644) "<")
 (data $12.1 (i32.const 1656) "\02\00\00\00\1e\00\00\00R\00e\00g\00i\00s\00t\00r\00y\00C\00r\00e\00a\00t\00e\00d")
 (data $13 (i32.const 1708) "\1c")
 (data $13.1 (i32.const 1720) "\02\00\00\00\0c\00\00\00m\00e\00t\00h\00o\00d")
 (data $14 (i32.const 1740) "<")
 (data $14.1 (i32.const 1752) "\02\00\00\00$\00\00\00m\00i\00s\00s\00i\00n\00g\00 \00a\00r\00g\00u\00m\00e\00n\00t\00:\00 ")
 (data $15 (i32.const 1804) "\1c")
 (data $15.1 (i32.const 1816) "\02")
 (data $16 (i32.const 1836) "L")
 (data $16.1 (i32.const 1848) "\02\00\00\002\00\00\00w\00r\00o\00n\00g\00 \00t\00y\00p\00e\00 \00f\00o\00r\00 \00a\00r\00g\00u\00m\00e\00n\00t\00:\00 ")
 (data $17 (i32.const 1916) "<")
 (data $17.1 (i32.const 1928) "\02\00\00\00$\00\00\00a\00r\00g\00u\00m\00e\00n\00t\00 \00c\00u\00t\00 \00s\00h\00o\00r\00t")
 (data $18 (i32.const 1980) "\1c")
 (data $18.1 (i32.const 1992) "\01")
 (data $19 (i32.const 2012) ",")
 (data $19.1 (i32.const 2024) "\02\00\00\00\12\00\00\00a\00d\00d\00_\00a\00g\00e\00n\00t")
 (data $20 (i32.const 2060) ",")
 (data $20.1 (i32.const 2072) "\02\00\00\00\18\00\00\00r\00e\00m\00o\00v\00e\00_\00a\00g\00e\00n\00t")
 (data $21 (i32.const 2108) "|")
 (data $21.1 (i32.const 2120) "\02\00\00\00^\00\00\00U\00n\00e\00x\00p\00e\00c\00t\00e\00d\00 \00\'\00n\00u\00l\00l\00\'\00 \00(\00n\00o\00t\00 \00a\00s\00s\00i\00g\00n\00e\00d\00 \00o\00r\00 \00f\00a\00i\00l\00e\00d\00 \00c\00a\00s\00t\00)")
 (data $22 (i32.const 2236) "<")
 (data $22.1 (i32.const 2248) "\02\00\00\00(\00\00\00a\00s\00s\00e\00m\00b\00l\00y\00/\00i\00d\00e\00n\00t\00i\00t\00y\00.\00t\00s")
 (data $23 (i32.const 2300) "\\")
 (data $23.1 (i32.const 2312) "\02\00\00\00F\00\00\00o\00n\00l\00y\00 \00t\00h\00e\00 \00r\00e\00g\00i\00s\00t\00r\00y\00 \00o\00w\00n\00e\00r\00 \00c\00a\00n\00 \00d\00o\00 \00t\00h\00i\00s")
 (data $24 (i32.const 2396) "\1c")
 (data $24.1 (i32.const 2408) "\02\00\00\00\n\00\00\00a\00g\00e\00n\00t")
 (data $25 (i32.const 2428) ",")
 (data $25.1 (i32.const 2440) "\02\00\00\00\14\00\00\00a\00d\00d\00_\00i\00s\00s\00u\00e\00r")
 (data $26 (i32.const 2476) "\1c")
 (data $26.1 (i32.const 2488) "\02\00\00\00\0c\00\00\00i\00s\00s\00u\00e\00r")
 (data $27 (i32.const 2508) "\1c")
 (data $27.1 (i32.const 2520) "\02\00\00\00\08\00\00\00i\00s\00s\00:")
 (data $28 (i32.const 2540) "\1c")
 (data $28.1 (i32.const 2552) "\02\00\00\00\0c\00\00\00t\00o\00p\00i\00c\00s")
 (data $29 (i32.const 2572) ",")
 (data $29.1 (i32.const 2584) "\02\00\00\00\16\00\00\00I\00s\00s\00u\00e\00r\00A\00d\00d\00e\00d")
 (data $30 (i32.const 2620) ",")
 (data $30.1 (i32.const 2632) "\02\00\00\00\1a\00\00\00r\00e\00m\00o\00v\00e\00_\00i\00s\00s\00u\00e\00r")
 (data $31 (i32.const 2668) ",")
 (data $31.1 (i32.const 2680) "\02\00\00\00\10\00\00\00r\00e\00g\00i\00s\00t\00e\00r")
 (data $32 (i32.const 2716) "\\")
 (data $32.1 (i32.const 2728) "\02\00\00\00B\00\00\00o\00n\00l\00y\00 \00a\00 \00r\00e\00g\00i\00s\00t\00r\00y\00 \00a\00g\00e\00n\00t\00 \00c\00a\00n\00 \00d\00o\00 \00t\00h\00i\00s")
 (data $33 (i32.const 2812) "\1c")
 (data $33.1 (i32.const 2824) "\02\00\00\00\0c\00\00\00w\00a\00l\00l\00e\00t")
 (data $34 (i32.const 2844) ",")
 (data $34.1 (i32.const 2856) "\02\00\00\00\10\00\00\00i\00d\00e\00n\00t\00i\00t\00y")
 (data $35 (i32.const 2892) ",")
 (data $35.1 (i32.const 2904) "\02\00\00\00\0e\00\00\00c\00o\00u\00n\00t\00r\00y")
 (data $36 (i32.const 2940) "L")
 (data $36.1 (i32.const 2952) "\02\00\00\006\00\00\00i\00d\00e\00n\00t\00i\00t\00y\00 \00n\00u\00m\00b\00e\00r\00s\00 \00s\00t\00a\00r\00t\00 \00a\00t\00 \001")
 (data $37 (i32.const 3020) "\1c")
 (data $37.1 (i32.const 3032) "\02\00\00\00\08\00\00\00c\00t\00y\00:")
 (data $38 (i32.const 3052) ",")
 (data $38.1 (i32.const 3064) "\02\00\00\00\14\00\00\00R\00e\00g\00i\00s\00t\00e\00r\00e\00d")
 (data $39 (i32.const 3100) ",")
 (data $39.1 (i32.const 3112) "\02\00\00\00\14\00\00\00u\00n\00r\00e\00g\00i\00s\00t\00e\00r")
 (data $40 (i32.const 3148) ",")
 (data $40.1 (i32.const 3160) "\02\00\00\00\18\00\00\00U\00n\00r\00e\00g\00i\00s\00t\00e\00r\00e\00d")
 (data $41 (i32.const 3196) ",")
 (data $41.1 (i32.const 3208) "\02\00\00\00\12\00\00\00a\00d\00d\00_\00c\00l\00a\00i\00m")
 (data $42 (i32.const 3244) "\1c")
 (data $42.1 (i32.const 3256) "\02\00\00\00\n\00\00\00t\00o\00p\00i\00c")
 (data $43 (i32.const 3276) "L")
 (data $43.1 (i32.const 3288) "\02\00\00\00:\00\00\00e\00x\00p\00i\00r\00e\00s\00 \00a\00t\00 \00h\00e\00i\00g\00h\00t\00 \00(\000\00 \00=\00 \00n\00e\00v\00e\00r\00)")
 (data $44 (i32.const 3356) "\\")
 (data $44.1 (i32.const 3368) "\02\00\00\00@\00\00\00a\00 \00c\00l\00a\00i\00m\00 \00i\00s\00 \00f\00o\00r\00 \00e\00x\00a\00c\00t\00l\00y\00 \00o\00n\00e\00 \00t\00o\00p\00i\00c")
 (data $45 (i32.const 3452) "l")
 (data $45.1 (i32.const 3464) "\02\00\00\00T\00\00\00y\00o\00u\00\'\00r\00e\00 \00n\00o\00t\00 \00a\00 \00t\00r\00u\00s\00t\00e\00d\00 \00i\00s\00s\00u\00e\00r\00 \00f\00o\00r\00 \00t\00h\00i\00s\00 \00c\00l\00a\00i\00m")
 (data $46 (i32.const 3564) ",")
 (data $46.1 (i32.const 3576) "\02\00\00\00\14\00\00\00C\00l\00a\00i\00m\00A\00d\00d\00e\00d")
 (data $47 (i32.const 3612) ",")
 (data $47.1 (i32.const 3624) "\02\00\00\00\18\00\00\00r\00e\00v\00o\00k\00e\00_\00c\00l\00a\00i\00m")
 (data $48 (i32.const 3660) "L")
 (data $48.1 (i32.const 3672) "\02\00\00\006\00\00\00y\00o\00u\00 \00c\00a\00n\00\'\00t\00 \00r\00e\00v\00o\00k\00e\00 \00t\00h\00i\00s\00 \00c\00l\00a\00i\00m")
 (data $49 (i32.const 3740) ",")
 (data $49.1 (i32.const 3752) "\02\00\00\00\18\00\00\00C\00l\00a\00i\00m\00R\00e\00v\00o\00k\00e\00d")
 (data $50 (i32.const 3788) ",")
 (data $50.1 (i32.const 3800) "\02\00\00\00\16\00\00\00i\00s\00_\00v\00e\00r\00i\00f\00i\00e\00d")
 (data $51 (i32.const 3836) ",")
 (data $51.1 (i32.const 3848) "\02\00\00\00\1a\00\00\00~\00l\00i\00b\00/\00a\00r\00r\00a\00y\00.\00t\00s")
 (data $52 (i32.const 3884) ",")
 (data $52.1 (i32.const 3896) "\02\00\00\00\16\00\00\00i\00d\00e\00n\00t\00i\00t\00y\00_\00o\00f")
 (data $53 (i32.const 3932) ",")
 (data $53.1 (i32.const 3944) "\02\00\00\00\14\00\00\00c\00o\00u\00n\00t\00r\00y\00_\00o\00f")
 (data $54 (i32.const 3980) "\1c")
 (data $54.1 (i32.const 3992) "\02\00\00\00\08\00\00\00i\00n\00f\00o")
 (data $55 (i32.const 4012) "<")
 (data $55.1 (i32.const 4024) "\02\00\00\00\"\00\00\00I\00d\00e\00n\00t\00i\00t\00y\00 \00r\00e\00g\00i\00s\00t\00r\00y")
 (data $56 (i32.const 4076) "<")
 (data $56.1 (i32.const 4088) "\02\00\00\00 \00\00\00u\00n\00k\00n\00o\00w\00n\00 \00m\00e\00t\00h\00o\00d\00:\00 ")
 (data $57 (i32.const 4140) "|")
 (data $57.1 (i32.const 4152) "\02\00\00\00^\00\00\00E\00l\00e\00m\00e\00n\00t\00 \00t\00y\00p\00e\00 \00m\00u\00s\00t\00 \00b\00e\00 \00n\00u\00l\00l\00a\00b\00l\00e\00 \00i\00f\00 \00a\00r\00r\00a\00y\00 \00i\00s\00 \00h\00o\00l\00e\00y")
 (export "verified" (func $assembly/identity/verified))
 (export "init" (func $assembly/identity/init))
 (export "call" (func $assembly/identity/call))
 (export "memory" (memory $0))
 (start $~start)
 (func $assembly/sdk/utf8 (param $0 i32) (result i32)
  (local $1 i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  local.get $0
  local.tee $1
  local.get $1
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.add
  local.set $3
  loop $while-continue|0
   local.get $1
   local.get $3
   i32.lt_u
   if
    local.get $1
    i32.load16_u
    local.tee $4
    i32.const 128
    i32.lt_u
    if (result i32)
     local.get $2
     i32.const 1
     i32.add
    else
     local.get $4
     i32.const 2048
     i32.lt_u
     if (result i32)
      local.get $2
      i32.const 2
      i32.add
     else
      local.get $4
      i32.const 64512
      i32.and
      i32.const 55296
      i32.eq
      local.get $1
      i32.const 2
      i32.add
      local.get $3
      i32.lt_u
      i32.and
      if
       local.get $1
       i32.load16_u offset=2
       i32.const 64512
       i32.and
       i32.const 56320
       i32.eq
       if
        local.get $2
        i32.const 4
        i32.add
        local.set $2
        local.get $1
        i32.const 4
        i32.add
        local.set $1
        br $while-continue|0
       end
      end
      local.get $2
      i32.const 3
      i32.add
     end
    end
    local.set $2
    local.get $1
    i32.const 2
    i32.add
    local.set $1
    br $while-continue|0
   end
  end
  local.get $2
  i32.const 1
  call $~lib/rt/stub/__new
  local.set $2
  local.get $0
  local.tee $1
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.const -2
  i32.and
  local.get $1
  i32.add
  local.set $4
  local.get $2
  local.set $0
  loop $while-continue|00
   local.get $1
   local.get $4
   i32.lt_u
   if
    local.get $1
    i32.load16_u
    local.tee $3
    i32.const 128
    i32.lt_u
    if (result i32)
     local.get $0
     local.get $3
     i32.store8
     local.get $0
     i32.const 1
     i32.add
    else
     local.get $3
     i32.const 2048
     i32.lt_u
     if (result i32)
      local.get $0
      local.get $3
      i32.const 6
      i32.shr_u
      i32.const 192
      i32.or
      local.get $3
      i32.const 63
      i32.and
      i32.const 128
      i32.or
      i32.const 8
      i32.shl
      i32.or
      i32.store16
      local.get $0
      i32.const 2
      i32.add
     else
      local.get $3
      i32.const 63488
      i32.and
      i32.const 55296
      i32.eq
      if
       local.get $3
       i32.const 56320
       i32.lt_u
       local.get $1
       i32.const 2
       i32.add
       local.get $4
       i32.lt_u
       i32.and
       if
        local.get $1
        i32.load16_u offset=2
        local.tee $5
        i32.const 64512
        i32.and
        i32.const 56320
        i32.eq
        if
         local.get $0
         local.get $3
         i32.const 1023
         i32.and
         i32.const 10
         i32.shl
         i32.const 65536
         i32.add
         local.get $5
         i32.const 1023
         i32.and
         i32.or
         local.tee $3
         i32.const 63
         i32.and
         i32.const 128
         i32.or
         i32.const 24
         i32.shl
         local.get $3
         i32.const 6
         i32.shr_u
         i32.const 63
         i32.and
         i32.const 128
         i32.or
         i32.const 16
         i32.shl
         i32.or
         local.get $3
         i32.const 12
         i32.shr_u
         i32.const 63
         i32.and
         i32.const 128
         i32.or
         i32.const 8
         i32.shl
         i32.or
         local.get $3
         i32.const 18
         i32.shr_u
         i32.const 240
         i32.or
         i32.or
         i32.store
         local.get $0
         i32.const 4
         i32.add
         local.set $0
         local.get $1
         i32.const 4
         i32.add
         local.set $1
         br $while-continue|00
        end
       end
      end
      local.get $0
      local.get $3
      i32.const 12
      i32.shr_u
      i32.const 224
      i32.or
      local.get $3
      i32.const 6
      i32.shr_u
      i32.const 63
      i32.and
      i32.const 128
      i32.or
      i32.const 8
      i32.shl
      i32.or
      i32.store16
      local.get $0
      local.get $3
      i32.const 63
      i32.and
      i32.const 128
      i32.or
      i32.store8 offset=2
      local.get $0
      i32.const 3
      i32.add
     end
    end
    local.set $0
    local.get $1
    i32.const 2
    i32.add
    local.set $1
    br $while-continue|00
   end
  end
  local.get $2
  i32.const 20
  i32.sub
  i32.load offset=16
  local.set $0
  i32.const 12
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $1
  local.get $2
  i32.store
  local.get $1
  local.get $0
  i32.store offset=8
  local.get $1
  local.get $2
  i32.store offset=4
  local.get $1
 )
 (func $assembly/sdk/concat (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  local.get $0
  i32.load offset=8
  local.get $1
  i32.load offset=8
  i32.add
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  local.get $0
  i32.const 0
  call $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array>
  local.get $2
  local.get $1
  local.get $0
  i32.load offset=8
  call $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array>
  local.get $2
 )
 (func $~lib/typedarray/Uint8Array#constructor (param $0 i32) (result i32)
  (local $1 i32)
  (local $2 i32)
  i32.const 12
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $1
  i32.eqz
  if
   i32.const 12
   i32.const 3
   call $~lib/rt/stub/__new
   local.set $1
  end
  local.get $1
  i32.const 0
  i32.store
  local.get $1
  i32.const 0
  i32.store offset=4
  local.get $1
  i32.const 0
  i32.store offset=8
  local.get $0
  i32.const 1073741820
  i32.gt_u
  if
   i32.const 1456
   i32.const 1504
   i32.const 19
   i32.const 57
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.const 1
  call $~lib/rt/stub/__new
  local.tee $2
  i32.const 0
  local.get $0
  memory.fill
  local.get $1
  local.get $2
  i32.store
  local.get $1
  local.get $2
  i32.store offset=4
  local.get $1
  local.get $0
  i32.store offset=8
  local.get $1
 )
 (func $assembly/sdk/u64Bytes (param $0 i64) (result i32)
  (local $1 i32)
  (local $2 i32)
  i32.const 8
  call $~lib/typedarray/Uint8Array#constructor
  local.set $2
  loop $for-loop|0
   local.get $1
   i32.const 8
   i32.lt_s
   if
    local.get $2
    local.get $1
    local.get $0
    local.get $1
    i64.extend_i32_s
    i64.const 3
    i64.shl
    i64.shr_u
    i32.wrap_i64
    i32.const 255
    i32.and
    call $~lib/typedarray/Uint8Array#__set
    local.get $1
    i32.const 1
    i32.add
    local.set $1
    br $for-loop|0
   end
  end
  local.get $2
 )
 (func $~lib/string/String.__eq (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  local.get $0
  local.get $1
  i32.eq
  if
   i32.const 1
   return
  end
  local.get $1
  i32.eqz
  local.get $0
  i32.eqz
  i32.or
  if
   i32.const 0
   return
  end
  local.get $0
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.const 1
  i32.shr_u
  local.tee $3
  local.get $1
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.const 1
  i32.shr_u
  i32.ne
  if
   i32.const 0
   return
  end
  local.get $0
  local.set $2
  local.get $3
  local.tee $0
  i32.const 4
  i32.ge_u
  if (result i32)
   local.get $2
   i32.const 7
   i32.and
   local.get $1
   i32.const 7
   i32.and
   i32.or
  else
   i32.const 1
  end
  i32.eqz
  if
   loop $do-loop|0
    local.get $2
    i64.load
    local.get $1
    i64.load
    i64.eq
    if
     local.get $2
     i32.const 8
     i32.add
     local.set $2
     local.get $1
     i32.const 8
     i32.add
     local.set $1
     local.get $0
     i32.const 4
     i32.sub
     local.tee $0
     i32.const 4
     i32.ge_u
     br_if $do-loop|0
    end
   end
  end
  block $__inlined_func$~lib/util/string/compareImpl$72
   loop $while-continue|1
    local.get $0
    local.tee $3
    i32.const 1
    i32.sub
    local.set $0
    local.get $3
    if
     local.get $2
     i32.load16_u
     local.tee $5
     local.get $1
     i32.load16_u
     local.tee $4
     i32.sub
     local.set $3
     local.get $4
     local.get $5
     i32.ne
     br_if $__inlined_func$~lib/util/string/compareImpl$72
     local.get $2
     i32.const 2
     i32.add
     local.set $2
     local.get $1
     i32.const 2
     i32.add
     local.set $1
     br $while-continue|1
    end
   end
   i32.const 0
   local.set $3
  end
  local.get $3
  i32.eqz
 )
 (func $~lib/rt/stub/__new (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  local.get $0
  i32.const 1073741804
  i32.gt_u
  if
   i32.const 1088
   i32.const 1152
   i32.const 86
   i32.const 30
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.const 16
  i32.add
  call $~lib/rt/stub/__alloc
  local.tee $3
  i32.const 4
  i32.sub
  local.tee $2
  i32.const 0
  i32.store offset=4
  local.get $2
  i32.const 0
  i32.store offset=8
  local.get $2
  local.get $1
  i32.store offset=12
  local.get $2
  local.get $0
  i32.store offset=16
  local.get $3
  i32.const 16
  i32.add
 )
 (func $~lib/typedarray/Uint8Array#__set (param $0 i32) (param $1 i32) (param $2 i32)
  local.get $1
  local.get $0
  i32.load offset=8
  i32.ge_u
  if
   i32.const 1328
   i32.const 1392
   i32.const 178
   i32.const 45
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.load offset=4
  local.get $1
  i32.add
  local.get $2
  i32.store8
 )
 (func $assembly/sdk/Writer#push (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  local.get $0
  i32.load
  local.tee $2
  i32.load offset=12
  local.tee $5
  i32.const 1
  i32.add
  local.tee $3
  local.get $2
  i32.load offset=8
  local.tee $4
  i32.const 2
  i32.shr_u
  i32.gt_u
  if
   local.get $3
   i32.const 268435455
   i32.gt_u
   if
    i32.const 1456
    i32.const 3856
    i32.const 19
    i32.const 48
    call $~lib/builtins/abort
    unreachable
   end
   local.get $2
   i32.load
   local.tee $6
   i32.const 1073741820
   local.get $4
   i32.const 1
   i32.shl
   local.tee $7
   local.get $7
   i32.const 1073741820
   i32.ge_u
   select
   local.tee $7
   i32.const 8
   local.get $3
   local.get $3
   i32.const 8
   i32.le_u
   select
   i32.const 2
   i32.shl
   local.tee $8
   local.get $7
   local.get $8
   i32.gt_u
   select
   local.tee $7
   call $~lib/rt/stub/__renew
   local.tee $8
   local.get $4
   i32.add
   i32.const 0
   local.get $7
   local.get $4
   i32.sub
   memory.fill
   local.get $6
   local.get $8
   i32.ne
   if
    local.get $2
    local.get $8
    i32.store
    local.get $2
    local.get $8
    i32.store offset=4
   end
   local.get $2
   local.get $7
   i32.store offset=8
  end
  local.get $2
  i32.load offset=4
  local.get $5
  i32.const 2
  i32.shl
  i32.add
  local.get $1
  i32.store
  local.get $2
  local.get $3
  i32.store offset=12
  local.get $0
  local.get $0
  i32.load offset=4
  local.get $1
  i32.load offset=8
  i32.add
  i32.store offset=4
  local.get $0
 )
 (func $~lib/typedarray/Uint8Array#__get (param $0 i32) (param $1 i32) (result i32)
  local.get $1
  local.get $0
  i32.load offset=8
  i32.ge_u
  if
   i32.const 1328
   i32.const 1392
   i32.const 167
   i32.const 45
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.load offset=4
  local.get $1
  i32.add
  i32.load8_u
 )
 (func $assembly/sdk/load (param $0 i32) (result i32)
  (local $1 i32)
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_storage_len
  local.tee $1
  i32.const 0
  i32.lt_s
  if
   i32.const 0
   return
  end
  local.get $1
  call $~lib/typedarray/Uint8Array#constructor
  local.set $1
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $1
  i32.load offset=4
  call $assembly/sdk/_storage_read
  drop
  local.get $1
 )
 (func $assembly/sdk/Reader#u64 (param $0 i32) (param $1 i32) (result i64)
  (local $2 i64)
  local.get $0
  i32.const 1
  local.get $1
  call $assembly/sdk/Reader#tag
  local.get $0
  i32.load offset=4
  i32.load offset=8
  local.get $0
  i32.load
  i32.const 8
  i32.add
  i32.lt_s
  if
   i32.const 1936
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  call $assembly/sdk/bytesU64
  local.get $0
  local.get $0
  i32.load
  i32.const 8
  i32.add
  i32.store
 )
 (func $assembly/sdk/bytesU64 (param $0 i32) (param $1 i32) (result i64)
  (local $2 i32)
  (local $3 i64)
  loop $for-loop|0
   local.get $2
   i32.const 8
   i32.lt_s
   if
    local.get $3
    local.get $0
    local.get $1
    local.get $2
    i32.add
    call $~lib/typedarray/Uint8Array#__get
    i64.extend_i32_u
    local.get $2
    i64.extend_i32_s
    i64.const 3
    i64.shl
    i64.shl
    i64.or
    local.set $3
    local.get $2
    i32.const 1
    i32.add
    local.set $2
    br $for-loop|0
   end
  end
  local.get $3
 )
 (func $assembly/sdk/Reader#addr (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  local.get $0
  i32.const 3
  local.get $1
  call $assembly/sdk/Reader#tag
  local.get $0
  i32.load offset=4
  i32.load offset=8
  local.get $0
  i32.load
  i32.const 20
  i32.add
  i32.lt_s
  if
   i32.const 1936
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load
  local.tee $1
  i32.const 20
  i32.add
  local.set $2
  local.get $0
  i32.load offset=4
  local.tee $3
  i32.load offset=8
  local.set $4
  local.get $1
  i32.const 0
  i32.lt_s
  if (result i32)
   local.get $1
   local.get $4
   i32.add
   local.tee $1
   i32.const 0
   local.get $1
   i32.const 0
   i32.gt_s
   select
  else
   local.get $1
   local.get $4
   local.get $1
   local.get $4
   i32.lt_s
   select
  end
  local.set $1
  local.get $2
  i32.const 0
  i32.lt_s
  if (result i32)
   local.get $2
   local.get $4
   i32.add
   local.tee $2
   i32.const 0
   local.get $2
   i32.const 0
   i32.gt_s
   select
  else
   local.get $2
   local.get $4
   local.get $2
   local.get $4
   i32.lt_s
   select
  end
  local.get $1
  i32.sub
  local.tee $2
  i32.const 0
  local.get $2
  i32.const 0
  i32.gt_s
  select
  local.tee $2
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $4
  i32.load offset=4
  local.get $3
  i32.load offset=4
  local.get $1
  i32.add
  local.get $2
  memory.copy
  local.get $0
  local.get $0
  i32.load
  i32.const 20
  i32.add
  i32.store
  local.get $4
 )
 (func $assembly/sdk/saveU64 (param $0 i32) (param $1 i64)
  (local $2 i32)
  local.get $1
  call $assembly/sdk/u64Bytes
  local.set $2
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $2
  i32.load offset=4
  local.get $2
  i32.load offset=8
  call $assembly/sdk/_storage_write
 )
 (func $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array> (param $0 i32) (param $1 i32) (param $2 i32)
  (local $3 i32)
  local.get $1
  i32.load offset=8
  local.set $3
  local.get $2
  i32.const 0
  i32.lt_s
  if (result i32)
   i32.const 1
  else
   local.get $0
   i32.load offset=8
   local.get $2
   local.get $3
   i32.add
   i32.lt_s
  end
  if
   i32.const 1328
   i32.const 1392
   i32.const 1902
   i32.const 5
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.load offset=4
  local.get $2
  i32.add
  local.get $1
  i32.load offset=4
  local.get $3
  memory.copy
 )
 (func $~lib/string/String.__concat (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  i32.const 1824
  local.set $2
  local.get $0
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.const -2
  i32.and
  local.tee $3
  local.get $1
  i32.const 20
  i32.sub
  i32.load offset=16
  i32.const -2
  i32.and
  local.tee $4
  i32.add
  local.tee $5
  if
   local.get $5
   i32.const 2
   call $~lib/rt/stub/__new
   local.tee $2
   local.get $0
   local.get $3
   memory.copy
   local.get $2
   local.get $3
   i32.add
   local.get $1
   local.get $4
   memory.copy
  end
  local.get $2
 )
 (func $assembly/sdk/Reader#tag (param $0 i32) (param $1 i32) (param $2 i32)
  (local $3 i32)
  (local $4 i32)
  local.get $0
  i32.load
  local.get $0
  i32.load offset=4
  i32.load offset=8
  i32.lt_s
  i32.const 1760
  local.get $2
  call $~lib/string/String.__concat
  local.set $4
  i32.eqz
  if
   local.get $4
   call $assembly/sdk/utf8
   local.tee $3
   i32.load offset=4
   local.get $3
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  call $~lib/typedarray/Uint8Array#__get
  local.get $1
  i32.const 255
  i32.and
  i32.eq
  i32.const 1856
  local.get $2
  call $~lib/string/String.__concat
  local.set $2
  i32.eqz
  if
   local.get $2
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  local.get $0
  i32.load
  i32.const 1
  i32.add
  i32.store
 )
 (func $assembly/identity/onlyOwner
  (local $0 i32)
  (local $1 i32)
  (local $2 i32)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.load offset=4
  call $assembly/sdk/_caller
  call $assembly/identity/owner
  local.set $1
  block $__inlined_func$assembly/sdk/sameAddress$74 (result i32)
   i32.const 0
   local.get $2
   i32.load offset=8
   local.get $1
   i32.load offset=8
   i32.ne
   br_if $__inlined_func$assembly/sdk/sameAddress$74
   drop
   loop $for-loop|0
    local.get $0
    local.get $2
    i32.load offset=8
    i32.lt_s
    if
     i32.const 0
     local.get $2
     local.get $0
     call $~lib/typedarray/Uint8Array#__get
     local.get $1
     local.get $0
     call $~lib/typedarray/Uint8Array#__get
     i32.ne
     br_if $__inlined_func$assembly/sdk/sameAddress$74
     drop
     local.get $0
     i32.const 1
     i32.add
     local.set $0
     br $for-loop|0
    end
   end
   i32.const 1
  end
  i32.eqz
  if
   i32.const 2320
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
 )
 (func $~lib/rt/stub/__renew (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  local.get $1
  i32.const 1073741804
  i32.gt_u
  if
   i32.const 1088
   i32.const 1152
   i32.const 99
   i32.const 30
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.const 16
  i32.sub
  local.tee $0
  i32.const 15
  i32.and
  i32.const 1
  local.get $0
  select
  if
   i32.const 0
   i32.const 1152
   i32.const 45
   i32.const 3
   call $~lib/builtins/abort
   unreachable
  end
  global.get $~lib/rt/stub/offset
  local.get $0
  i32.const 4
  i32.sub
  local.tee $3
  i32.load
  local.tee $4
  local.get $0
  i32.add
  i32.eq
  local.set $5
  local.get $1
  i32.const 16
  i32.add
  local.tee $6
  i32.const 19
  i32.add
  i32.const -16
  i32.and
  i32.const 4
  i32.sub
  local.set $2
  local.get $4
  local.get $6
  i32.lt_u
  if
   local.get $5
   if
    local.get $6
    i32.const 1073741820
    i32.gt_u
    if
     i32.const 1088
     i32.const 1152
     i32.const 52
     i32.const 33
     call $~lib/builtins/abort
     unreachable
    end
    local.get $0
    local.get $2
    i32.add
    local.tee $4
    memory.size
    local.tee $5
    i32.const 16
    i32.shl
    i32.const 15
    i32.add
    i32.const -16
    i32.and
    local.tee $6
    i32.gt_u
    if
     local.get $5
     local.get $4
     local.get $6
     i32.sub
     i32.const 65535
     i32.add
     i32.const -65536
     i32.and
     i32.const 16
     i32.shr_u
     local.tee $6
     local.get $5
     local.get $6
     i32.gt_s
     select
     memory.grow
     i32.const 0
     i32.lt_s
     if
      local.get $6
      memory.grow
      i32.const 0
      i32.lt_s
      if
       unreachable
      end
     end
    end
    local.get $4
    global.set $~lib/rt/stub/offset
    local.get $3
    local.get $2
    i32.store
   else
    local.get $2
    local.get $4
    i32.const 1
    i32.shl
    local.tee $3
    local.get $2
    local.get $3
    i32.gt_u
    select
    call $~lib/rt/stub/__alloc
    local.tee $2
    local.get $0
    local.get $4
    memory.copy
    local.get $2
    local.set $0
   end
  else
   local.get $5
   if
    local.get $0
    local.get $2
    i32.add
    global.set $~lib/rt/stub/offset
    local.get $3
    local.get $2
    i32.store
   end
  end
  local.get $0
  i32.const 4
  i32.sub
  local.get $1
  i32.store offset=16
  local.get $0
  i32.const 16
  i32.add
 )
 (func $~lib/rt/stub/__alloc (param $0 i32) (result i32)
  (local $1 i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  local.get $0
  i32.const 1073741820
  i32.gt_u
  if
   i32.const 1088
   i32.const 1152
   i32.const 33
   i32.const 29
   call $~lib/builtins/abort
   unreachable
  end
  global.get $~lib/rt/stub/offset
  i32.const 4
  i32.add
  local.tee $1
  local.get $0
  i32.const 19
  i32.add
  i32.const -16
  i32.and
  i32.const 4
  i32.sub
  local.tee $0
  i32.add
  local.tee $2
  memory.size
  local.tee $3
  i32.const 16
  i32.shl
  i32.const 15
  i32.add
  i32.const -16
  i32.and
  local.tee $4
  i32.gt_u
  if
   local.get $3
   local.get $2
   local.get $4
   i32.sub
   i32.const 65535
   i32.add
   i32.const -65536
   i32.and
   i32.const 16
   i32.shr_u
   local.tee $4
   local.get $3
   local.get $4
   i32.gt_s
   select
   memory.grow
   i32.const 0
   i32.lt_s
   if
    local.get $4
    memory.grow
    i32.const 0
    i32.lt_s
    if
     unreachable
    end
   end
  end
  global.get $~lib/rt/stub/offset
  local.get $2
  global.set $~lib/rt/stub/offset
  local.get $0
  i32.store
  local.get $1
 )
 (func $~lib/array/Array<~lib/typedarray/Uint8Array>#__get (param $0 i32) (param $1 i32) (result i32)
  local.get $1
  local.get $0
  i32.load offset=12
  i32.ge_u
  if
   i32.const 1328
   i32.const 3856
   i32.const 114
   i32.const 42
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.load offset=4
  local.get $1
  i32.const 2
  i32.shl
  i32.add
  i32.load
  local.tee $0
  i32.eqz
  if
   i32.const 4160
   i32.const 3856
   i32.const 118
   i32.const 40
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
 )
 (func $assembly/sdk/saveFlag (param $0 i32) (param $1 i32)
  local.get $1
  if
   i32.const 1
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $1
   i32.const 0
   i32.const 1
   call $~lib/typedarray/Uint8Array#__set
   local.get $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   local.get $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_storage_write
  else
   local.get $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_storage_delete
  end
 )
 (func $assembly/identity/verified (param $0 i32) (param $1 i64) (result i32)
  (local $2 i64)
  (local $3 i64)
  (local $4 i64)
  i32.const 1056
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $0
  if (result i64)
   local.get $0
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $4
  i64.eqz
  if
   i32.const 0
   return
  end
  i64.const 1
  local.set $2
  loop $for-loop|0
   local.get $2
   i64.const 0
   i64.ne
   local.get $1
   local.get $2
   i64.ge_u
   i32.and
   if
    local.get $1
    local.get $2
    i64.and
    i64.const 0
    i64.ne
    if (result i32)
     i32.const 1568
     call $assembly/sdk/utf8
     local.get $4
     call $assembly/sdk/u64Bytes
     call $assembly/sdk/concat
     local.get $2
     call $assembly/sdk/u64Bytes
     call $assembly/sdk/concat
     call $assembly/sdk/load
     local.tee $0
     if (result i64)
      local.get $0
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     local.tee $3
     i64.eqz
     if (result i32)
      i32.const 0
     else
      local.get $3
      i64.const 1
      i64.eq
      if (result i32)
       i32.const 1
      else
       call $assembly/sdk/_height
       local.get $3
       i64.const 1
       i64.sub
       i64.lt_u
      end
     end
    else
     i32.const 1
    end
    i32.eqz
    if
     i32.const 0
     return
    end
    local.get $2
    i64.const 1
    i64.shl
    local.set $2
    br $for-loop|0
   end
  end
  i32.const 1
 )
 (func $assembly/identity/owner (result i32)
  (local $0 i32)
  i32.const 1600
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $0
  i32.eqz
  if
   i32.const 2128
   i32.const 2256
   i32.const 21
   i32.const 10
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
 )
 (func $assembly/identity/onlyAgent
  (local $0 i32)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=4
  call $assembly/sdk/_caller
  local.get $0
  call $assembly/identity/isAgent
  i32.eqz
  if
   i32.const 2736
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
 )
 (func $assembly/identity/isAgent (param $0 i32) (result i32)
  i32.const 1632
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $0
  if (result i32)
   local.get $0
   i32.load offset=8
   i32.const 0
   i32.gt_s
  else
   i32.const 0
  end
  if (result i32)
   local.get $0
   i32.const 0
   call $~lib/typedarray/Uint8Array#__get
   i32.const 1
   i32.eq
  else
   i32.const 0
  end
 )
 (func $~start
  i32.const 4268
  global.set $~lib/rt/stub/offset
 )
 (func $assembly/sdk/Reader#str (param $0 i32) (result i32)
  (local $1 i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  local.get $0
  i32.const 4
  i32.const 1728
  call $assembly/sdk/Reader#tag
  local.get $0
  i32.load offset=4
  i32.load offset=8
  local.get $0
  i32.load
  i32.const 4
  i32.add
  i32.lt_s
  if
   i32.const 1936
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  call $~lib/typedarray/Uint8Array#__get
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  i32.const 1
  i32.add
  call $~lib/typedarray/Uint8Array#__get
  i32.const 8
  i32.shl
  i32.or
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  i32.const 2
  i32.add
  call $~lib/typedarray/Uint8Array#__get
  i32.const 16
  i32.shl
  i32.or
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load
  i32.const 3
  i32.add
  call $~lib/typedarray/Uint8Array#__get
  i32.const 24
  i32.shl
  i32.or
  local.set $6
  local.get $0
  local.get $0
  i32.load
  i32.const 4
  i32.add
  i32.store
  local.get $6
  i32.const 0
  i32.ge_s
  if (result i32)
   local.get $0
   i32.load offset=4
   i32.load offset=8
   local.get $0
   i32.load
   local.get $6
   i32.add
   i32.ge_s
  else
   i32.const 0
  end
  i32.eqz
  if
   i32.const 1936
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load offset=4
  i32.load offset=4
  local.get $0
  i32.load
  i32.add
  local.tee $1
  local.get $6
  i32.add
  local.set $4
  local.get $1
  local.get $4
  i32.gt_u
  if
   i32.const 0
   i32.const 1280
   i32.const 770
   i32.const 7
   call $~lib/builtins/abort
   unreachable
  end
  local.get $6
  i32.const 1
  i32.shl
  i32.const 2
  call $~lib/rt/stub/__new
  local.tee $5
  local.set $3
  loop $while-continue|0
   local.get $1
   local.get $4
   i32.lt_u
   if
    block $while-break|0
     local.get $1
     i32.load8_u
     local.set $7
     local.get $1
     i32.const 1
     i32.add
     local.set $1
     local.get $7
     i32.const 128
     i32.and
     if
      local.get $1
      local.get $4
      i32.eq
      br_if $while-break|0
      local.get $1
      i32.load8_u
      i32.const 63
      i32.and
      local.set $8
      local.get $1
      i32.const 1
      i32.add
      local.set $1
      local.get $7
      i32.const 224
      i32.and
      i32.const 192
      i32.eq
      if
       local.get $3
       local.get $7
       i32.const 31
       i32.and
       i32.const 6
       i32.shl
       local.get $8
       i32.or
       i32.store16
      else
       local.get $1
       local.get $4
       i32.eq
       br_if $while-break|0
       local.get $1
       i32.load8_u
       i32.const 63
       i32.and
       local.set $2
       local.get $1
       i32.const 1
       i32.add
       local.set $1
       local.get $7
       i32.const 240
       i32.and
       i32.const 224
       i32.eq
       if
        local.get $7
        i32.const 15
        i32.and
        i32.const 12
        i32.shl
        local.get $8
        i32.const 6
        i32.shl
        i32.or
        local.get $2
        i32.or
        local.set $2
       else
        local.get $1
        local.get $4
        i32.eq
        br_if $while-break|0
        local.get $1
        i32.load8_u
        i32.const 63
        i32.and
        local.get $7
        i32.const 7
        i32.and
        i32.const 18
        i32.shl
        local.get $8
        i32.const 12
        i32.shl
        i32.or
        local.get $2
        i32.const 6
        i32.shl
        i32.or
        i32.or
        local.set $2
        local.get $1
        i32.const 1
        i32.add
        local.set $1
       end
       local.get $2
       i32.const 65536
       i32.lt_u
       if
        local.get $3
        local.get $2
        i32.store16
       else
        local.get $3
        local.get $2
        i32.const 65536
        i32.sub
        local.tee $2
        i32.const 10
        i32.shr_u
        i32.const 55296
        i32.or
        local.get $2
        i32.const 1023
        i32.and
        i32.const 56320
        i32.or
        i32.const 16
        i32.shl
        i32.or
        i32.store
        local.get $3
        i32.const 2
        i32.add
        local.set $3
       end
      end
     else
      local.get $3
      local.get $7
      i32.store16
     end
     local.get $3
     i32.const 2
     i32.add
     local.set $3
     br $while-continue|0
    end
   end
  end
  local.get $5
  local.get $3
  local.get $5
  i32.sub
  call $~lib/rt/stub/__renew
  local.get $0
  local.get $0
  i32.load
  local.get $6
  i32.add
  i32.store
 )
 (func $assembly/identity/init
  (local $0 i32)
  (local $1 i32)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=4
  call $assembly/sdk/_caller
  i32.const 1600
  call $assembly/sdk/utf8
  local.tee $1
  i32.load offset=4
  local.get $1
  i32.load offset=8
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 1632
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  i32.const 1
  call $assembly/sdk/saveFlag
  i32.const 1664
  call $assembly/sdk/utf8
  local.tee $1
  i32.load offset=4
  local.get $1
  i32.load offset=8
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_emit
 )
 (func $assembly/identity/call
  (local $0 i32)
  (local $1 i64)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i64)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  (local $9 i64)
  (local $10 i64)
  call $assembly/sdk/_input_len
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=8
  i32.const 0
  i32.gt_s
  if
   local.get $0
   i32.load offset=4
   call $assembly/sdk/_input_read
  end
  i32.const 8
  i32.const 5
  call $~lib/rt/stub/__new
  local.tee $6
  local.get $0
  i32.store offset=4
  local.get $6
  i32.const 0
  i32.store
  local.get $6
  call $assembly/sdk/Reader#str
  local.set $7
  i32.const 8
  i32.const 6
  call $~lib/rt/stub/__new
  local.tee $0
  i32.eqz
  if
   i32.const 0
   i32.const 0
   call $~lib/rt/stub/__new
   local.set $0
  end
  i32.const 0
  i32.const 1
  call $~lib/rt/stub/__new
  local.tee $8
  i32.const 2000
  i32.const 0
  memory.copy
  i32.const 16
  i32.const 7
  call $~lib/rt/stub/__new
  local.tee $4
  local.get $8
  i32.store
  local.get $4
  local.get $8
  i32.store offset=4
  local.get $4
  i32.const 0
  i32.store offset=8
  local.get $4
  i32.const 0
  i32.store offset=12
  local.get $0
  local.get $4
  i32.store
  local.get $0
  i32.const 0
  i32.store offset=4
  local.get $7
  i32.const 2032
  call $~lib/string/String.__eq
  if (result i32)
   i32.const 1
  else
   local.get $7
   i32.const 2080
   call $~lib/string/String.__eq
  end
  if
   call $assembly/identity/onlyOwner
   local.get $6
   i32.const 2416
   call $assembly/sdk/Reader#addr
   local.set $4
   i32.const 1632
   call $assembly/sdk/utf8
   local.get $4
   call $assembly/sdk/concat
   local.get $7
   i32.const 2032
   call $~lib/string/String.__eq
   call $assembly/sdk/saveFlag
  else
   local.get $7
   i32.const 2448
   call $~lib/string/String.__eq
   if
    call $assembly/identity/onlyOwner
    local.get $6
    i32.const 2496
    call $assembly/sdk/Reader#addr
    local.set $4
    i32.const 2528
    call $assembly/sdk/utf8
    local.get $4
    call $assembly/sdk/concat
    local.get $6
    i32.const 2560
    call $assembly/sdk/Reader#u64
    call $assembly/sdk/saveU64
    i32.const 2592
    call $assembly/sdk/utf8
    local.tee $6
    i32.load offset=4
    local.get $6
    i32.load offset=8
    local.get $4
    i32.load offset=4
    local.get $4
    i32.load offset=8
    call $assembly/sdk/_emit
   else
    local.get $7
    i32.const 2640
    call $~lib/string/String.__eq
    if
     call $assembly/identity/onlyOwner
     local.get $6
     i32.const 2496
     call $assembly/sdk/Reader#addr
     local.set $4
     i32.const 2528
     call $assembly/sdk/utf8
     local.get $4
     call $assembly/sdk/concat
     local.tee $4
     i32.load offset=4
     local.get $4
     i32.load offset=8
     call $assembly/sdk/_storage_delete
    else
     local.get $7
     i32.const 2688
     call $~lib/string/String.__eq
     if
      call $assembly/identity/onlyAgent
      local.get $6
      i32.const 2832
      call $assembly/sdk/Reader#addr
      local.set $4
      local.get $6
      i32.const 2864
      call $assembly/sdk/Reader#u64
      local.set $1
      local.get $6
      i32.const 2912
      call $assembly/sdk/Reader#u64
      local.set $5
      local.get $1
      i64.eqz
      if
       i32.const 2960
       call $assembly/sdk/utf8
       local.tee $6
       i32.load offset=4
       local.get $6
       i32.load offset=8
       call $assembly/sdk/_revert
      end
      i32.const 1056
      call $assembly/sdk/utf8
      local.get $4
      call $assembly/sdk/concat
      local.get $1
      call $assembly/sdk/saveU64
      i32.const 3040
      call $assembly/sdk/utf8
      local.get $1
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/concat
      local.get $5
      call $assembly/sdk/saveU64
      local.get $4
      local.get $1
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/concat
      local.set $4
      i32.const 3072
      call $assembly/sdk/utf8
      local.tee $6
      i32.load offset=4
      local.get $6
      i32.load offset=8
      local.get $4
      i32.load offset=4
      local.get $4
      i32.load offset=8
      call $assembly/sdk/_emit
     else
      local.get $7
      i32.const 3120
      call $~lib/string/String.__eq
      if
       call $assembly/identity/onlyAgent
       local.get $6
       i32.const 2832
       call $assembly/sdk/Reader#addr
       local.set $4
       i32.const 1056
       call $assembly/sdk/utf8
       local.get $4
       call $assembly/sdk/concat
       local.tee $6
       i32.load offset=4
       local.get $6
       i32.load offset=8
       call $assembly/sdk/_storage_delete
       i32.const 3168
       call $assembly/sdk/utf8
       local.tee $6
       i32.load offset=4
       local.get $6
       i32.load offset=8
       local.get $4
       i32.load offset=4
       local.get $4
       i32.load offset=8
       call $assembly/sdk/_emit
      else
       local.get $7
       i32.const 3216
       call $~lib/string/String.__eq
       if
        local.get $6
        i32.const 2864
        call $assembly/sdk/Reader#u64
        local.set $9
        local.get $6
        i32.const 3264
        call $assembly/sdk/Reader#u64
        local.set $1
        local.get $6
        i32.const 3296
        call $assembly/sdk/Reader#u64
        local.set $10
        i32.const 20
        call $~lib/typedarray/Uint8Array#constructor
        local.tee $4
        i32.load offset=4
        call $assembly/sdk/_caller
        i32.const 2528
        call $assembly/sdk/utf8
        local.get $4
        call $assembly/sdk/concat
        call $assembly/sdk/load
        local.tee $4
        if (result i64)
         local.get $4
         i32.const 0
         call $assembly/sdk/bytesU64
        else
         i64.const 0
        end
        local.set $5
        local.get $1
        local.get $1
        i64.const 1
        i64.sub
        i64.and
        i64.eqz
        local.get $1
        i64.const 0
        i64.ne
        i32.and
        i32.eqz
        if
         i32.const 3376
         call $assembly/sdk/utf8
         local.tee $4
         i32.load offset=4
         local.get $4
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        local.get $1
        local.get $5
        i64.and
        i64.eqz
        if
         i32.const 3472
         call $assembly/sdk/utf8
         local.tee $4
         i32.load offset=4
         local.get $4
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        i32.const 1568
        call $assembly/sdk/utf8
        local.get $9
        call $assembly/sdk/u64Bytes
        call $assembly/sdk/concat
        local.get $1
        call $assembly/sdk/u64Bytes
        call $assembly/sdk/concat
        local.get $10
        i64.const 1
        i64.add
        call $assembly/sdk/saveU64
        local.get $9
        call $assembly/sdk/u64Bytes
        local.get $1
        call $assembly/sdk/u64Bytes
        call $assembly/sdk/concat
        local.set $4
        i32.const 3584
        call $assembly/sdk/utf8
        local.tee $6
        i32.load offset=4
        local.get $6
        i32.load offset=8
        local.get $4
        i32.load offset=4
        local.get $4
        i32.load offset=8
        call $assembly/sdk/_emit
       else
        local.get $7
        i32.const 3632
        call $~lib/string/String.__eq
        if
         local.get $6
         i32.const 2864
         call $assembly/sdk/Reader#u64
         local.set $1
         local.get $6
         i32.const 3264
         call $assembly/sdk/Reader#u64
         local.set $5
         i32.const 20
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $4
         i32.load offset=4
         call $assembly/sdk/_caller
         i32.const 2528
         call $assembly/sdk/utf8
         local.get $4
         call $assembly/sdk/concat
         call $assembly/sdk/load
         local.tee $4
         if (result i64)
          local.get $4
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         local.get $5
         i64.and
         i64.const 0
         i64.ne
         if (result i32)
          i32.const 1
         else
          i32.const 20
          call $~lib/typedarray/Uint8Array#constructor
          local.tee $4
          i32.load offset=4
          call $assembly/sdk/_caller
          local.get $4
          call $assembly/identity/isAgent
         end
         i32.eqz
         if
          i32.const 3680
          call $assembly/sdk/utf8
          local.tee $4
          i32.load offset=4
          local.get $4
          i32.load offset=8
          call $assembly/sdk/_revert
         end
         i32.const 1568
         call $assembly/sdk/utf8
         local.get $1
         call $assembly/sdk/u64Bytes
         call $assembly/sdk/concat
         local.get $5
         call $assembly/sdk/u64Bytes
         call $assembly/sdk/concat
         local.tee $4
         i32.load offset=4
         local.get $4
         i32.load offset=8
         call $assembly/sdk/_storage_delete
         local.get $1
         call $assembly/sdk/u64Bytes
         local.get $5
         call $assembly/sdk/u64Bytes
         call $assembly/sdk/concat
         local.set $4
         i32.const 3760
         call $assembly/sdk/utf8
         local.tee $6
         i32.load offset=4
         local.get $6
         i32.load offset=8
         local.get $4
         i32.load offset=4
         local.get $4
         i32.load offset=8
         call $assembly/sdk/_emit
        else
         local.get $7
         i32.const 3808
         call $~lib/string/String.__eq
         if
          local.get $6
          i32.const 2832
          call $assembly/sdk/Reader#addr
          local.get $6
          i32.const 2560
          call $assembly/sdk/Reader#u64
          call $assembly/identity/verified
          i32.const 0
          i32.ne
          i64.extend_i32_u
          local.set $1
          i32.const 1
          call $~lib/typedarray/Uint8Array#constructor
          local.tee $4
          i32.const 0
          i32.const 1
          call $~lib/typedarray/Uint8Array#__set
          local.get $0
          local.get $4
          call $assembly/sdk/Writer#push
          drop
          local.get $0
          local.get $1
          call $assembly/sdk/u64Bytes
          call $assembly/sdk/Writer#push
          drop
         else
          local.get $7
          i32.const 3904
          call $~lib/string/String.__eq
          if
           local.get $6
           i32.const 2832
           call $assembly/sdk/Reader#addr
           local.set $4
           i32.const 1056
           call $assembly/sdk/utf8
           local.get $4
           call $assembly/sdk/concat
           call $assembly/sdk/load
           local.tee $4
           if (result i64)
            local.get $4
            i32.const 0
            call $assembly/sdk/bytesU64
           else
            i64.const 0
           end
           local.set $1
           i32.const 1
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $4
           i32.const 0
           i32.const 1
           call $~lib/typedarray/Uint8Array#__set
           local.get $0
           local.get $4
           call $assembly/sdk/Writer#push
           drop
           local.get $0
           local.get $1
           call $assembly/sdk/u64Bytes
           call $assembly/sdk/Writer#push
           drop
          else
           local.get $7
           i32.const 3952
           call $~lib/string/String.__eq
           if
            local.get $6
            i32.const 2832
            call $assembly/sdk/Reader#addr
            local.set $4
            i32.const 1056
            call $assembly/sdk/utf8
            local.get $4
            call $assembly/sdk/concat
            call $assembly/sdk/load
            local.tee $4
            if (result i64)
             local.get $4
             i32.const 0
             call $assembly/sdk/bytesU64
            else
             i64.const 0
            end
            local.tee $1
            i64.eqz
            if (result i64)
             i64.const 0
            else
             i32.const 3040
             call $assembly/sdk/utf8
             local.get $1
             call $assembly/sdk/u64Bytes
             call $assembly/sdk/concat
             call $assembly/sdk/load
             local.tee $4
             if (result i64)
              local.get $4
              i32.const 0
              call $assembly/sdk/bytesU64
             else
              i64.const 0
             end
            end
            local.set $1
            i32.const 1
            call $~lib/typedarray/Uint8Array#constructor
            local.tee $4
            i32.const 0
            i32.const 1
            call $~lib/typedarray/Uint8Array#__set
            local.get $0
            local.get $4
            call $assembly/sdk/Writer#push
            drop
            local.get $0
            local.get $1
            call $assembly/sdk/u64Bytes
            call $assembly/sdk/Writer#push
            drop
           else
            local.get $7
            i32.const 4000
            call $~lib/string/String.__eq
            if
             i32.const 4032
             call $assembly/sdk/utf8
             local.set $4
             i32.const 1
             call $~lib/typedarray/Uint8Array#constructor
             local.tee $6
             i32.const 0
             i32.const 4
             call $~lib/typedarray/Uint8Array#__set
             local.get $0
             local.get $6
             call $assembly/sdk/Writer#push
             drop
             local.get $4
             i32.load offset=8
             local.set $6
             i32.const 4
             call $~lib/typedarray/Uint8Array#constructor
             local.tee $7
             i32.const 0
             local.get $6
             i32.const 255
             i32.and
             call $~lib/typedarray/Uint8Array#__set
             local.get $7
             i32.const 1
             local.get $6
             i32.const 8
             i32.shr_s
             i32.const 255
             i32.and
             call $~lib/typedarray/Uint8Array#__set
             local.get $7
             i32.const 2
             local.get $6
             i32.const 16
             i32.shr_s
             i32.const 255
             i32.and
             call $~lib/typedarray/Uint8Array#__set
             local.get $7
             i32.const 3
             local.get $6
             i32.const 24
             i32.shr_s
             call $~lib/typedarray/Uint8Array#__set
             local.get $0
             local.get $7
             call $assembly/sdk/Writer#push
             drop
             local.get $0
             local.get $4
             call $assembly/sdk/Writer#push
             local.set $4
             call $assembly/identity/owner
             local.set $6
             i32.const 1
             call $~lib/typedarray/Uint8Array#constructor
             local.tee $7
             i32.const 0
             i32.const 3
             call $~lib/typedarray/Uint8Array#__set
             local.get $4
             local.get $7
             call $assembly/sdk/Writer#push
             drop
             local.get $4
             local.get $6
             call $assembly/sdk/Writer#push
             drop
            else
             i32.const 4096
             local.get $7
             call $~lib/string/String.__concat
             call $assembly/sdk/utf8
             local.tee $4
             i32.load offset=4
             local.get $4
             i32.load offset=8
             call $assembly/sdk/_revert
            end
           end
          end
         end
        end
       end
      end
     end
    end
   end
  end
  local.get $0
  i32.load offset=4
  call $~lib/typedarray/Uint8Array#constructor
  local.set $4
  loop $for-loop|0
   local.get $2
   local.get $0
   i32.load
   local.tee $6
   i32.load offset=12
   i32.lt_s
   if
    local.get $4
    local.get $6
    local.get $2
    call $~lib/array/Array<~lib/typedarray/Uint8Array>#__get
    local.get $3
    call $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array>
    local.get $3
    local.get $0
    i32.load
    local.get $2
    call $~lib/array/Array<~lib/typedarray/Uint8Array>#__get
    i32.load offset=8
    i32.add
    local.set $3
    local.get $2
    i32.const 1
    i32.add
    local.set $2
    br $for-loop|0
   end
  end
  local.get $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  call $assembly/sdk/_output
 )
)
