/** @module : ALU
 *  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory

 *  Copyright (c) 2018 BRISC-V (ASCS/ECE/BU)
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */

module ALU #(parameter DATA_WIDTH = 32)(
        ALU_Control,
        operand_A, operand_B,
        ALU_result, zero, branch
);
input [5:0] ALU_Control;
input [DATA_WIDTH-1:0]  operand_A ;
input [DATA_WIDTH-1:0]  operand_B ;
output zero, branch;
output [DATA_WIDTH-1:0] ALU_result;


wire signed [DATA_WIDTH-1:0] signed_operand_A;
wire signed [DATA_WIDTH-1:0] signed_operand_B;

wire [4:0] shamt = operand_B [4:0];     // I_immediate[4:0];

// wires for signed operations
wire [(DATA_WIDTH*2)-1:0] arithmetic_right_shift_double;
wire [DATA_WIDTH-1:0] arithmetic_right_shift;
wire signed [DATA_WIDTH-1:0] signed_less_than;
wire signed [DATA_WIDTH-1:0] signed_greater_than_equal;

assign signed_operand_A = operand_A;
assign signed_operand_B = operand_B;

assign zero   = (ALU_result==0);
assign branch = ((ALU_Control[4:3] == 2'b10) & (ALU_result == 1'b1))? 1'b1 : 1'b0;

// Signed Operations
assign arithmetic_right_shift_double = ({ {DATA_WIDTH{operand_A[DATA_WIDTH-1]}}, operand_A }) >> shamt;
assign arithmetic_right_shift = arithmetic_right_shift_double[DATA_WIDTH-1:0];
assign signed_less_than = signed_operand_A < signed_operand_B;
assign signed_greater_than_equal = signed_operand_A >= signed_operand_B;

assign ALU_result =
            (ALU_Control == 6'b000_000)? operand_A + operand_B:                /* ADD, ADDI*/
            (ALU_Control == 6'b001_000)? operand_A - operand_B:                /* SUB */
            (ALU_Control == 6'b000_100)? operand_A ^ operand_B:                /* XOR, XORI*/
            (ALU_Control == 6'b000_110)? operand_A | operand_B:                /* OR, ORI */
            (ALU_Control == 6'b000_111)? operand_A & operand_B:                /* AND, ANDI */
            (ALU_Control == 6'b000_010)? signed_less_than:                     /* SLT, SLTI */
            (ALU_Control == 6'b000_011)? operand_A < operand_B:                /* SLTU, SLTIU */
            (ALU_Control == 6'b000_001)? operand_A << shamt:                   /* SLL, SLLI => 0's shifted in from right */
            (ALU_Control == 6'b000_101)? operand_A >> shamt:                   /* SRL, SRLI => 0's shifted in from left */
            (ALU_Control == 6'b001_101)? arithmetic_right_shift:               /* SRA, SRAI => sign bit shifted in from left */
            (ALU_Control == 6'b011_111)? operand_A:                            /* operand_A = PC+4 for JAL   and JALR */
            (ALU_Control == 6'b010_000)? operand_A == operand_B:               /* BEQ */
            (ALU_Control == 6'b010_001)? operand_A != operand_B:               /* BNE */
            (ALU_Control == 6'b010_100)? signed_less_than:                     /* BLT */
            (ALU_Control == 6'b010_101)? signed_greater_than_equal:            /* BGE */
            (ALU_Control == 6'b010_110)? operand_A < operand_B:                /* BLTU */
            (ALU_Control == 6'b010_111)? operand_A >= operand_B:               /* BGEU */
            {DATA_WIDTH{1'b0}};
endmodule
