`timescale 1ns / 1ps
`default_nettype none


module fetcher #(
    parameter ADDR_WIDTH = 8,
    parameter INST_WIDTH = 32
)(
    input  wire                 clk,
    input  wire                 reset,
    input  wire                 fetch_enable,

    output reg  [INST_WIDTH-1:0] instruction,
    output reg  [ADDR_WIDTH-1:0] pc
);

    // Simple instruction memory (ROM)
    reg [INST_WIDTH-1:0] instr_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        instr_mem[0] = 32'h00000001;
        instr_mem[1] = 32'h00000002;
        instr_mem[2] = 32'h00000003;
        instr_mem[3] = 32'h00000004;
    end

    always @(posedge clk) begin
        if (reset) begin
            pc <= {ADDR_WIDTH{1'b0}};
            instruction <= {INST_WIDTH{1'b0}};
        end else if (fetch_enable) begin
            instruction <= instr_mem[pc];
            pc <= pc + 1'b1;
        end
    end

endmodule

`default_nettype wire
