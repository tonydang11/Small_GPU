// compute_core.v
`include "definitions.vh"

module compute_core (
    input clk,
    input reset,
    output reg halt
);

    //  FSM State Definitions (Pipeline Stages)
    // 4-stage pipeline: FETCH → DECODE → EXECUTE → WRITEBACK
    localparam FETCH     = 2'b00;
    localparam DECODE    = 2'b01;
    localparam EXECUTE   = 2'b10;
    localparam WRITEBACK = 2'b11;

    reg [1:0] state, next_state;

    //  Architectural State (Registers, PC, Memory)
    // Register file: [thread][register]
    reg [`DATA_WIDTH-1:0] register_file [0:`NUM_THREADS-1][0:`REG_COUNT-1];

    // Program counter per thread
    reg [3:0] pc [0:`NUM_THREADS-1];

    // Active thread mask
    reg [`NUM_THREADS-1:0] active_threads;

    // Simple data memory
    reg [`DATA_WIDTH-1:0] data_mem [0:15];

    //  Pipeline Registers: FETCH Stage
    reg [`THREAD_ID_WIDTH-1:0] fetch_thread;
    reg [`DATA_WIDTH-1:0] fetch_instruction;
    reg [3:0] fetch_pc;

    //  Pipeline Registers: DECODE Stage

    reg [`THREAD_ID_WIDTH-1:0] decode_thread;
    reg [`DATA_WIDTH-1:0] decode_instruction;
    reg [3:0] decode_pc;    
    
    //  Pipeline Registers: EXECUTE Stage
    reg [`THREAD_ID_WIDTH-1:0] exec_thread;
    reg [3:0] exec_opcode;
    reg [3:0] exec_dest_reg;
    reg [3:0] exec_src1_reg;
    reg [3:0] exec_src2_reg;
    reg [7:0] exec_immediate;
    reg [3:0] exec_pc;
    reg [`DATA_WIDTH-1:0] exec_operand_a;
    reg [`DATA_WIDTH-1:0] exec_operand_b;

    //  Thread Scheduler (Priority-based)
    reg [`THREAD_ID_WIDTH-1:0] selected_thread;
    reg thread_selected;
    integer i;

    // Priority encoder: select lowest active thread
    always @(*) begin
        selected_thread = 0;
        thread_selected = 0;
        for (i = 0; i < `NUM_THREADS; i = i + 1) begin
            if (active_threads[i] && !thread_selected) begin
                selected_thread = i;
                thread_selected = 1;
            end
        end
    end

    //  Per-thread Compare Flags (for JLT)
    reg [`NUM_THREADS-1:0] thread_cmp_flags;

    //  Instruction Fetch Unit
    wire [`DATA_WIDTH-1:0] fetcher_instruction;

    fetcher fetcher_inst (
        .pc_in(pc[selected_thread]),
        .instruction(fetcher_instruction)
    );

    //  Instruction Decoder
    wire [3:0] decoder_opcode;
    wire [3:0] decoder_dest_reg;
    wire [3:0] decoder_src1_reg;
    wire [3:0] decoder_src2_reg;
    wire [7:0] decoder_immediate;

    decoder decoder_inst (
        .instruction(decode_instruction),
        .opcode(decoder_opcode),
        .dest_reg(decoder_dest_reg),
        .src1_reg(decoder_src1_reg),
        .src2_reg(decoder_src2_reg),
        .immediate(decoder_immediate)
    );

    //  ALU
    wire [`DATA_WIDTH-1:0] alu_result;
    wire alu_cmp_flag;

    alu alu_inst (
        .opcode(exec_opcode),
        .operand_a(exec_operand_a),
        .operand_b(exec_operand_b),
        .result(alu_result),
        .cmp_flag(alu_cmp_flag)
    );

    //  Data Memory Initialization
    initial begin
        $readmemh("src/data_memory.mem", data_mem);
    end

    //  FSM Next-State Logic
    always @(*) begin
        case (state)
            FETCH:     next_state = DECODE;
            DECODE:    next_state = EXECUTE;
            EXECUTE:   next_state = WRITEBACK;
            WRITEBACK: next_state = FETCH;
            default:   next_state = FETCH;
        endcase
    end

    //  FSM State Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    //  FETCH Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fetch_thread <= 0;
            fetch_instruction <= 0;
            fetch_pc <= 0;
        end else if (state == FETCH && thread_selected) begin
            fetch_thread <= selected_thread;
            fetch_instruction <= fetcher_instruction;
            fetch_pc <= pc[selected_thread];
        end
    end

    //  DECODE Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_thread <= 0;
            decode_instruction <= 0;
            decode_pc <= 0;
        end else if (state == DECODE) begin
            decode_thread <= fetch_thread;
            decode_instruction <= fetch_instruction;
            decode_pc <= fetch_pc;
        end
    end

    //  EXECUTE Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            exec_thread <= 0;
            exec_opcode <= 0;
            exec_dest_reg <= 0;
            exec_src1_reg <= 0;
            exec_src2_reg <= 0;
            exec_immediate <= 0;
            exec_pc <= 0;
            exec_operand_a <= 0;
            exec_operand_b <= 0;
        end else if (state == EXECUTE) begin
            exec_thread <= decode_thread;
            exec_opcode <= decoder_opcode;
            exec_dest_reg <= decoder_dest_reg;
            exec_src1_reg <= decoder_src1_reg;
            exec_src2_reg <= decoder_src2_reg;
            exec_immediate <= decoder_immediate;
            exec_pc <= decode_pc;
            // Operand selection logic
        end
    end

    //  WRITEBACK Stage
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            halt <= 0;
        end else if (state == WRITEBACK && active_threads[exec_thread]) begin
            // Register writeback, PC update, memory ops, HALT handling
        end
    end

    //  Simulation Dump
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, compute_core);
    end

endmodule
