import riscv_pkg::*;

module register_file(
    input  logic        clk,
    input  logic        rstb,
    input  logic        wr_en,
    input  logic [31:0] wr_reg,
    input  logic  [4:0] addr_rs1,
    input  logic  [4:0] addr_rs2,
    input  logic  [4:0] addr_rd,
    input  logic        flush,
    output logic [31:0] rs1,
    output logic [31:0] rs2
);

logic [31:0] regs[0:31];

always_ff @(posedge clk) begin
    if(~rstb) begin
        for(int i=0; i<32; i++) begin
            regs[i] <= '0;
        end
    end
    else if(wr_en) begin
        regs[addr_rd] <= (addr_rd == 5'b0) ? '0 : wr_reg;
    end

    //rs1 <= flush ? 32'h0 : ((wr_en && addr_rd == addr_rs1 && addr_rd != 5'b0) ? wr_reg : regs[addr_rs1]);
    //rs2 <= flush ? 32'h0 : ((wr_en && addr_rd == addr_rs2 && addr_rd != 5'b0) ? wr_reg : regs[addr_rs2]);
    rs1 <= flush ? 32'h0 : regs[addr_rs1];
    rs2 <= flush ? 32'h0 : regs[addr_rs2];
end

endmodule
