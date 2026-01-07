`include "alu.v"

module alu_tb;

    reg [3:0] opcode;
    reg [`DATA_WIDTH-1:0] operand_a;
    reg [`DATA_WIDTH-1:0] operand_b;

    wire [`DATA_WIDTH-1:0] result;
    wire cmp_flag;

    alu uut (
        .opcode(opcode),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .result(result),
        .cmp_flag(cmp_flag)
    );

    initial begin
        opcode    = 4'b0000;
        operand_a = 16'h0000;
        operand_b = 16'h0000;

        $monitor("T=%0t | op=%b | A=%d | B=%d | R=%d | CMP=%b",
                 $time, opcode, operand_a, operand_b, result, cmp_flag);

        // ADD: 7 + 5 = 12
        #10 opcode = `OP_ADD;  operand_a = 16'd7;  operand_b = 16'd5;
        #10;

        // SUB: 9 - 4 = 5
        #10 opcode = `OP_SUB;  operand_a = 16'd9;  operand_b = 16'd4;
        #10;

        // MUL: 6 * 3 = 18
        #10 opcode = `OP_MUL;  operand_a = 16'd6;  operand_b = 16'd3;
        #10;

        // CMP: 2 < 8 → cmp_flag = 1
        #10 opcode = `OP_CMP;  operand_a = 16'd2;  operand_b = 16'd8;
        #10;

        // ADDI: 10 + 15 = 25
        #10 opcode = `OP_ADDI; operand_a = 16'd10; operand_b = 16'd15;
        #10;

        $finish;
    end
endmodule

