`include "definitions.vh"

module compute_core (
    input clk,
    input reset,
    output reg halt
);
    reg [`DATA_WIDTH-1:0] register_file [0:`NUM_THREADS-1][0:`REG_COUNT-1];
    reg [3:0] pc [0:`NUM_THREADS-1];  // 4-bit PC for 16 instruction memory entries
    reg [`NUM_THREADS-1:0] active_threads;
    reg [`DATA_WIDTH-1:0] data_mem [0:15];
    
    wire [`THREAD_ID_WIDTH-1:0] scheduled_thread;
    wire [`DATA_WIDTH-1:0] instruction;
    wire [3:0] opcode;
    wire [3:0] dest_reg;
    wire [3:0] src1_reg;
    wire [3:0] src2_reg;
    wire [7:0] immediate;
    
    // ALU signals
    reg [`DATA_WIDTH-1:0] alu_operand_a;
    reg [`DATA_WIDTH-1:0] alu_operand_b;
    wire [`DATA_WIDTH-1:0] alu_result;
    wire alu_cmp_flag;
    
    // Per-thread compare flags
    reg [`NUM_THREADS-1:0] cmp_flags;
    
    integer i, current_thread;
    reg [`NUM_THREADS-1:0] next_active_threads;
    
    // Instantiate Scheduler
    scheduler scheduler_inst (
        .clk(clk),
        .reset(reset),
        .active_threads(active_threads),
        .scheduled_thread(scheduled_thread)
    );
    
    // Instantiate Fetcher
    fetcher fetcher_inst (
        .pc_in(pc[scheduled_thread]),
        .instruction(instruction)
    );
    
    // Instantiate Decoder
    decoder decoder_inst (
        .instruction(instruction),
        .opcode(opcode),
        .dest_reg(dest_reg),
        .src1_reg(src1_reg),
        .src2_reg(src2_reg),
        .immediate(immediate)
    );
    
    // Instantiate ALU
    alu alu_inst (
        .opcode(opcode),
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .result(alu_result),
        .cmp_flag(alu_cmp_flag)
    );
    
    // Initialize data memory
    initial begin
        $readmemh("src/data_memory.mem", data_mem);
        $display("Data Memory Initialized:");
        for (i = 0; i < 16; i = i + 1) begin
            $display("data_mem[%0d] = %h", i, data_mem[i]);
        end
    end
    
    // Core logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < `NUM_THREADS; i = i + 1) begin
                pc[i] <= 0;
                active_threads[i] <= 1;
                cmp_flags[i] <= 0;
                for (current_thread = 0; current_thread < `REG_COUNT; current_thread = current_thread + 1) begin
                    register_file[i][current_thread] <= 0;
                end
                register_file[i][15] <= i;
            end
            halt <= 0;
            $display("DUT Reset at time %0t", $time);
        end 
        else if (!halt) begin
            next_active_threads = active_threads;
            current_thread = scheduled_thread;
            
            if (active_threads[current_thread]) begin
                // Prepare ALU inputs based on instruction type
                case (opcode)
                    `OP_ADD, `OP_SUB, `OP_MUL, `OP_CMP: begin
                        alu_operand_a = register_file[current_thread][src1_reg];
                        alu_operand_b = register_file[current_thread][src2_reg];
                    end
                    `OP_ADDI, `OP_SUBI: begin
                        alu_operand_a = register_file[current_thread][dest_reg];
                        alu_operand_b = {{8{immediate[7]}}, immediate}; // Sign extend
                    end
                    default: begin
                        alu_operand_a = 0;
                        alu_operand_b = 0;
                    end
                endcase
                
                // Execute instruction
                case (opcode)
                    `OP_ADD: begin
                        register_file[current_thread][dest_reg] <= alu_result;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_SUB: begin
                        register_file[current_thread][dest_reg] <= alu_result;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_MUL: begin
                        register_file[current_thread][dest_reg] <= alu_result;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_CMP: begin
                        cmp_flags[current_thread] <= alu_cmp_flag;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_ADDI: begin
                        register_file[current_thread][dest_reg] <= alu_result;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_SUBI: begin
                        register_file[current_thread][dest_reg] <= alu_result;
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_JMP: begin
                        pc[current_thread] <= immediate[3:0];  // Only 4 bits
                    end
                    
                    `OP_JLT: begin
                        if (cmp_flags[current_thread] == 1) begin
                            pc[current_thread] <= immediate[3:0];  // Only 4 bits
                        end else begin
                            pc[current_thread] <= pc[current_thread] + 1;
                        end
                    end
                    
                    `OP_LDR: begin
                        register_file[current_thread][dest_reg] <= data_mem[immediate[3:0]];
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_STR: begin
                        data_mem[immediate[3:0]] <= register_file[current_thread][dest_reg];
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                    
                    `OP_HALT: begin
                        next_active_threads[current_thread] = 0;
                        $display("Thread %0d executing HALT. Halting.", current_thread);
                    end
                    
                    default: begin
                        $display("Thread %0d encountered undefined opcode %b. No operation performed.", 
                                current_thread, opcode);
                        pc[current_thread] <= pc[current_thread] + 1;
                    end
                endcase
                
                // Logging
                $display("Time=%0t | Thread=%0d | PC=%0d | Instruction=%h | Opcode=%b | dest=R%0d | src1=R%0d | src2=R%0d | imm=%d", 
                         $time, current_thread, pc[current_thread], instruction, opcode, 
                         dest_reg, src1_reg, src2_reg, immediate);
            end
            
            active_threads <= next_active_threads;
            
            // Check if all threads have halted
            if (next_active_threads == 0) begin
                halt <= 1;
                $display("All threads have halted at time %0t", $time);
            end
        end
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, compute_core);
    end
    
endmodule