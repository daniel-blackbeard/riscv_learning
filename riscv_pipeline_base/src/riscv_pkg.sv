`timescale 1ns / 1ps

package riscv_pkg;

localparam int INST_MEM_ADDR_SIZE = 12;
localparam int DATA_MEM_ADDR_SIZE = 10;


typedef enum logic [11:0] {
  R_TYPE     = 12'b0000_0000_0001,
  I_TYPE     = 12'b0000_0000_0010,
  L_TYPE     = 12'b0000_0000_0100,
  S_TYPE     = 12'b0000_0000_1000,
  B_TYPE     = 12'b0000_0001_0000,
  JAL_TYPE   = 12'b0000_0010_0000,
  JALR_TYPE  = 12'b0000_0100_0000,
  LUI_TYPE   = 12'b0000_1000_0000,
  AUIPC_TYPE = 12'b0001_0000_0000,
  SYS_TYPE   = 12'b0010_0000_0000,
  FENCE_TYPE = 12'b0100_0000_0000,
  NOP_TYPE   = 12'b1000_0000_0000
} cu_inst_t;

typedef enum logic [3:0] {
  ADD  = 4'b0000,
  SUB  = 4'b0001,
  AND  = 4'b0010,
  OR   = 4'b0011,
  XOR  = 4'b0100,
  SLL  = 4'b0101,
  SRL  = 4'b0110,
  SRA  = 4'b0111,
  SLT  = 4'b1000,
  SLTU = 4'b1001
} alu_op_t;

typedef enum logic [2:0] {
  IMM_NONE   = 3'b000,
  IMM_I  = 3'b001,
  IMM_S  = 3'b010,
  IMM_B  = 3'b011,
  IMM_U  = 3'b100,
  IMM_J  = 3'b101
} imm_t;

typedef enum logic [2:0] {
  REGSRC_ALU    = 3'b000,
  REGSRC_IMM    = 3'b001,
  REGSRC_MEM    = 3'b010,
  REGSRC_PC_4   = 3'b011,
  REGSRC_PC_IMM = 3'b100
} reg_w_src_t;

typedef enum logic [1:0] {
  PCSRC_PC_4   = 2'b00,
  PCSRC_PC_IMM = 2'b01,
  PCSRC_ALU    = 2'b10,
  PCSRC_BRANCH = 2'b11
} pc_src_t;

typedef enum logic [2:0] {
  NOC  = 3'b000,
  BEQ  = 3'b001,
  BNE  = 3'b010,
  BLT  = 3'b011,
  BGE  = 3'b100,
  BLTU = 3'b101,
  BGEU = 3'b110
} alu_comp_t;

typedef enum logic {
  OP2_REG = 1'b0,
  OP2_IMM = 1'b1
} alu_op2_t;

typedef enum logic [1:0] {
  WIDE = 2'b00,
  HALF = 2'b01,
  BYTE = 2'b10
} mem_d_size_t;

typedef enum logic {
  SIGNED   = 1'b0,
  UNSIGNED = 1'b1
} mem_d_sign_t;


typedef enum logic [1:0] {
  NO_FORWARD   = 2'b00,
  MEM_FORWARD  = 2'b01,
  WB_FORWARD   = 2'b10
} reg_fw_t;

typedef struct packed {
  pc_src_t pc_src;
} if_ctrl_t;

typedef struct packed {
  imm_t imm;
} id_ctrl_t;

typedef struct packed {
  alu_op2_t  alu_op2;
  alu_comp_t alu_comp;
  alu_op_t   alu_op;
} ex_ctrl_t;

typedef struct packed {
  logic        mem_w_en;
  mem_d_size_t mem_size;
  mem_d_sign_t mem_signed;
} mem_ctrl_t;

typedef struct packed {
  logic reg_w_en;
  reg_w_src_t reg_src;
} wb_ctrl_t;

endpackage
