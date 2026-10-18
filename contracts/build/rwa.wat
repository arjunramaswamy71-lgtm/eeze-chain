(module
 (type $0 (func (param i32 i32) (result i32)))
 (type $1 (func (param i32) (result i32)))
 (type $2 (func (param i32 i32)))
 (type $3 (func))
 (type $4 (func (param i32 i32 i32 i32)))
 (type $5 (func (param i32 i32 i32)))
 (type $6 (func (param i32)))
 (type $7 (func (param i32 i32) (result i64)))
 (type $8 (func (param i32 i64)))
 (type $9 (func (result i32)))
 (type $10 (func (param i64) (result i32)))
 (type $11 (func (result i64)))
 (type $12 (func (param i64 i64) (result i32)))
 (type $13 (func (param i32 i64) (result i64)))
 (type $14 (func (param i32 i32 i64)))
 (type $15 (func (param i32) (result i64)))
 (type $16 (func (param i32 i64) (result i32)))
 (type $17 (func (param i32 i32 i32) (result i32)))
 (import "env" "revert" (func $assembly/sdk/_revert (param i32 i32)))
 (import "env" "abort" (func $~lib/builtins/abort (param i32 i32 i32 i32)))
 (import "env" "storage_write" (func $assembly/sdk/_storage_write (param i32 i32 i32 i32)))
 (import "env" "emit" (func $assembly/sdk/_emit (param i32 i32 i32 i32)))
 (import "env" "caller" (func $assembly/sdk/_caller (param i32)))
 (import "env" "value" (func $assembly/sdk/_value (result i64)))
 (import "env" "input_read" (func $assembly/sdk/_input_read (param i32)))
 (import "env" "input_len" (func $assembly/sdk/_input_len (result i32)))
 (import "env" "transfer" (func $assembly/sdk/_transfer (param i32 i64) (result i32)))
 (import "env" "storage_read" (func $assembly/sdk/_storage_read (param i32 i32 i32) (result i32)))
 (import "env" "storage_len" (func $assembly/sdk/_storage_len (param i32 i32) (result i32)))
 (import "env" "storage_delete" (func $assembly/sdk/_storage_delete (param i32 i32)))
 (import "env" "output" (func $assembly/sdk/_output (param i32 i32)))
 (global $~lib/rt/stub/offset (mut i32) (i32.const 0))
 (memory $0 1)
 (data $0 (i32.const 1036) "<")
 (data $0.1 (i32.const 1048) "\02\00\00\00(\00\00\00A\00l\00l\00o\00c\00a\00t\00i\00o\00n\00 \00t\00o\00o\00 \00l\00a\00r\00g\00e")
 (data $1 (i32.const 1100) "<")
 (data $1.1 (i32.const 1112) "\02\00\00\00\1e\00\00\00~\00l\00i\00b\00/\00r\00t\00/\00s\00t\00u\00b\00.\00t\00s")
 (data $2 (i32.const 1164) ",")
 (data $2.1 (i32.const 1176) "\02\00\00\00\1c\00\00\00I\00n\00v\00a\00l\00i\00d\00 \00l\00e\00n\00g\00t\00h")
 (data $3 (i32.const 1212) "<")
 (data $3.1 (i32.const 1224) "\02\00\00\00&\00\00\00~\00l\00i\00b\00/\00a\00r\00r\00a\00y\00b\00u\00f\00f\00e\00r\00.\00t\00s")
 (data $4 (i32.const 1276) "\1c")
 (data $4.1 (i32.const 1288) "\02\00\00\00\08\00\00\00n\00a\00m\00e")
 (data $5 (i32.const 1308) "<")
 (data $5.1 (i32.const 1320) "\02\00\00\00$\00\00\00m\00i\00s\00s\00i\00n\00g\00 \00a\00r\00g\00u\00m\00e\00n\00t\00:\00 ")
 (data $6 (i32.const 1372) "\1c")
 (data $6.1 (i32.const 1384) "\02")
 (data $7 (i32.const 1404) "<")
 (data $7.1 (i32.const 1416) "\02\00\00\00$\00\00\00U\00n\00p\00a\00i\00r\00e\00d\00 \00s\00u\00r\00r\00o\00g\00a\00t\00e")
 (data $8 (i32.const 1468) ",")
 (data $8.1 (i32.const 1480) "\02\00\00\00\1c\00\00\00~\00l\00i\00b\00/\00s\00t\00r\00i\00n\00g\00.\00t\00s")
 (data $9 (i32.const 1516) "<")
 (data $9.1 (i32.const 1528) "\02\00\00\00$\00\00\00I\00n\00d\00e\00x\00 \00o\00u\00t\00 \00o\00f\00 \00r\00a\00n\00g\00e")
 (data $10 (i32.const 1580) "<")
 (data $10.1 (i32.const 1592) "\02\00\00\00$\00\00\00~\00l\00i\00b\00/\00t\00y\00p\00e\00d\00a\00r\00r\00a\00y\00.\00t\00s")
 (data $11 (i32.const 1644) "L")
 (data $11.1 (i32.const 1656) "\02\00\00\002\00\00\00w\00r\00o\00n\00g\00 \00t\00y\00p\00e\00 \00f\00o\00r\00 \00a\00r\00g\00u\00m\00e\00n\00t\00:\00 ")
 (data $12 (i32.const 1724) "<")
 (data $12.1 (i32.const 1736) "\02\00\00\00$\00\00\00a\00r\00g\00u\00m\00e\00n\00t\00 \00c\00u\00t\00 \00s\00h\00o\00r\00t")
 (data $13 (i32.const 1788) "\1c")
 (data $13.1 (i32.const 1800) "\02\00\00\00\0c\00\00\00s\00y\00m\00b\00o\00l")
 (data $14 (i32.const 1820) ",")
 (data $14.1 (i32.const 1832) "\02\00\00\00\18\00\00\00t\00o\00t\00a\00l\00 \00s\00h\00a\00r\00e\00s")
 (data $15 (i32.const 1868) "\1c")
 (data $15.1 (i32.const 1880) "\02\00\00\00\n\00\00\00p\00r\00i\00c\00e")
 (data $16 (i32.const 1900) ",")
 (data $16.1 (i32.const 1912) "\02\00\00\00\10\00\00\00d\00o\00c\00u\00m\00e\00n\00t")
 (data $17 (i32.const 1948) "L")
 (data $17.1 (i32.const 1960) "\02\00\00\00.\00\00\00n\00e\00e\00d\00 \00a\00t\00 \00l\00e\00a\00s\00t\00 \00o\00n\00e\00 \00s\00h\00a\00r\00e")
 (data $18 (i32.const 2028) "\1c")
 (data $18.1 (i32.const 2040) "\02\00\00\00\06\00\00\00d\00o\00c")
 (data $19 (i32.const 2060) "\1c")
 (data $19.1 (i32.const 2072) "\02\00\00\00\0c\00\00\00i\00s\00s\00u\00e\00r")
 (data $20 (i32.const 2092) "\1c")
 (data $20.1 (i32.const 2104) "\02\00\00\00\n\00\00\00t\00o\00t\00a\00l")
 (data $21 (i32.const 2124) "\1c")
 (data $21.1 (i32.const 2136) "\02\00\00\00\08\00\00\00k\00y\00c\00:")
 (data $22 (i32.const 2156) "\1c")
 (data $22.1 (i32.const 2168) "\02\00\00\00\08\00\00\00b\00a\00l\00:")
 (data $23 (i32.const 2188) "\1c")
 (data $23.1 (i32.const 2200) "\02\00\00\00\0c\00\00\00I\00s\00s\00u\00e\00d")
 (data $24 (i32.const 2220) "\1c")
 (data $24.1 (i32.const 2232) "\02\00\00\00\0c\00\00\00m\00e\00t\00h\00o\00d")
 (data $25 (i32.const 2252) "\1c")
 (data $25.1 (i32.const 2264) "\01")
 (data $26 (i32.const 2284) ",")
 (data $26.1 (i32.const 2296) "\02\00\00\00\10\00\00\00t\00r\00a\00n\00s\00f\00e\00r")
 (data $27 (i32.const 2332) "\1c")
 (data $27.1 (i32.const 2344) "\02\00\00\00\04\00\00\00t\00o")
 (data $28 (i32.const 2364) "\1c")
 (data $28.1 (i32.const 2376) "\02\00\00\00\0c\00\00\00a\00m\00o\00u\00n\00t")
 (data $29 (i32.const 2396) "<")
 (data $29.1 (i32.const 2408) "\02\00\00\00,\00\00\00y\00o\00u\00 \00h\00a\00v\00e\00n\00\'\00t\00 \00p\00a\00s\00s\00e\00d\00 \00K\00Y\00C")
 (data $30 (i32.const 2460) "L")
 (data $30.1 (i32.const 2472) "\02\00\00\004\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00 \00h\00a\00s\00n\00\'\00t\00 \00p\00a\00s\00s\00e\00d\00 \00K\00Y\00C")
 (data $31 (i32.const 2540) "\1c")
 (data $31.1 (i32.const 2552) "\02\00\00\00\08\00\00\00f\00r\00z\00:")
 (data $32 (i32.const 2572) "L")
 (data $32.1 (i32.const 2584) "\02\00\00\004\00\00\00s\00e\00n\00d\00e\00r\00\'\00s\00 \00a\00c\00c\00o\00u\00n\00t\00 \00i\00s\00 \00f\00r\00o\00z\00e\00n")
 (data $33 (i32.const 2652) "L")
 (data $33.1 (i32.const 2664) "\02\00\00\008\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00\'\00s\00 \00a\00c\00c\00o\00u\00n\00t\00 \00i\00s\00 \00f\00r\00o\00z\00e\00n")
 (data $34 (i32.const 2732) "<")
 (data $34.1 (i32.const 2744) "\02\00\00\00\"\00\00\00n\00o\00t\00 \00e\00n\00o\00u\00g\00h\00 \00s\00h\00a\00r\00e\00s")
 (data $35 (i32.const 2796) "\1c")
 (data $35.1 (i32.const 2808) "\02\00\00\00\n\00\00\00o\00w\00e\00d\00:")
 (data $36 (i32.const 2828) "\1c")
 (data $36.1 (i32.const 2840) "\02\00\00\00\06\00\00\00a\00c\00c")
 (data $37 (i32.const 2860) "\1c")
 (data $37.1 (i32.const 2872) "\02\00\00\00\n\00\00\00l\00a\00s\00t\00:")
 (data $38 (i32.const 2892) ",")
 (data $38.1 (i32.const 2904) "\02\00\00\00\1c\00\00\00d\00i\00v\00i\00d\00e\00 \00b\00y\00 \00z\00e\00r\00o")
 (data $39 (i32.const 2940) ",")
 (data $39.1 (i32.const 2952) "\02\00\00\00\1c\00\00\00n\00u\00m\00b\00e\00r\00 \00t\00o\00o\00 \00b\00i\00g")
 (data $40 (i32.const 2988) ",")
 (data $40.1 (i32.const 3000) "\02\00\00\00\10\00\00\00T\00r\00a\00n\00s\00f\00e\00r")
 (data $41 (i32.const 3036) "\1c")
 (data $41.1 (i32.const 3048) "\02\00\00\00\06\00\00\00b\00u\00y")
 (data $42 (i32.const 3068) "\\")
 (data $42.1 (i32.const 3080) "\02\00\00\00B\00\00\00s\00h\00a\00r\00e\00s\00 \00a\00r\00e\00 \00n\00o\00t\00 \00f\00o\00r\00 \00s\00a\00l\00e\00 \00r\00i\00g\00h\00t\00 \00n\00o\00w")
 (data $43 (i32.const 3164) "L")
 (data $43.1 (i32.const 3176) "\02\00\00\006\00\00\00s\00e\00n\00d\00 \00e\00x\00a\00c\00t\00l\00y\00 \00p\00r\00i\00c\00e\00 \00x\00 \00a\00m\00o\00u\00n\00t")
 (data $44 (i32.const 3244) "|")
 (data $44.1 (i32.const 3256) "\02\00\00\00^\00\00\00U\00n\00e\00x\00p\00e\00c\00t\00e\00d\00 \00\'\00n\00u\00l\00l\00\'\00 \00(\00n\00o\00t\00 \00a\00s\00s\00i\00g\00n\00e\00d\00 \00o\00r\00 \00f\00a\00i\00l\00e\00d\00 \00c\00a\00s\00t\00)")
 (data $45 (i32.const 3372) "<")
 (data $45.1 (i32.const 3384) "\02\00\00\00\1e\00\00\00a\00s\00s\00e\00m\00b\00l\00y\00/\00r\00w\00a\00.\00t\00s")
 (data $46 (i32.const 3436) "\\")
 (data $46.1 (i32.const 3448) "\02\00\00\00B\00\00\00c\00o\00n\00t\00r\00a\00c\00t\00 \00d\00o\00e\00s\00n\00\'\00t\00 \00h\00a\00v\00e\00 \00e\00n\00o\00u\00g\00h\00 \00C\00T\00D\00Y")
 (data $47 (i32.const 3532) "\1c")
 (data $47.1 (i32.const 3544) "\02\00\00\00\06\00\00\00B\00u\00y")
 (data $48 (i32.const 3564) ",")
 (data $48.1 (i32.const 3576) "\02\00\00\00\14\00\00\00d\00i\00s\00t\00r\00i\00b\00u\00t\00e")
 (data $49 (i32.const 3612) "L")
 (data $49.1 (i32.const 3624) "\02\00\00\008\00\00\00s\00e\00n\00d\00 \00s\00o\00m\00e\00 \00C\00T\00D\00Y\00 \00t\00o\00 \00d\00i\00s\00t\00r\00i\00b\00u\00t\00e")
 (data $50 (i32.const 3692) "\1c")
 (data $50.1 (i32.const 3704) "\02\00\00\00\08\00\00\00p\00a\00i\00d")
 (data $51 (i32.const 3724) ",")
 (data $51.1 (i32.const 3736) "\02\00\00\00\10\00\00\00D\00i\00v\00i\00d\00e\00n\00d")
 (data $52 (i32.const 3772) "\1c")
 (data $52.1 (i32.const 3784) "\02\00\00\00\n\00\00\00c\00l\00a\00i\00m")
 (data $53 (i32.const 3804) "<")
 (data $53.1 (i32.const 3816) "\02\00\00\00 \00\00\00n\00o\00t\00h\00i\00n\00g\00 \00t\00o\00 \00c\00l\00a\00i\00m")
 (data $54 (i32.const 3868) "\1c")
 (data $54.1 (i32.const 3880) "\02\00\00\00\n\00\00\00C\00l\00a\00i\00m")
 (data $55 (i32.const 3900) ",")
 (data $55.1 (i32.const 3912) "\02\00\00\00\1a\00\00\00~\00l\00i\00b\00/\00a\00r\00r\00a\00y\00.\00t\00s")
 (data $56 (i32.const 3948) ",")
 (data $56.1 (i32.const 3960) "\02\00\00\00\0e\00\00\00a\00p\00p\00r\00o\00v\00e")
 (data $57 (i32.const 3996) "\1c")
 (data $57.1 (i32.const 4008) "\02\00\00\00\0c\00\00\00r\00e\00v\00o\00k\00e")
 (data $58 (i32.const 4028) "L")
 (data $58.1 (i32.const 4040) "\02\00\00\006\00\00\00o\00n\00l\00y\00 \00t\00h\00e\00 \00i\00s\00s\00u\00e\00r\00 \00c\00a\00n\00 \00d\00o\00 \00t\00h\00i\00s")
 (data $59 (i32.const 4108) "\1c")
 (data $59.1 (i32.const 4120) "\02\00\00\00\06\00\00\00w\00h\00o")
 (data $60 (i32.const 4140) ",")
 (data $60.1 (i32.const 4152) "\02\00\00\00\10\00\00\00A\00p\00p\00r\00o\00v\00e\00d")
 (data $61 (i32.const 4188) ",")
 (data $61.1 (i32.const 4200) "\02\00\00\00\0e\00\00\00R\00e\00v\00o\00k\00e\00d")
 (data $62 (i32.const 4236) "\1c")
 (data $62.1 (i32.const 4248) "\02\00\00\00\0c\00\00\00f\00r\00e\00e\00z\00e")
 (data $63 (i32.const 4268) ",")
 (data $63.1 (i32.const 4280) "\02\00\00\00\10\00\00\00u\00n\00f\00r\00e\00e\00z\00e")
 (data $64 (i32.const 4316) "\1c")
 (data $64.1 (i32.const 4328) "\02\00\00\00\0c\00\00\00F\00r\00o\00z\00e\00n")
 (data $65 (i32.const 4348) ",")
 (data $65.1 (i32.const 4360) "\02\00\00\00\10\00\00\00U\00n\00f\00r\00o\00z\00e\00n")
 (data $66 (i32.const 4396) ",")
 (data $66.1 (i32.const 4408) "\02\00\00\00\12\00\00\00s\00e\00t\00_\00p\00r\00i\00c\00e")
 (data $67 (i32.const 4444) ",")
 (data $67.1 (i32.const 4456) "\02\00\00\00\1c\00\00\00f\00o\00r\00c\00e\00_\00t\00r\00a\00n\00s\00f\00e\00r")
 (data $68 (i32.const 4492) "\1c")
 (data $68.1 (i32.const 4504) "\02\00\00\00\08\00\00\00f\00r\00o\00m")
 (data $69 (i32.const 4524) ",")
 (data $69.1 (i32.const 4536) "\02\00\00\00\1c\00\00\00F\00o\00r\00c\00e\00d\00T\00r\00a\00n\00s\00f\00e\00r")
 (data $70 (i32.const 4572) "\1c")
 (data $70.1 (i32.const 4584) "\02\00\00\00\08\00\00\00i\00n\00f\00o")
 (data $71 (i32.const 4604) ",")
 (data $71.1 (i32.const 4616) "\02\00\00\00\14\00\00\00b\00a\00l\00a\00n\00c\00e\00_\00o\00f")
 (data $72 (i32.const 4652) ",")
 (data $72.1 (i32.const 4664) "\02\00\00\00\12\00\00\00c\00l\00a\00i\00m\00a\00b\00l\00e")
 (data $73 (i32.const 4700) "\1c")
 (data $73.1 (i32.const 4712) "\02\00\00\00\0c\00\00\00s\00t\00a\00t\00u\00s")
 (data $74 (i32.const 4732) "<")
 (data $74.1 (i32.const 4744) "\02\00\00\00 \00\00\00u\00n\00k\00n\00o\00w\00n\00 \00m\00e\00t\00h\00o\00d\00:\00 ")
 (data $75 (i32.const 4796) "|")
 (data $75.1 (i32.const 4808) "\02\00\00\00^\00\00\00E\00l\00e\00m\00e\00n\00t\00 \00t\00y\00p\00e\00 \00m\00u\00s\00t\00 \00b\00e\00 \00n\00u\00l\00l\00a\00b\00l\00e\00 \00i\00f\00 \00a\00r\00r\00a\00y\00 \00i\00s\00 \00h\00o\00l\00e\00y")
 (export "init" (func $assembly/rwa/init))
 (export "call" (func $assembly/rwa/call))
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
  i32.const 5
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
  i32.const 5
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
   i32.const 1184
   i32.const 1232
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
 (func $~lib/rt/stub/__new (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  local.get $0
  i32.const 1073741804
  i32.gt_u
  if
   i32.const 1056
   i32.const 1120
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
    i32.const 1184
    i32.const 3920
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
  block $__inlined_func$~lib/util/string/compareImpl$85
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
     br_if $__inlined_func$~lib/util/string/compareImpl$85
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
 (func $~lib/typedarray/Uint8Array#__set (param $0 i32) (param $1 i32) (param $2 i32)
  local.get $1
  local.get $0
  i32.load offset=8
  i32.ge_u
  if
   i32.const 1536
   i32.const 1600
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
 (func $~lib/typedarray/Uint8Array#__get (param $0 i32) (param $1 i32) (result i32)
  local.get $1
  local.get $0
  i32.load offset=8
  i32.ge_u
  if
   i32.const 1536
   i32.const 1600
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
 (func $assembly/sdk/loadFlag (param $0 i32) (result i32)
  local.get $0
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
   i32.const 1744
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
   i32.const 1744
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
 (func $assembly/rwa/settle (param $0 i32)
  (local $1 i32)
  i32.const 2816
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.get $0
  call $assembly/rwa/earned
  call $assembly/sdk/saveU64
  i32.const 2880
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.set $0
  i32.const 2848
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  call $assembly/sdk/U128.from
  local.tee $1
  i64.load
  call $assembly/sdk/u64Bytes
  local.get $1
  i64.load offset=8
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  local.set $1
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $1
  i32.load offset=4
  local.get $1
  i32.load offset=8
  call $assembly/sdk/_storage_write
 )
 (func $~lib/string/String.UTF8.decodeUnsafe (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  local.get $0
  local.get $1
  i32.add
  local.tee $3
  local.get $0
  i32.lt_u
  if
   i32.const 0
   i32.const 1488
   i32.const 770
   i32.const 7
   call $~lib/builtins/abort
   unreachable
  end
  local.get $1
  i32.const 1
  i32.shl
  i32.const 2
  call $~lib/rt/stub/__new
  local.tee $4
  local.set $1
  loop $while-continue|0
   local.get $0
   local.get $3
   i32.lt_u
   if
    block $while-break|0
     local.get $0
     i32.load8_u
     local.set $5
     local.get $0
     i32.const 1
     i32.add
     local.set $0
     local.get $5
     i32.const 128
     i32.and
     if
      local.get $0
      local.get $3
      i32.eq
      br_if $while-break|0
      local.get $0
      i32.load8_u
      i32.const 63
      i32.and
      local.set $6
      local.get $0
      i32.const 1
      i32.add
      local.set $0
      local.get $5
      i32.const 224
      i32.and
      i32.const 192
      i32.eq
      if
       local.get $1
       local.get $5
       i32.const 31
       i32.and
       i32.const 6
       i32.shl
       local.get $6
       i32.or
       i32.store16
      else
       local.get $0
       local.get $3
       i32.eq
       br_if $while-break|0
       local.get $0
       i32.load8_u
       i32.const 63
       i32.and
       local.set $2
       local.get $0
       i32.const 1
       i32.add
       local.set $0
       local.get $5
       i32.const 240
       i32.and
       i32.const 224
       i32.eq
       if
        local.get $5
        i32.const 15
        i32.and
        i32.const 12
        i32.shl
        local.get $6
        i32.const 6
        i32.shl
        i32.or
        local.get $2
        i32.or
        local.set $2
       else
        local.get $0
        local.get $3
        i32.eq
        br_if $while-break|0
        local.get $0
        i32.load8_u
        i32.const 63
        i32.and
        local.get $5
        i32.const 7
        i32.and
        i32.const 18
        i32.shl
        local.get $6
        i32.const 12
        i32.shl
        i32.or
        local.get $2
        i32.const 6
        i32.shl
        i32.or
        i32.or
        local.set $2
        local.get $0
        i32.const 1
        i32.add
        local.set $0
       end
       local.get $2
       i32.const 65536
       i32.lt_u
       if
        local.get $1
        local.get $2
        i32.store16
       else
        local.get $1
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
        local.get $1
        i32.const 2
        i32.add
        local.set $1
       end
      end
     else
      local.get $1
      local.get $5
      i32.store16
     end
     local.get $1
     i32.const 2
     i32.add
     local.set $1
     br $while-continue|0
    end
   end
  end
  local.get $4
  local.get $1
  local.get $4
  i32.sub
  call $~lib/rt/stub/__renew
 )
 (func $assembly/sdk/U128.from (param $0 i32) (result i32)
  (local $1 i64)
  (local $2 i64)
  local.get $0
  i32.eqz
  if
   i32.const 16
   i32.const 9
   call $~lib/rt/stub/__new
   local.tee $0
   i64.const 0
   i64.store
   local.get $0
   i64.const 0
   i64.store offset=8
   local.get $0
   return
  end
  local.get $0
  i32.const 0
  call $assembly/sdk/bytesU64
  local.set $1
  local.get $0
  i32.const 8
  call $assembly/sdk/bytesU64
  local.set $2
  i32.const 16
  i32.const 9
  call $~lib/rt/stub/__new
  local.tee $0
  local.get $1
  i64.store
  local.get $0
  local.get $2
  i64.store offset=8
  local.get $0
 )
 (func $assembly/sdk/Reader#str (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  local.get $0
  i32.const 4
  local.get $1
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
   i32.const 1744
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
  local.set $1
  local.get $0
  local.get $0
  i32.load
  i32.const 4
  i32.add
  i32.store
  local.get $1
  i32.const 0
  i32.ge_s
  if (result i32)
   local.get $0
   i32.load offset=4
   i32.load offset=8
   local.get $0
   i32.load
   local.get $1
   i32.add
   i32.ge_s
  else
   i32.const 0
  end
  i32.eqz
  if
   i32.const 1744
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.load offset=4
  i32.load offset=4
  local.get $0
  i32.load
  i32.add
  local.get $1
  call $~lib/string/String.UTF8.decodeUnsafe
  local.get $0
  local.get $0
  i32.load
  local.get $1
  i32.add
  i32.store
 )
 (func $assembly/rwa/onlyIssuer
  (local $0 i32)
  (local $1 i32)
  (local $2 i32)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.load offset=4
  call $assembly/sdk/_caller
  call $assembly/rwa/issuer
  local.set $1
  block $__inlined_func$assembly/sdk/sameAddress$142 (result i32)
   i32.const 0
   local.get $2
   i32.load offset=8
   local.get $1
   i32.load offset=8
   i32.ne
   br_if $__inlined_func$assembly/sdk/sameAddress$142
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
     br_if $__inlined_func$assembly/sdk/sameAddress$142
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
   i32.const 4048
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
 )
 (func $assembly/rwa/issuer (result i32)
  (local $0 i32)
  i32.const 2080
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $0
  i32.eqz
  if
   i32.const 3264
   i32.const 3392
   i32.const 28
   i32.const 10
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
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
   i32.const 1536
   i32.const 1600
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
  i32.const 1392
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
 (func $assembly/sdk/Writer#str (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  (local $3 i32)
  local.get $1
  call $assembly/sdk/utf8
  local.set $1
  i32.const 1
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.const 0
  i32.const 4
  call $~lib/typedarray/Uint8Array#__set
  local.get $0
  local.get $2
  call $assembly/sdk/Writer#push
  drop
  local.get $1
  i32.load offset=8
  local.set $3
  i32.const 4
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.const 0
  local.get $3
  i32.const 255
  i32.and
  call $~lib/typedarray/Uint8Array#__set
  local.get $2
  i32.const 1
  local.get $3
  i32.const 8
  i32.shr_s
  i32.const 255
  i32.and
  call $~lib/typedarray/Uint8Array#__set
  local.get $2
  i32.const 2
  local.get $3
  i32.const 16
  i32.shr_s
  i32.const 255
  i32.and
  call $~lib/typedarray/Uint8Array#__set
  local.get $2
  i32.const 3
  local.get $3
  i32.const 24
  i32.shr_s
  call $~lib/typedarray/Uint8Array#__set
  local.get $0
  local.get $2
  call $assembly/sdk/Writer#push
  drop
  local.get $0
  local.get $1
  call $assembly/sdk/Writer#push
 )
 (func $assembly/sdk/U128.mul (param $0 i64) (param $1 i64) (result i32)
  (local $2 i64)
  (local $3 i32)
  (local $4 i64)
  (local $5 i64)
  (local $6 i64)
  local.get $0
  i64.const 4294967295
  i64.and
  local.tee $4
  local.get $1
  i64.const 4294967295
  i64.and
  local.tee $5
  i64.mul
  local.set $2
  local.get $1
  i64.const 32
  i64.shr_u
  local.tee $1
  local.get $4
  i64.mul
  local.tee $4
  i64.const 4294967295
  i64.and
  local.get $2
  i64.const 32
  i64.shr_u
  i64.add
  local.get $0
  i64.const 32
  i64.shr_u
  local.tee $0
  local.get $5
  i64.mul
  local.tee $5
  i64.const 4294967295
  i64.and
  i64.add
  local.set $6
  i32.const 16
  i32.const 9
  call $~lib/rt/stub/__new
  local.tee $3
  local.get $0
  local.get $1
  i64.mul
  local.get $4
  i64.const 32
  i64.shr_u
  i64.add
  local.get $5
  i64.const 32
  i64.shr_u
  i64.add
  local.get $6
  i64.const 32
  i64.shr_u
  i64.add
  i64.store
  local.get $3
  local.get $2
  i64.const 4294967295
  i64.and
  local.get $6
  i64.const 32
  i64.shl
  i64.or
  i64.store offset=8
  local.get $3
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
  i32.const 1328
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
  i32.const 1664
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
   i32.const 1056
   i32.const 1120
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
   i32.const 1120
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
     i32.const 1056
     i32.const 1120
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
   i32.const 1056
   i32.const 1120
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
   i32.const 1536
   i32.const 3920
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
   i32.const 4816
   i32.const 3920
   i32.const 118
   i32.const 40
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
 )
 (func $assembly/sdk/pay (param $0 i32) (param $1 i64)
  local.get $1
  i64.eqz
  if
   return
  end
  local.get $0
  i32.load offset=4
  local.get $1
  call $assembly/sdk/_transfer
  if
   i32.const 3456
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
 )
 (func $assembly/sdk/Writer#bool (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  i32.const 1
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.const 0
  i32.const 1
  call $~lib/typedarray/Uint8Array#__set
  local.get $0
  local.get $2
  call $assembly/sdk/Writer#push
  drop
  local.get $0
  local.get $1
  i32.const 0
  i32.ne
  i64.extend_i32_u
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/Writer#push
 )
 (func $assembly/sdk/U128#div (param $0 i32) (param $1 i64) (result i64)
  (local $2 i32)
  (local $3 i64)
  (local $4 i64)
  (local $5 i32)
  (local $6 i64)
  local.get $1
  i64.eqz
  if
   i32.const 2912
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 127
  local.set $2
  loop $for-loop|0
   local.get $2
   i32.const 0
   i32.ge_s
   if
    local.get $3
    i64.const 1
    i64.shl
    local.set $6
    local.get $3
    i64.const 63
    i64.shr_u
    i32.wrap_i64
    local.get $2
    i32.const 64
    i32.ge_s
    if (result i64)
     local.get $0
     i64.load
     local.get $2
     i32.const -64
     i32.add
     i64.extend_i32_s
     i64.shr_u
     i64.const 1
     i64.and
    else
     local.get $0
     i64.load offset=8
     local.get $2
     i64.extend_i32_s
     i64.shr_u
     i64.const 1
     i64.and
    end
    local.get $6
    i64.or
    local.tee $3
    local.get $1
    i64.ge_u
    i32.or
    if
     local.get $3
     local.get $1
     i64.sub
     local.set $3
     local.get $2
     i32.const 64
     i32.lt_s
     if
      local.get $4
      i64.const 1
      local.get $2
      i64.extend_i32_s
      i64.shl
      i64.or
      local.set $4
     else
      i32.const 2960
      call $assembly/sdk/utf8
      local.tee $5
      i32.load offset=4
      local.get $5
      i32.load offset=8
      call $assembly/sdk/_revert
     end
    end
    local.get $2
    i32.const 1
    i32.sub
    local.set $2
    br $for-loop|0
   end
  end
  local.get $4
 )
 (func $assembly/rwa/move (param $0 i32) (param $1 i32) (param $2 i64)
  (local $3 i64)
  (local $4 i32)
  i32.const 2144
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
  i32.eqz
  if
   i32.const 2480
   call $assembly/sdk/utf8
   local.tee $4
   i32.load offset=4
   local.get $4
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 2560
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
  if
   i32.const 2592
   call $assembly/sdk/utf8
   local.tee $4
   i32.load offset=4
   local.get $4
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 2560
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
  if
   i32.const 2672
   call $assembly/sdk/utf8
   local.tee $4
   i32.load offset=4
   local.get $4
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $2
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $0
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
  local.tee $3
  i64.gt_u
  if
   i32.const 2752
   call $assembly/sdk/utf8
   local.tee $4
   i32.load offset=4
   local.get $4
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  call $assembly/rwa/settle
  local.get $1
  call $assembly/rwa/settle
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.get $3
  local.get $2
  i64.sub
  call $assembly/sdk/saveU64
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $1
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
  local.get $2
  i64.add
  call $assembly/sdk/saveU64
  local.get $0
  local.get $1
  call $assembly/sdk/concat
  local.get $2
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  local.set $0
  i32.const 3008
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
 (func $assembly/rwa/earned (param $0 i32) (result i64)
  (local $1 i64)
  (local $2 i32)
  (local $3 i32)
  (local $4 i64)
  (local $5 i64)
  i32.const 2848
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  call $assembly/sdk/U128.from
  local.set $2
  i32.const 2880
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/load
  call $assembly/sdk/U128.from
  local.set $3
  local.get $2
  i64.load
  local.get $3
  i64.load
  i64.sub
  local.get $2
  i64.load offset=8
  local.tee $4
  local.get $3
  i64.load offset=8
  local.tee $1
  i64.lt_u
  i64.extend_i32_u
  i64.sub
  local.set $5
  i32.const 16
  i32.const 9
  call $~lib/rt/stub/__new
  local.tee $2
  local.get $5
  i64.store
  local.get $2
  local.get $4
  local.get $1
  i64.sub
  i64.store offset=8
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $3
  if (result i64)
   local.get $3
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.set $1
  local.get $2
  i64.load offset=8
  local.get $1
  call $assembly/sdk/U128.mul
  local.tee $3
  i64.load
  local.get $1
  local.get $2
  i64.load
  i64.mul
  i64.add
  local.set $1
  local.get $3
  i64.load offset=8
  local.set $4
  i32.const 16
  i32.const 9
  call $~lib/rt/stub/__new
  local.tee $2
  local.get $1
  i64.store
  local.get $2
  local.get $4
  i64.store offset=8
  i32.const 2816
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
  local.get $2
  i64.const 1000000000000000000
  call $assembly/sdk/U128#div
  i64.add
 )
 (func $~start
  i32.const 4924
  global.set $~lib/rt/stub/offset
 )
 (func $assembly/rwa/init
  (local $0 i32)
  (local $1 i64)
  (local $2 i64)
  (local $3 i32)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
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
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $3
  local.get $0
  i32.store offset=4
  local.get $3
  i32.const 0
  i32.store
  local.get $3
  i32.const 1296
  call $assembly/sdk/Reader#str
  local.get $3
  i32.const 1808
  call $assembly/sdk/Reader#str
  local.set $5
  local.get $3
  i32.const 1840
  call $assembly/sdk/Reader#u64
  local.set $1
  local.get $3
  i32.const 1888
  call $assembly/sdk/Reader#u64
  local.set $2
  local.get $3
  i32.const 1920
  call $assembly/sdk/Reader#str
  local.set $3
  local.get $1
  i64.eqz
  if
   i32.const 1968
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $6
  i32.load offset=4
  call $assembly/sdk/_caller
  i32.const 1296
  call $assembly/sdk/utf8
  local.set $0
  call $assembly/sdk/utf8
  local.set $4
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 1808
  call $assembly/sdk/utf8
  local.set $0
  local.get $5
  call $assembly/sdk/utf8
  local.set $4
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2048
  call $assembly/sdk/utf8
  local.set $0
  local.get $3
  call $assembly/sdk/utf8
  local.set $3
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $3
  i32.load offset=4
  local.get $3
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2080
  call $assembly/sdk/utf8
  local.tee $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  local.get $6
  i32.load offset=4
  local.get $6
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2112
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/saveU64
  i32.const 1888
  call $assembly/sdk/utf8
  local.get $2
  call $assembly/sdk/saveU64
  i32.const 2144
  call $assembly/sdk/utf8
  local.get $6
  call $assembly/sdk/concat
  i32.const 1
  call $assembly/sdk/saveFlag
  i32.const 2176
  call $assembly/sdk/utf8
  local.get $6
  call $assembly/sdk/concat
  local.get $1
  call $assembly/sdk/saveU64
  local.get $6
  local.get $1
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  local.set $0
  i32.const 2208
  call $assembly/sdk/utf8
  local.tee $3
  i32.load offset=4
  local.get $3
  i32.load offset=8
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_emit
 )
 (func $assembly/rwa/call
  (local $0 i32)
  (local $1 i32)
  (local $2 i32)
  (local $3 i64)
  (local $4 i32)
  (local $5 i64)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  (local $9 i64)
  (local $10 i64)
  (local $11 i64)
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
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $6
  local.get $0
  i32.store offset=4
  local.get $6
  i32.const 0
  i32.store
  local.get $6
  i32.const 2240
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
  i32.const 2272
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
  i32.const 2304
  call $~lib/string/String.__eq
  if
   local.get $6
   i32.const 2352
   call $assembly/sdk/Reader#addr
   local.set $4
   local.get $6
   i32.const 2384
   call $assembly/sdk/Reader#u64
   local.set $3
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $6
   i32.load offset=4
   call $assembly/sdk/_caller
   i32.const 2144
   call $assembly/sdk/utf8
   local.get $6
   call $assembly/sdk/concat
   call $assembly/sdk/loadFlag
   i32.eqz
   if
    i32.const 2416
    call $assembly/sdk/utf8
    local.tee $6
    i32.load offset=4
    local.get $6
    i32.load offset=8
    call $assembly/sdk/_revert
   end
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $6
   i32.load offset=4
   call $assembly/sdk/_caller
   local.get $6
   local.get $4
   local.get $3
   call $assembly/rwa/move
  else
   local.get $7
   i32.const 3056
   call $~lib/string/String.__eq
   if
    local.get $6
    i32.const 2384
    call $assembly/sdk/Reader#u64
    local.set $3
    i32.const 1888
    call $assembly/sdk/utf8
    call $assembly/sdk/load
    local.tee $4
    if (result i64)
     local.get $4
     i32.const 0
     call $assembly/sdk/bytesU64
    else
     i64.const 0
    end
    local.tee $5
    i64.eqz
    if
     i32.const 3088
     call $assembly/sdk/utf8
     local.tee $4
     i32.load offset=4
     local.get $4
     i32.load offset=8
     call $assembly/sdk/_revert
    end
    i32.const 20
    call $~lib/typedarray/Uint8Array#constructor
    local.tee $4
    i32.load offset=4
    call $assembly/sdk/_caller
    i32.const 2144
    call $assembly/sdk/utf8
    local.get $4
    call $assembly/sdk/concat
    call $assembly/sdk/loadFlag
    i32.eqz
    if
     i32.const 2416
     call $assembly/sdk/utf8
     local.tee $4
     i32.load offset=4
     local.get $4
     i32.load offset=8
     call $assembly/sdk/_revert
    end
    local.get $5
    local.get $3
    call $assembly/sdk/U128.mul
    local.tee $4
    i64.load
    i64.eqz
    if (result i32)
     local.get $4
     i64.load offset=8
     call $assembly/sdk/_value
     i64.eq
    else
     i32.const 0
    end
    i32.eqz
    if
     i32.const 3184
     call $assembly/sdk/utf8
     local.tee $4
     i32.load offset=4
     local.get $4
     i32.load offset=8
     call $assembly/sdk/_revert
    end
    call $assembly/rwa/issuer
    i32.const 20
    call $~lib/typedarray/Uint8Array#constructor
    local.tee $6
    i32.load offset=4
    call $assembly/sdk/_caller
    local.get $6
    local.get $3
    call $assembly/rwa/move
    call $assembly/rwa/issuer
    call $assembly/sdk/_value
    call $assembly/sdk/pay
    i32.const 20
    call $~lib/typedarray/Uint8Array#constructor
    local.tee $4
    i32.load offset=4
    call $assembly/sdk/_caller
    local.get $4
    local.get $3
    call $assembly/sdk/u64Bytes
    call $assembly/sdk/concat
    local.set $4
    i32.const 3552
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
    i32.const 3584
    call $~lib/string/String.__eq
    if
     call $assembly/sdk/_value
     local.tee $9
     i64.eqz
     if
      i32.const 3632
      call $assembly/sdk/utf8
      local.tee $4
      i32.load offset=4
      local.get $4
      i32.load offset=8
      call $assembly/sdk/_revert
     end
     i32.const 2112
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     local.tee $4
     if (result i64)
      local.get $4
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     local.set $3
     local.get $9
     i64.const 1000000000000000000
     call $assembly/sdk/U128.mul
     local.tee $4
     i64.load
     local.tee $5
     local.get $3
     i64.div_u
     local.set $10
     local.get $5
     local.get $3
     i64.rem_u
     local.set $11
     local.get $4
     i64.load offset=8
     local.set $5
     i32.const 16
     i32.const 9
     call $~lib/rt/stub/__new
     local.tee $4
     local.get $11
     i64.store
     local.get $4
     local.get $5
     i64.store offset=8
     local.get $4
     local.get $3
     call $assembly/sdk/U128#div
     local.set $3
     i32.const 16
     i32.const 9
     call $~lib/rt/stub/__new
     local.tee $4
     local.get $10
     i64.store
     local.get $4
     local.get $3
     i64.store offset=8
     i32.const 2848
     call $assembly/sdk/utf8
     local.set $6
     i32.const 2848
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     call $assembly/sdk/U128.from
     local.tee $7
     i64.load offset=8
     local.tee $3
     local.get $3
     local.get $4
     i64.load offset=8
     i64.add
     local.tee $3
     i64.gt_u
     i64.extend_i32_u
     local.get $7
     i64.load
     local.get $4
     i64.load
     i64.add
     i64.add
     local.set $5
     i32.const 16
     i32.const 9
     call $~lib/rt/stub/__new
     local.tee $4
     local.get $5
     i64.store
     local.get $4
     local.get $3
     i64.store offset=8
     local.get $4
     i64.load
     call $assembly/sdk/u64Bytes
     local.get $4
     i64.load offset=8
     call $assembly/sdk/u64Bytes
     call $assembly/sdk/concat
     local.set $4
     local.get $6
     i32.load offset=4
     local.get $6
     i32.load offset=8
     local.get $4
     i32.load offset=4
     local.get $4
     i32.load offset=8
     call $assembly/sdk/_storage_write
     i32.const 3712
     call $assembly/sdk/utf8
     i32.const 3712
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     local.tee $4
     if (result i64)
      local.get $4
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     local.get $9
     i64.add
     call $assembly/sdk/saveU64
     local.get $9
     call $assembly/sdk/u64Bytes
     local.set $4
     i32.const 3744
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
     i32.const 3792
     call $~lib/string/String.__eq
     if
      i32.const 20
      call $~lib/typedarray/Uint8Array#constructor
      local.tee $4
      i32.load offset=4
      call $assembly/sdk/_caller
      local.get $4
      call $assembly/rwa/settle
      i32.const 2816
      call $assembly/sdk/utf8
      local.get $4
      call $assembly/sdk/concat
      call $assembly/sdk/load
      local.tee $6
      if (result i64)
       local.get $6
       i32.const 0
       call $assembly/sdk/bytesU64
      else
       i64.const 0
      end
      local.tee $3
      i64.eqz
      if
       i32.const 3824
       call $assembly/sdk/utf8
       local.tee $6
       i32.load offset=4
       local.get $6
       i32.load offset=8
       call $assembly/sdk/_revert
      end
      i32.const 2816
      call $assembly/sdk/utf8
      local.get $4
      call $assembly/sdk/concat
      i64.const 0
      call $assembly/sdk/saveU64
      local.get $4
      local.get $3
      call $assembly/sdk/pay
      local.get $4
      local.get $3
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/concat
      local.set $4
      i32.const 3888
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
      local.get $3
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/Writer#push
      drop
     else
      local.get $7
      i32.const 3968
      call $~lib/string/String.__eq
      if (result i32)
       i32.const 1
      else
       local.get $7
       i32.const 4016
       call $~lib/string/String.__eq
      end
      if
       call $assembly/rwa/onlyIssuer
       local.get $6
       i32.const 4128
       call $assembly/sdk/Reader#addr
       local.set $4
       i32.const 2144
       call $assembly/sdk/utf8
       local.get $4
       call $assembly/sdk/concat
       local.get $7
       i32.const 3968
       call $~lib/string/String.__eq
       call $assembly/sdk/saveFlag
       i32.const 4160
       i32.const 4208
       local.get $7
       i32.const 3968
       call $~lib/string/String.__eq
       select
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
       i32.const 4256
       call $~lib/string/String.__eq
       if (result i32)
        i32.const 1
       else
        local.get $7
        i32.const 4288
        call $~lib/string/String.__eq
       end
       if
        call $assembly/rwa/onlyIssuer
        local.get $6
        i32.const 4128
        call $assembly/sdk/Reader#addr
        local.set $4
        i32.const 2560
        call $assembly/sdk/utf8
        local.get $4
        call $assembly/sdk/concat
        local.get $7
        i32.const 4256
        call $~lib/string/String.__eq
        call $assembly/sdk/saveFlag
        i32.const 4336
        i32.const 4368
        local.get $7
        i32.const 4256
        call $~lib/string/String.__eq
        select
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
        i32.const 4416
        call $~lib/string/String.__eq
        if
         call $assembly/rwa/onlyIssuer
         i32.const 1888
         call $assembly/sdk/utf8
         local.get $6
         i32.const 1888
         call $assembly/sdk/Reader#u64
         call $assembly/sdk/saveU64
        else
         local.get $7
         i32.const 4464
         call $~lib/string/String.__eq
         if
          call $assembly/rwa/onlyIssuer
          local.get $6
          i32.const 4512
          call $assembly/sdk/Reader#addr
          local.set $4
          local.get $6
          i32.const 2352
          call $assembly/sdk/Reader#addr
          local.set $7
          local.get $6
          i32.const 2384
          call $assembly/sdk/Reader#u64
          local.set $3
          i32.const 2144
          call $assembly/sdk/utf8
          local.get $7
          call $assembly/sdk/concat
          call $assembly/sdk/loadFlag
          i32.eqz
          if
           i32.const 2480
           call $assembly/sdk/utf8
           local.tee $6
           i32.load offset=4
           local.get $6
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          local.get $3
          i32.const 2176
          call $assembly/sdk/utf8
          local.get $4
          call $assembly/sdk/concat
          call $assembly/sdk/load
          local.tee $6
          if (result i64)
           local.get $6
           i32.const 0
           call $assembly/sdk/bytesU64
          else
           i64.const 0
          end
          local.tee $5
          i64.gt_u
          if
           i32.const 2752
           call $assembly/sdk/utf8
           local.tee $6
           i32.load offset=4
           local.get $6
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          local.get $4
          call $assembly/rwa/settle
          local.get $7
          call $assembly/rwa/settle
          i32.const 2176
          call $assembly/sdk/utf8
          local.get $4
          call $assembly/sdk/concat
          local.get $5
          local.get $3
          i64.sub
          call $assembly/sdk/saveU64
          i32.const 2176
          call $assembly/sdk/utf8
          local.get $7
          call $assembly/sdk/concat
          i32.const 2176
          call $assembly/sdk/utf8
          local.get $7
          call $assembly/sdk/concat
          call $assembly/sdk/load
          local.tee $6
          if (result i64)
           local.get $6
           i32.const 0
           call $assembly/sdk/bytesU64
          else
           i64.const 0
          end
          local.get $3
          i64.add
          call $assembly/sdk/saveU64
          local.get $4
          local.get $7
          call $assembly/sdk/concat
          local.get $3
          call $assembly/sdk/u64Bytes
          call $assembly/sdk/concat
          local.set $4
          i32.const 4544
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
          i32.const 4592
          call $~lib/string/String.__eq
          if
           i32.const 1296
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $4
           i32.eqz
           if
            i32.const 3264
            i32.const 3392
            i32.const 172
            i32.const 30
            call $~lib/builtins/abort
            unreachable
           end
           local.get $0
           local.get $4
           i32.load
           local.tee $4
           local.get $4
           i32.const 20
           i32.sub
           i32.load offset=16
           call $~lib/string/String.UTF8.decodeUnsafe
           call $assembly/sdk/Writer#str
           i32.const 1808
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $6
           i32.eqz
           if
            i32.const 3264
            i32.const 3392
            i32.const 173
            i32.const 31
            call $~lib/builtins/abort
            unreachable
           end
           local.get $6
           i32.load
           local.tee $4
           local.get $4
           i32.const 20
           i32.sub
           i32.load offset=16
           call $~lib/string/String.UTF8.decodeUnsafe
           call $assembly/sdk/Writer#str
           local.set $4
           i32.const 2112
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $6
           if (result i64)
            local.get $6
            i32.const 0
            call $assembly/sdk/bytesU64
           else
            i64.const 0
           end
           local.set $3
           i32.const 1
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $6
           i32.const 0
           i32.const 1
           call $~lib/typedarray/Uint8Array#__set
           local.get $4
           local.get $6
           call $assembly/sdk/Writer#push
           drop
           local.get $4
           local.get $3
           call $assembly/sdk/u64Bytes
           call $assembly/sdk/Writer#push
           local.set $4
           i32.const 1888
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $6
           if (result i64)
            local.get $6
            i32.const 0
            call $assembly/sdk/bytesU64
           else
            i64.const 0
           end
           local.set $3
           i32.const 1
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $6
           i32.const 0
           i32.const 1
           call $~lib/typedarray/Uint8Array#__set
           local.get $4
           local.get $6
           call $assembly/sdk/Writer#push
           drop
           local.get $4
           local.get $3
           call $assembly/sdk/u64Bytes
           call $assembly/sdk/Writer#push
           local.set $4
           call $assembly/rwa/issuer
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
           i32.const 2048
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $6
           i32.eqz
           if
            i32.const 3264
            i32.const 3392
            i32.const 177
            i32.const 31
            call $~lib/builtins/abort
            unreachable
           end
           local.get $6
           i32.load
           local.tee $4
           local.get $4
           i32.const 20
           i32.sub
           i32.load offset=16
           call $~lib/string/String.UTF8.decodeUnsafe
           call $assembly/sdk/Writer#str
           local.set $4
           i32.const 3712
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $6
           if (result i64)
            local.get $6
            i32.const 0
            call $assembly/sdk/bytesU64
           else
            i64.const 0
           end
           local.set $3
           i32.const 1
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $6
           i32.const 0
           i32.const 1
           call $~lib/typedarray/Uint8Array#__set
           local.get $4
           local.get $6
           call $assembly/sdk/Writer#push
           drop
           local.get $4
           local.get $3
           call $assembly/sdk/u64Bytes
           call $assembly/sdk/Writer#push
           drop
          else
           local.get $7
           i32.const 4624
           call $~lib/string/String.__eq
           if
            local.get $6
            i32.const 4128
            call $assembly/sdk/Reader#addr
            local.set $4
            i32.const 2176
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
            local.set $3
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
            local.get $3
            call $assembly/sdk/u64Bytes
            call $assembly/sdk/Writer#push
            drop
           else
            local.get $7
            i32.const 4672
            call $~lib/string/String.__eq
            if
             local.get $6
             i32.const 4128
             call $assembly/sdk/Reader#addr
             call $assembly/rwa/earned
             local.set $3
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
             local.get $3
             call $assembly/sdk/u64Bytes
             call $assembly/sdk/Writer#push
             drop
            else
             local.get $7
             i32.const 4720
             call $~lib/string/String.__eq
             if
              local.get $6
              i32.const 4128
              call $assembly/sdk/Reader#addr
              local.set $4
              local.get $0
              i32.const 2144
              call $assembly/sdk/utf8
              local.get $4
              call $assembly/sdk/concat
              call $assembly/sdk/loadFlag
              call $assembly/sdk/Writer#bool
              i32.const 2560
              call $assembly/sdk/utf8
              local.get $4
              call $assembly/sdk/concat
              call $assembly/sdk/loadFlag
              call $assembly/sdk/Writer#bool
              drop
             else
              i32.const 4752
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
    local.get $1
    call $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array>
    local.get $1
    local.get $0
    i32.load
    local.get $2
    call $~lib/array/Array<~lib/typedarray/Uint8Array>#__get
    i32.load offset=8
    i32.add
    local.set $1
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
