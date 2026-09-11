`timescale 1ns / 1ps

import riscv_pkg::*;

module control_unit(
    input  logic    [6:0] opcode,
    input  logic    [2:0] func3,
    input  logic    [6:0] func7,
    output if_ctrl_t      if_ctrl,
    output id_ctrl_t      id_ctrl,
    output ex_ctrl_t      ex_ctrl,
    output mem_ctrl_t     mem_ctrl,
    output wb_ctrl_t      wb_ctrl,
    output cu_inst_t      inst_type
);

always_comb begin
    // defaults
    if_ctrl  = '{pc_src: PCSRC_PC_4};
    id_ctrl  = '{imm: IMM_NONE};
    ex_ctrl  = '{alu_op2: OP2_REG, alu_comp: NOC, alu_op: ADD};
    mem_ctrl = '{mem_w_en: 1'b0, mem_size: WIDE, mem_signed: SIGNED};
    wb_ctrl  = '{reg_w_en: 1'b0, reg_src: REGSRC_ALU};

    // silently droping bits [1:0] for now until C extension
    case(opcode[6:2])
        5'b01100 : begin
            inst_type = R_TYPE;
        wb_ctrl.reg_w_en = 1'b1;
            case(func3)
                3'b000 : ex_ctrl.alu_op = (func7 == 7'b0100000) ? SUB : ADD;
                3'b001 : ex_ctrl.alu_op = SLL;
                3'b010 : ex_ctrl.alu_op = SLT;
                3'b011 : ex_ctrl.alu_op = SLTU;
                3'b100 : ex_ctrl.alu_op = XOR;
                3'b101 : ex_ctrl.alu_op = (func7 == 7'b0100000) ? SRA : SRL;
                3'b110 : ex_ctrl.alu_op = OR;
                3'b111 : ex_ctrl.alu_op = AND;
            endcase
        end

        5'b00100 : begin
            inst_type = I_TYPE;
            id_ctrl.imm = IMM_I;
            wb_ctrl.reg_w_en = 1'b1;
            ex_ctrl.alu_op2 = OP2_IMM;
            case(func3)
                3'b000 : ex_ctrl.alu_op = ADD;
                3'b001 : ex_ctrl.alu_op = SLL;
                3'b010 : ex_ctrl.alu_op = SLT;
                3'b011 : ex_ctrl.alu_op = SLTU;
                3'b100 : ex_ctrl.alu_op = XOR;
                3'b101 : ex_ctrl.alu_op = (func7 == 7'b0100000) ? SRA : SRL;
                3'b110 : ex_ctrl.alu_op = OR;
                3'b111 : ex_ctrl.alu_op = AND;
            endcase
        end

        5'b00000 : begin
            inst_type = L_TYPE;
            id_ctrl.imm = IMM_I;
            wb_ctrl.reg_w_en = 1'b1;
            wb_ctrl.reg_src = REGSRC_MEM;
            ex_ctrl.alu_op2 = OP2_IMM;
            case(func3)
                   3'b000 : begin
                              mem_ctrl.mem_size   = BYTE;
                              mem_ctrl.mem_signed = SIGNED;
                            end
                   3'b001 : begin
                              mem_ctrl.mem_size   = HALF;
                              mem_ctrl.mem_signed = SIGNED;
                            end
                   3'b010 : begin
                              mem_ctrl.mem_size   = WIDE;
                              mem_ctrl.mem_signed = SIGNED;
                            end
                   3'b100 : begin
                              mem_ctrl.mem_size   = BYTE;
                              mem_ctrl.mem_signed = UNSIGNED;
                            end
                   3'b101 : begin
                              mem_ctrl.mem_size   = HALF;
                              mem_ctrl.mem_signed = UNSIGNED;
                            end
                   default: begin
                              mem_ctrl.mem_size   = WIDE;
                              mem_ctrl.mem_signed = UNSIGNED;
                            end
            endcase
        end

        5'b01000 : begin
            inst_type = S_TYPE;
            id_ctrl.imm = IMM_S;
            ex_ctrl.alu_op2 = OP2_REG;
            mem_ctrl.mem_w_en = 1'b1;
            case(func3)
                3'b000 : mem_ctrl.mem_size = BYTE;
                3'b001 : mem_ctrl.mem_size = HALF;
                default: mem_ctrl.mem_size = WIDE;
            endcase
        end

        5'b11000 : begin
            inst_type = B_TYPE;
            id_ctrl.imm = IMM_B;
            if_ctrl.pc_src = PCSRC_BRANCH;
            ex_ctrl.alu_op = SUB;
            case(func3)
                3'b000 : ex_ctrl.alu_comp = BEQ;
                3'b001 : ex_ctrl.alu_comp = BNE;
                3'b100 : ex_ctrl.alu_comp = BLT;
                3'b101 : ex_ctrl.alu_comp = BGE;
                3'b110 : ex_ctrl.alu_comp = BLTU;
                3'b111 : ex_ctrl.alu_comp = BGEU;
                default: ex_ctrl.alu_comp = BEQ;
            endcase
        end

        5'b11011 : begin
            inst_type = JAL_TYPE;
            id_ctrl.imm = IMM_J;
            ex_ctrl.alu_op2 = OP2_IMM;
            wb_ctrl.reg_src = REGSRC_PC_4;
            if_ctrl.pc_src = PCSRC_PC_IMM;
            wb_ctrl.reg_w_en = 1'b1;
        end 

        5'b11001 : begin
            inst_type = JALR_TYPE;
            id_ctrl.imm = IMM_I;
            ex_ctrl.alu_op2 = OP2_IMM;
            wb_ctrl.reg_src = REGSRC_PC_4;
            if_ctrl.pc_src = PCSRC_ALU;
            wb_ctrl.reg_w_en = 1'b1;
        end

        5'b01101 : begin
            inst_type = LUI_TYPE;
            id_ctrl.imm = IMM_U;
            ex_ctrl.alu_op2 = OP2_IMM;
            wb_ctrl.reg_src = REGSRC_IMM;
            wb_ctrl.reg_w_en = 1'b1;
        end

        5'b00101 : begin
            inst_type = AUIPC_TYPE;
            id_ctrl.imm = IMM_U;
            ex_ctrl.alu_op2 = OP2_IMM;
            wb_ctrl.reg_src = REGSRC_PC_IMM;
            wb_ctrl.reg_w_en = 1'b1;
        end

        5'b11100 : begin
            inst_type = SYS_TYPE;
            id_ctrl.imm = IMM_NONE;
        end

        5'b00011 : begin
            inst_type = FENCE_TYPE;
            id_ctrl.imm = IMM_NONE;
        end

        default : begin
            inst_type = NOP_TYPE;
            id_ctrl.imm = IMM_NONE;
        end
    endcase
end
endmodule
