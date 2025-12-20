// fetcher.v
module fetcher #(
    parameter ADDR_WIDTH = 4,   
    parameter DATA_WIDTH = 32,  
    parameter MEM_DEPTH  = 16   
)(
    input  [ADDR_WIDTH-1:0] pc_in,
    output [DATA_WIDTH-1:0] instruction,
    input  [DATA_WIDTH-1:0] instr_mem [0:MEM_DEPTH-1]
);

    assign instruction = instr_mem[pc_in];

endmodule
