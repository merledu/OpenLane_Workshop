/** @module : memory
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
 
module memory_unit #(parameter CORE = 0, DATA_WIDTH = 32, INDEX_BITS = 6, 
                     OFFSET_BITS = 3, ADDRESS_BITS = 20)(
                         `ifdef USE_POWER_PINS
                          inout VPWR,
                          inout VGND,
                        `endif
        clock, reset, 
        load, store,
        address, 
        store_data,
        data_addr, 
        load_data,
        valid, 
        ready, 
        report
); 

input clock, reset; 
input load, store;
input [ADDRESS_BITS-1:0] address;
input [DATA_WIDTH-1:0]   store_data;
input report;

output [ADDRESS_BITS-1:0] data_addr;
output [DATA_WIDTH-1:0]   load_data;
output valid; 
output ready;  

mem_interface #(CORE, DATA_WIDTH, INDEX_BITS, OFFSET_BITS, ADDRESS_BITS)  
                    d_mem_interface (
                     .clock(clock), 
                     .reset(reset),
                     .read(load), 
                     .write(store), 
                     .read_address(address), 
                     .write_address(address), 
                     .in_data(store_data), 
                     .out_addr(data_addr),
                     .out_data(load_data), 
                     .valid(valid), 
                     .ready(ready),
                     .report(report)
);
/*
reg [31: 0] cycles; 
always @ (posedge clock) begin 
    cycles <= reset? 0 : cycles + 1; 
    if (report)begin
        $display ("------ Core %d Memory Unit - Current Cycle %d -------", CORE, cycles); 
        $display ("| Address     [%h]", address);
        $display ("| Load        [%b]", load); 
        $display ("| Data Address[%h]", data_addr);
        $display ("| Load Data   [%h]", load_data);
        $display ("| Store       [%b]", store); 
        $display ("| Store Data  [%h]", store_data);
        $display ("| Ready       [%b]", ready);
        $display ("| Valid       [%b]", valid);
        $display ("----------------------------------------------------------------------");
    end
end
*/
endmodule
