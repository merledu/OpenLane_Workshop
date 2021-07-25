/** @module : RISC_V_Core
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
 *
 */

 /*
  Modules will be used for ASIC: RISC_V_Core, ALU, control_unit, decode, execute, fetch,
                                 mem_interface, memory, regFile, writeback, DFFRAM 
 */

module RISC_V_Core #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6,
                     OFFSET_BITS = 3, ADDRESS_BITS = 8)(
`ifdef USE_POWER_PINS
  inout VPWR,
  inout VGND,
`endif
    clock,
    reset,
    start,
    prog_address,

    from_peripheral,
    from_peripheral_data,
    from_peripheral_valid,
    to_peripheral,
    to_peripheral_data,
    to_peripheral_valid,

    // In-System Programmer Interface
    isp_address,
    isp_data,
    isp_write,

    current_PC,

    report
);

input  clock, reset, start;
input  [ADDRESS_BITS - 1:0]  prog_address;

// For I/O funstions
input  [1:0]   from_peripheral;
input  [31:0]  from_peripheral_data; 
input          from_peripheral_valid;
output [1:0]   to_peripheral;
output [31:0]  to_peripheral_data; 
output         to_peripheral_valid;

// In-System Programmer Interface
input [ADDRESS_BITS-1:0] isp_address;
input [DATA_WIDTH-1:0] isp_data;
input isp_write;

output [31:0]  current_PC;

input  report; // performance reporting

wire [31:0]  instruction;
wire [ADDRESS_BITS-1: 0] inst_PC;
wire i_valid, i_ready;
wire d_valid, d_ready;

wire [ADDRESS_BITS-1: 0] JAL_target;   
wire [ADDRESS_BITS-1: 0] JALR_target;   
wire [ADDRESS_BITS-1: 0] branch_target; 

wire  write;
wire  [4:0]  write_reg;    
wire  [DATA_WIDTH-1:0] write_data; 

wire [DATA_WIDTH-1:0]  rs1_data; 
wire [DATA_WIDTH-1:0]  rs2_data;
wire [4:0]   rd;  

wire [6:0]  opcode;
wire [6:0]  funct7; 
wire [2:0]  funct3;

wire memRead; 
wire memtoReg;
wire [2:0] ALUOp;
wire branch_op;
wire [1:0] next_PC_sel;
wire [1:0] operand_A_sel; 
wire operand_B_sel; 
wire [1:0] extend_sel; 
wire [DATA_WIDTH-1:0]  extend_imm;
    
wire memWrite;
wire regWrite;

wire branch;
wire [DATA_WIDTH-1:0]   ALU_result; 
wire [ADDRESS_BITS-1:0] generated_addr = ALU_result; // the case the address is not 32-bit

wire ALU_branch; 
wire zero; // Have not done anything with this signal

wire [DATA_WIDTH-1:0]    memory_data;
wire [ADDRESS_BITS-1: 0] memory_addr; // To use to check the address coming out the memory stage

reg  [1:0]   to_peripheral;
reg  [31:0]  to_peripheral_data; 
reg          to_peripheral_valid;

assign current_PC = inst_PC;

fetch_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) IF (
        `ifdef USE_POWER_PINS
          .VPWR(VPWR),
          .VGND(VGND),
        `endif
        .clock(clock),
        .reset(reset),
        .start(start),

        .PC_select(next_PC_sel),
        .program_address(prog_address),
        .JAL_target(JAL_target),
        .JALR_target(JALR_target),
        .branch(branch),
        .branch_target(branch_target),

        .instruction(instruction),
        .inst_PC(inst_PC),
        .valid(i_valid),
        .ready(i_ready),

        .isp_address(isp_address),
        .isp_data(isp_data),
        .isp_write(isp_write),

        .report(report)
);

decode_unit #(CORE, ADDRESS_BITS) ID (
        .clock(clock), 
        .reset(reset),  
        
        .instruction(instruction), 
        .PC(inst_PC),
        .extend_sel(extend_sel),
        .write(write), 
        .write_reg(write_reg), 
        .write_data(write_data), 
      
        .opcode(opcode), 
        .funct3(funct3), 
        .funct7(funct7),
        .rs1_data(rs1_data), 
        .rs2_data(rs2_data), 
        .rd(rd), 
 
        .extend_imm(extend_imm),
        .branch_target(branch_target), 
        .JAL_target(JAL_target),
        
        .report(report)
); 

control_unit #(CORE) CU (
        .clock(clock), 
        .reset(reset),   
        
        .opcode(opcode),
        .branch_op(branch_op), 
        .memRead(memRead), 
        .memtoReg(memtoReg), 
        .ALUOp(ALUOp), 
        .memWrite(memWrite), 
        .next_PC_sel(next_PC_sel), 
        .operand_A_sel(operand_A_sel), 
        .operand_B_sel(operand_B_sel),
        .extend_sel(extend_sel),        
        .regWrite(regWrite), 
        
        .report(report)
);

execution_unit #(CORE, DATA_WIDTH, ADDRESS_BITS) EU (
        .clock(clock), 
        .reset(reset), 
        
        .ALU_Operation(ALUOp), 
        .funct3(funct3), 
        .funct7(funct7),
        .branch_op(branch_op),
        .PC(inst_PC), 
        .ALU_ASrc(operand_A_sel),
        .ALU_BSrc(operand_B_sel),
        .regRead_1(rs1_data), 
        .regRead_2(rs2_data), 
        .extend(extend_imm), 
        .ALU_result(ALU_result), 
        .zero(zero), 
        .branch(branch),
        .JALR_target(JALR_target),
        
        .report(report)
);

memory_unit #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS) MU (
        `ifdef USE_POWER_PINS
          .VPWR(VPWR),
          .VGND(VGND),
        `endif
        .clock(clock), 
        .reset(reset), 
        
        .load(memRead), 
        .store(memWrite),
        .address(generated_addr), 
        .store_data(rs2_data),
        .data_addr(memory_addr), 
        .load_data(memory_data),
        .valid(d_valid),
        .ready(d_ready),
        
        .report(report)
); 

writeback_unit #(CORE, DATA_WIDTH) WB (
        .clock(clock), 
        .reset(reset),   
        
        .opWrite(regWrite),
        .opSel(memRead), 
        .opReg(rd), 
        .ALU_Result(ALU_result), 
        .memory_data(memory_data), 
        .write(write), 
        .write_reg(write_reg), 
        .write_data(write_data), 
        
        .report(report)
); 

//Registers s1-s11 [$9,$x18-$x27] are saved across calls ... Using s1-s9 [$9,x18-x25] for final results
always @ (posedge clock) begin        
         if (write && (((write_reg >= 18) && (write_reg <= 25))|| (write_reg == 9)))  begin
              to_peripheral       <= 0;
              to_peripheral_data  <= write_data; 
              to_peripheral_valid <= 1;
              //$display (" Core [%d] Register [%d] Value = %d", CORE, write_reg, write_data);
         end
         else to_peripheral_valid <= 0;  
end
    
endmodule
