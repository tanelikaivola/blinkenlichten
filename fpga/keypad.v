`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:46:45 10/04/2016 
// Design Name: 
// Module Name:    keypad 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module keypad(
    input [2:0] COL,
    inout [3:0] ROW,
    input [3:0] ROW_asic,
    output reg ERROR = 0
);

wire [3:0] ROW_READ;
IOBUF io0 (.T(~ROW_asic[0]), .I(ROW_asic[0]), .O(ROW_READ[0]), .IO(ROW[0]));
IOBUF io1 (.T(~ROW_asic[1]), .I(ROW_asic[1]), .O(ROW_READ[1]), .IO(ROW[1]));
IOBUF io2 (.T(~ROW_asic[2]), .I(ROW_asic[2]), .O(ROW_READ[2]), .IO(ROW[2]));
IOBUF io3 (.T(~ROW_asic[3]), .I(ROW_asic[3]), .O(ROW_READ[3]), .IO(ROW[3]));

end

endmodule
