# RV32I hazard/forwarding stress test for riscv_datapath.
#
# Assemble/link so this lands at address 0x0 (matches the CPU's reset PC and
# instruction_memory's base). E.g.:
#   riscv32-unknown-elf-as -march=rv32i -o stress_test.o stress_test.S
#   riscv32-unknown-elf-ld -Ttext=0x0 -o stress_test.elf stress_test.o
#   riscv32-unknown-elf-objcopy -O binary stress_test.elf stress_test.bin
#   (then convert stress_test.bin -> stress_test.mem, one 32-bit hex word
#    per line, matching instruction_memory.sv's $readmemh format)
#
# No OS/runtime assumed: no .data section, all state lives in registers and
# in the CPU's own data memory via explicit sw/lw with x0-relative offsets.

    .text
    .globl _start
_start:
    # ---- basic ALU ops + forwarding chains ----
    addi x1, x0, 10          # x1 = 10
    addi x2, x0, 20          # x2 = 20
    add  x3, x1, x2          # x3 = 30
    add  x4, x3, x3          # x4 = 60   (EX/MEM forward, both operands from x3)
    sub  x5, x4, x1          # x5 = 50   (MEM/WB forward)

    # ---- store-forwarding + load-use hazard via rs1 ----
    sw   x5, 0(x0)           # mem[0] = 50   (store uses x5, produced immediately before)
    lw   x6, 0(x0)           # x6 = 50
    addi x7, x6, 1           # x7 = 51   (load-use hazard: x6 used as rs1 right after its load)

    # ---- load-use hazard via rs2 (the historically buggy path) ----
    sw   x7, 4(x0)           # mem[4] = 51
    lw   x8, 4(x0)           # x8 = 51
    add  x9, x1, x8          # x9 = 61   (load-use hazard: x8 used as rs2 right after its load)

    # ---- x0 write/read-back ----
    addi x0, x1, 99          # attempted write to x0, must stay architecturally 0
    add  x10, x0, x0         # x10 = 0   (confirms x0 still reads 0 right after the "write")

    # ---- branches: each taken, each followed by a poison instruction that must be skipped ----
    beq  x10, x0, beq_ok
    addi x20, x0, 999        # poison: must be skipped
beq_ok:
    addi x11, x0, 111

    addi x12, x0, 5
    bne  x12, x0, bne_ok
    addi x21, x0, 999        # poison
bne_ok:
    addi x13, x0, 222

    addi x14, x0, -3
    blt  x14, x0, blt_ok
    addi x22, x0, 999        # poison
blt_ok:
    addi x15, x0, 333

    bge  x0, x14, bge_ok
    addi x23, x0, 999        # poison
bge_ok:
    addi x16, x0, 444

    sltu x24, x0, x14        # x24 = 1   (0 <u 0xFFFFFFFD, unsigned compare)
    bltu x0, x14, bltu_ok
    addi x25, x0, 999        # poison
bltu_ok:
    addi x17, x0, 555

    # ---- JAL: link value isn't checked numerically (layout-dependent); the poison/skip
    #      below is what actually proves the jump landed in the right place ----
    jal  x18, jal_target
    addi x26, x0, 999        # poison, never fetched
jal_target:
    addi x19, x0, 666

    # ---- JALR: force an ODD (rs1+imm) sum so the target's LSB-clear is actually exercised ----
    la   x27, auipc_check     # x27 = exact (even, word-aligned) target address
    addi x31, x27, 1          # x31 = x27 + 1 (odd) -- forces a misaligned jalr sum
    jalr x28, 0(x31)          # target = (x31 + 0) & ~1, should land exactly back on x27
    addi x30, x0, 999        # poison, never fetched if the LSB-clear works
auipc_check:
    auipc x31, 0               # x31 = pc here; testbench checks x31 == x27 (tests &~1 fix)

    # ---- done marker: store a known value so the testbench can detect completion
    #      without depending on any absolute code address ----
    sw   x11, 102(x0)        # mem[1020] = 111 (x11, already verified above)

halt:
    jal  x0, halt              # infinite self-loop
