`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:46:40 09/28/2016 
// Design Name: 
// Module Name:    test 
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

// 8917 8174 1715 1136

module test(
    input CLK_IN,
    output [7:0] LEDS,
    output [7:0] DEBUG,
	 output reg WS,
	 output OPEN,
	 
	 input [2:0] COL,
	 inout [3:0] ROW,
	 
	 input [3:0] SW
    );

localparam CLKDIV = 20;
wire [7:0] BRT;
wire CLK; (* BUFG = "clk" *)
reg RESET = 1;

wire [255:0] W;
reg [255:0] W2 = 256'b0;
wire WS_asic;
wire ERROR;

reg [8:0] startup = 0;
reg [CLKDIV:0] counter = 0;

wire [3:0] ROW_asic;

custom challenge (
    .RESET(SW[0]), 
    .CLK(CLK),
    .COL(COL),
    .ROW(ROW_asic),
    .OPEN(OPEN), 
    .W(W),
    .DEBUG(DEBUG[6:0])
    );

ws2812b display (
    .RESET(RESET), 
    .W(W2), 
	 .CLK50(CLK_IN),
    .WS(WS_asic),
//    .DEBUG(DEBUG[7:0])
	 .OPENER(OPENER),
	 .ERROR(ERROR)
    );

sr_timer #(200) success (
    .S(OPEN),
    .R(RESET),
    .CLK(CLK),
	 .OUT(OPENER)
);

keypad keypad (
    .COL(COL), 
    .ROW(ROW), 
    .ROW_asic(ROW_asic), 
    .ERROR(ERROR)
    );

always @(posedge CLK_IN) begin
	counter <= counter + 1;
end

wire CLK2;
assign CLK = counter[CLKDIV-1];
assign CLK2 = counter[CLKDIV-3];

always @(negedge CLK2) begin
	W2 <= W;
end

always @(posedge CLK_IN)
  if (startup < 8'hffff) startup <= startup + 1;  // count to 255d, then stop
  else RESET <= 0;  // deassert reset at terminal count

assign LEDS = DEBUG | {8{OPENER}};
assign DEBUG[7] = WS;

always @(*) WS = WS_asic;

endmodule
