// decoder.v
`include "definitions.vh"

module decoder (
    input [`DATA_WIDTH-1:0] instruction,
    output reg [3:0] opcode,
    output reg [3:0] dest_reg,
    output reg [3:0] src1_reg,
    output reg [3:0] src2_reg,
    output reg [7:0] immediate
);
    always @(*) begin
        opcode = instruction[15:12];
        dest_reg = instruction[11:8];
        
        // R-Type: Op | Dest | Src1 | Src2
        // I-Type: Op | Dest | Immediate
        
        src1_reg = instruction[7:4];   // Used in R-Type
        src2_reg = instruction[3:0];   // Used in R-Type
        // immediate = instruction[7:0];  // Used in I-Type
    end
endmodule