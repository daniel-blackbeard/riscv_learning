import riscv_pkg::*;

module reg_forward_unit(
    input  logic          mem_reg_w_en,
    input  logic          wb_reg_w_en,
    input  logic    [4:0] mem_rd,
    input  logic    [4:0] wb_rd,
    input  logic    [4:0] ex_rs1,
    input  logic    [4:0] ex_rs2,
    output reg_fw_t       forward_rs1,
    output reg_fw_t       forward_rs2
);

always_comb begin
    // RS1
    if (mem_reg_w_en && (mem_rd != 5'd0) && (ex_rs1 == mem_rd))
        forward_rs1 = MEM_FORWARD;
    else if (wb_reg_w_en && (wb_rd != 5'd0) && (ex_rs1 == wb_rd))
        forward_rs1 = WB_FORWARD;
    else
        forward_rs1 = NO_FORWARD;

    // RS2
    if (mem_reg_w_en && (mem_rd != 5'd0) && (ex_rs2 == mem_rd))
        forward_rs2 = MEM_FORWARD;
    else if (wb_reg_w_en && (wb_rd != 5'd0) && (ex_rs2 == wb_rd))
        forward_rs2 = WB_FORWARD;
    else
        forward_rs2 = NO_FORWARD;
end

endmodule
