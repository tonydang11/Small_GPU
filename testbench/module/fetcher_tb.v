// testbench/module/fetcher_tb.v

module fetcher_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 16;

    // Inputs
    reg [ADDR_WIDTH-1:0] pc_in;    // Testbench dùng 16-bit
    
    // Outputs
    wire [DATA_WIDTH-1:0] instruction;

    // Instantiate - CHỈ kết nối ports có thật
    fetcher uut (
        .pc_in(pc_in[3:0]),        // Chỉ truyền 4 bit thấp
        .instruction(instruction)
        // KHÔNG có .instr_mem()!
    );

    // Testbench stimulus
    initial begin
        // Display header
        $display("Time\tPC\tInstruction");
        
        // Apply test cases
        #10 pc_in = 0;
        #10 pc_in = 1;
        #10 pc_in = 2;
        #10 pc_in = 3;
        #10 pc_in = 4;
        #10 pc_in = 5;
        #10 pc_in = 6;
        #10 pc_in = 7;
        #10 pc_in = 8;
        #10 pc_in = 9;
        #10 pc_in = 10;
        #10 pc_in = 11;
        #10 pc_in = 12;
        #10 pc_in = 13;
        #10 pc_in = 14;
        #10 pc_in = 15;

        // End simulation
        #10 $finish;
    end

    // Monitor
    always @(pc_in) begin
        $display("%0t\t%h\t%h", $time, pc_in[3:0], instruction);
    end

endmodule
