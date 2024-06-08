`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:56 03/19/2013 
// Design Name: 
// Module Name:    segdisplay 
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
module segdisplay(
	input wire segclk,		//7-segment clock
	input wire clr,			//asynchronous reset
	output reg [6:0] seg,	//7-segment display LEDs
	output reg [3:0] an,		//7-segment display anode enable,
	input wire tool_on,
	input wire size_sel,
	input wire [2:0] color
	);

// constants for displaying letters on display
parameter N = 7'b1001000;
parameter E = 7'b0000110;
parameter R = 7'b1001100;
parameter P = 7'b0001100;
parameter zero = 7'b1000000;
parameter one = 7'b1111001;
parameter two = 7'b0100100;
parameter three = 7'b0110000;
parameter four = 7'b0011001;
parameter five = 7'b0010010;
parameter six = 7'b0000010;
parameter seven = 7'b1111000;

// Finite State Machine (FSM) states
parameter left = 2'b00;
parameter midleft = 2'b01;
parameter midright = 2'b10;
parameter right = 2'b11;

// state register
reg [1:0] state;

// FSM which cycles though every digit of the display every 2.62ms.
// This should be fast enough to trick our eyes into seeing that
// all four digits are on display at the same time.
always @(posedge segclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		seg <= 7'b1111111;
		an <= 7'b1111;
		state <= left;
	end
	// display the character for the current position
	// and then move to the next state
	else
	begin
		case(state)
			left:
			begin
			    if (tool_on == 1)
			        seg <= one;
			    else
				    seg <= zero;
				an <= 4'b0111;
				state <= midleft;
			end
			midleft:
			begin
			    if (size_sel == 1)
			        seg <= one;
			    else
			        seg <= zero;
				an <= 4'b1011;
				state <= midright;
			end
			midright:
			begin
			    if (color == 3'd1)
			        seg <= one;
			    else if (color == 3'd2)
                    seg <= two;
			    else if (color == 3'd3)
                    seg <= three;
			    else if (color == 3'd4)
                    seg <= four;
                else if (color == 3'd5)
                    seg <= five;
                else if (color == 3'd6)
                    seg <= six;
                else if (color == 3'd0)
                    seg <= zero;
                else
                    seg <= seven;
				an <= 4'b1101;
				state <= right;
			end
			right:
			begin
			    if (color == 3'd0)
                    seg <= E;
                else
				    seg <= P;
				an <= 4'b1110;
				state <= left;
			end
		endcase
	end
end

endmodule
