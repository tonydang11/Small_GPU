// alu.v
`include "definitions.vh"


module alu (
    input [3:0] opcode,
    input [`DATA_WIDTH-1:0] operand_a,
    input [`DATA_WIDTH-1:0] operand_b,
    output reg [`DATA_WIDTH-1:0] result,
    output reg cmp_flag
);
    always @(*) begin
        cmp_flag = 0;
        result = 0;
        case (opcode)
            `OP_ADD: result = operand_a + operand_b;
            `OP_SUB: result = operand_a - operand_b;
            `OP_MUL: result = operand_a * operand_b;
            `OP_CMP: begin
                if (operand_a < operand_b)
                    cmp_flag = 1;
                else
                    cmp_flag = 0;
            end
            // For ADDI/SUBI, the control logic (compute_core) will feed immediate into operand_b
            // and use OP_ADD/OP_SUB opcode, or we can add specific cases if needed.
            // But reusing ADD/SUB is cleaner if opcode is mapped. 
            // However, since definitions.vh has specific opcodes ADDI/SUBI, let's support them transparently
            // treating them same as ADD/SUB here?
            // Actually, in compute_core, I wrote: 
            // `OP_ADDI: alu_result = ... + immediate`
            // If we use this ALU module externally, we might want it to handle OP_ADDI too.
            // But usually ALU just adds A and B. 
            // Let's keep it simple: ALU takes A and B. It adds them if opcode is ADD or ADDI.
            `OP_ADDI: result = operand_a + operand_b;
            `OP_SUBI: result = operand_a - operand_b;
            
            default: result = 0;
        endcase
    end
endmodule