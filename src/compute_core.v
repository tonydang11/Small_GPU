`include "definitions.vh"

module compute_core (
    input clk,
    input reset,
    output reg halt
);

    // ========================================================================
    // STATE MACHINE APPROACH - Different from typical immediate execution
    // ========================================================================
    localparam FETCH = 2'b00;
    localparam DECODE = 2'b01;
    localparam EXECUTE = 2'b10;
    localparam WRITEBACK = 2'b11;
    
    reg [1:0] state, next_state;
    
    // ========================================================================
    // REGISTER FILE & MEMORY - Standard
    // ========================================================================
    reg [`DATA_WIDTH-1:0] register_file [0:`NUM_THREADS-1][0:`REG_COUNT-1];
    reg [3:0] pc [0:`NUM_THREADS-1];
    reg [`NUM_THREADS-1:0] active_threads;
    reg [`DATA_WIDTH-1:0] data_mem [0:15];
    
    // ========================================================================
    // PIPELINE REGISTERS - Key difference: explicit pipeline stages
    // ========================================================================
    reg [`THREAD_ID_WIDTH-1:0] fetch_thread;
    reg [`DATA_WIDTH-1:0] fetch_instruction;
    reg [3:0] fetch_pc;
    
    reg [`THREAD_ID_WIDTH-1:0] decode_thread;
    reg [`DATA_WIDTH-1:0] decode_instruction;
    reg [3:0] decode_pc;
    
    reg [`THREAD_ID_WIDTH-1:0] exec_thread;
    reg [3:0] exec_opcode;
    reg [3:0] exec_dest_reg;
    reg [3:0] exec_src1_reg;
    reg [3:0] exec_src2_reg;
    reg [7:0] exec_immediate;
    reg [3:0] exec_pc;
    reg [`DATA_WIDTH-1:0] exec_operand_a;
    reg [`DATA_WIDTH-1:0] exec_operand_b;
    
    // ========================================================================
    // PRIORITY-BASED SCHEDULER - Different from round-robin
    // Lower thread ID = higher priority
    // ========================================================================
    reg [`THREAD_ID_WIDTH-1:0] selected_thread;
    reg thread_selected;
    
    integer i;
    
    always @(*) begin
        selected_thread = 0;
        thread_selected = 0;
        // Priority encoder: select lowest-numbered active thread
        for (i = 0; i < `NUM_THREADS; i = i + 1) begin
            if (active_threads[i] && !thread_selected) begin
                selected_thread = i;
                thread_selected = 1;
            end
        end
    end
    
    // ========================================================================
    // PER-THREAD COMPARE FLAGS
    // ========================================================================
    reg [`NUM_THREADS-1:0] thread_cmp_flags;
    
    // ========================================================================
    // MODULE INSTANTIATIONS
    // ========================================================================
    wire [`DATA_WIDTH-1:0] fetcher_instruction;
    
    fetcher fetcher_inst (
        .pc_in(pc[selected_thread]),
        .instruction(fetcher_instruction)
    );
    
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
    
    wire [`DATA_WIDTH-1:0] alu_result;
    wire alu_cmp_flag;
    
    alu alu_inst (
        .opcode(exec_opcode),
        .operand_a(exec_operand_a),
        .operand_b(exec_operand_b),
        .result(alu_result),
        .cmp_flag(alu_cmp_flag)
    );
    
    // ========================================================================
    // MEMORY INITIALIZATION
    // ========================================================================
    initial begin
        $readmemh("src/data_memory.mem", data_mem);
        $display("Data Memory Initialized:");
        for (i = 0; i < 16; i = i + 1) begin
            $display("data_mem[%0d] = %h", i, data_mem[i]);
        end
    end
    
    // ========================================================================
    // STATE MACHINE - Next State Logic
    // ========================================================================
    always @(*) begin
        case (state)
            FETCH:     next_state = DECODE;
            DECODE:    next_state = EXECUTE;
            EXECUTE:   next_state = WRITEBACK;
            WRITEBACK: next_state = FETCH;
            default:   next_state = FETCH;
        endcase
    end
    
    // ========================================================================
    // STATE MACHINE - State Register
    // ========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= FETCH;
        end else begin
            state <= next_state;
        end
    end
    
    // ========================================================================
    // PIPELINE STAGE 1: FETCH
    // ========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fetch_thread <= 0;
            fetch_instruction <= 0;
            fetch_pc <= 0;
        end else if (state == FETCH && thread_selected) begin
            fetch_thread <= selected_thread;
            fetch_instruction <= fetcher_instruction;
            fetch_pc <= pc[selected_thread];
            $display("[FETCH] Time=%0t | Thread=%0d | PC=%0d | Instr=%h", 
                     $time, selected_thread, pc[selected_thread], fetcher_instruction);
        end
    end
    
    // ========================================================================
    // PIPELINE STAGE 2: DECODE
    // ========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            decode_thread <= 0;
            decode_instruction <= 0;
            decode_pc <= 0;
        end else if (state == DECODE) begin
            decode_thread <= fetch_thread;
            decode_instruction <= fetch_instruction;
            decode_pc <= fetch_pc;
            $display("[DECODE] Time=%0t | Thread=%0d | Opcode=%b | Dest=R%0d", 
                     $time, fetch_thread, decoder_opcode, decoder_dest_reg);
        end
    end
    
    // ========================================================================
    // PIPELINE STAGE 3: EXECUTE (Prepare operands)
    // ========================================================================
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
            
            // Operand preparation based on instruction type
            case (decoder_opcode)
                `OP_ADD, `OP_SUB, `OP_MUL, `OP_CMP: begin
                    exec_operand_a <= register_file[decode_thread][decoder_src1_reg];
                    exec_operand_b <= register_file[decode_thread][decoder_src2_reg];
                end
                `OP_ADDI, `OP_SUBI: begin
                    exec_operand_a <= register_file[decode_thread][decoder_dest_reg];
                    exec_operand_b <= {{8{decoder_immediate[7]}}, decoder_immediate};
                end
                `OP_LDR: begin
                    exec_operand_a <= 0;
                    exec_operand_b <= 0;
                end
                `OP_STR: begin
                    exec_operand_a <= register_file[decode_thread][decoder_dest_reg];
                    exec_operand_b <= 0;
                end
                default: begin
                    exec_operand_a <= 0;
                    exec_operand_b <= 0;
                end
            endcase
            
            $display("[EXECUTE] Time=%0t | Thread=%0d | Op=%b | A=%h | B=%h", 
                     $time, decode_thread, decoder_opcode, 
                     register_file[decode_thread][decoder_src1_reg],
                     register_file[decode_thread][decoder_src2_reg]);
        end
    end
    
    // ========================================================================
    // PIPELINE STAGE 4: WRITEBACK
    // ========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < `NUM_THREADS; i = i + 1) begin
                pc[i] <= 0;
                active_threads[i] <= 1;
                thread_cmp_flags[i] <= 0;
                for (integer j = 0; j < `REG_COUNT; j = j + 1) begin
                    register_file[i][j] <= 0;
                end
                register_file[i][15] <= i;  // R15 = Thread ID
            end
            halt <= 0;
        end else if (state == WRITEBACK && active_threads[exec_thread]) begin
            
            case (exec_opcode)
                `OP_ADD, `OP_SUB, `OP_MUL, `OP_ADDI, `OP_SUBI: begin
                    register_file[exec_thread][exec_dest_reg] <= alu_result;
                    pc[exec_thread] <= exec_pc + 1;
                    $display("[WRITEBACK] Thread=%0d | R%0d <= %h | PC=%0d->%0d", 
                             exec_thread, exec_dest_reg, alu_result, exec_pc, exec_pc+1);
                end
                
                `OP_CMP: begin
                    thread_cmp_flags[exec_thread] <= alu_cmp_flag;
                    pc[exec_thread] <= exec_pc + 1;
                    $display("[WRITEBACK] Thread=%0d | CMP_FLAG=%b | PC=%0d->%0d", 
                             exec_thread, alu_cmp_flag, exec_pc, exec_pc+1);
                end
                
                `OP_JMP: begin
                    pc[exec_thread] <= exec_immediate[3:0];
                    $display("[WRITEBACK] Thread=%0d | JMP to PC=%0d", 
                             exec_thread, exec_immediate[3:0]);
                end
                
                `OP_JLT: begin
                    if (thread_cmp_flags[exec_thread]) begin
                        pc[exec_thread] <= exec_immediate[3:0];
                        $display("[WRITEBACK] Thread=%0d | JLT taken to PC=%0d", 
                                 exec_thread, exec_immediate[3:0]);
                    end else begin
                        pc[exec_thread] <= exec_pc + 1;
                        $display("[WRITEBACK] Thread=%0d | JLT not taken | PC=%0d->%0d", 
                                 exec_thread, exec_pc, exec_pc+1);
                    end
                end
                
                `OP_LDR: begin
                    register_file[exec_thread][exec_dest_reg] <= data_mem[exec_immediate[3:0]];
                    pc[exec_thread] <= exec_pc + 1;
                    $display("[WRITEBACK] Thread=%0d | LDR R%0d <= mem[%0d]=%h", 
                             exec_thread, exec_dest_reg, exec_immediate[3:0], 
                             data_mem[exec_immediate[3:0]]);
                end
                
                `OP_STR: begin
                    data_mem[exec_immediate[3:0]] <= exec_operand_a;
                    pc[exec_thread] <= exec_pc + 1;
                    $display("[WRITEBACK] Thread=%0d | STR mem[%0d] <= %h", 
                             exec_thread, exec_immediate[3:0], exec_operand_a);
                end
                
                `OP_HALT: begin
                    active_threads[exec_thread] <= 0;
                    $display("[WRITEBACK] Thread=%0d | HALT", exec_thread);
                end
                
                default: begin
                    pc[exec_thread] <= exec_pc + 1;
                    $display("[WRITEBACK] Thread=%0d | NOP | PC=%0d->%0d", 
                             exec_thread, exec_pc, exec_pc+1);
                end
            endcase
            
            // Check if all threads halted
            if (active_threads == (1 << exec_thread) && exec_opcode == `OP_HALT) begin
                halt <= 1;
                $display("=== ALL THREADS HALTED at time %0t ===", $time);
            end
        end
    end
    
    // ========================================================================
    // WAVEFORM DUMP
    // ========================================================================
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, compute_core);
    end
    
endmodule