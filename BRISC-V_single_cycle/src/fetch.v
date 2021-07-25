/** @module : fetch_unit
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

module fetch_unit #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6,
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
                       `ifdef USE_POWER_PINS
                          inout VPWR,
                          inout VGND,
                        `endif
        clock, reset, start,

        PC_select,
        program_address,
        JAL_target,
        JALR_target,
        branch,
        branch_target,

        // In-System Programmer Interface
        isp_address,
        isp_data,
        isp_write,

        instruction,
        inst_PC,
        valid,
        ready,
        report
);

input clock, reset, start;
input [1:0] PC_select;

input [ADDRESS_BITS-1:0] program_address;
input [ADDRESS_BITS-1:0] JAL_target;
input [ADDRESS_BITS-1:0] JALR_target;
input branch;
input [ADDRESS_BITS-1:0] branch_target;

// In-System Programmer Interface
input [ADDRESS_BITS-1:0] isp_address;
input [DATA_WIDTH-1:0] isp_data;
input isp_write;

output [DATA_WIDTH-1:0]   instruction;
output [ADDRESS_BITS-1:0] inst_PC;
output valid;
output ready;

input report;

reg [ADDRESS_BITS-1:0] old_PC;
reg fetch;

reg  [ADDRESS_BITS-1:0] PC_reg;
wire [ADDRESS_BITS-1:0] PC = reset? program_address : PC_reg;
wire [ADDRESS_BITS-1:0] PC_plus4 = PC + 4;

//Adjustment to be word addressable instruction addresses
wire [ADDRESS_BITS-1:0] inst_addr = PC >> 2;
wire [ADDRESS_BITS-1:0] out_addr;
assign inst_PC =  out_addr << 2;

mem_interface #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS)
                    i_mem_interface (
                     .clock(clock),
                     .reset(reset),
                     .read(fetch),
                     .write(isp_write),
                     .write_address(isp_address),
                     .read_address(inst_addr),
                     .in_data(isp_data),
                     .out_addr(out_addr),
                     .out_data(instruction),
                     .valid(valid),
                     .ready(ready),
                     .report(report)
);

always @ (posedge clock) begin
      if (reset) begin 
        fetch        <= 0; 
        PC_reg       <= 0;  
        old_PC       <= 0; 
      end 
      else begin 
        if (start) begin 
            fetch        <= 1;
            PC_reg       <= program_address;            
            old_PC       <= 0; 
        end 
        else begin 
            fetch        <= 1;
            PC_reg       <= (PC_select == 2'b10)?  JAL_target: 
                            (PC_select == 2'b11)?  JALR_target: 
                            ((PC_select == 2'b01)& branch)?  branch_target : PC_plus4;  
            old_PC       <= PC_reg; 
        end
      end
end
/*
reg [31: 0] cycles; 
always @ (posedge clock) begin 
    cycles <= reset? 0 : cycles + 1; 
    if (report)begin
        $display ("------ Core %d Fetch Unit - Current Cycle %d --------", CORE, cycles); 
        $display ("| Prog_Address[%h]", program_address);
        $display ("| Control     [%b]", PC_select);
        $display ("| PC          [%h]", PC);
        $display ("| old_PC      [%h]", old_PC);
        $display ("| PC_plus4    [%h]", PC_plus4);
        $display ("| JAL_target  [%h]", JAL_target);
        $display ("| JALR_target [%h]", JALR_target);
        $display ("| Branch      [%b]", branch);
        $display ("| branchTarget[%h]", branch_target);
        $display ("| Read        [%b]", fetch);
        $display ("| instruction [%h]", instruction);
        $display ("| inst_PC     [%h]", inst_PC);
        $display ("| Ready       [%b]", ready);
        $display ("| Valid       [%b]", valid);
        $display ("----------------------------------------------------------------------");
    end
end
*/
endmodule
