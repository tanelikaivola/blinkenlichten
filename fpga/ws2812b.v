`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    01:44:44 09/29/2016 
// Design Name: 
// Module Name:    ws2812b 
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

module ws2812b(
    input RESET,
    input [LEDS-1:0] W,
    input CLK50, // 50MHz = 0.02us
	 input OPENER,
	 input ERROR,
    output reg WS,
	 output reg[2:0] STATE,
	 output [7:0] DEBUG
);

parameter LEDS = 8*32;

localparam  INIT = 3'd0,
				RST = 3'd1, // NEXT PIXEL
				TH = 3'd2,
				TQ = 3'd3,
				TL = 3'd4,
				STEP = 3'd6;

localparam  dINIT = 4000,
				dRST = 2500, // NEXT PIXEL, default 2500 = 50us
				dTH = 17, // 17
				dTQ = 26, // 26
				dTL = 17, // 17
				dSTEP = 1; // 1

reg [11:0] COUNTER = 0; // 2500 ticks = RESET, 20 = T0H, 40 = T1H, 42.5 = T0L, 22.5 = T1L
reg [11:0] DELAY = 0;

wire [7:0] PIXEL;
wire [7:0] BIT;
wire [7:0] NS;
wire pRST;
assign pRST = (STATE == RST);
pixel_bit_counter PBC (
    .CLK(CLK50),
    .RST(pRST),
    .PIXEL(PIXEL), 
    .BIT(BIT),
	 .NS(NS),
	 .DONE(DONE)
    );
defparam PBC.PIXELS = LEDS;
defparam PBC.NSS = dTH + dTQ + dTL + 3;

wire [7:0] mem_a;
wire [23:0] mem_d;
wire mem_we;

wire [7:0] dpra;
wire [23:0] dpo;
displaymem MEM (
  .a(0), // input [7 : 0] a
  .d(0), // input [23 : 0] d
  .clk(CLK50), // input clk
  .we(0), // input we

  .dpra(dpra), // input [7 : 0] dpra
  .qdpo_clk(CLK50), // input qdpo_clk
  .dpo(dpo) // output [23 : 0] dpo
);

assign dpra = PIXEL;

reg[2:0] NextState;
reg[11:0] NextDelay;

always @(posedge CLK50) begin
	if (RESET) begin
		COUNTER <= 0;
		STATE <= INIT;
		DELAY <= dINIT;
	end
	else if (COUNTER >= DELAY) begin
		COUNTER <= 0;
		if(NextState == STEP) begin
			STATE <= TH;
			DELAY <= dTH;
		end else begin
			STATE <= NextState;
			DELAY <= NextDelay;
		end
	end
	else COUNTER <= COUNTER + 1;
end

always @(posedge CLK50) begin
	case (STATE)
		INIT: WS <= 0;
		RST: WS <= 0;
		TH: WS <= 1;
		TQ: if(!OPENER) WS <= (ERROR & (BIT==3 | BIT == 10) ) | (~ERROR & (W[PIXEL] & dpo[BIT]) | (((BIT%8)==7) & dpo[BIT])); // Colors from mem
			else WS <= (BIT==2); // Green, somewhat brighter..*/
		TL: WS <= 0;
	endcase
end


always @(*) begin
	NextState = STATE;
	NextDelay = DELAY;
	
	case (STATE)
		INIT: begin
			NextState = RST;
			NextDelay = dRST;
		end
		TH: begin
			NextState = TQ;
			NextDelay = dTQ;
		end
		TQ: begin
			NextState = TL;
			NextDelay = dTL;
		end
		TL: begin
			if(DONE) begin
				NextState = RST;
				NextDelay = dRST;
			end
			else NextState = STEP;
		end
		RST: begin
			NextState = STEP;
		end
	endcase
end

endmodule
