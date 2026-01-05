`include "definitions.vh"

module compute_core (
    input  clk,
    input  reset,
    output reg halt
);

    // Registers & Memories 
    reg [`DATA_WIDTH-1:0] register_file [0:`NUM_THREADS-1][0:`REG_COUNT-1];
    reg [`ADDR_WIDTH-1:0] pc [0:`NUM_THREADS-1];
    reg [`NUM_THREADS-1:0] active_threads;

    reg [`DATA_WIDTH-1:0] data_mem  [0:255];
    reg [`DATA_WIDTH-1:0] instr_mem [0:255];

    // Scheduler / Fetch / Decode
    wire [`THREAD_ID_WIDTH-1:0] scheduled_thread;
    wire [`DATA_WIDTH-1:0] instruction;
    wire [3:0] opcode, dest_reg, src1_reg, src2_reg;
    wire [7:0] immediate;

    scheduler #(
        .NUM_THREADS(`NUM_THREADS)
    ) scheduler_inst (
        .clk(clk),
        .reset(reset),
        .active_threads(active_threads),
        .scheduled_thread(scheduled_thread)
    );

    fetcher fetcher_inst (
        .pc_in(pc[scheduled_thread]),
        .instruction(instruction),
        .instr_mem(instr_mem)
    );

    decoder decoder_inst (
        .instruction(instruction),
        .opcode(opcode),
        .dest_reg(dest_reg),
        .src1_reg(src1_reg),
        .src2_reg(src2_reg),
        .immediate(immediate)
    );


    // Internal signals
    integer i, j;
    reg pc_increment;
    reg cmp_flag;
    reg [`THREAD_ID_WIDTH-1:0] current_thread;
    reg [`NUM_THREADS-1:0] next_active_threads;
    reg [`DATA_WIDTH-1:0] alu_result;


    // Memory initialization
    initial begin
        $readmemh("src/instruction_memory.mem", instr_mem);
        $readmemh("src/data_memory.mem", data_mem);
    end

    // Core logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            halt <= 0;
            cmp_flag <= 0;

            for (i = 0; i < `NUM_THREADS; i = i + 1) begin
                pc[i] <= 0;
                active_threads[i] <= 1;

                for (j = 0; j < `REG_COUNT; j = j + 1)
                    register_file[i][j] <= 0;

                register_file[i][15] <= i; // R15 = thread ID
            end

            $display("=== GPU RESET at time %0t ===", $time);

        end else if (!halt) begin
            // defaults
            current_thread      <= scheduled_thread;
            next_active_threads <= active_threads;
            pc_increment        <= 1;
            cmp_flag            <= cmp_flag;

            if (active_threads[scheduled_thread]) begin
                case (opcode)

                    `OP_ADD: begin
                        alu_result <= register_file[scheduled_thread][src1_reg] +
                                      register_file[scheduled_thread][src2_reg];
                        register_file[scheduled_thread][dest_reg] <= alu_result;
                    end

                    `OP_SUB: begin
                        alu_result <= register_file[scheduled_thread][src1_reg] -
                                      register_file[scheduled_thread][src2_reg];
                        register_file[scheduled_thread][dest_reg] <= alu_result;
                    end

                    `OP_MUL: begin
                        alu_result <= register_file[scheduled_thread][src1_reg] *
                                      register_file[scheduled_thread][src2_reg];
                        register_file[scheduled_thread][dest_reg] <= alu_result;
                    end

                    `OP_ADDI: begin
                        alu_result <= register_file[scheduled_thread][dest_reg] + immediate;
                        register_file[scheduled_thread][dest_reg] <= alu_result;
                    end

                    `OP_SUBI: begin
                        alu_result <= register_file[scheduled_thread][dest_reg] - immediate;
                        register_file[scheduled_thread][dest_reg] <= alu_result;
                    end

                    `OP_CMP: begin
                        cmp_flag <= (register_file[scheduled_thread][src1_reg] <
                                     register_file[scheduled_thread][src2_reg]);
                    end

                    `OP_JMP: begin
                        pc[scheduled_thread] <= immediate;
                        pc_increment <= 0;
                    end

                    `OP_JLT: begin
                        if (cmp_flag) begin
                            pc[scheduled_thread] <= immediate;
                            pc_increment <= 0;
                        end
                    end

                    `OP_LDR: begin
                        register_file[scheduled_thread][dest_reg] <= data_mem[immediate];
                    end

                    `OP_STR: begin
                        data_mem[immediate] <= register_file[scheduled_thread][dest_reg];
                    end

                    `OP_HALT: begin
                        next_active_threads[scheduled_thread] <= 0;
                        $display("Thread %0d HALT", scheduled_thread);
                    end

                    default: begin
                        // NOP
                    end
                endcase

                if (pc_increment)
                    pc[scheduled_thread] <= pc[scheduled_thread] + 1;

                $display("T=%0t | Th=%0d | PC=%0d | OP=%b | R%0d R%0d R%0d IMM=%0d",
                         $time, scheduled_thread, pc[scheduled_thread],
                         opcode, dest_reg, src1_reg, src2_reg, immediate);
            end

            active_threads <= next_active_threads;

            if (next_active_threads == 0) begin
                halt <= 1;
                $display("=== ALL THREADS HALTED at %0t ===", $time);
            end
        end
    end

    // Waveform
    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(1, compute_core);
    end

endmodule
