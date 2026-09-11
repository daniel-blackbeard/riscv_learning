`timescale 1ns / 1ps

import riscv_pkg::*;

module riscv_datapath(
    input  logic clk,
    input  logic rstb,
    output logic status
);

// IF signals
logic                   [31:0] pc;
logic                   [31:0] pc_next;
logic                   [31:0] pc_plus_4;
logic                   [31:0] inst;

// ID signals
logic                   [31:0] id_pc;
logic                   [31:0] id_inst;

logic                   [31:0] rs1;
logic                   [31:0] rs2;
logic                   [31:0] imm;
logic                    [4:0] rs1_addr;
logic                    [4:0] rs2_addr;
logic                    [4:0] rd_addr;
logic                   [31:0] id_alu_op2;
if_ctrl_t                      id_if_ctrl;
id_ctrl_t                      id_id_ctrl;
ex_ctrl_t                      id_ex_ctrl;
mem_ctrl_t                     id_mem_ctrl;
wb_ctrl_t                      id_wb_ctrl;
cu_inst_t                      inst_type;

logic                          stall;

// EX signals
logic                   [31:0] ex_pc;
logic                   [31:0] ex_rs1;
logic                   [31:0] ex_rs2;
logic                   [31:0] ex_imm;
logic                   [31:0] ex_alu_op2;
logic                   [31:0] alu_res;
logic                          alu_branch;
logic                   [31:0] pc_plus_imm;
logic                   [31:0] ex_pc_plus_4;
logic                   [31:0] mem_addr;
logic                    [4:0] ex_rd_addr;
logic                    [4:0] ex_rs1_addr;
logic                    [4:0] ex_rs2_addr;

if_ctrl_t                      ex_if_ctrl;
ex_ctrl_t                      ex_ex_ctrl;
mem_ctrl_t                     ex_mem_ctrl;
wb_ctrl_t                      ex_wb_ctrl;
cu_inst_t                      ex_inst_type;

reg_fw_t                       forward_rs1;
reg_fw_t                       forward_rs2;
logic                   [31:0] fw_rs1;
logic                   [31:0] fw_rs2;

logic                          flush;

// MEM signals
logic                   [31:0] mem_rs2;
logic                   [31:0] mem_imm;
logic                   [31:0] mem_alu_res;
logic                   [31:0] data_out;
logic                   [31:0] mem_pc_plus_imm;
logic                   [31:0] mem_pc_plus_4;
logic                   [31:0] mem_result;
logic                    [4:0] mem_rd_addr;
logic                          mem_alu_branch;

if_ctrl_t                      mem_if_ctrl;
mem_ctrl_t                     mem_mem_ctrl;
wb_ctrl_t                      mem_wb_ctrl;
cu_inst_t                      mem_inst_type;

// WB signals
logic                   [31:0] wb_data_out;
logic                   [31:0] reg_w_data;
logic                    [4:0] wb_rd_addr;
logic                   [31:0] wb_alu_res;

wb_ctrl_t                      wb_wb_ctrl;

//===============================================
// IF STAGE
//===============================================

always_ff @(posedge clk) begin
    if(~rstb) begin
        pc_next <= 32'hFFFFFFFC;
        status  <= '0;
    end else begin
        pc_next <= pc;
        status  <= stall;
    end
end

instruction_memory i_instmem(
    .clk(clk),
    .addr(pc),
    .inst(inst)
);

assign pc_plus_4 = stall ? pc_next : pc_next + 4;

always_comb begin
    case(mem_if_ctrl.pc_src)
        PCSRC_PC_4   :  pc = pc_plus_4;                                     // normal
        PCSRC_PC_IMM :  pc = mem_pc_plus_imm;                                   // JAL
        PCSRC_ALU    :  pc = {mem_alu_res[31:1], 1'b0};                         // JALR
        PCSRC_BRANCH :  pc = mem_alu_branch ? mem_pc_plus_imm : pc_plus_4;  // conditional branches
        default      :  pc = pc_plus_4;
    endcase
end


// IF to ID
reg_if_id u_ifid(
    .clk(clk),
    .rstb(rstb & ~flush),
    .i_pc(pc),
    .i_inst(inst),
    .o_pc(id_pc),
    .o_inst(id_inst)
);

//===============================================
// ID STAGE
//===============================================

assign rs1_addr = id_inst[19:15];
assign rs2_addr = id_inst[24:20];
assign rd_addr  = id_inst[11:7];

register_file u_reg(
    .clk(clk),
    .rstb(rstb),
    .wr_en(wb_wb_ctrl.reg_w_en),
    .wr_reg(reg_w_data),
    .addr_rs1(rs1_addr),
    .addr_rs2(rs2_addr),
    .addr_rd(wb_rd_addr),
    .rs1(rs1),
    .rs2(rs2)
);

imm_decoder u_imm_dec(
  .inst(id_inst),
  .imm_type(id_id_ctrl.imm),
  .imm_out(imm)
);

control_unit u_cu(
    .opcode(id_inst[6:0]),
    .func3(id_inst[14:12]),
    .func7(id_inst[31:25]),
    .if_ctrl(id_if_ctrl),
    .id_ctrl(id_id_ctrl),
    .ex_ctrl(id_ex_ctrl),
    .mem_ctrl(id_mem_ctrl),
    .wb_ctrl(id_wb_ctrl),
    .inst_type(inst_type)
);

load_use_detector u_lud(
    .next_rs1(rs1_addr),
    .next_rs2(rs2_addr),
    .curr_rd(ex_rd_addr),
    .curr_inst_type(ex_inst_type),
    .stall(stall)
);

always_comb begin
    case(id_ex_ctrl.alu_op2)
        OP2_REG: id_alu_op2 = rs2;
        OP2_IMM: id_alu_op2 = imm;
        default: id_alu_op2 = '0;
    endcase
end

// ID to EX
reg_id_ex u_idex(
    .clk(clk),
    .rstb(rstb & ~stall & ~flush),
    .i_pc(id_pc),
    .i_rs1(rs1),
    .i_rs2(rs2),
    .i_imm(imm),
    .i_alu_op2(id_alu_op2),
    .i_rd_addr(rd_addr),
    .i_rs1_addr(rs1_addr),
    .i_rs2_addr(rs2_addr),
    .i_ex_ctrl(id_ex_ctrl),
    .i_mem_ctrl(id_mem_ctrl),
    .i_wb_ctrl(id_wb_ctrl),
    .i_if_ctrl(id_if_ctrl),
    .i_inst_type(inst_type),
    .o_pc(ex_pc),
    .o_rs1(ex_rs1),
    .o_rs2(ex_rs2),
    .o_imm(ex_imm),
    .o_alu_op2(ex_alu_op2),
    .o_rd_addr(ex_rd_addr),
    .o_rs1_addr(ex_rs1_addr),
    .o_rs2_addr(ex_rs2_addr),
    .o_ex_ctrl(ex_ex_ctrl),
    .o_mem_ctrl(ex_mem_ctrl),
    .o_wb_ctrl(ex_wb_ctrl),
    .o_if_ctrl(ex_if_ctrl),
    .o_inst_type(ex_inst_type)
);

//===============================================
// EX STAGE
//===============================================

reg_forward_unit u_fwu(
    .mem_reg_w_en(mem_wb_ctrl.reg_w_en),
    .wb_reg_w_en(wb_wb_ctrl.reg_w_en),
    .mem_rd(mem_rd_addr),
    .wb_rd(wb_rd_addr),
    .ex_rs1(ex_rs1_addr),
    .ex_rs2(ex_rs2_addr),
    .forward_rs1(forward_rs1),
    .forward_rs2(forward_rs2)
);

alu u_alu(
  .op1(fw_rs1),
  .op2(fw_rs2),
  .op_sel(ex_ex_ctrl.alu_op),
  .comp_type(ex_ex_ctrl.alu_comp),
  .res(alu_res),
  .flags(),
  .branch(alu_branch)
);

always_comb begin
   case(forward_rs1)
       NO_FORWARD  : fw_rs1 = ex_rs1;
       MEM_FORWARD : fw_rs1 = mem_result;
       WB_FORWARD  : fw_rs1 = reg_w_data;
       default     : fw_rs1 = ex_rs1;
   endcase
end

always_comb begin
    case(forward_rs2)
        NO_FORWARD  : fw_rs2 = ex_alu_op2;
        MEM_FORWARD : fw_rs2 = mem_result;
        WB_FORWARD  : fw_rs2 = reg_w_data;
        default     : fw_rs2 = ex_alu_op2;
    endcase
end

assign pc_plus_imm  = ex_pc + (ex_imm &~1);
assign mem_addr  = fw_rs1 + ex_imm;
assign ex_pc_plus_4 = ex_pc + 4;


// EX to MEM
reg_ex_mem u_exmem(
    .clk(clk),
    .rstb(rstb & ~flush),
    .i_alu_res(alu_res),
    .i_pc_plus_4(ex_pc_plus_4),
    .i_pc_plus_imm(pc_plus_imm),
    .i_imm(ex_imm),
    .i_rs2(fw_rs2),
    .i_rd_addr(ex_rd_addr),
    .i_alu_branch(alu_branch),
    .i_mem_ctrl(ex_mem_ctrl),
    .i_wb_ctrl(ex_wb_ctrl),
    .i_if_ctrl(ex_if_ctrl),
    .i_inst_type(ex_inst_type),
    .o_alu_res(mem_alu_res),
    .o_pc_plus_4(mem_pc_plus_4),
    .o_pc_plus_imm(mem_pc_plus_imm),
    .o_imm(mem_imm),
    .o_rs2(mem_rs2),
    .o_rd_addr(mem_rd_addr),
    .o_alu_branch(mem_alu_branch),
    .o_mem_ctrl(mem_mem_ctrl),
    .o_wb_ctrl(mem_wb_ctrl),
    .o_if_ctrl(mem_if_ctrl),
    .o_inst_type(mem_inst_type)
);

//===============================================
// MEM STAGE
//===============================================

data_memory u_data_mem(
    .clk(clk),
    .w_en(ex_mem_ctrl.mem_w_en),
    .addr(mem_addr[DATA_MEM_ADDR_SIZE-1:0]),
    .data_in(mem_rs2),
    .data_out(data_out)
);

always_comb begin
  case(mem_wb_ctrl.reg_src)
    REGSRC_ALU    : mem_result = mem_alu_res;
    REGSRC_PC_4   : mem_result = mem_pc_plus_4;
    REGSRC_PC_IMM : mem_result = mem_pc_plus_imm;
    REGSRC_IMM    : mem_result = mem_imm;
    default       : mem_result = mem_alu_res;
  endcase
end

// MEM to WB
reg_mem_wb u_memwb(
    .clk(clk),
    .rstb(rstb),
    .i_data_out(data_out),
    .i_alu_result(mem_result),
    .i_rd_addr(mem_rd_addr),
    .i_wb_ctrl(mem_wb_ctrl),
    .o_data_out(wb_data_out),
    .o_alu_result(wb_alu_res),
    .o_rd_addr(wb_rd_addr),
    .o_wb_ctrl(wb_wb_ctrl)
);

assign flush = (mem_alu_branch | mem_inst_type == JAL_TYPE | mem_inst_type == JALR_TYPE);

//===============================================
// WB STAGE
//===============================================

always_comb begin
  case(wb_wb_ctrl.reg_src)
    REGSRC_MEM    : reg_w_data = wb_data_out;
    default       : reg_w_data = wb_alu_res;
  endcase
end

endmodule
