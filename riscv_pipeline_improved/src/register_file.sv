import riscv_pkg::*;

module register_file(
    input  logic        clk,
    input  logic        rstb,
    input  logic        wr_en,
    input  logic [31:0] wr_reg,
    input  logic  [4:0] addr_rs1,
    input  logic  [4:0] addr_rs2,
    input  logic  [4:0] addr_rd,
    output logic [31:0] rs1,
    output logic [31:0] rs2
);

logic [31:0] regs[0:31];

//logic [31:0] probe_a, probe_b;

always_ff @(posedge clk) begin
    if(~rstb) begin
        for(int i=0; i<32; i++) begin
            regs[i] <= '0;
        end
    end
    else if(wr_en) begin
        regs[addr_rd] <= (addr_rd == 5'b0) ? '0 : wr_reg;
    end

    //rs1 <= regs[addr_rs1];
    //rs2 <= regs[addr_rs2];
end

assign rs1 = regs[addr_rs1];
assign rs2 = regs[addr_rs2];

endmodule
