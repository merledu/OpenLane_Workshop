/** @module : execute
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
 
// 32-bit Exection 
module execution_unit #(parameter CORE = 0, DATA_WIDTH = 32, ADDRESS_BITS = 20)(
        clock, reset, 
        ALU_Operation, 
        funct3, funct7,
        PC, ALU_ASrc, ALU_BSrc, 
        branch_op, 
        regRead_1, regRead_2, 
        extend,
        ALU_result, zero, branch, 
        JALR_target,    
        
        report
);
input  clock; 
input  reset;  
input [2:0] ALU_Operation; 
input [6:0] funct7; 
input [2:0] funct3;
input [ADDRESS_BITS-1:0]  PC;
input [1:0] ALU_ASrc; 
input ALU_BSrc;
input branch_op;
input [DATA_WIDTH-1:0]  regRead_1 ;
input [DATA_WIDTH-1:0]  regRead_2 ; 
input [DATA_WIDTH-1:0]  extend;

output zero, branch; 
output [DATA_WIDTH-1:0] ALU_result;
output [ADDRESS_BITS-1:0] JALR_target;

input report; 
 
wire [5:0] ALU_Control = (ALU_Operation == 3'b011)? 
                         6'b011_111 :      //pass for JAL and JALR
                         (ALU_Operation == 3'b010)? 
                         {3'b010,funct3} : //branches
                         
                         //R Type instructions
                         ({ALU_Operation, funct7} == {3'b000, 7'b0000000})? 
                         {3'b000,funct3} : 
                         ({ALU_Operation, funct7} == {3'b000, 7'b0100000})? 
                         {3'b001,funct3} :
                         (ALU_Operation == 3'b000)?                  
                         {3'b000,funct3} :
                          
                         //I Type instructions
                         ({ALU_Operation, funct3, funct7} == {3'b001, 3'b101, 7'b0000000})? 
                         {3'b000,funct3} : 
                         ({ALU_Operation, funct3, funct7} == {3'b001, 3'b101, 7'b0100000})? 
                         {3'b001,funct3} : 
                         ({ALU_Operation, funct3} == {3'b001, 3'b101})? 
                         {3'b000,funct3} : 
                         (ALU_Operation == 3'b001)?                  
                         {3'b000,funct3} : 
                         6'b000_000;      //addition
                         
wire [DATA_WIDTH-1:0]  operand_A  =  (ALU_ASrc == 2'b01)? PC : 
                                     (ALU_ASrc == 2'b10)? (PC + 4) : regRead_1;
wire [DATA_WIDTH-1:0]  operand_B  =   ALU_BSrc? extend : regRead_2;

wire ALU_branch;
assign branch  = (ALU_branch & branch_op)? 1 : 0; 

ALU #(DATA_WIDTH) EU (
        .ALU_Control(ALU_Control), 
        .operand_A(operand_A), 
        .operand_B(operand_B), 
        .ALU_result(ALU_result), 
        .zero(zero), 
        .branch(ALU_branch)
); 

/* Only JALR Target. JAL happens in the decode unit*/
assign JALR_target        = {regRead_1 + extend} & 32'hffff_fffe; 
/*
reg [31: 0] cycles; 
always @ (posedge clock) begin 
    cycles <= reset? 0 : cycles + 1; 
    if (report)begin
        $display ("------ Core %d Execute Unit - Current Cycle %d ------", CORE, cycles); 
        $display ("| ALU_Operat  [%b]", ALU_Operation);
        $display ("| funct7      [%b]", funct7); 
        $display ("| funct3      [%b]", funct3);
        $display ("| ALU_Control [%b]", ALU_Control);
        $display ("| operand_A   [%h]", operand_A); 
        $display ("| operand_B   [%h]", operand_B);
        $display ("| Zero        [%b]", zero);
        $display ("| Branch      [%b]", branch);
        $display ("| ALU_result  [%h]", ALU_result);
        $display ("| JALR_taget  [%h]", JALR_target);
        $display ("----------------------------------------------------------------------");
    end
end
*/
endmodule
