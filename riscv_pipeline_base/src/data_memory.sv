`timescale 1ns / 1ps

import riscv_pkg::*;

module data_memory(
    input  logic                          clk,
    input  logic                          rstb,
    input  logic                          w_en,
    input  mem_d_sign_t                   mem_signext,
    input  mem_d_size_t                   d_width,
    input  logic [DATA_MEM_ADDR_SIZE-1:0] addr,
    input  logic                   [31:0] data_in,
    output logic                   [31:0] data_out
);

localparam int WORD_DEPTH = 2**(DATA_MEM_ADDR_SIZE-2);

logic [DATA_MEM_ADDR_SIZE-3:0] word_addr;
assign word_addr = addr[DATA_MEM_ADDR_SIZE-1:2];

(* ram_style = "block" *) logic [7:0] ram0 [0:WORD_DEPTH-1];  // byte lane 0
(* ram_style = "block" *) logic [7:0] ram1 [0:WORD_DEPTH-1];  // byte lane 1
(* ram_style = "block" *) logic [7:0] ram2 [0:WORD_DEPTH-1];  // byte lane 2
(* ram_style = "block" *) logic [7:0] ram3 [0:WORD_DEPTH-1];  // byte lane 3

logic       lane_we  [4];
logic [7:0] lane_din [4];

always_comb begin
    lane_we[0]  = 1'b0;  lane_we[1]  = 1'b0;  lane_we[2]  = 1'b0;  lane_we[3]  = 1'b0;
    lane_din[0] = data_in[7:0];   lane_din[1] = data_in[15:8];
    lane_din[2] = data_in[23:16]; lane_din[3] = data_in[31:24];

    if (w_en) begin
        case (d_width)
            BYTE : begin
                lane_we[addr[1:0]]  = 1'b1;
                lane_din[addr[1:0]] = data_in[7:0];
            end
            HALF : begin
                if (addr[1]) begin
                    lane_we[2]  = 1'b1;
                    lane_we[3]  = 1'b1;
                    lane_din[2] = data_in[7:0];
                    lane_din[3] = data_in[15:8];
                end else begin
                    lane_we[0] = 1'b1;
                    lane_we[1] = 1'b1;
                end
            end
            WIDE : begin
                lane_we[0] = 1'b1;
                lane_we[1] = 1'b1;
                lane_we[2] = 1'b1;
                lane_we[3] = 1'b1;
            end
            default : ;
        endcase
    end
end

// raw registered reads — trivial "reg <= mem[addr]" per lane, matching the
// block-RAM inference template. Width/sign selection is pushed downstream so
// it no longer sits inside the memory-read expression.
logic [7:0]    ram0_q, ram1_q, ram2_q, ram3_q;
logic [1:0]    addr_q;
mem_d_size_t   d_width_q;
mem_d_sign_t   mem_signext_q;

always_ff @(posedge clk) begin
    ram0_q <= ram0[word_addr];
    ram1_q <= ram1[word_addr];
    ram2_q <= ram2[word_addr];
    ram3_q <= ram3[word_addr];

    addr_q        <= addr[1:0];
    d_width_q     <= d_width;
    mem_signext_q <= mem_signext;

    if (lane_we[0]) ram0[word_addr] <= lane_din[0];
    if (lane_we[1]) ram1[word_addr] <= lane_din[1];
    if (lane_we[2]) ram2[word_addr] <= lane_din[2];
    if (lane_we[3]) ram3[word_addr] <= lane_din[3];
end

// width/sign-extension mux — ordinary combinational logic downstream of the
// registered reads above, so it no longer interferes with BRAM inference.
always_comb begin
    case (d_width_q)
        BYTE : begin
            case (addr_q)
                2'd0 : data_out = (mem_signext_q == SIGNED) ? {{24{ram0_q[7]}}, ram0_q} : {24'b0, ram0_q};
                2'd1 : data_out = (mem_signext_q == SIGNED) ? {{24{ram1_q[7]}}, ram1_q} : {24'b0, ram1_q};
                2'd2 : data_out = (mem_signext_q == SIGNED) ? {{24{ram2_q[7]}}, ram2_q} : {24'b0, ram2_q};
                2'd3 : data_out = (mem_signext_q == SIGNED) ? {{24{ram3_q[7]}}, ram3_q} : {24'b0, ram3_q};
            endcase
        end
        HALF : begin
            if (addr_q[1])
                data_out = (mem_signext_q == SIGNED) ? {{16{ram3_q[7]}}, ram3_q, ram2_q} : {16'b0, ram3_q, ram2_q};
            else
                data_out = (mem_signext_q == SIGNED) ? {{16{ram1_q[7]}}, ram1_q, ram0_q} : {16'b0, ram1_q, ram0_q};
        end
        WIDE : data_out = {ram3_q, ram2_q, ram1_q, ram0_q};
        default : data_out = '0;
    endcase
end

endmodule
