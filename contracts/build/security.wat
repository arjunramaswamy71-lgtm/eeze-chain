(module
 (type $0 (func (param i32 i32) (result i32)))
 (type $1 (func (param i32) (result i32)))
 (type $2 (func (param i32 i64)))
 (type $3 (func (param i32)))
 (type $4 (func))
 (type $5 (func (param i32 i32)))
 (type $6 (func (param i32 i32) (result i64)))
 (type $7 (func (param i32 i32 i32)))
 (type $8 (func (param i32 i32 i32 i32)))
 (type $9 (func (result i32)))
 (type $10 (func (param i64) (result i64)))
 (type $11 (func (param i32 i32 i32) (result i32)))
 (type $12 (func (param i64) (result i32)))
 (type $13 (func (param i64 i64) (result i32)))
 (type $14 (func (param i32 i64) (result i64)))
 (type $15 (func (param i32 i32 i64 i32)))
 (type $16 (func (result i64)))
 (type $17 (func (param i32 i32 i64)))
 (type $18 (func (param i32) (result i64)))
 (type $19 (func (param i32 i64) (result i32)))
 (import "env" "revert" (func $assembly/sdk/_revert (param i32 i32)))
 (import "env" "self_address" (func $assembly/sdk/_self (param i32)))
 (import "env" "abort" (func $~lib/builtins/abort (param i32 i32 i32 i32)))
 (import "env" "storage_write" (func $assembly/sdk/_storage_write (param i32 i32 i32 i32)))
 (import "env" "emit" (func $assembly/sdk/_emit (param i32 i32 i32 i32)))
 (import "env" "value" (func $assembly/sdk/_value (result i64)))
 (import "env" "caller" (func $assembly/sdk/_caller (param i32)))
 (import "env" "input_read" (func $assembly/sdk/_input_read (param i32)))
 (import "env" "input_len" (func $assembly/sdk/_input_len (result i32)))
 (import "env" "transfer" (func $assembly/sdk/_transfer (param i32 i64) (result i32)))
 (import "env" "storage_read" (func $assembly/sdk/_storage_read (param i32 i32 i32) (result i32)))
 (import "env" "storage_len" (func $assembly/sdk/_storage_len (param i32 i32) (result i32)))
 (import "env" "storage_delete" (func $assembly/sdk/_storage_delete (param i32 i32)))
 (import "env" "static_call" (func $assembly/sdk/_static_call (param i32 i32 i32) (result i32)))
 (import "env" "return_data" (func $assembly/sdk/_return_data (param i32)))
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
 (data $14 (i32.const 1820) "\1c")
 (data $14.1 (i32.const 1832) "\02\00\00\00\08\00\00\00k\00i\00n\00d")
 (data $15 (i32.const 1852) "<")
 (data $15.1 (i32.const 1864) "\02\00\00\00\"\00\00\00i\00d\00e\00n\00t\00i\00t\00y\00 \00r\00e\00g\00i\00s\00t\00r\00y")
 (data $16 (i32.const 1916) "<")
 (data $16.1 (i32.const 1928) "\02\00\00\00*\00\00\00r\00e\00q\00u\00i\00r\00e\00d\00 \00c\00l\00a\00i\00m\00 \00t\00o\00p\00i\00c\00s")
 (data $17 (i32.const 1980) "<")
 (data $17.1 (i32.const 1992) "\02\00\00\00\1e\00\00\00p\00r\00i\00c\00e\00 \00p\00e\00r\00 \00s\00h\00a\00r\00e")
 (data $18 (i32.const 2044) ",")
 (data $18.1 (i32.const 2056) "\02\00\00\00\18\00\00\00t\00o\00t\00a\00l\00 \00s\00h\00a\00r\00e\00s")
 (data $19 (i32.const 2092) ",")
 (data $19.1 (i32.const 2104) "\02\00\00\00\10\00\00\00d\00o\00c\00u\00m\00e\00n\00t")
 (data $20 (i32.const 2140) ",")
 (data $20.1 (i32.const 2152) "\02\00\00\00\10\00\00\00p\00r\00o\00p\00e\00r\00t\00y")
 (data $21 (i32.const 2188) "\1c")
 (data $21.1 (i32.const 2200) "\02\00\00\00\08\00\00\00f\00u\00n\00d")
 (data $22 (i32.const 2220) "L")
 (data $22.1 (i32.const 2232) "\02\00\00\00:\00\00\00k\00i\00n\00d\00 \00m\00u\00s\00t\00 \00b\00e\00 \00p\00r\00o\00p\00e\00r\00t\00y\00 \00o\00r\00 \00f\00u\00n\00d")
 (data $23 (i32.const 2300) "L")
 (data $23.1 (i32.const 2312) "\02\00\00\00.\00\00\00n\00e\00e\00d\00 \00a\00t\00 \00l\00e\00a\00s\00t\00 \00o\00n\00e\00 \00s\00h\00a\00r\00e")
 (data $24 (i32.const 2380) "\1c")
 (data $24.1 (i32.const 2392) "\02\00\00\00\06\00\00\00d\00o\00c")
 (data $25 (i32.const 2412) "\1c")
 (data $25.1 (i32.const 2424) "\02\00\00\00\n\00\00\00o\00w\00n\00e\00r")
 (data $26 (i32.const 2444) ",")
 (data $26.1 (i32.const 2456) "\02\00\00\00\10\00\00\00r\00e\00g\00i\00s\00t\00r\00y")
 (data $27 (i32.const 2492) "\1c")
 (data $27.1 (i32.const 2504) "\02\00\00\00\0c\00\00\00t\00o\00p\00i\00c\00s")
 (data $28 (i32.const 2524) "\1c")
 (data $28.1 (i32.const 2536) "\02\00\00\00\n\00\00\00p\00r\00i\00c\00e")
 (data $29 (i32.const 2556) "\1c")
 (data $29.1 (i32.const 2568) "\02\00\00\00\n\00\00\00t\00o\00t\00a\00l")
 (data $30 (i32.const 2588) "\1c")
 (data $30.1 (i32.const 2600) "\02\00\00\00\08\00\00\00b\00a\00l\00:")
 (data $31 (i32.const 2620) "\1c")
 (data $31.1 (i32.const 2632) "\02\00\00\00\0c\00\00\00I\00s\00s\00u\00e\00d")
 (data $32 (i32.const 2652) "\1c")
 (data $32.1 (i32.const 2664) "\02\00\00\00\0c\00\00\00m\00e\00t\00h\00o\00d")
 (data $33 (i32.const 2684) "\1c")
 (data $33.1 (i32.const 2696) "\01")
 (data $34 (i32.const 2716) ",")
 (data $34.1 (i32.const 2728) "\02\00\00\00\10\00\00\00t\00r\00a\00n\00s\00f\00e\00r")
 (data $35 (i32.const 2764) "\1c")
 (data $35.1 (i32.const 2776) "\02\00\00\00\04\00\00\00t\00o")
 (data $36 (i32.const 2796) "\1c")
 (data $36.1 (i32.const 2808) "\02\00\00\00\0c\00\00\00a\00m\00o\00u\00n\00t")
 (data $37 (i32.const 2828) "\1c")
 (data $37.1 (i32.const 2840) "\02\00\00\00\0c\00\00\00p\00a\00u\00s\00e\00d")
 (data $38 (i32.const 2860) "<")
 (data $38.1 (i32.const 2872) "\02\00\00\00\"\00\00\00t\00r\00a\00d\00i\00n\00g\00 \00i\00s\00 \00p\00a\00u\00s\00e\00d")
 (data $39 (i32.const 2924) "\1c")
 (data $39.1 (i32.const 2936) "\02\00\00\00\08\00\00\00f\00r\00z\00:")
 (data $40 (i32.const 2956) "L")
 (data $40.1 (i32.const 2968) "\02\00\00\004\00\00\00s\00e\00n\00d\00e\00r\00\'\00s\00 \00a\00c\00c\00o\00u\00n\00t\00 \00i\00s\00 \00f\00r\00o\00z\00e\00n")
 (data $41 (i32.const 3036) "<")
 (data $41.1 (i32.const 3048) "\02\00\00\00\"\00\00\00n\00o\00t\00 \00e\00n\00o\00u\00g\00h\00 \00s\00h\00a\00r\00e\00s")
 (data $42 (i32.const 3100) "\1c")
 (data $42.1 (i32.const 3112) "\02\00\00\00\08\00\00\00p\00f\00z\00:")
 (data $43 (i32.const 3132) "L")
 (data $43.1 (i32.const 3144) "\02\00\00\00<\00\00\00p\00a\00r\00t\00 \00o\00f\00 \00t\00h\00e\00s\00e\00 \00s\00h\00a\00r\00e\00s\00 \00i\00s\00 \00f\00r\00o\00z\00e\00n")
 (data $44 (i32.const 3212) "|")
 (data $44.1 (i32.const 3224) "\02\00\00\00^\00\00\00U\00n\00e\00x\00p\00e\00c\00t\00e\00d\00 \00\'\00n\00u\00l\00l\00\'\00 \00(\00n\00o\00t\00 \00a\00s\00s\00i\00g\00n\00e\00d\00 \00o\00r\00 \00f\00a\00i\00l\00e\00d\00 \00c\00a\00s\00t\00)")
 (data $45 (i32.const 3340) "<")
 (data $45.1 (i32.const 3352) "\02\00\00\00(\00\00\00a\00s\00s\00e\00m\00b\00l\00y\00/\00s\00e\00c\00u\00r\00i\00t\00y\00.\00t\00s")
 (data $46 (i32.const 3404) ",")
 (data $46.1 (i32.const 3416) "\02\00\00\00\16\00\00\00i\00s\00_\00v\00e\00r\00i\00f\00i\00e\00d")
 (data $47 (i32.const 3452) ",")
 (data $47.1 (i32.const 3464) "\02\00\00\00\1a\00\00\00~\00l\00i\00b\00/\00a\00r\00r\00a\00y\00.\00t\00s")
 (data $48 (i32.const 3500) "|")
 (data $48.1 (i32.const 3512) "\02\00\00\00^\00\00\00E\00l\00e\00m\00e\00n\00t\00 \00t\00y\00p\00e\00 \00m\00u\00s\00t\00 \00b\00e\00 \00n\00u\00l\00l\00a\00b\00l\00e\00 \00i\00f\00 \00a\00r\00r\00a\00y\00 \00i\00s\00 \00h\00o\00l\00e\00y")
 (data $49 (i32.const 3628) "\\")
 (data $49.1 (i32.const 3640) "\02\00\00\00F\00\00\00t\00h\00e\00 \00i\00d\00e\00n\00t\00i\00t\00y\00 \00r\00e\00g\00i\00s\00t\00r\00y\00 \00d\00i\00d\00n\00\'\00t\00 \00a\00n\00s\00w\00e\00r")
 (data $50 (i32.const 3724) "\1c")
 (data $50.1 (i32.const 3736) "\02\00\00\00\0c\00\00\00a\00n\00s\00w\00e\00r")
 (data $51 (i32.const 3756) "|")
 (data $51.1 (i32.const 3768) "\02\00\00\00`\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00 \00h\00a\00s\00n\00\'\00t\00 \00p\00a\00s\00s\00e\00d\00 \00t\00h\00e\00 \00r\00e\00q\00u\00i\00r\00e\00d\00 \00c\00h\00e\00c\00k\00s\00 \00(\00K\00Y\00C\00)")
 (data $52 (i32.const 3884) "\1c")
 (data $52.1 (i32.const 3896) "\02\00\00\00\n\00\00\00c\00t\00y\00o\00n")
 (data $53 (i32.const 3916) "\1c")
 (data $53.1 (i32.const 3928) "\02\00\00\00\08\00\00\00c\00t\00y\00:")
 (data $54 (i32.const 3948) ",")
 (data $54.1 (i32.const 3960) "\02\00\00\00\14\00\00\00c\00o\00u\00n\00t\00r\00y\00_\00o\00f")
 (data $55 (i32.const 3996) "|")
 (data $55.1 (i32.const 4008) "\02\00\00\00f\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00\'\00s\00 \00c\00o\00u\00n\00t\00r\00y\00 \00i\00s\00n\00\'\00t\00 \00a\00l\00l\00o\00w\00e\00d\00 \00t\00o\00 \00h\00o\00l\00d\00 \00t\00h\00i\00s\00 \00a\00s\00s\00e\00t")
 (data $56 (i32.const 4124) "L")
 (data $56.1 (i32.const 4136) "\02\00\00\008\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00\'\00s\00 \00a\00c\00c\00o\00u\00n\00t\00 \00i\00s\00 \00f\00r\00o\00z\00e\00n")
 (data $57 (i32.const 4204) ",")
 (data $57.1 (i32.const 4216) "\02\00\00\00\16\00\00\00m\00a\00x\00_\00b\00a\00l\00a\00n\00c\00e")
 (data $58 (i32.const 4252) "|")
 (data $58.1 (i32.const 4264) "\02\00\00\00h\00\00\00r\00e\00c\00e\00i\00v\00e\00r\00 \00w\00o\00u\00l\00d\00 \00h\00o\00l\00d\00 \00m\00o\00r\00e\00 \00t\00h\00a\00n\00 \00t\00h\00e\00 \00l\00i\00m\00i\00t\00 \00p\00e\00r\00 \00i\00n\00v\00e\00s\00t\00o\00r")
 (data $59 (i32.const 4380) ",")
 (data $59.1 (i32.const 4392) "\02\00\00\00\16\00\00\00m\00a\00x\00_\00h\00o\00l\00d\00e\00r\00s")
 (data $60 (i32.const 4428) ",")
 (data $60.1 (i32.const 4440) "\02\00\00\00\0e\00\00\00h\00o\00l\00d\00e\00r\00s")
 (data $61 (i32.const 4476) "|")
 (data $61.1 (i32.const 4488) "\02\00\00\00^\00\00\00t\00h\00i\00s\00 \00a\00s\00s\00e\00t\00 \00a\00l\00r\00e\00a\00d\00y\00 \00h\00a\00s\00 \00t\00h\00e\00 \00m\00o\00s\00t\00 \00h\00o\00l\00d\00e\00r\00s\00 \00a\00l\00l\00o\00w\00e\00d")
 (data $62 (i32.const 4604) ",")
 (data $62.1 (i32.const 4616) "\02\00\00\00\10\00\00\00T\00r\00a\00n\00s\00f\00e\00r")
 (data $63 (i32.const 4652) "\1c")
 (data $63.1 (i32.const 4664) "\02\00\00\00\n\00\00\00o\00w\00e\00d\00:")
 (data $64 (i32.const 4684) "\1c")
 (data $64.1 (i32.const 4696) "\02\00\00\00\06\00\00\00a\00c\00c")
 (data $65 (i32.const 4716) "\1c")
 (data $65.1 (i32.const 4728) "\02\00\00\00\n\00\00\00l\00a\00s\00t\00:")
 (data $66 (i32.const 4748) ",")
 (data $66.1 (i32.const 4760) "\02\00\00\00\1c\00\00\00d\00i\00v\00i\00d\00e\00 \00b\00y\00 \00z\00e\00r\00o")
 (data $67 (i32.const 4796) ",")
 (data $67.1 (i32.const 4808) "\02\00\00\00\1c\00\00\00n\00u\00m\00b\00e\00r\00 \00t\00o\00o\00 \00b\00i\00g")
 (data $68 (i32.const 4844) "\1c")
 (data $68.1 (i32.const 4856) "\02\00\00\00\06\00\00\00b\00u\00y")
 (data $69 (i32.const 4876) "|")
 (data $69.1 (i32.const 4888) "\02\00\00\00b\00\00\00s\00h\00a\00r\00e\00s\00 \00a\00r\00e\00 \00n\00o\00t\00 \00f\00o\00r\00 \00s\00a\00l\00e\00 \00f\00r\00o\00m\00 \00t\00h\00e\00 \00i\00s\00s\00u\00e\00r\00 \00r\00i\00g\00h\00t\00 \00n\00o\00w")
 (data $70 (i32.const 5004) "L")
 (data $70.1 (i32.const 5016) "\02\00\00\006\00\00\00s\00e\00n\00d\00 \00e\00x\00a\00c\00t\00l\00y\00 \00p\00r\00i\00c\00e\00 \00x\00 \00a\00m\00o\00u\00n\00t")
 (data $71 (i32.const 5084) ",")
 (data $71.1 (i32.const 5096) "\02\00\00\00\0e\00\00\00r\00e\00s\00e\00r\00v\00e")
 (data $72 (i32.const 5132) "\\")
 (data $72.1 (i32.const 5144) "\02\00\00\00B\00\00\00c\00o\00n\00t\00r\00a\00c\00t\00 \00d\00o\00e\00s\00n\00\'\00t\00 \00h\00a\00v\00e\00 \00e\00n\00o\00u\00g\00h\00 \00C\00T\00D\00Y")
 (data $73 (i32.const 5228) "\1c")
 (data $73.1 (i32.const 5240) "\02\00\00\00\06\00\00\00B\00u\00y")
 (data $74 (i32.const 5260) "\1c")
 (data $74.1 (i32.const 5272) "\02\00\00\00\0c\00\00\00r\00e\00d\00e\00e\00m")
 (data $75 (i32.const 5292) "\\")
 (data $75.1 (i32.const 5304) "\02\00\00\00@\00\00\00o\00n\00l\00y\00 \00f\00u\00n\00d\00 \00s\00h\00a\00r\00e\00s\00 \00c\00a\00n\00 \00b\00e\00 \00r\00e\00d\00e\00e\00m\00e\00d")
 (data $76 (i32.const 5388) "\8c")
 (data $76.1 (i32.const 5400) "\02\00\00\00v\00\00\00t\00h\00e\00 \00f\00u\00n\00d\00\'\00s\00 \00r\00e\00s\00e\00r\00v\00e\00 \00i\00s\00 \00t\00o\00o\00 \00l\00o\00w\00 \00t\00o\00 \00r\00e\00d\00e\00e\00m\00 \00t\00h\00a\00t\00 \00m\00u\00c\00h\00 \00r\00i\00g\00h\00t\00 \00n\00o\00w")
 (data $77 (i32.const 5532) "\1c")
 (data $77.1 (i32.const 5544) "\02\00\00\00\0c\00\00\00R\00e\00d\00e\00e\00m")
 (data $78 (i32.const 5564) "\1c")
 (data $78.1 (i32.const 5576) "\02\00\00\00\n\00\00\00c\00l\00a\00i\00m")
 (data $79 (i32.const 5596) "<")
 (data $79.1 (i32.const 5608) "\02\00\00\00 \00\00\00n\00o\00t\00h\00i\00n\00g\00 \00t\00o\00 \00c\00l\00a\00i\00m")
 (data $80 (i32.const 5660) "\1c")
 (data $80.1 (i32.const 5672) "\02\00\00\00\n\00\00\00C\00l\00a\00i\00m")
 (data $81 (i32.const 5692) ",")
 (data $81.1 (i32.const 5704) "\02\00\00\00\14\00\00\00d\00i\00s\00t\00r\00i\00b\00u\00t\00e")
 (data $82 (i32.const 5740) "L")
 (data $82.1 (i32.const 5752) "\02\00\00\008\00\00\00s\00e\00n\00d\00 \00s\00o\00m\00e\00 \00C\00T\00D\00Y\00 \00t\00o\00 \00d\00i\00s\00t\00r\00i\00b\00u\00t\00e")
 (data $83 (i32.const 5820) "L")
 (data $83.1 (i32.const 5832) "\02\00\00\008\00\00\00n\00o\00 \00i\00n\00v\00e\00s\00t\00o\00r\00 \00h\00o\00l\00d\00s\00 \00s\00h\00a\00r\00e\00s\00 \00y\00e\00t")
 (data $84 (i32.const 5900) "\1c")
 (data $84.1 (i32.const 5912) "\02\00\00\00\08\00\00\00p\00a\00i\00d")
 (data $85 (i32.const 5932) "\1c")
 (data $85.1 (i32.const 5944) "\02\00\00\00\0c\00\00\00I\00n\00c\00o\00m\00e")
 (data $86 (i32.const 5964) ",")
 (data $86.1 (i32.const 5976) "\02\00\00\00\1a\00\00\00a\00d\00d\00_\00l\00i\00q\00u\00i\00d\00i\00t\00y")
 (data $87 (i32.const 6012) "l")
 (data $87.1 (i32.const 6024) "\02\00\00\00X\00\00\00y\00o\00u\00 \00h\00a\00v\00e\00n\00\'\00t\00 \00p\00a\00s\00s\00e\00d\00 \00t\00h\00e\00 \00r\00e\00q\00u\00i\00r\00e\00d\00 \00c\00h\00e\00c\00k\00s\00 \00(\00K\00Y\00C\00)")
 (data $88 (i32.const 6124) ",")
 (data $88.1 (i32.const 6136) "\02\00\00\00\12\00\00\00p\00o\00o\00l\00_\00c\00t\00d\00y")
 (data $89 (i32.const 6172) "\1c")
 (data $89.1 (i32.const 6184) "\02\00\00\00\0c\00\00\00s\00h\00a\00r\00e\00s")
 (data $90 (i32.const 6204) "L")
 (data $90.1 (i32.const 6216) "\02\00\00\000\00\00\00a\00d\00d\00 \00b\00o\00t\00h\00 \00s\00h\00a\00r\00e\00s\00 \00a\00n\00d\00 \00C\00T\00D\00Y")
 (data $91 (i32.const 6284) "\1c")
 (data $91.1 (i32.const 6296) "\02\00\00\00\06\00\00\00l\00p\00s")
 (data $92 (i32.const 6316) "l")
 (data $92.1 (i32.const 6328) "\02\00\00\00R\00\00\00a\00d\00d\00 \00m\00o\00r\00e\00 \00s\00h\00a\00r\00e\00s\00 \00t\00o\00 \00m\00a\00t\00c\00h\00 \00t\00h\00e\00 \00p\00o\00o\00l\00\'\00s\00 \00p\00r\00i\00c\00e")
 (data $93 (i32.const 6428) ",")
 (data $93.1 (i32.const 6440) "\02\00\00\00\16\00\00\00P\00o\00o\00l\00D\00e\00p\00o\00s\00i\00t")
 (data $94 (i32.const 6476) ",")
 (data $94.1 (i32.const 6488) "\02\00\00\00\12\00\00\00t\00o\00o\00 \00s\00m\00a\00l\00l")
 (data $95 (i32.const 6524) "\1c")
 (data $95.1 (i32.const 6536) "\02\00\00\00\06\00\00\00l\00p\00:")
 (data $96 (i32.const 6556) "<")
 (data $96.1 (i32.const 6568) "\02\00\00\00 \00\00\00r\00e\00m\00o\00v\00e\00_\00l\00i\00q\00u\00i\00d\00i\00t\00y")
 (data $97 (i32.const 6620) ",")
 (data $97.1 (i32.const 6632) "\02\00\00\00\14\00\00\00p\00o\00o\00l\00 \00u\00n\00i\00t\00s")
 (data $98 (i32.const 6668) "\\")
 (data $98.1 (i32.const 6680) "\02\00\00\00F\00\00\00y\00o\00u\00 \00d\00o\00n\00\'\00t\00 \00h\00a\00v\00e\00 \00t\00h\00a\00t\00 \00m\00a\00n\00y\00 \00p\00o\00o\00l\00 \00u\00n\00i\00t\00s")
 (data $99 (i32.const 6764) ",")
 (data $99.1 (i32.const 6776) "\02\00\00\00\18\00\00\00P\00o\00o\00l\00W\00i\00t\00h\00d\00r\00a\00w")
 (data $100 (i32.const 6812) ",")
 (data $100.1 (i32.const 6824) "\02\00\00\00\10\00\00\00s\00w\00a\00p\00_\00b\00u\00y")
 (data $101 (i32.const 6860) ",")
 (data $101.1 (i32.const 6872) "\02\00\00\00\1c\00\00\00m\00i\00n\00 \00s\00h\00a\00r\00e\00s\00 \00o\00u\00t")
 (data $102 (i32.const 6908) "|")
 (data $102.1 (i32.const 6920) "\02\00\00\00j\00\00\00p\00r\00i\00c\00e\00 \00m\00o\00v\00e\00d\00:\00 \00y\00o\00u\00\'\00d\00 \00g\00e\00t\00 \00f\00e\00w\00e\00r\00 \00s\00h\00a\00r\00e\00s\00 \00t\00h\00a\00n\00 \00y\00o\00u\00r\00 \00m\00i\00n\00i\00m\00u\00m")
 (data $103 (i32.const 7036) "\\")
 (data $103.1 (i32.const 7048) "\02\00\00\00L\00\00\00t\00h\00e\00 \00p\00o\00o\00l\00 \00d\00o\00e\00s\00n\00\'\00t\00 \00h\00a\00v\00e\00 \00t\00h\00a\00t\00 \00m\00a\00n\00y\00 \00s\00h\00a\00r\00e\00s")
 (data $104 (i32.const 7132) "<")
 (data $104.1 (i32.const 7144) "\02\00\00\00(\00\00\00n\00o\00t\00 \00e\00n\00o\00u\00g\00h\00 \00C\00T\00D\00Y\00 \00s\00e\00n\00t")
 (data $105 (i32.const 7196) ",")
 (data $105.1 (i32.const 7208) "\02\00\00\00\0e\00\00\00S\00w\00a\00p\00B\00u\00y")
 (data $106 (i32.const 7244) ",")
 (data $106.1 (i32.const 7256) "\02\00\00\00\12\00\00\00s\00w\00a\00p\00_\00s\00e\00l\00l")
 (data $107 (i32.const 7292) ",")
 (data $107.1 (i32.const 7304) "\02\00\00\00\12\00\00\00s\00h\00a\00r\00e\00s\00 \00i\00n")
 (data $108 (i32.const 7340) ",")
 (data $108.1 (i32.const 7352) "\02\00\00\00\18\00\00\00m\00i\00n\00 \00C\00T\00D\00Y\00 \00o\00u\00t")
 (data $109 (i32.const 7388) "|")
 (data $109.1 (i32.const 7400) "\02\00\00\00d\00\00\00p\00r\00i\00c\00e\00 \00m\00o\00v\00e\00d\00:\00 \00y\00o\00u\00\'\00d\00 \00g\00e\00t\00 \00l\00e\00s\00s\00 \00C\00T\00D\00Y\00 \00t\00h\00a\00n\00 \00y\00o\00u\00r\00 \00m\00i\00n\00i\00m\00u\00m")
 (data $110 (i32.const 7516) ",")
 (data $110.1 (i32.const 7528) "\02\00\00\00\10\00\00\00S\00w\00a\00p\00S\00e\00l\00l")
 (data $111 (i32.const 7564) ",")
 (data $111.1 (i32.const 7576) "\02\00\00\00\12\00\00\00a\00d\00d\00_\00a\00g\00e\00n\00t")
 (data $112 (i32.const 7612) ",")
 (data $112.1 (i32.const 7624) "\02\00\00\00\18\00\00\00r\00e\00m\00o\00v\00e\00_\00a\00g\00e\00n\00t")
 (data $113 (i32.const 7660) "\\")
 (data $113.1 (i32.const 7672) "\02\00\00\00B\00\00\00o\00n\00l\00y\00 \00t\00h\00e\00 \00i\00s\00s\00u\00e\00r\00 \00c\00a\00n\00 \00c\00h\00a\00n\00g\00e\00 \00a\00g\00e\00n\00t\00s")
 (data $114 (i32.const 7756) "\1c")
 (data $114.1 (i32.const 7768) "\02\00\00\00\08\00\00\00a\00g\00t\00:")
 (data $115 (i32.const 7788) "\1c")
 (data $115.1 (i32.const 7800) "\02\00\00\00\n\00\00\00a\00g\00e\00n\00t")
 (data $116 (i32.const 7820) "\1c")
 (data $116.1 (i32.const 7832) "\02\00\00\00\n\00\00\00p\00a\00u\00s\00e")
 (data $117 (i32.const 7852) ",")
 (data $117.1 (i32.const 7864) "\02\00\00\00\0e\00\00\00u\00n\00p\00a\00u\00s\00e")
 (data $118 (i32.const 7900) "l")
 (data $118.1 (i32.const 7912) "\02\00\00\00R\00\00\00o\00n\00l\00y\00 \00t\00h\00e\00 \00i\00s\00s\00u\00e\00r\00 \00o\00r\00 \00i\00t\00s\00 \00a\00g\00e\00n\00t\00s\00 \00c\00a\00n\00 \00d\00o\00 \00t\00h\00i\00s")
 (data $119 (i32.const 8012) "\1c")
 (data $119.1 (i32.const 8024) "\02\00\00\00\0c\00\00\00P\00a\00u\00s\00e\00d")
 (data $120 (i32.const 8044) ",")
 (data $120.1 (i32.const 8056) "\02\00\00\00\10\00\00\00U\00n\00p\00a\00u\00s\00e\00d")
 (data $121 (i32.const 8092) "\1c")
 (data $121.1 (i32.const 8104) "\02\00\00\00\0c\00\00\00f\00r\00e\00e\00z\00e")
 (data $122 (i32.const 8124) ",")
 (data $122.1 (i32.const 8136) "\02\00\00\00\10\00\00\00u\00n\00f\00r\00e\00e\00z\00e")
 (data $123 (i32.const 8172) "\1c")
 (data $123.1 (i32.const 8184) "\02\00\00\00\06\00\00\00w\00h\00o")
 (data $124 (i32.const 8204) "\1c")
 (data $124.1 (i32.const 8216) "\02\00\00\00\0c\00\00\00F\00r\00o\00z\00e\00n")
 (data $125 (i32.const 8236) ",")
 (data $125.1 (i32.const 8248) "\02\00\00\00\10\00\00\00U\00n\00f\00r\00o\00z\00e\00n")
 (data $126 (i32.const 8284) ",")
 (data $126.1 (i32.const 8296) "\02\00\00\00\1c\00\00\00f\00r\00e\00e\00z\00e\00_\00p\00a\00r\00t\00i\00a\00l")
 (data $127 (i32.const 8332) "\\")
 (data $127.1 (i32.const 8344) "\02\00\00\00@\00\00\00c\00a\00n\00\'\00t\00 \00f\00r\00e\00e\00z\00e\00 \00m\00o\00r\00e\00 \00t\00h\00a\00n\00 \00t\00h\00e\00y\00 \00h\00o\00l\00d")
 (data $128 (i32.const 8428) ",")
 (data $128.1 (i32.const 8440) "\02\00\00\00\18\00\00\00P\00a\00r\00t\00l\00y\00F\00r\00o\00z\00e\00n")
 (data $129 (i32.const 8476) "<")
 (data $129.1 (i32.const 8488) "\02\00\00\00 \00\00\00u\00n\00f\00r\00e\00e\00z\00e\00_\00p\00a\00r\00t\00i\00a\00l")
 (data $130 (i32.const 8540) ",")
 (data $130.1 (i32.const 8552) "\02\00\00\00\1c\00\00\00f\00o\00r\00c\00e\00_\00t\00r\00a\00n\00s\00f\00e\00r")
 (data $131 (i32.const 8588) "\1c")
 (data $131.1 (i32.const 8600) "\02\00\00\00\08\00\00\00f\00r\00o\00m")
 (data $132 (i32.const 8620) ",")
 (data $132.1 (i32.const 8632) "\02\00\00\00\1c\00\00\00F\00o\00r\00c\00e\00d\00T\00r\00a\00n\00s\00f\00e\00r")
 (data $133 (i32.const 8668) ",")
 (data $133.1 (i32.const 8680) "\02\00\00\00\0e\00\00\00r\00e\00c\00o\00v\00e\00r")
 (data $134 (i32.const 8716) ",")
 (data $134.1 (i32.const 8728) "\02\00\00\00\16\00\00\00l\00o\00s\00t\00 \00w\00a\00l\00l\00e\00t")
 (data $135 (i32.const 8764) ",")
 (data $135.1 (i32.const 8776) "\02\00\00\00\14\00\00\00n\00e\00w\00 \00w\00a\00l\00l\00e\00t")
 (data $136 (i32.const 8812) ",")
 (data $136.1 (i32.const 8824) "\02\00\00\00\16\00\00\00i\00d\00e\00n\00t\00i\00t\00y\00_\00o\00f")
 (data $137 (i32.const 8860) "|")
 (data $137.1 (i32.const 8872) "\02\00\00\00b\00\00\00t\00h\00e\00 \00t\00w\00o\00 \00w\00a\00l\00l\00e\00t\00s\00 \00d\00o\00n\00\'\00t\00 \00b\00e\00l\00o\00n\00g\00 \00t\00o\00 \00t\00h\00e\00 \00s\00a\00m\00e\00 \00i\00d\00e\00n\00t\00i\00t\00y")
 (data $138 (i32.const 8988) ",")
 (data $138.1 (i32.const 9000) "\02\00\00\00\12\00\00\00R\00e\00c\00o\00v\00e\00r\00e\00d")
 (data $139 (i32.const 9036) "\1c")
 (data $139.1 (i32.const 9048) "\02\00\00\00\08\00\00\00m\00i\00n\00t")
 (data $140 (i32.const 9068) "\1c")
 (data $140.1 (i32.const 9080) "\02\00\00\00\0c\00\00\00M\00i\00n\00t\00e\00d")
 (data $141 (i32.const 9100) "\1c")
 (data $141.1 (i32.const 9112) "\02\00\00\00\08\00\00\00b\00u\00r\00n")
 (data $142 (i32.const 9132) "\1c")
 (data $142.1 (i32.const 9144) "\02\00\00\00\0c\00\00\00B\00u\00r\00n\00e\00d")
 (data $143 (i32.const 9164) ",")
 (data $143.1 (i32.const 9176) "\02\00\00\00\12\00\00\00s\00e\00t\00_\00p\00r\00i\00c\00e")
 (data $144 (i32.const 9212) ",")
 (data $144.1 (i32.const 9224) "\02\00\00\00\12\00\00\00s\00e\00t\00_\00r\00u\00l\00e\00s")
 (data $145 (i32.const 9260) "L")
 (data $145.1 (i32.const 9272) "\02\00\00\004\00\00\00m\00a\00x\00 \00h\00o\00l\00d\00e\00r\00s\00 \00(\000\00 \00=\00 \00n\00o\00 \00l\00i\00m\00i\00t\00)")
 (data $146 (i32.const 9340) "\\")
 (data $146.1 (i32.const 9352) "\02\00\00\00L\00\00\00m\00a\00x\00 \00s\00h\00a\00r\00e\00s\00 \00p\00e\00r\00 \00i\00n\00v\00e\00s\00t\00o\00r\00 \00(\000\00 \00=\00 \00n\00o\00 \00l\00i\00m\00i\00t\00)")
 (data $147 (i32.const 9436) ",")
 (data $147.1 (i32.const 9448) "\02\00\00\00\1a\00\00\00a\00l\00l\00o\00w\00_\00c\00o\00u\00n\00t\00r\00y")
 (data $148 (i32.const 9484) ",")
 (data $148.1 (i32.const 9496) "\02\00\00\00\1a\00\00\00b\00l\00o\00c\00k\00_\00c\00o\00u\00n\00t\00r\00y")
 (data $149 (i32.const 9532) ",")
 (data $149.1 (i32.const 9544) "\02\00\00\00\0e\00\00\00c\00o\00u\00n\00t\00r\00y")
 (data $150 (i32.const 9580) ",")
 (data $150.1 (i32.const 9592) "\02\00\00\00\18\00\00\00f\00u\00n\00d\00_\00r\00e\00s\00e\00r\00v\00e")
 (data $151 (i32.const 9628) "\1c")
 (data $151.1 (i32.const 9640) "\02\00\00\00\08\00\00\00i\00n\00f\00o")
 (data $152 (i32.const 9660) ",")
 (data $152.1 (i32.const 9672) "\02\00\00\00\14\00\00\00b\00a\00l\00a\00n\00c\00e\00_\00o\00f")
 (data $153 (i32.const 9708) ",")
 (data $153.1 (i32.const 9720) "\02\00\00\00\12\00\00\00c\00l\00a\00i\00m\00a\00b\00l\00e")
 (data $154 (i32.const 9756) "\1c")
 (data $154.1 (i32.const 9768) "\02\00\00\00\0c\00\00\00s\00t\00a\00t\00u\00s")
 (data $155 (i32.const 9788) "\1c")
 (data $155.1 (i32.const 9800) "\02\00\00\00\08\00\00\00p\00o\00o\00l")
 (data $156 (i32.const 9820) "\1c")
 (data $156.1 (i32.const 9832) "\02\00\00\00\n\00\00\00l\00p\00_\00o\00f")
 (data $157 (i32.const 9852) ",")
 (data $157.1 (i32.const 9864) "\02\00\00\00\12\00\00\00q\00u\00o\00t\00e\00_\00b\00u\00y")
 (data $158 (i32.const 9900) ",")
 (data $158.1 (i32.const 9912) "\02\00\00\00\0e\00\00\00C\00T\00D\00Y\00 \00i\00n")
 (data $159 (i32.const 9948) ",")
 (data $159.1 (i32.const 9960) "\02\00\00\00\16\00\00\00c\00o\00s\00t\00_\00t\00o\00_\00b\00u\00y")
 (data $160 (i32.const 9996) ",")
 (data $160.1 (i32.const 10008) "\02\00\00\00\14\00\00\00q\00u\00o\00t\00e\00_\00s\00e\00l\00l")
 (data $161 (i32.const 10044) "\1c")
 (data $161.1 (i32.const 10056) "\02\00\00\00\n\00\00\00r\00u\00l\00e\00s")
 (data $162 (i32.const 10076) "<")
 (data $162.1 (i32.const 10088) "\02\00\00\00 \00\00\00u\00n\00k\00n\00o\00w\00n\00 \00m\00e\00t\00h\00o\00d\00:\00 ")
 (export "init" (func $assembly/security/init))
 (export "call" (func $assembly/security/call))
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
    i32.const 3472
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
  block $__inlined_func$~lib/util/string/compareImpl$70
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
     br_if $__inlined_func$~lib/util/string/compareImpl$70
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
 (func $assembly/security/owner (result i32)
  (local $0 i32)
  i32.const 2432
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $0
  i32.eqz
  if
   i32.const 3232
   i32.const 3360
   i32.const 32
   i32.const 39
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
 )
 (func $assembly/sdk/sameAddress (param $0 i32) (param $1 i32) (result i32)
  (local $2 i32)
  local.get $0
  i32.load offset=8
  local.get $1
  i32.load offset=8
  i32.ne
  if
   i32.const 0
   return
  end
  loop $for-loop|0
   local.get $2
   local.get $0
   i32.load offset=8
   i32.lt_s
   if
    local.get $0
    local.get $2
    call $~lib/typedarray/Uint8Array#__get
    local.get $1
    local.get $2
    call $~lib/typedarray/Uint8Array#__get
    i32.ne
    if
     i32.const 0
     return
    end
    local.get $2
    i32.const 1
    i32.add
    local.set $2
    br $for-loop|0
   end
  end
  i32.const 1
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
 (func $assembly/sdk/U128#div (param $0 i32) (param $1 i64) (result i64)
  (local $2 i32)
  (local $3 i64)
  (local $4 i64)
  (local $5 i32)
  (local $6 i64)
  local.get $1
  i64.eqz
  if
   i32.const 4768
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
      i32.const 4816
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
 (func $assembly/security/onlyAgent
  (local $0 i32)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=4
  call $assembly/sdk/_caller
  local.get $0
  call $assembly/security/owner
  call $assembly/sdk/sameAddress
  if (result i32)
   i32.const 1
  else
   i32.const 7776
   call $assembly/sdk/utf8
   local.get $0
   call $assembly/sdk/concat
   call $assembly/sdk/loadFlag
  end
  i32.eqz
  if
   i32.const 7920
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
  end
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
 (func $assembly/security/forceMove (param $0 i32) (param $1 i32) (param $2 i64) (param $3 i32)
  (local $4 i32)
  i32.const 2608
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
  local.get $2
  i64.lt_u
  if
   i32.const 3056
   call $assembly/sdk/utf8
   local.tee $4
   i32.load offset=4
   local.get $4
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  call $assembly/security/settle
  local.get $1
  call $assembly/security/settle
  local.get $0
  i32.const 2608
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
  local.get $2
  i64.sub
  call $assembly/security/setBalance
  local.get $1
  i32.const 2608
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
  call $assembly/security/setBalance
  local.get $0
  local.get $1
  call $assembly/sdk/concat
  local.get $2
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  local.set $0
  local.get $3
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
 (func $assembly/security/settle (param $0 i32)
  (local $1 i32)
  i32.const 4672
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.get $0
  call $assembly/security/earned
  call $assembly/sdk/saveU64
  i32.const 4736
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.set $0
  i32.const 4704
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
 (func $assembly/security/verified (param $0 i32) (result i32)
  (local $1 i32)
  local.get $0
  call $assembly/security/owner
  call $assembly/sdk/sameAddress
  if (result i32)
   i32.const 1
  else
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $1
   i32.load offset=4
   call $assembly/sdk/_self
   local.get $0
   local.get $1
   call $assembly/sdk/sameAddress
  end
  if
   i32.const 1
   return
  end
  i32.const 3424
  local.get $0
  call $assembly/security/registryAsk
  i64.const 0
  i64.ne
 )
 (func $assembly/security/str (param $0 i32) (result i32)
  local.get $0
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $0
  i32.eqz
  if
   i32.const 3232
   i32.const 3360
   i32.const 30
   i32.const 64
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
  i32.load
  local.tee $0
  local.get $0
  i32.const 20
  i32.sub
  i32.load offset=16
  call $~lib/string/String.UTF8.decodeUnsafe
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
   i32.const 5152
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
 (func $assembly/security/checkSend (param $0 i32) (param $1 i64)
  (local $2 i64)
  (local $3 i32)
  i32.const 2944
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
  if
   i32.const 2976
   call $assembly/sdk/utf8
   local.tee $3
   i32.load offset=4
   local.get $3
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $1
  i32.const 2608
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
  local.tee $2
  i64.gt_u
  if
   i32.const 3056
   call $assembly/sdk/utf8
   local.tee $3
   i32.load offset=4
   local.get $3
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 3120
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
  local.get $1
  i64.sub
  i64.gt_u
  if
   i32.const 3152
   call $assembly/sdk/utf8
   local.tee $0
   i32.load offset=4
   local.get $0
   i32.load offset=8
   call $assembly/sdk/_revert
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
 (func $assembly/security/settlePool
  (local $0 i32)
  (local $1 i64)
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=4
  call $assembly/sdk/_self
  local.get $0
  call $assembly/security/settle
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $0
  i32.load offset=4
  call $assembly/sdk/_self
  i32.const 4672
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
  local.tee $1
  i64.const 0
  i64.ne
  if
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $0
   i32.load offset=4
   call $assembly/sdk/_self
   i32.const 4672
   call $assembly/sdk/utf8
   local.get $0
   call $assembly/sdk/concat
   i64.const 0
   call $assembly/sdk/saveU64
   i32.const 6144
   call $assembly/sdk/utf8
   i32.const 6144
   call $assembly/sdk/utf8
   call $assembly/sdk/load
   local.tee $0
   if (result i64)
    local.get $0
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
   local.get $1
   i64.add
   call $assembly/sdk/saveU64
  end
 )
 (func $assembly/security/setBalance (param $0 i32) (param $1 i64)
  (local $2 i64)
  (local $3 i32)
  i32.const 2608
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
  local.set $2
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  local.get $1
  call $assembly/sdk/saveU64
  local.get $0
  call $assembly/security/owner
  call $assembly/sdk/sameAddress
  if (result i32)
   i32.const 1
  else
   local.get $0
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $0
   i32.load offset=4
   call $assembly/sdk/_self
   local.get $0
   call $assembly/sdk/sameAddress
  end
  if
   return
  end
  local.get $2
  i64.eqz
  local.get $1
  i64.const 0
  i64.ne
  i32.and
  if
   i32.const 4448
   call $assembly/sdk/utf8
   i32.const 4448
   call $assembly/sdk/utf8
   call $assembly/sdk/load
   local.tee $0
   if (result i64)
    local.get $0
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
   i64.const 1
   i64.add
   call $assembly/sdk/saveU64
  end
  local.get $1
  i64.eqz
  local.get $2
  i64.const 0
  i64.ne
  i32.and
  if
   i32.const 4448
   call $assembly/sdk/utf8
   i32.const 4448
   call $assembly/sdk/utf8
   call $assembly/sdk/load
   local.tee $0
   if (result i64)
    local.get $0
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
   i64.const 1
   i64.sub
   call $assembly/sdk/saveU64
  end
 )
 (func $assembly/security/registryAsk (param $0 i32) (param $1 i32) (result i64)
  (local $2 i32)
  (local $3 i32)
  (local $4 i64)
  call $assembly/sdk/Writer#constructor
  local.get $0
  call $assembly/sdk/Writer#str
  local.tee $2
  i32.const 1
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $3
  i32.const 0
  i32.const 3
  call $~lib/typedarray/Uint8Array#__set
  local.get $3
  call $assembly/sdk/Writer#push
  drop
  local.get $2
  local.get $1
  call $assembly/sdk/Writer#push
  local.set $1
  local.get $0
  i32.const 3424
  call $~lib/string/String.__eq
  if
   i32.const 2512
   call $assembly/sdk/utf8
   call $assembly/sdk/load
   local.tee $0
   if (result i64)
    local.get $0
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
   local.set $4
   i32.const 1
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $0
   i32.const 0
   i32.const 1
   call $~lib/typedarray/Uint8Array#__set
   local.get $1
   local.get $0
   call $assembly/sdk/Writer#push
   drop
   local.get $1
   local.get $4
   call $assembly/sdk/u64Bytes
   call $assembly/sdk/Writer#push
   drop
  end
  i32.const 2464
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $2
  i32.eqz
  if
   i32.const 3232
   i32.const 3360
   i32.const 48
   i32.const 26
   call $~lib/builtins/abort
   unreachable
  end
  local.get $1
  call $assembly/sdk/Writer#done
  local.set $1
  i32.const 0
  local.set $0
  local.get $2
  i32.load offset=4
  local.get $1
  i32.load offset=4
  local.get $1
  i32.load offset=8
  call $assembly/sdk/_static_call
  local.tee $1
  i32.const 0
  i32.ge_s
  if
   local.get $1
   call $~lib/typedarray/Uint8Array#constructor
   local.set $0
   local.get $1
   i32.const 0
   i32.gt_s
   if
    local.get $0
    i32.load offset=4
    call $assembly/sdk/_return_data
   end
  end
  local.get $0
  i32.eqz
  if
   i32.const 3648
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  i32.eqz
  if
   i32.const 3232
   i32.const 3360
   i32.const 50
   i32.const 21
   call $~lib/builtins/abort
   unreachable
  end
  i32.const 8
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $1
  local.get $0
  i32.store offset=4
  local.get $1
  i32.const 0
  i32.store
  local.get $1
  i32.const 3744
  call $assembly/sdk/Reader#u64
 )
 (func $assembly/security/checkReceive (param $0 i32) (param $1 i64)
  (local $2 i32)
  (local $3 i64)
  local.get $0
  call $assembly/security/verified
  i32.eqz
  if
   i32.const 3776
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  call $assembly/security/countryOk
  i32.eqz
  if
   i32.const 4016
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 2944
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
  if
   i32.const 4144
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $0
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $2
  if (result i64)
   local.get $2
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.get $1
  i64.add
  local.set $3
  i32.const 4224
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $2
  if (result i64)
   local.get $2
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $1
  i64.const 0
  i64.ne
  if (result i32)
   local.get $0
   call $assembly/security/owner
   call $assembly/sdk/sameAddress
  else
   i32.const 1
  end
  if (result i32)
   i32.const 0
  else
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $2
   i32.load offset=4
   call $assembly/sdk/_self
   local.get $0
   local.get $2
   call $assembly/sdk/sameAddress
   i32.eqz
  end
  i32.const 0
  local.get $1
  local.get $3
  i64.lt_u
  select
  if
   i32.const 4272
   call $assembly/sdk/utf8
   local.tee $2
   i32.load offset=4
   local.get $2
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 4400
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $2
  if (result i64)
   local.get $2
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $1
  i64.const 0
  i64.ne
  if (result i64)
   i32.const 2608
   call $assembly/sdk/utf8
   local.get $0
   call $assembly/sdk/concat
   call $assembly/sdk/load
   local.tee $2
   if (result i64)
    local.get $2
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
  else
   i64.const 1
  end
  i64.eqz
  if (result i32)
   local.get $0
   call $assembly/security/owner
   call $assembly/sdk/sameAddress
  else
   i32.const 1
  end
  if (result i32)
   i32.const 1
  else
   local.get $0
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $0
   i32.load offset=4
   call $assembly/sdk/_self
   local.get $0
   call $assembly/sdk/sameAddress
  end
  i32.eqz
  if
   i32.const 4448
   call $assembly/sdk/utf8
   call $assembly/sdk/load
   local.tee $0
   if (result i64)
    local.get $0
    i32.const 0
    call $assembly/sdk/bytesU64
   else
    i64.const 0
   end
   local.get $1
   i64.ge_u
   if
    i32.const 4496
    call $assembly/sdk/utf8
    local.tee $0
    i32.load offset=4
    local.get $0
    i32.load offset=8
    call $assembly/sdk/_revert
   end
  end
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
   i32.const 3472
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
   i32.const 3520
   i32.const 3472
   i32.const 118
   i32.const 40
   call $~lib/builtins/abort
   unreachable
  end
  local.get $0
 )
 (func $assembly/security/quoteSell (param $0 i64) (result i64)
  (local $1 i32)
  (local $2 i64)
  (local $3 i64)
  i32.const 6144
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.set $2
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $1
  i32.load offset=4
  call $assembly/sdk/_self
  local.get $0
  i64.eqz
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $3
  i64.eqz
  local.get $2
  i64.eqz
  i32.or
  i32.or
  if
   i64.const 0
   return
  end
  local.get $2
  local.get $0
  i64.const 997
  call $assembly/sdk/U128.mul
  i64.const 1000
  call $assembly/sdk/U128#div
  local.tee $0
  call $assembly/sdk/U128.mul
  local.get $0
  local.get $3
  i64.add
  call $assembly/sdk/U128#div
 )
 (func $assembly/security/quoteBuy (param $0 i64) (result i64)
  (local $1 i32)
  (local $2 i64)
  (local $3 i64)
  i32.const 6144
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.set $2
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $1
  i32.load offset=4
  call $assembly/sdk/_self
  local.get $0
  i64.eqz
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $3
  i64.eqz
  local.get $2
  i64.eqz
  i32.or
  i32.or
  if
   i64.const 0
   return
  end
  local.get $3
  local.get $0
  i64.const 997
  call $assembly/sdk/U128.mul
  i64.const 1000
  call $assembly/sdk/U128#div
  local.tee $0
  call $assembly/sdk/U128.mul
  local.get $0
  local.get $2
  i64.add
  call $assembly/sdk/U128#div
 )
 (func $assembly/security/move (param $0 i32) (param $1 i32) (param $2 i64)
  (local $3 i32)
  i32.const 2848
  call $assembly/sdk/utf8
  call $assembly/sdk/loadFlag
  if
   i32.const 2880
   call $assembly/sdk/utf8
   local.tee $3
   i32.load offset=4
   local.get $3
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $0
  local.get $2
  call $assembly/security/checkSend
  local.get $1
  local.get $2
  call $assembly/security/checkReceive
  local.get $0
  local.get $1
  local.get $2
  i32.const 4624
  call $assembly/security/forceMove
 )
 (func $assembly/security/earned (param $0 i32) (result i64)
  (local $1 i64)
  (local $2 i32)
  (local $3 i32)
  (local $4 i64)
  (local $5 i64)
  local.get $0
  call $assembly/security/owner
  call $assembly/sdk/sameAddress
  if
   i32.const 4672
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
   return
  end
  i32.const 4704
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  call $assembly/sdk/U128.from
  local.set $2
  i32.const 4736
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
  i32.const 2608
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
  i32.const 4672
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
 (func $assembly/security/countryOk (param $0 i32) (result i32)
  (local $1 i32)
  i32.const 3904
  call $assembly/sdk/utf8
  call $assembly/sdk/loadFlag
  if (result i32)
   local.get $0
   call $assembly/security/owner
   call $assembly/sdk/sameAddress
  else
   i32.const 1
  end
  if (result i32)
   i32.const 1
  else
   i32.const 20
   call $~lib/typedarray/Uint8Array#constructor
   local.tee $1
   i32.load offset=4
   call $assembly/sdk/_self
   local.get $0
   local.get $1
   call $assembly/sdk/sameAddress
  end
  if
   i32.const 1
   return
  end
  i32.const 3936
  call $assembly/sdk/utf8
  i32.const 3968
  local.get $0
  call $assembly/security/registryAsk
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  call $assembly/sdk/loadFlag
 )
 (func $assembly/security/costToBuy (param $0 i64) (result i64)
  (local $1 i32)
  (local $2 i64)
  (local $3 i64)
  i32.const 6144
  call $assembly/sdk/utf8
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $1
  i32.load offset=4
  call $assembly/sdk/_self
  local.get $0
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/concat
  call $assembly/sdk/load
  local.tee $1
  if (result i64)
   local.get $1
   i32.const 0
   call $assembly/sdk/bytesU64
  else
   i64.const 0
  end
  local.tee $3
  i64.ge_u
  if
   i32.const 7056
   call $assembly/sdk/utf8
   local.tee $1
   i32.load offset=4
   local.get $1
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i64.const 1000
  i64.mul
  local.get $0
  call $assembly/sdk/U128.mul
  local.get $3
  local.get $0
  i64.sub
  i64.const 997
  i64.mul
  call $assembly/sdk/U128#div
  i64.const 1
  i64.add
 )
 (func $assembly/sdk/Writer#done (param $0 i32) (result i32)
  (local $1 i32)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  local.get $0
  i32.load offset=4
  call $~lib/typedarray/Uint8Array#constructor
  local.set $2
  loop $for-loop|0
   local.get $1
   local.get $0
   i32.load
   local.tee $4
   i32.load offset=12
   i32.lt_s
   if
    local.get $2
    local.get $4
    local.get $1
    call $~lib/array/Array<~lib/typedarray/Uint8Array>#__get
    local.get $3
    call $~lib/typedarray/Uint8Array#set<~lib/typedarray/Uint8Array>
    local.get $3
    local.get $0
    i32.load
    local.get $1
    call $~lib/array/Array<~lib/typedarray/Uint8Array>#__get
    i32.load offset=8
    i32.add
    local.set $3
    local.get $1
    i32.const 1
    i32.add
    local.set $1
    br $for-loop|0
   end
  end
  local.get $2
 )
 (func $assembly/sdk/Writer#constructor (result i32)
  (local $0 i32)
  (local $1 i32)
  (local $2 i32)
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
  local.tee $2
  i32.const 2704
  i32.const 0
  memory.copy
  i32.const 16
  i32.const 7
  call $~lib/rt/stub/__new
  local.tee $1
  local.get $2
  i32.store
  local.get $1
  local.get $2
  i32.store offset=4
  local.get $1
  i32.const 0
  i32.store offset=8
  local.get $1
  i32.const 0
  i32.store offset=12
  local.get $0
  local.get $1
  i32.store
  local.get $0
  i32.const 0
  i32.store offset=4
  local.get $0
 )
 (func $~start
  i32.const 10140
  global.set $~lib/rt/stub/offset
 )
 (func $assembly/security/init
  (local $0 i32)
  (local $1 i64)
  (local $2 i64)
  (local $3 i64)
  (local $4 i32)
  (local $5 i32)
  (local $6 i32)
  (local $7 i32)
  (local $8 i32)
  (local $9 i32)
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
  local.tee $5
  local.get $0
  i32.store offset=4
  local.get $5
  i32.const 0
  i32.store
  local.get $5
  i32.const 1296
  call $assembly/sdk/Reader#str
  local.get $5
  i32.const 1808
  call $assembly/sdk/Reader#str
  local.set $4
  local.get $5
  i32.const 1840
  call $assembly/sdk/Reader#str
  local.set $7
  local.get $5
  i32.const 1872
  call $assembly/sdk/Reader#addr
  local.set $0
  local.get $5
  i32.const 1936
  call $assembly/sdk/Reader#u64
  local.set $2
  local.get $5
  i32.const 2000
  call $assembly/sdk/Reader#u64
  local.set $3
  local.get $5
  i32.const 2064
  call $assembly/sdk/Reader#u64
  local.set $1
  local.get $5
  i32.const 2112
  call $assembly/sdk/Reader#str
  local.set $5
  local.get $7
  i32.const 2160
  call $~lib/string/String.__eq
  if (result i32)
   i32.const 1
  else
   local.get $7
   i32.const 2208
   call $~lib/string/String.__eq
  end
  i32.eqz
  if
   i32.const 2240
   call $assembly/sdk/utf8
   local.tee $8
   i32.load offset=4
   local.get $8
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  local.get $1
  i64.eqz
  if
   i32.const 2320
   call $assembly/sdk/utf8
   local.tee $8
   i32.load offset=4
   local.get $8
   i32.load offset=8
   call $assembly/sdk/_revert
  end
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $8
  i32.load offset=4
  call $assembly/sdk/_caller
  i32.const 1296
  call $assembly/sdk/utf8
  local.set $9
  call $assembly/sdk/utf8
  local.set $6
  local.get $9
  i32.load offset=4
  local.get $9
  i32.load offset=8
  local.get $6
  i32.load offset=4
  local.get $6
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 1808
  call $assembly/sdk/utf8
  local.set $6
  local.get $4
  call $assembly/sdk/utf8
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
  i32.const 1840
  call $assembly/sdk/utf8
  local.set $4
  local.get $7
  call $assembly/sdk/utf8
  local.set $6
  local.get $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  local.get $6
  i32.load offset=4
  local.get $6
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2400
  call $assembly/sdk/utf8
  local.set $4
  local.get $5
  call $assembly/sdk/utf8
  local.set $5
  local.get $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  local.get $5
  i32.load offset=4
  local.get $5
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2432
  call $assembly/sdk/utf8
  local.tee $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  local.get $8
  i32.load offset=4
  local.get $8
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2464
  call $assembly/sdk/utf8
  local.tee $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_storage_write
  i32.const 2512
  call $assembly/sdk/utf8
  local.get $2
  call $assembly/sdk/saveU64
  i32.const 2544
  call $assembly/sdk/utf8
  local.get $3
  call $assembly/sdk/saveU64
  i32.const 2576
  call $assembly/sdk/utf8
  local.get $1
  call $assembly/sdk/saveU64
  i32.const 2608
  call $assembly/sdk/utf8
  local.get $8
  call $assembly/sdk/concat
  local.get $1
  call $assembly/sdk/saveU64
  local.get $8
  local.get $1
  call $assembly/sdk/u64Bytes
  call $assembly/sdk/concat
  local.set $0
  i32.const 2640
  call $assembly/sdk/utf8
  local.tee $4
  i32.load offset=4
  local.get $4
  i32.load offset=8
  local.get $0
  i32.load offset=4
  local.get $0
  i32.load offset=8
  call $assembly/sdk/_emit
 )
 (func $assembly/security/call
  (local $0 i64)
  (local $1 i64)
  (local $2 i32)
  (local $3 i32)
  (local $4 i32)
  (local $5 i64)
  (local $6 i64)
  (local $7 i64)
  (local $8 i32)
  (local $9 i32)
  (local $10 i32)
  (local $11 i64)
  (local $12 i64)
  call $assembly/sdk/_input_len
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $2
  i32.load offset=8
  i32.const 0
  i32.gt_s
  if
   local.get $2
   i32.load offset=4
   call $assembly/sdk/_input_read
  end
  i32.const 8
  i32.const 4
  call $~lib/rt/stub/__new
  local.tee $10
  local.get $2
  i32.store offset=4
  local.get $10
  i32.const 0
  i32.store
  local.get $10
  i32.const 2672
  call $assembly/sdk/Reader#str
  local.set $9
  call $assembly/sdk/Writer#constructor
  local.set $8
  i32.const 20
  call $~lib/typedarray/Uint8Array#constructor
  local.tee $4
  i32.load offset=4
  call $assembly/sdk/_caller
  local.get $9
  i32.const 2736
  call $~lib/string/String.__eq
  if
   local.get $4
   local.get $10
   i32.const 2784
   call $assembly/sdk/Reader#addr
   local.get $10
   i32.const 2816
   call $assembly/sdk/Reader#u64
   call $assembly/security/move
  else
   local.get $9
   i32.const 4864
   call $~lib/string/String.__eq
   if
    local.get $10
    i32.const 2816
    call $assembly/sdk/Reader#u64
    local.set $1
    i32.const 2544
    call $assembly/sdk/utf8
    call $assembly/sdk/load
    local.tee $2
    if (result i64)
     local.get $2
     i32.const 0
     call $assembly/sdk/bytesU64
    else
     i64.const 0
    end
    local.tee $0
    i64.eqz
    if
     i32.const 4896
     call $assembly/sdk/utf8
     local.tee $2
     i32.load offset=4
     local.get $2
     i32.load offset=8
     call $assembly/sdk/_revert
    end
    local.get $0
    local.get $1
    call $assembly/sdk/U128.mul
    local.tee $2
    i64.load
    i64.eqz
    if (result i32)
     local.get $2
     i64.load offset=8
     call $assembly/sdk/_value
     i64.eq
    else
     i32.const 0
    end
    i32.eqz
    if
     i32.const 5024
     call $assembly/sdk/utf8
     local.tee $2
     i32.load offset=4
     local.get $2
     i32.load offset=8
     call $assembly/sdk/_revert
    end
    call $assembly/security/owner
    local.get $4
    local.get $1
    call $assembly/security/move
    i32.const 1840
    call $assembly/security/str
    i32.const 2208
    call $~lib/string/String.__eq
    if
     i32.const 5104
     call $assembly/sdk/utf8
     i32.const 5104
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     local.tee $2
     if (result i64)
      local.get $2
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     local.set $0
     call $assembly/sdk/_value
     local.get $0
     i64.add
     call $assembly/sdk/saveU64
    else
     call $assembly/security/owner
     call $assembly/sdk/_value
     call $assembly/sdk/pay
    end
    local.get $4
    local.get $1
    call $assembly/sdk/u64Bytes
    call $assembly/sdk/concat
    local.set $3
    i32.const 5248
    call $assembly/sdk/utf8
    local.tee $2
    i32.load offset=4
    local.get $2
    i32.load offset=8
    local.get $3
    i32.load offset=4
    local.get $3
    i32.load offset=8
    call $assembly/sdk/_emit
   else
    local.get $9
    i32.const 5280
    call $~lib/string/String.__eq
    if
     i32.const 1840
     call $assembly/security/str
     i32.const 2208
     call $~lib/string/String.__eq
     i32.eqz
     if
      i32.const 5312
      call $assembly/sdk/utf8
      local.tee $2
      i32.load offset=4
      local.get $2
      i32.load offset=8
      call $assembly/sdk/_revert
     end
     i32.const 2848
     call $assembly/sdk/utf8
     call $assembly/sdk/loadFlag
     if
      i32.const 2880
      call $assembly/sdk/utf8
      local.tee $2
      i32.load offset=4
      local.get $2
      i32.load offset=8
      call $assembly/sdk/_revert
     end
     local.get $4
     local.get $10
     i32.const 2816
     call $assembly/sdk/Reader#u64
     local.tee $5
     call $assembly/security/checkSend
     local.get $5
     i32.const 2544
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     local.tee $2
     if (result i64)
      local.get $2
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     call $assembly/sdk/U128.mul
     i64.const 1
     call $assembly/sdk/U128#div
     local.tee $1
     i32.const 5104
     call $assembly/sdk/utf8
     call $assembly/sdk/load
     local.tee $2
     if (result i64)
      local.get $2
      i32.const 0
      call $assembly/sdk/bytesU64
     else
      i64.const 0
     end
     local.tee $0
     i64.gt_u
     if
      i32.const 5408
      call $assembly/sdk/utf8
      local.tee $2
      i32.load offset=4
      local.get $2
      i32.load offset=8
      call $assembly/sdk/_revert
     end
     local.get $4
     call $assembly/security/owner
     local.get $5
     i32.const 5552
     call $assembly/security/forceMove
     i32.const 5104
     call $assembly/sdk/utf8
     local.get $0
     local.get $1
     i64.sub
     call $assembly/sdk/saveU64
     local.get $4
     local.get $1
     call $assembly/sdk/pay
    else
     local.get $9
     i32.const 5584
     call $~lib/string/String.__eq
     if
      local.get $4
      call $assembly/security/settle
      i32.const 4672
      call $assembly/sdk/utf8
      local.get $4
      call $assembly/sdk/concat
      call $assembly/sdk/load
      local.tee $2
      if (result i64)
       local.get $2
       i32.const 0
       call $assembly/sdk/bytesU64
      else
       i64.const 0
      end
      local.tee $0
      i64.eqz
      if
       i32.const 5616
       call $assembly/sdk/utf8
       local.tee $2
       i32.load offset=4
       local.get $2
       i32.load offset=8
       call $assembly/sdk/_revert
      end
      i32.const 4672
      call $assembly/sdk/utf8
      local.get $4
      call $assembly/sdk/concat
      i64.const 0
      call $assembly/sdk/saveU64
      local.get $4
      local.get $0
      call $assembly/sdk/pay
      local.get $4
      local.get $0
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/concat
      local.set $3
      i32.const 5680
      call $assembly/sdk/utf8
      local.tee $2
      i32.load offset=4
      local.get $2
      i32.load offset=8
      local.get $3
      i32.load offset=4
      local.get $3
      i32.load offset=8
      call $assembly/sdk/_emit
      i32.const 1
      call $~lib/typedarray/Uint8Array#constructor
      local.tee $2
      i32.const 0
      i32.const 1
      call $~lib/typedarray/Uint8Array#__set
      local.get $8
      local.get $2
      call $assembly/sdk/Writer#push
      drop
      local.get $8
      local.get $0
      call $assembly/sdk/u64Bytes
      call $assembly/sdk/Writer#push
      drop
     else
      local.get $9
      i32.const 5712
      call $~lib/string/String.__eq
      if
       call $assembly/sdk/_value
       local.tee $7
       i64.eqz
       if
        i32.const 5760
        call $assembly/sdk/utf8
        local.tee $2
        i32.load offset=4
        local.get $2
        i32.load offset=8
        call $assembly/sdk/_revert
       end
       i32.const 2576
       call $assembly/sdk/utf8
       call $assembly/sdk/load
       local.tee $2
       if (result i64)
        local.get $2
        i32.const 0
        call $assembly/sdk/bytesU64
       else
        i64.const 0
       end
       call $assembly/security/owner
       local.set $2
       i32.const 2608
       call $assembly/sdk/utf8
       local.get $2
       call $assembly/sdk/concat
       call $assembly/sdk/load
       local.tee $2
       if (result i64)
        local.get $2
        i32.const 0
        call $assembly/sdk/bytesU64
       else
        i64.const 0
       end
       i64.sub
       local.tee $6
       i64.eqz
       if
        i32.const 5840
        call $assembly/sdk/utf8
        local.tee $2
        i32.load offset=4
        local.get $2
        i32.load offset=8
        call $assembly/sdk/_revert
       end
       local.get $7
       i64.const 1000000000000000000
       call $assembly/sdk/U128.mul
       local.tee $2
       i64.load
       local.tee $0
       local.get $6
       i64.div_u
       local.set $5
       local.get $0
       local.get $6
       i64.rem_u
       local.set $1
       local.get $2
       i64.load offset=8
       local.set $0
       i32.const 16
       i32.const 9
       call $~lib/rt/stub/__new
       local.tee $2
       local.get $1
       i64.store
       local.get $2
       local.get $0
       i64.store offset=8
       local.get $2
       local.get $6
       call $assembly/sdk/U128#div
       local.set $0
       i32.const 16
       i32.const 9
       call $~lib/rt/stub/__new
       local.tee $4
       local.get $5
       i64.store
       local.get $4
       local.get $0
       i64.store offset=8
       i32.const 4704
       call $assembly/sdk/utf8
       local.set $3
       i32.const 4704
       call $assembly/sdk/utf8
       call $assembly/sdk/load
       call $assembly/sdk/U128.from
       local.tee $2
       i64.load offset=8
       local.tee $0
       local.get $0
       local.get $4
       i64.load offset=8
       i64.add
       local.tee $1
       i64.gt_u
       i64.extend_i32_u
       local.get $2
       i64.load
       local.get $4
       i64.load
       i64.add
       i64.add
       local.set $0
       i32.const 16
       i32.const 9
       call $~lib/rt/stub/__new
       local.tee $2
       local.get $0
       i64.store
       local.get $2
       local.get $1
       i64.store offset=8
       local.get $2
       i64.load
       call $assembly/sdk/u64Bytes
       local.get $2
       i64.load offset=8
       call $assembly/sdk/u64Bytes
       call $assembly/sdk/concat
       local.set $2
       local.get $3
       i32.load offset=4
       local.get $3
       i32.load offset=8
       local.get $2
       i32.load offset=4
       local.get $2
       i32.load offset=8
       call $assembly/sdk/_storage_write
       i32.const 5920
       call $assembly/sdk/utf8
       i32.const 5920
       call $assembly/sdk/utf8
       call $assembly/sdk/load
       local.tee $2
       if (result i64)
        local.get $2
        i32.const 0
        call $assembly/sdk/bytesU64
       else
        i64.const 0
       end
       local.get $7
       i64.add
       call $assembly/sdk/saveU64
       local.get $7
       call $assembly/sdk/u64Bytes
       local.set $3
       i32.const 5952
       call $assembly/sdk/utf8
       local.tee $2
       i32.load offset=4
       local.get $2
       i32.load offset=8
       local.get $3
       i32.load offset=4
       local.get $3
       i32.load offset=8
       call $assembly/sdk/_emit
      else
       local.get $9
       i32.const 5984
       call $~lib/string/String.__eq
       if
        i32.const 2848
        call $assembly/sdk/utf8
        call $assembly/sdk/loadFlag
        if
         i32.const 2880
         call $assembly/sdk/utf8
         local.tee $2
         i32.load offset=4
         local.get $2
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        local.get $4
        call $assembly/security/verified
        i32.eqz
        if
         i32.const 6032
         call $assembly/sdk/utf8
         local.tee $2
         i32.load offset=4
         local.get $2
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        call $assembly/security/settlePool
        local.get $10
        i32.const 6192
        call $assembly/sdk/Reader#u64
        local.set $7
        call $assembly/sdk/_value
        local.tee $6
        i64.const 0
        i64.ne
        local.get $7
        i64.const 0
        i64.ne
        i32.and
        i32.eqz
        if
         i32.const 6224
         call $assembly/sdk/utf8
         local.tee $2
         i32.load offset=4
         local.get $2
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        i32.const 6144
        call $assembly/sdk/utf8
        call $assembly/sdk/load
        local.tee $2
        if (result i64)
         local.get $2
         i32.const 0
         call $assembly/sdk/bytesU64
        else
         i64.const 0
        end
        local.set $12
        i32.const 20
        call $~lib/typedarray/Uint8Array#constructor
        local.tee $2
        i32.load offset=4
        call $assembly/sdk/_self
        i32.const 2608
        call $assembly/sdk/utf8
        local.get $2
        call $assembly/sdk/concat
        call $assembly/sdk/load
        local.tee $2
        if (result i64)
         local.get $2
         i32.const 0
         call $assembly/sdk/bytesU64
        else
         i64.const 0
        end
        local.set $0
        i32.const 6304
        call $assembly/sdk/utf8
        call $assembly/sdk/load
        local.tee $2
        if (result i64)
         local.get $2
         i32.const 0
         call $assembly/sdk/bytesU64
        else
         i64.const 0
        end
        local.tee $11
        i64.eqz
        if
         local.get $7
         local.get $6
         call $assembly/sdk/U128.mul
         i64.const 1
         call $assembly/sdk/U128#div
         local.tee $5
         local.tee $1
         i64.const 2
         i64.ge_u
         if
          local.get $1
          i64.const 1
          i64.add
          i64.const 1
          i64.shr_u
          local.set $0
          loop $while-continue|0
           local.get $0
           local.get $1
           i64.lt_u
           if
            local.get $5
            local.get $0
            local.tee $1
            i64.div_u
            local.get $1
            i64.add
            i64.const 1
            i64.shr_u
            local.set $0
            br $while-continue|0
           end
          end
         end
        else
         local.get $6
         local.get $0
         call $assembly/sdk/U128.mul
         local.get $12
         call $assembly/sdk/U128#div
         local.tee $0
         local.get $7
         i64.gt_u
         if
          i32.const 6336
          call $assembly/sdk/utf8
          local.tee $2
          i32.load offset=4
          local.get $2
          i32.load offset=8
          call $assembly/sdk/_revert
         end
         local.get $6
         local.get $11
         call $assembly/sdk/U128.mul
         local.get $12
         call $assembly/sdk/U128#div
         local.set $1
         local.get $4
         local.get $0
         call $assembly/security/checkSend
         i32.const 20
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.load offset=4
         call $assembly/sdk/_self
         local.get $4
         local.get $2
         local.get $0
         i32.const 6448
         call $assembly/security/forceMove
        end
        local.get $11
        i64.eqz
        if
         local.get $4
         local.get $7
         call $assembly/security/checkSend
         i32.const 20
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.load offset=4
         call $assembly/sdk/_self
         local.get $4
         local.get $2
         local.get $7
         i32.const 6448
         call $assembly/security/forceMove
        end
        local.get $1
        i64.eqz
        if
         i32.const 6496
         call $assembly/sdk/utf8
         local.tee $2
         i32.load offset=4
         local.get $2
         i32.load offset=8
         call $assembly/sdk/_revert
        end
        i32.const 6144
        call $assembly/sdk/utf8
        local.get $6
        local.get $12
        i64.add
        call $assembly/sdk/saveU64
        i32.const 6304
        call $assembly/sdk/utf8
        local.get $1
        local.get $11
        i64.add
        call $assembly/sdk/saveU64
        i32.const 6544
        call $assembly/sdk/utf8
        local.get $4
        call $assembly/sdk/concat
        i32.const 6544
        call $assembly/sdk/utf8
        local.get $4
        call $assembly/sdk/concat
        call $assembly/sdk/load
        local.tee $2
        if (result i64)
         local.get $2
         i32.const 0
         call $assembly/sdk/bytesU64
        else
         i64.const 0
        end
        local.get $1
        i64.add
        call $assembly/sdk/saveU64
        i32.const 1
        call $~lib/typedarray/Uint8Array#constructor
        local.tee $2
        i32.const 0
        i32.const 1
        call $~lib/typedarray/Uint8Array#__set
        local.get $8
        local.get $2
        call $assembly/sdk/Writer#push
        drop
        local.get $8
        local.get $1
        call $assembly/sdk/u64Bytes
        call $assembly/sdk/Writer#push
        drop
       else
        local.get $9
        i32.const 6576
        call $~lib/string/String.__eq
        if
         call $assembly/security/settlePool
         local.get $10
         i32.const 6640
         call $assembly/sdk/Reader#u64
         local.tee $7
         i64.const 0
         i64.ne
         i32.const 6544
         call $assembly/sdk/utf8
         local.get $4
         call $assembly/sdk/concat
         call $assembly/sdk/load
         local.tee $2
         if (result i64)
          local.get $2
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         local.tee $6
         local.get $7
         i64.ge_u
         i32.and
         i32.eqz
         if
          i32.const 6688
          call $assembly/sdk/utf8
          local.tee $2
          i32.load offset=4
          local.get $2
          i32.load offset=8
          call $assembly/sdk/_revert
         end
         i32.const 6304
         call $assembly/sdk/utf8
         call $assembly/sdk/load
         local.tee $2
         if (result i64)
          local.get $2
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         local.set $5
         local.get $7
         i32.const 6144
         call $assembly/sdk/utf8
         call $assembly/sdk/load
         local.tee $2
         if (result i64)
          local.get $2
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         call $assembly/sdk/U128.mul
         local.get $5
         call $assembly/sdk/U128#div
         local.set $1
         i32.const 20
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.load offset=4
         call $assembly/sdk/_self
         local.get $4
         local.get $7
         i32.const 2608
         call $assembly/sdk/utf8
         local.get $2
         call $assembly/sdk/concat
         call $assembly/sdk/load
         local.tee $2
         if (result i64)
          local.get $2
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         call $assembly/sdk/U128.mul
         local.get $5
         call $assembly/sdk/U128#div
         local.tee $0
         call $assembly/security/checkReceive
         i32.const 6544
         call $assembly/sdk/utf8
         local.get $4
         call $assembly/sdk/concat
         local.get $6
         local.get $7
         i64.sub
         call $assembly/sdk/saveU64
         i32.const 6304
         call $assembly/sdk/utf8
         local.get $5
         local.get $7
         i64.sub
         call $assembly/sdk/saveU64
         i32.const 6144
         call $assembly/sdk/utf8
         i32.const 6144
         call $assembly/sdk/utf8
         call $assembly/sdk/load
         local.tee $2
         if (result i64)
          local.get $2
          i32.const 0
          call $assembly/sdk/bytesU64
         else
          i64.const 0
         end
         local.get $1
         i64.sub
         call $assembly/sdk/saveU64
         i32.const 20
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.load offset=4
         call $assembly/sdk/_self
         local.get $2
         local.get $4
         local.get $0
         i32.const 6784
         call $assembly/security/forceMove
         local.get $4
         local.get $1
         call $assembly/sdk/pay
         i32.const 1
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.const 0
         i32.const 1
         call $~lib/typedarray/Uint8Array#__set
         local.get $8
         local.get $2
         call $assembly/sdk/Writer#push
         drop
         local.get $8
         local.get $1
         call $assembly/sdk/u64Bytes
         call $assembly/sdk/Writer#push
         local.set $3
         i32.const 1
         call $~lib/typedarray/Uint8Array#constructor
         local.tee $2
         i32.const 0
         i32.const 1
         call $~lib/typedarray/Uint8Array#__set
         local.get $3
         local.get $2
         call $assembly/sdk/Writer#push
         drop
         local.get $3
         local.get $0
         call $assembly/sdk/u64Bytes
         call $assembly/sdk/Writer#push
         drop
        else
         local.get $9
         i32.const 6832
         call $~lib/string/String.__eq
         if
          i32.const 2848
          call $assembly/sdk/utf8
          call $assembly/sdk/loadFlag
          if
           i32.const 2880
           call $assembly/sdk/utf8
           local.tee $2
           i32.load offset=4
           local.get $2
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          local.get $4
          call $assembly/security/verified
          i32.eqz
          if
           i32.const 6032
           call $assembly/sdk/utf8
           local.tee $2
           i32.load offset=4
           local.get $2
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          call $assembly/security/settlePool
          local.get $10
          i32.const 6880
          call $assembly/sdk/Reader#u64
          local.set $0
          call $assembly/sdk/_value
          call $assembly/security/quoteBuy
          local.tee $1
          i64.const 0
          i64.ne
          local.get $0
          local.get $1
          i64.le_u
          i32.and
          i32.eqz
          if
           i32.const 6928
           call $assembly/sdk/utf8
           local.tee $2
           i32.load offset=4
           local.get $2
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          local.get $4
          local.get $1
          call $assembly/security/checkReceive
          local.get $1
          call $assembly/security/costToBuy
          local.set $0
          call $assembly/sdk/_value
          local.get $0
          i64.lt_u
          if
           i32.const 7152
           call $assembly/sdk/utf8
           local.tee $2
           i32.load offset=4
           local.get $2
           i32.load offset=8
           call $assembly/sdk/_revert
          end
          i32.const 6144
          call $assembly/sdk/utf8
          i32.const 6144
          call $assembly/sdk/utf8
          call $assembly/sdk/load
          local.tee $2
          if (result i64)
           local.get $2
           i32.const 0
           call $assembly/sdk/bytesU64
          else
           i64.const 0
          end
          local.get $0
          i64.add
          call $assembly/sdk/saveU64
          i32.const 20
          call $~lib/typedarray/Uint8Array#constructor
          local.tee $2
          i32.load offset=4
          call $assembly/sdk/_self
          local.get $2
          local.get $4
          local.get $1
          i32.const 7216
          call $assembly/security/forceMove
          local.get $4
          call $assembly/sdk/_value
          local.get $0
          i64.sub
          call $assembly/sdk/pay
          i32.const 1
          call $~lib/typedarray/Uint8Array#constructor
          local.tee $2
          i32.const 0
          i32.const 1
          call $~lib/typedarray/Uint8Array#__set
          local.get $8
          local.get $2
          call $assembly/sdk/Writer#push
          drop
          local.get $8
          local.get $1
          call $assembly/sdk/u64Bytes
          call $assembly/sdk/Writer#push
          local.set $3
          i32.const 1
          call $~lib/typedarray/Uint8Array#constructor
          local.tee $2
          i32.const 0
          i32.const 1
          call $~lib/typedarray/Uint8Array#__set
          local.get $3
          local.get $2
          call $assembly/sdk/Writer#push
          drop
          local.get $3
          local.get $0
          call $assembly/sdk/u64Bytes
          call $assembly/sdk/Writer#push
          drop
         else
          local.get $9
          i32.const 7264
          call $~lib/string/String.__eq
          if
           i32.const 2848
           call $assembly/sdk/utf8
           call $assembly/sdk/loadFlag
           if
            i32.const 2880
            call $assembly/sdk/utf8
            local.tee $2
            i32.load offset=4
            local.get $2
            i32.load offset=8
            call $assembly/sdk/_revert
           end
           local.get $4
           call $assembly/security/verified
           i32.eqz
           if
            i32.const 6032
            call $assembly/sdk/utf8
            local.tee $2
            i32.load offset=4
            local.get $2
            i32.load offset=8
            call $assembly/sdk/_revert
           end
           call $assembly/security/settlePool
           local.get $10
           i32.const 7312
           call $assembly/sdk/Reader#u64
           local.set $5
           local.get $10
           i32.const 7360
           call $assembly/sdk/Reader#u64
           local.set $1
           local.get $5
           call $assembly/security/quoteSell
           local.tee $0
           i64.const 0
           i64.ne
           local.get $0
           local.get $1
           i64.ge_u
           i32.and
           i32.eqz
           if
            i32.const 7408
            call $assembly/sdk/utf8
            local.tee $2
            i32.load offset=4
            local.get $2
            i32.load offset=8
            call $assembly/sdk/_revert
           end
           local.get $4
           local.get $5
           call $assembly/security/checkSend
           i32.const 20
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $2
           i32.load offset=4
           call $assembly/sdk/_self
           local.get $4
           local.get $2
           local.get $5
           i32.const 7536
           call $assembly/security/forceMove
           i32.const 6144
           call $assembly/sdk/utf8
           i32.const 6144
           call $assembly/sdk/utf8
           call $assembly/sdk/load
           local.tee $2
           if (result i64)
            local.get $2
            i32.const 0
            call $assembly/sdk/bytesU64
           else
            i64.const 0
           end
           local.get $0
           i64.sub
           call $assembly/sdk/saveU64
           local.get $4
           local.get $0
           call $assembly/sdk/pay
           i32.const 1
           call $~lib/typedarray/Uint8Array#constructor
           local.tee $2
           i32.const 0
           i32.const 1
           call $~lib/typedarray/Uint8Array#__set
           local.get $8
           local.get $2
           call $assembly/sdk/Writer#push
           drop
           local.get $8
           local.get $0
           call $assembly/sdk/u64Bytes
           call $assembly/sdk/Writer#push
           drop
          else
           local.get $9
           i32.const 7584
           call $~lib/string/String.__eq
           if (result i32)
            i32.const 1
           else
            local.get $9
            i32.const 7632
            call $~lib/string/String.__eq
           end
           if
            local.get $4
            call $assembly/security/owner
            call $assembly/sdk/sameAddress
            i32.eqz
            if
             i32.const 7680
             call $assembly/sdk/utf8
             local.tee $2
             i32.load offset=4
             local.get $2
             i32.load offset=8
             call $assembly/sdk/_revert
            end
            local.get $10
            i32.const 7808
            call $assembly/sdk/Reader#addr
            local.set $2
            i32.const 7776
            call $assembly/sdk/utf8
            local.get $2
            call $assembly/sdk/concat
            local.get $9
            i32.const 7584
            call $~lib/string/String.__eq
            call $assembly/sdk/saveFlag
           else
            local.get $9
            i32.const 7840
            call $~lib/string/String.__eq
            if (result i32)
             i32.const 1
            else
             local.get $9
             i32.const 7872
             call $~lib/string/String.__eq
            end
            if
             call $assembly/security/onlyAgent
             i32.const 2848
             call $assembly/sdk/utf8
             local.get $9
             i32.const 7840
             call $~lib/string/String.__eq
             call $assembly/sdk/saveFlag
             i32.const 8032
             i32.const 8064
             local.get $9
             i32.const 7840
             call $~lib/string/String.__eq
             select
             call $assembly/sdk/utf8
             local.tee $2
             i32.load offset=4
             local.get $2
             i32.load offset=8
             local.get $4
             i32.load offset=4
             local.get $4
             i32.load offset=8
             call $assembly/sdk/_emit
            else
             local.get $9
             i32.const 8112
             call $~lib/string/String.__eq
             if (result i32)
              i32.const 1
             else
              local.get $9
              i32.const 8144
              call $~lib/string/String.__eq
             end
             if
              call $assembly/security/onlyAgent
              local.get $10
              i32.const 8192
              call $assembly/sdk/Reader#addr
              local.set $3
              i32.const 2944
              call $assembly/sdk/utf8
              local.get $3
              call $assembly/sdk/concat
              local.get $9
              i32.const 8112
              call $~lib/string/String.__eq
              call $assembly/sdk/saveFlag
              i32.const 8224
              i32.const 8256
              local.get $9
              i32.const 8112
              call $~lib/string/String.__eq
              select
              call $assembly/sdk/utf8
              local.tee $2
              i32.load offset=4
              local.get $2
              i32.load offset=8
              local.get $3
              i32.load offset=4
              local.get $3
              i32.load offset=8
              call $assembly/sdk/_emit
             else
              local.get $9
              i32.const 8304
              call $~lib/string/String.__eq
              if
               call $assembly/security/onlyAgent
               local.get $10
               i32.const 8192
               call $assembly/sdk/Reader#addr
               local.set $3
               local.get $10
               i32.const 2816
               call $assembly/sdk/Reader#u64
               local.tee $1
               i32.const 3120
               call $assembly/sdk/utf8
               local.get $3
               call $assembly/sdk/concat
               call $assembly/sdk/load
               local.tee $2
               if (result i64)
                local.get $2
                i32.const 0
                call $assembly/sdk/bytesU64
               else
                i64.const 0
               end
               i64.add
               local.tee $0
               i32.const 2608
               call $assembly/sdk/utf8
               local.get $3
               call $assembly/sdk/concat
               call $assembly/sdk/load
               local.tee $2
               if (result i64)
                local.get $2
                i32.const 0
                call $assembly/sdk/bytesU64
               else
                i64.const 0
               end
               i64.gt_u
               if
                i32.const 8352
                call $assembly/sdk/utf8
                local.tee $2
                i32.load offset=4
                local.get $2
                i32.load offset=8
                call $assembly/sdk/_revert
               end
               i32.const 3120
               call $assembly/sdk/utf8
               local.get $3
               call $assembly/sdk/concat
               local.get $0
               call $assembly/sdk/saveU64
               local.get $3
               local.get $1
               call $assembly/sdk/u64Bytes
               call $assembly/sdk/concat
               local.set $3
               i32.const 8448
               call $assembly/sdk/utf8
               local.tee $2
               i32.load offset=4
               local.get $2
               i32.load offset=8
               local.get $3
               i32.load offset=4
               local.get $3
               i32.load offset=8
               call $assembly/sdk/_emit
              else
               local.get $9
               i32.const 8496
               call $~lib/string/String.__eq
               if
                call $assembly/security/onlyAgent
                local.get $10
                i32.const 8192
                call $assembly/sdk/Reader#addr
                local.set $3
                local.get $10
                i32.const 2816
                call $assembly/sdk/Reader#u64
                local.set $1
                i32.const 3120
                call $assembly/sdk/utf8
                local.get $3
                call $assembly/sdk/concat
                call $assembly/sdk/load
                local.tee $2
                if (result i64)
                 local.get $2
                 i32.const 0
                 call $assembly/sdk/bytesU64
                else
                 i64.const 0
                end
                local.set $0
                i32.const 3120
                call $assembly/sdk/utf8
                local.get $3
                call $assembly/sdk/concat
                local.get $0
                local.get $1
                i64.sub
                i64.const 0
                local.get $0
                local.get $1
                i64.gt_u
                select
                call $assembly/sdk/saveU64
               else
                local.get $9
                i32.const 8560
                call $~lib/string/String.__eq
                if
                 call $assembly/security/onlyAgent
                 local.get $10
                 i32.const 8608
                 call $assembly/sdk/Reader#addr
                 local.set $4
                 local.get $10
                 i32.const 2784
                 call $assembly/sdk/Reader#addr
                 local.set $3
                 local.get $10
                 i32.const 2816
                 call $assembly/sdk/Reader#u64
                 local.set $1
                 local.get $3
                 call $assembly/security/verified
                 i32.eqz
                 if
                  i32.const 3776
                  call $assembly/sdk/utf8
                  local.tee $2
                  i32.load offset=4
                  local.get $2
                  i32.load offset=8
                  call $assembly/sdk/_revert
                 end
                 i32.const 3120
                 call $assembly/sdk/utf8
                 local.get $4
                 call $assembly/sdk/concat
                 call $assembly/sdk/load
                 local.tee $2
                 if (result i64)
                  local.get $2
                  i32.const 0
                  call $assembly/sdk/bytesU64
                 else
                  i64.const 0
                 end
                 i32.const 2608
                 call $assembly/sdk/utf8
                 local.get $4
                 call $assembly/sdk/concat
                 call $assembly/sdk/load
                 local.tee $2
                 if (result i64)
                  local.get $2
                  i32.const 0
                  call $assembly/sdk/bytesU64
                 else
                  i64.const 0
                 end
                 local.get $1
                 i64.sub
                 local.tee $0
                 i64.gt_u
                 if
                  i32.const 3120
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  local.get $0
                  call $assembly/sdk/saveU64
                 end
                 local.get $4
                 local.get $3
                 local.get $1
                 i32.const 8640
                 call $assembly/security/forceMove
                else
                 local.get $9
                 i32.const 8688
                 call $~lib/string/String.__eq
                 if
                  call $assembly/security/onlyAgent
                  local.get $10
                  i32.const 8736
                  call $assembly/sdk/Reader#addr
                  local.set $4
                  local.get $10
                  i32.const 8784
                  call $assembly/sdk/Reader#addr
                  local.set $3
                  i32.const 8832
                  local.get $4
                  call $assembly/security/registryAsk
                  local.tee $0
                  i64.const 0
                  i64.ne
                  if (result i32)
                   i32.const 8832
                   local.get $3
                   call $assembly/security/registryAsk
                   local.get $0
                   i64.eq
                  else
                   i32.const 0
                  end
                  i32.eqz
                  if
                   i32.const 8880
                   call $assembly/sdk/utf8
                   local.tee $2
                   i32.load offset=4
                   local.get $2
                   i32.load offset=8
                   call $assembly/sdk/_revert
                  end
                  local.get $4
                  call $assembly/security/settle
                  local.get $3
                  call $assembly/security/settle
                  i32.const 4672
                  call $assembly/sdk/utf8
                  local.get $3
                  call $assembly/sdk/concat
                  i32.const 4672
                  call $assembly/sdk/utf8
                  local.get $3
                  call $assembly/sdk/concat
                  call $assembly/sdk/load
                  local.tee $2
                  if (result i64)
                   local.get $2
                   i32.const 0
                   call $assembly/sdk/bytesU64
                  else
                   i64.const 0
                  end
                  i32.const 4672
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  call $assembly/sdk/load
                  local.tee $2
                  if (result i64)
                   local.get $2
                   i32.const 0
                   call $assembly/sdk/bytesU64
                  else
                   i64.const 0
                  end
                  i64.add
                  call $assembly/sdk/saveU64
                  i32.const 4672
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  i64.const 0
                  call $assembly/sdk/saveU64
                  i32.const 3120
                  call $assembly/sdk/utf8
                  local.get $3
                  call $assembly/sdk/concat
                  i32.const 3120
                  call $assembly/sdk/utf8
                  local.get $3
                  call $assembly/sdk/concat
                  call $assembly/sdk/load
                  local.tee $2
                  if (result i64)
                   local.get $2
                   i32.const 0
                   call $assembly/sdk/bytesU64
                  else
                   i64.const 0
                  end
                  i32.const 3120
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  call $assembly/sdk/load
                  local.tee $2
                  if (result i64)
                   local.get $2
                   i32.const 0
                   call $assembly/sdk/bytesU64
                  else
                   i64.const 0
                  end
                  i64.add
                  call $assembly/sdk/saveU64
                  i32.const 3120
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  i64.const 0
                  call $assembly/sdk/saveU64
                  i32.const 2944
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  call $assembly/sdk/loadFlag
                  if
                   i32.const 2944
                   call $assembly/sdk/utf8
                   local.get $3
                   call $assembly/sdk/concat
                   i32.const 1
                   call $assembly/sdk/saveFlag
                  end
                  local.get $4
                  local.get $3
                  i32.const 2608
                  call $assembly/sdk/utf8
                  local.get $4
                  call $assembly/sdk/concat
                  call $assembly/sdk/load
                  local.tee $2
                  if (result i64)
                   local.get $2
                   i32.const 0
                   call $assembly/sdk/bytesU64
                  else
                   i64.const 0
                  end
                  i32.const 9008
                  call $assembly/security/forceMove
                 else
                  local.get $9
                  i32.const 9056
                  call $~lib/string/String.__eq
                  if
                   call $assembly/security/onlyAgent
                   local.get $10
                   i32.const 2784
                   call $assembly/sdk/Reader#addr
                   local.tee $3
                   local.get $10
                   i32.const 2816
                   call $assembly/sdk/Reader#u64
                   local.tee $0
                   call $assembly/security/checkReceive
                   local.get $3
                   call $assembly/security/settle
                   local.get $3
                   i32.const 2608
                   call $assembly/sdk/utf8
                   local.get $3
                   call $assembly/sdk/concat
                   call $assembly/sdk/load
                   local.tee $2
                   if (result i64)
                    local.get $2
                    i32.const 0
                    call $assembly/sdk/bytesU64
                   else
                    i64.const 0
                   end
                   local.get $0
                   i64.add
                   call $assembly/security/setBalance
                   i32.const 2576
                   call $assembly/sdk/utf8
                   i32.const 2576
                   call $assembly/sdk/utf8
                   call $assembly/sdk/load
                   local.tee $2
                   if (result i64)
                    local.get $2
                    i32.const 0
                    call $assembly/sdk/bytesU64
                   else
                    i64.const 0
                   end
                   local.get $0
                   i64.add
                   call $assembly/sdk/saveU64
                   local.get $3
                   local.get $0
                   call $assembly/sdk/u64Bytes
                   call $assembly/sdk/concat
                   local.set $3
                   i32.const 9088
                   call $assembly/sdk/utf8
                   local.tee $2
                   i32.load offset=4
                   local.get $2
                   i32.load offset=8
                   local.get $3
                   i32.load offset=4
                   local.get $3
                   i32.load offset=8
                   call $assembly/sdk/_emit
                  else
                   local.get $9
                   i32.const 9120
                   call $~lib/string/String.__eq
                   if
                    call $assembly/security/onlyAgent
                    local.get $10
                    i32.const 8608
                    call $assembly/sdk/Reader#addr
                    local.set $3
                    local.get $10
                    i32.const 2816
                    call $assembly/sdk/Reader#u64
                    local.tee $0
                    i32.const 2608
                    call $assembly/sdk/utf8
                    local.get $3
                    call $assembly/sdk/concat
                    call $assembly/sdk/load
                    local.tee $2
                    if (result i64)
                     local.get $2
                     i32.const 0
                     call $assembly/sdk/bytesU64
                    else
                     i64.const 0
                    end
                    i64.gt_u
                    if
                     i32.const 3056
                     call $assembly/sdk/utf8
                     local.tee $2
                     i32.load offset=4
                     local.get $2
                     i32.load offset=8
                     call $assembly/sdk/_revert
                    end
                    local.get $3
                    call $assembly/security/settle
                    local.get $3
                    i32.const 2608
                    call $assembly/sdk/utf8
                    local.get $3
                    call $assembly/sdk/concat
                    call $assembly/sdk/load
                    local.tee $2
                    if (result i64)
                     local.get $2
                     i32.const 0
                     call $assembly/sdk/bytesU64
                    else
                     i64.const 0
                    end
                    local.get $0
                    i64.sub
                    call $assembly/security/setBalance
                    i32.const 2576
                    call $assembly/sdk/utf8
                    i32.const 2576
                    call $assembly/sdk/utf8
                    call $assembly/sdk/load
                    local.tee $2
                    if (result i64)
                     local.get $2
                     i32.const 0
                     call $assembly/sdk/bytesU64
                    else
                     i64.const 0
                    end
                    local.get $0
                    i64.sub
                    call $assembly/sdk/saveU64
                    local.get $3
                    local.get $0
                    call $assembly/sdk/u64Bytes
                    call $assembly/sdk/concat
                    local.set $3
                    i32.const 9152
                    call $assembly/sdk/utf8
                    local.tee $2
                    i32.load offset=4
                    local.get $2
                    i32.load offset=8
                    local.get $3
                    i32.load offset=4
                    local.get $3
                    i32.load offset=8
                    call $assembly/sdk/_emit
                   else
                    local.get $9
                    i32.const 9184
                    call $~lib/string/String.__eq
                    if
                     call $assembly/security/onlyAgent
                     i32.const 2544
                     call $assembly/sdk/utf8
                     local.get $10
                     i32.const 2544
                     call $assembly/sdk/Reader#u64
                     call $assembly/sdk/saveU64
                    else
                     local.get $9
                     i32.const 9232
                     call $~lib/string/String.__eq
                     if
                      call $assembly/security/onlyAgent
                      i32.const 4400
                      call $assembly/sdk/utf8
                      local.get $10
                      i32.const 9280
                      call $assembly/sdk/Reader#u64
                      call $assembly/sdk/saveU64
                      i32.const 4224
                      call $assembly/sdk/utf8
                      local.get $10
                      i32.const 9360
                      call $assembly/sdk/Reader#u64
                      call $assembly/sdk/saveU64
                     else
                      local.get $9
                      i32.const 9456
                      call $~lib/string/String.__eq
                      if (result i32)
                       i32.const 1
                      else
                       local.get $9
                       i32.const 9504
                       call $~lib/string/String.__eq
                      end
                      if
                       call $assembly/security/onlyAgent
                       local.get $10
                       i32.const 9552
                       call $assembly/sdk/Reader#u64
                       local.set $0
                       i32.const 3936
                       call $assembly/sdk/utf8
                       local.get $0
                       call $assembly/sdk/u64Bytes
                       call $assembly/sdk/concat
                       local.get $9
                       i32.const 9456
                       call $~lib/string/String.__eq
                       call $assembly/sdk/saveFlag
                       i32.const 3904
                       call $assembly/sdk/utf8
                       i32.const 1
                       call $assembly/sdk/saveFlag
                      else
                       local.get $9
                       i32.const 9600
                       call $~lib/string/String.__eq
                       if
                        call $assembly/security/onlyAgent
                        i32.const 5104
                        call $assembly/sdk/utf8
                        i32.const 5104
                        call $assembly/sdk/utf8
                        call $assembly/sdk/load
                        local.tee $2
                        if (result i64)
                         local.get $2
                         i32.const 0
                         call $assembly/sdk/bytesU64
                        else
                         i64.const 0
                        end
                        local.set $0
                        call $assembly/sdk/_value
                        local.get $0
                        i64.add
                        call $assembly/sdk/saveU64
                       else
                        local.get $9
                        i32.const 9648
                        call $~lib/string/String.__eq
                        if
                         local.get $8
                         i32.const 1296
                         call $assembly/security/str
                         call $assembly/sdk/Writer#str
                         i32.const 1808
                         call $assembly/security/str
                         call $assembly/sdk/Writer#str
                         local.set $3
                         i32.const 2576
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $2
                         if (result i64)
                          local.get $2
                          i32.const 0
                          call $assembly/sdk/bytesU64
                         else
                          i64.const 0
                         end
                         local.set $0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $3
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $3
                         local.get $0
                         call $assembly/sdk/u64Bytes
                         call $assembly/sdk/Writer#push
                         local.set $3
                         i32.const 2544
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $2
                         if (result i64)
                          local.get $2
                          i32.const 0
                          call $assembly/sdk/bytesU64
                         else
                          i64.const 0
                         end
                         local.set $0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $3
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $3
                         local.get $0
                         call $assembly/sdk/u64Bytes
                         call $assembly/sdk/Writer#push
                         local.set $4
                         call $assembly/security/owner
                         local.set $3
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 3
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $4
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $4
                         local.get $3
                         call $assembly/sdk/Writer#push
                         i32.const 2400
                         call $assembly/security/str
                         call $assembly/sdk/Writer#str
                         local.set $3
                         i32.const 5920
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $2
                         if (result i64)
                          local.get $2
                          i32.const 0
                          call $assembly/sdk/bytesU64
                         else
                          i64.const 0
                         end
                         local.set $0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $3
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $3
                         local.get $0
                         call $assembly/sdk/u64Bytes
                         call $assembly/sdk/Writer#push
                         i32.const 1840
                         call $assembly/security/str
                         call $assembly/sdk/Writer#str
                         local.set $4
                         i32.const 2464
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $3
                         i32.eqz
                         if
                          i32.const 3232
                          i32.const 3360
                          i32.const 399
                          i32.const 13
                          call $~lib/builtins/abort
                          unreachable
                         end
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 3
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $4
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $4
                         local.get $3
                         call $assembly/sdk/Writer#push
                         i32.const 2848
                         call $assembly/sdk/utf8
                         call $assembly/sdk/loadFlag
                         call $assembly/sdk/Writer#bool
                         local.set $3
                         i32.const 4448
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $2
                         if (result i64)
                          local.get $2
                          i32.const 0
                          call $assembly/sdk/bytesU64
                         else
                          i64.const 0
                         end
                         local.set $0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $3
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $3
                         local.get $0
                         call $assembly/sdk/u64Bytes
                         call $assembly/sdk/Writer#push
                         local.set $3
                         i32.const 5104
                         call $assembly/sdk/utf8
                         call $assembly/sdk/load
                         local.tee $2
                         if (result i64)
                          local.get $2
                          i32.const 0
                          call $assembly/sdk/bytesU64
                         else
                          i64.const 0
                         end
                         local.set $0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#constructor
                         local.tee $2
                         i32.const 0
                         i32.const 1
                         call $~lib/typedarray/Uint8Array#__set
                         local.get $3
                         local.get $2
                         call $assembly/sdk/Writer#push
                         drop
                         local.get $3
                         local.get $0
                         call $assembly/sdk/u64Bytes
                         call $assembly/sdk/Writer#push
                         drop
                        else
                         local.get $9
                         i32.const 9680
                         call $~lib/string/String.__eq
                         if
                          local.get $10
                          i32.const 8192
                          call $assembly/sdk/Reader#addr
                          local.set $2
                          i32.const 2608
                          call $assembly/sdk/utf8
                          local.get $2
                          call $assembly/sdk/concat
                          call $assembly/sdk/load
                          local.tee $2
                          if (result i64)
                           local.get $2
                           i32.const 0
                           call $assembly/sdk/bytesU64
                          else
                           i64.const 0
                          end
                          local.set $0
                          i32.const 1
                          call $~lib/typedarray/Uint8Array#constructor
                          local.tee $2
                          i32.const 0
                          i32.const 1
                          call $~lib/typedarray/Uint8Array#__set
                          local.get $8
                          local.get $2
                          call $assembly/sdk/Writer#push
                          drop
                          local.get $8
                          local.get $0
                          call $assembly/sdk/u64Bytes
                          call $assembly/sdk/Writer#push
                          drop
                         else
                          local.get $9
                          i32.const 9728
                          call $~lib/string/String.__eq
                          if
                           local.get $10
                           i32.const 8192
                           call $assembly/sdk/Reader#addr
                           call $assembly/security/earned
                           local.set $0
                           i32.const 1
                           call $~lib/typedarray/Uint8Array#constructor
                           local.tee $2
                           i32.const 0
                           i32.const 1
                           call $~lib/typedarray/Uint8Array#__set
                           local.get $8
                           local.get $2
                           call $assembly/sdk/Writer#push
                           drop
                           local.get $8
                           local.get $0
                           call $assembly/sdk/u64Bytes
                           call $assembly/sdk/Writer#push
                           drop
                          else
                           local.get $9
                           i32.const 9776
                           call $~lib/string/String.__eq
                           if
                            local.get $8
                            local.get $10
                            i32.const 8192
                            call $assembly/sdk/Reader#addr
                            local.tee $4
                            call $assembly/security/verified
                            call $assembly/sdk/Writer#bool
                            i32.const 2944
                            call $assembly/sdk/utf8
                            local.get $4
                            call $assembly/sdk/concat
                            call $assembly/sdk/loadFlag
                            call $assembly/sdk/Writer#bool
                            local.set $3
                            i32.const 3120
                            call $assembly/sdk/utf8
                            local.get $4
                            call $assembly/sdk/concat
                            call $assembly/sdk/load
                            local.tee $2
                            if (result i64)
                             local.get $2
                             i32.const 0
                             call $assembly/sdk/bytesU64
                            else
                             i64.const 0
                            end
                            local.set $0
                            i32.const 1
                            call $~lib/typedarray/Uint8Array#constructor
                            local.tee $2
                            i32.const 0
                            i32.const 1
                            call $~lib/typedarray/Uint8Array#__set
                            local.get $3
                            local.get $2
                            call $assembly/sdk/Writer#push
                            drop
                            local.get $3
                            local.get $0
                            call $assembly/sdk/u64Bytes
                            call $assembly/sdk/Writer#push
                            local.get $4
                            call $assembly/security/countryOk
                            call $assembly/sdk/Writer#bool
                            local.get $4
                            call $assembly/security/owner
                            call $assembly/sdk/sameAddress
                            if (result i32)
                             i32.const 1
                            else
                             i32.const 7776
                             call $assembly/sdk/utf8
                             local.get $4
                             call $assembly/sdk/concat
                             call $assembly/sdk/loadFlag
                            end
                            call $assembly/sdk/Writer#bool
                            drop
                           else
                            local.get $9
                            i32.const 9808
                            call $~lib/string/String.__eq
                            if
                             i32.const 6144
                             call $assembly/sdk/utf8
                             call $assembly/sdk/load
                             local.tee $2
                             if (result i64)
                              local.get $2
                              i32.const 0
                              call $assembly/sdk/bytesU64
                             else
                              i64.const 0
                             end
                             local.set $0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#constructor
                             local.tee $2
                             i32.const 0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#__set
                             local.get $8
                             local.get $2
                             call $assembly/sdk/Writer#push
                             drop
                             local.get $8
                             local.get $0
                             call $assembly/sdk/u64Bytes
                             call $assembly/sdk/Writer#push
                             local.set $3
                             i32.const 20
                             call $~lib/typedarray/Uint8Array#constructor
                             local.tee $2
                             i32.load offset=4
                             call $assembly/sdk/_self
                             i32.const 2608
                             call $assembly/sdk/utf8
                             local.get $2
                             call $assembly/sdk/concat
                             call $assembly/sdk/load
                             local.tee $2
                             if (result i64)
                              local.get $2
                              i32.const 0
                              call $assembly/sdk/bytesU64
                             else
                              i64.const 0
                             end
                             local.set $0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#constructor
                             local.tee $2
                             i32.const 0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#__set
                             local.get $3
                             local.get $2
                             call $assembly/sdk/Writer#push
                             drop
                             local.get $3
                             local.get $0
                             call $assembly/sdk/u64Bytes
                             call $assembly/sdk/Writer#push
                             local.set $3
                             i32.const 6304
                             call $assembly/sdk/utf8
                             call $assembly/sdk/load
                             local.tee $2
                             if (result i64)
                              local.get $2
                              i32.const 0
                              call $assembly/sdk/bytesU64
                             else
                              i64.const 0
                             end
                             local.set $0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#constructor
                             local.tee $2
                             i32.const 0
                             i32.const 1
                             call $~lib/typedarray/Uint8Array#__set
                             local.get $3
                             local.get $2
                             call $assembly/sdk/Writer#push
                             drop
                             local.get $3
                             local.get $0
                             call $assembly/sdk/u64Bytes
                             call $assembly/sdk/Writer#push
                             drop
                            else
                             local.get $9
                             i32.const 9840
                             call $~lib/string/String.__eq
                             if
                              local.get $10
                              i32.const 8192
                              call $assembly/sdk/Reader#addr
                              local.set $2
                              i32.const 6544
                              call $assembly/sdk/utf8
                              local.get $2
                              call $assembly/sdk/concat
                              call $assembly/sdk/load
                              local.tee $2
                              if (result i64)
                               local.get $2
                               i32.const 0
                               call $assembly/sdk/bytesU64
                              else
                               i64.const 0
                              end
                              local.set $0
                              i32.const 1
                              call $~lib/typedarray/Uint8Array#constructor
                              local.tee $2
                              i32.const 0
                              i32.const 1
                              call $~lib/typedarray/Uint8Array#__set
                              local.get $8
                              local.get $2
                              call $assembly/sdk/Writer#push
                              drop
                              local.get $8
                              local.get $0
                              call $assembly/sdk/u64Bytes
                              call $assembly/sdk/Writer#push
                              drop
                             else
                              local.get $9
                              i32.const 9872
                              call $~lib/string/String.__eq
                              if
                               local.get $10
                               i32.const 9920
                               call $assembly/sdk/Reader#u64
                               call $assembly/security/quoteBuy
                               local.set $0
                               i32.const 1
                               call $~lib/typedarray/Uint8Array#constructor
                               local.tee $2
                               i32.const 0
                               i32.const 1
                               call $~lib/typedarray/Uint8Array#__set
                               local.get $8
                               local.get $2
                               call $assembly/sdk/Writer#push
                               drop
                               local.get $8
                               local.get $0
                               call $assembly/sdk/u64Bytes
                               call $assembly/sdk/Writer#push
                               drop
                              else
                               local.get $9
                               i32.const 9968
                               call $~lib/string/String.__eq
                               if
                                local.get $10
                                i32.const 6192
                                call $assembly/sdk/Reader#u64
                                call $assembly/security/costToBuy
                                local.set $0
                                i32.const 1
                                call $~lib/typedarray/Uint8Array#constructor
                                local.tee $2
                                i32.const 0
                                i32.const 1
                                call $~lib/typedarray/Uint8Array#__set
                                local.get $8
                                local.get $2
                                call $assembly/sdk/Writer#push
                                drop
                                local.get $8
                                local.get $0
                                call $assembly/sdk/u64Bytes
                                call $assembly/sdk/Writer#push
                                drop
                               else
                                local.get $9
                                i32.const 10016
                                call $~lib/string/String.__eq
                                if
                                 local.get $10
                                 i32.const 7312
                                 call $assembly/sdk/Reader#u64
                                 call $assembly/security/quoteSell
                                 local.set $0
                                 i32.const 1
                                 call $~lib/typedarray/Uint8Array#constructor
                                 local.tee $2
                                 i32.const 0
                                 i32.const 1
                                 call $~lib/typedarray/Uint8Array#__set
                                 local.get $8
                                 local.get $2
                                 call $assembly/sdk/Writer#push
                                 drop
                                 local.get $8
                                 local.get $0
                                 call $assembly/sdk/u64Bytes
                                 call $assembly/sdk/Writer#push
                                 drop
                                else
                                 local.get $9
                                 i32.const 10064
                                 call $~lib/string/String.__eq
                                 if
                                  i32.const 4400
                                  call $assembly/sdk/utf8
                                  call $assembly/sdk/load
                                  local.tee $2
                                  if (result i64)
                                   local.get $2
                                   i32.const 0
                                   call $assembly/sdk/bytesU64
                                  else
                                   i64.const 0
                                  end
                                  local.set $0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#constructor
                                  local.tee $2
                                  i32.const 0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#__set
                                  local.get $8
                                  local.get $2
                                  call $assembly/sdk/Writer#push
                                  drop
                                  local.get $8
                                  local.get $0
                                  call $assembly/sdk/u64Bytes
                                  call $assembly/sdk/Writer#push
                                  local.set $3
                                  i32.const 4224
                                  call $assembly/sdk/utf8
                                  call $assembly/sdk/load
                                  local.tee $2
                                  if (result i64)
                                   local.get $2
                                   i32.const 0
                                   call $assembly/sdk/bytesU64
                                  else
                                   i64.const 0
                                  end
                                  local.set $0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#constructor
                                  local.tee $2
                                  i32.const 0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#__set
                                  local.get $3
                                  local.get $2
                                  call $assembly/sdk/Writer#push
                                  drop
                                  local.get $3
                                  local.get $0
                                  call $assembly/sdk/u64Bytes
                                  call $assembly/sdk/Writer#push
                                  i32.const 3904
                                  call $assembly/sdk/utf8
                                  call $assembly/sdk/loadFlag
                                  call $assembly/sdk/Writer#bool
                                  local.set $3
                                  i32.const 2512
                                  call $assembly/sdk/utf8
                                  call $assembly/sdk/load
                                  local.tee $2
                                  if (result i64)
                                   local.get $2
                                   i32.const 0
                                   call $assembly/sdk/bytesU64
                                  else
                                   i64.const 0
                                  end
                                  local.set $0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#constructor
                                  local.tee $2
                                  i32.const 0
                                  i32.const 1
                                  call $~lib/typedarray/Uint8Array#__set
                                  local.get $3
                                  local.get $2
                                  call $assembly/sdk/Writer#push
                                  drop
                                  local.get $3
                                  local.get $0
                                  call $assembly/sdk/u64Bytes
                                  call $assembly/sdk/Writer#push
                                  drop
                                 else
                                  i32.const 10096
                                  local.get $9
                                  call $~lib/string/String.__concat
                                  call $assembly/sdk/utf8
                                  local.tee $2
                                  i32.load offset=4
                                  local.get $2
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
         end
        end
       end
      end
     end
    end
   end
  end
  local.get $8
  call $assembly/sdk/Writer#done
  local.tee $2
  i32.load offset=4
  local.get $2
  i32.load offset=8
  call $assembly/sdk/_output
 )
)
