`timescale 1ns/1ps

module tb_riscv_core;

logic clk = 1'b0;

always #5 clk <= ~clk;

// output declaration of module riscv_core
logic status;
logic rstb;

riscv_datapath u_riscv32_dut(
    .clk(clk),
    .rstb(rstb),
    .status(status)
);

// point the DUT's instruction memory at the stress-test program instead of
// the default FPGA program, without touching src/. Assumes stress_test.S has
// been assembled into programs/stress_test.mem (see comments in that file).
// defparam u_riscv32_dut.i_instmem.MEM_INIT_FILE = "../../programs/stress_test.mem";

int errors = 0;
int checks = 0;

task automatic check(string name, logic [31:0] actual, logic [31:0] expected);
    checks++;
    if (actual !== expected) begin
        errors++;
        $display("FAIL [%0d] %-22s got=0x%08h expected=0x%08h", checks, name, actual, expected);
    end else begin
        $display("PASS [%0d] %-22s = 0x%08h", checks, name, actual);
    end
endtask

initial begin
   rstb = 1'b0;

  // ==========================================================================
  // Enable the CPU by unlocking reset
  // ==========================================================================
  @(negedge clk);
  rstb = 1'b0;
  @(posedge clk); #1;      // one full reset cycle

  @(negedge clk);
  rstb = 1'b1;             // release reset
  @(posedge clk); #1;      // one cycle for reset to commit

  // Generously long: exact instruction count depends on how the assembler
  // expands pseudo-instructions (e.g. "la"), plus load-use stalls and
  // pipeline fill latency. The program ends in an infinite self-loop, so
  // running long before checking is always safe.
  #1000;

  $display("=== tb_riscv_core self-check: stress_test.mem ===");

  // ---- register file checks (via hierarchical reference) ----
  check("x1  (10)",           u_riscv32_dut.u_reg.regs[1],  32'd10);
  check("x2  (20)",           u_riscv32_dut.u_reg.regs[2],  32'd20);
  check("x3  (add)",          u_riscv32_dut.u_reg.regs[3],  32'd30);
  check("x4  (EX/MEM fwd)",   u_riscv32_dut.u_reg.regs[4],  32'd60);
  check("x5  (MEM/WB fwd)",   u_riscv32_dut.u_reg.regs[5],  32'd50);
  check("x6  (load)",         u_riscv32_dut.u_reg.regs[6],  32'd50);
  check("x7  (load-use rs1)", u_riscv32_dut.u_reg.regs[7],  32'd51);
  check("x8  (load)",         u_riscv32_dut.u_reg.regs[8],  32'd51);
  check("x9  (load-use rs2)", u_riscv32_dut.u_reg.regs[9],  32'd61);
  check("x0  (write-blocked)",u_riscv32_dut.u_reg.regs[0],  32'd0);
  check("x10 (x0 read-back)", u_riscv32_dut.u_reg.regs[10], 32'd0);
  check("x11 (post-beq)",     u_riscv32_dut.u_reg.regs[11], 32'd111);
  check("x12",                u_riscv32_dut.u_reg.regs[12], 32'd5);
  check("x13 (post-bne)",     u_riscv32_dut.u_reg.regs[13], 32'd222);
  check("x14 (-3)",           u_riscv32_dut.u_reg.regs[14], 32'hFFFFFFFD);
  check("x15 (post-blt)",     u_riscv32_dut.u_reg.regs[15], 32'd333);
  check("x16 (post-bge)",     u_riscv32_dut.u_reg.regs[16], 32'd444);
  check("x17 (post-bltu)",    u_riscv32_dut.u_reg.regs[17], 32'd555);
  check("x19 (post-jal)",     u_riscv32_dut.u_reg.regs[19], 32'd666);
  check("x20 (beq skip)",     u_riscv32_dut.u_reg.regs[20], 32'd0);
  check("x21 (bne skip)",     u_riscv32_dut.u_reg.regs[21], 32'd0);
  check("x22 (blt skip)",     u_riscv32_dut.u_reg.regs[22], 32'd0);
  check("x23 (bge skip)",     u_riscv32_dut.u_reg.regs[23], 32'd0);
  check("x24 (sltu)",         u_riscv32_dut.u_reg.regs[24], 32'd1);
  check("x25 (bltu skip)",    u_riscv32_dut.u_reg.regs[25], 32'd0);
  check("x26 (jal skip)",     u_riscv32_dut.u_reg.regs[26], 32'd0);
  check("x30 (jalr skip)",    u_riscv32_dut.u_reg.regs[30], 32'd0);

  // JALR &~1 fix: x27 = target address computed via `la`, x31 = auipc result
  // sampled right after the jalr landed. These must be equal regardless of
  // where the assembler/linker actually placed the code.
  check("x31 == x27 (jalr &~1)", u_riscv32_dut.u_reg.regs[31], u_riscv32_dut.u_reg.regs[27]);

  // ---- data memory checks (via hierarchical reference to the 4 byte lanes) ----
  check("mem[0] (sw x5)", u_riscv32_dut.u_data_mem.ram[0], 32'd50);
  check("mem[4] (sw x7)", u_riscv32_dut.u_data_mem.ram[1], 32'd51);

  // ---- done marker: proves the program ran to completion (reached the halt
  //      loop) without depending on any absolute code address ----
  check("mem[1020] (done)", u_riscv32_dut.u_data_mem.ram[255], 32'd111);

  if (errors == 0)
    $display("=== ALL %0d CHECKS PASSED ===", checks);
  else
    $display("=== %0d/%0d CHECKS FAILED ===", errors, checks);

  $finish;
end

endmodule
