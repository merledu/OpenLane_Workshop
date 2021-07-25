/*  @author : Adaptive & Secure Computing Systems (ASCS) Laboratory
 
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
 *
 *  
 */

/*********************************************************************************
*                              control_unit.v                                    *
*********************************************************************************/


module control_unit #(parameter CORE = 0)(
    clock, reset,
    opcode,
    branch_op, memRead, 
    memtoReg, ALUOp, 
    next_PC_sel, 
    operand_A_sel, operand_B_sel,
    extend_sel,
    memWrite, regWrite, 
    report
);

    input clock;
    input reset;
    input [6:0] opcode;
        
    output branch_op;
    output memRead; 
    output memtoReg; 
    output [2:0] ALUOp; 
    output memWrite;
    output [1:0] next_PC_sel;
    output [1:0] operand_A_sel; 
    output operand_B_sel; 
    output [1:0] extend_sel; 
    output regWrite; 
    input  report;
    
    localparam [6:0]R_TYPE  = 7'b0110011, 
                    I_TYPE  = 7'b0010011, 
                    STORE   = 7'b0100011,
                    LOAD    = 7'b0000011,
                    BRANCH  = 7'b1100011,
                    JALR    = 7'b1100111,
                    JAL     = 7'b1101111,
                    AUIPC   = 7'b0010111,
                    LUI     = 7'b0110111,
                    FENCES  = 7'b0001111,
                    SYSCALL = 7'b1110011;

    assign regWrite      = ((opcode == R_TYPE) | (opcode == I_TYPE) | (opcode == LOAD)
                            | (opcode == JALR) | (opcode == JAL) | (opcode == AUIPC) 
                            | (opcode == LUI))? 1 : 0; 
    assign memWrite      = (opcode == STORE)?   1 : 0; 
    assign branch_op     = (opcode == BRANCH)?  1 : 0; 
    assign memRead       = (opcode == LOAD)?    1 : 0; 
    assign memtoReg      = (opcode == LOAD)?    1 : 0; 

    assign ALUOp         = (opcode == R_TYPE)?  3'b000 : 
                           (opcode == I_TYPE)?  3'b001 :
                           (opcode == STORE)?   3'b101 :   
                           (opcode == LOAD)?    3'b100 : 
                           (opcode == BRANCH)?  3'b010 : 
                           ((opcode == JALR)  | (opcode == JAL))? 3'b011 :
                           ((opcode == AUIPC) | (opcode == LUI))? 3'b110 : 0; 
    
    assign operand_A_sel = (opcode == AUIPC)?  2'b01 : 
                           (opcode == LUI)?    2'b11 : 
                           ((opcode == JALR)  | (opcode == JAL))?  2'b10 : 0; 
                           
    assign operand_B_sel = ((opcode == I_TYPE) | (opcode == STORE)| 
                           (opcode == LOAD) | (opcode == AUIPC) | 
                           (opcode == LUI))? 1 : 0; 

    assign extend_sel    = ((opcode == I_TYPE)  | (opcode == LOAD))?  2'b00 : 
                           (opcode == STORE)?   2'b01  : 
                           ((opcode == AUIPC) | (opcode == LUI))? 2'b10 : 0;

    assign next_PC_sel   = (opcode == BRANCH)?  2'b01 : 
                           (opcode == JAL)?     2'b10 : 
                           (opcode == JALR)?    2'b11 : 0; 
/*    
reg [31: 0] cycles; 
always @ (posedge clock) begin 
    cycles <= reset? 0 : cycles + 1; 
    if (report)begin
        $display ("------ Core %d Control Unit - Current Cycle %d ------", CORE, cycles); 
        $display ("| Opcode      [%b]", opcode);
        $display ("| Branch_op   [%b]", branch_op);
        $display ("| memRead     [%b]", memRead);
        $display ("| memtoReg    [%b]", memtoReg);
        $display ("| memWrite    [%b]", memWrite);
        $display ("| RegWrite    [%b]", regWrite);
        $display ("| ALUOp       [%b]", ALUOp);
        $display ("| Extend_sel  [%b]", extend_sel);
        $display ("| ALUSrc_A    [%b]", operand_A_sel);
        $display ("| ALUSrc_B    [%b]", operand_B_sel);
        $display ("| Next PC     [%b]", next_PC_sel);
        $display ("----------------------------------------------------------------------");
    end
end
*/
endmodule
