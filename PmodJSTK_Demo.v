`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineer: Josh Sackos
// 
// Create Date:    07/11/2012
// Module Name:    PmodJSTK_Demo 
// Project Name: 	 PmodJSTK_Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: This is a demo for the Digilent PmodJSTK. Data is sent and received
//					 to and from the PmodJSTK at a frequency of 5Hz, and positional 
//					 data is displayed on the seven segment display (SSD). The positional
//					 data of the joystick ranges from 0 to 1023 in both the X and Y
//					 directions. Only one coordinate can be displayed on the SSD at a
//					 time, therefore switch SW0 is used to select which coordinate's data
//	   			 to display. The status of the buttons on the PmodJSTK are
//					 displayed on LD2, LD1, and LD0 on the Nexys3. The LEDs will
//					 illuminate when a button is pressed. Switches SW2 and SW1 on the
//					 Nexys3 will turn on LD1 and LD2 on the PmodJSTK respectively. Button
//					 BTND on the Nexys3 is used for resetting the demo. The PmodJSTK
//					 connects to pins [4:1] on port JA on the Nexys3. SPI mode 0 is used
//					 for communication between the PmodJSTK and the Nexys3.
//
//					 NOTE: The digits on the SSD may at times appear to flicker, this
//						    is due to small pertebations in the positional data being read
//							 by the PmodJSTK's ADC. To reduce the flicker simply reduce
//							 the rate at which the data being displayed is updated.
//
// Revision History: 
// 						Revision 0.01 - File Created (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////


// ============================================================================== 
// 										  Define Module
// ==============================================================================
module PmodJSTK_Demo(
    CLK,
    RST,
    MISO,
	 SW,
    SS,
    MOSI,
    SCLK,
    LED,
	 AN,
	 SEG
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
			input CLK;					// 100Mhz onboard clock
			input RST;					// Button D
			input MISO;					// Master In Slave Out, Pin 3, Port JA
			input [2:0] SW;			// Switches 2, 1, and 0
			output SS;					// Slave Select, Pin 1, Port JA
			output MOSI;				// Master Out Slave In, Pin 2, Port JA
			output SCLK;				// Serial Clock, Pin 4, Port JA
			output [2:0] LED;			// LEDs 2, 1, and 0
			output [3:0] AN;			// Anodes for Seven Segment Display
			output [6:0] SEG;			// Cathodes for Seven Segment Display
//            output [39:0] cursor_pos;

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
			wire SS;						// Active low
			wire MOSI;					// Data transfer from master to slave
			wire SCLK;					// Serial clock that controls communication
			reg [2:0] LED;				// Status of PmodJSTK buttons displayed on LEDs
			wire [3:0] AN;				// Anodes for Seven Segment Display
			wire [6:0] SEG;			// Cathodes for Seven Segment Display

			// Holds data to be sent to PmodJSTK
			wire [7:0] sndData;

			// Signal to send/receive data to/from PmodJSTK
			wire sndRec;

			// Data read from PmodJSTK
			wire [39:0] jstkData;

			// Signal carrying output data that user selected
			wire [9:0] posData;
			
//			reg [39:0] cursor_pos_reg = 40'b0;
			reg [9:0] x_pos_reg = 10'd500;
			reg [9:0] x_pos_raw = 10'd0;
			reg [9:0] y_pos_reg = 10'd500;
			reg [9:0] y_pos_raw = 10'd0;

	// ===========================================================================
	// 										Implementation
	// ===========================================================================


			//-----------------------------------------------
			//  	  			PmodJSTK Interface
			//-----------------------------------------------
			PmodJSTK PmodJSTK_Int(
					.CLK(CLK),
					.RST(RST),
					.sndRec(sndRec),
					.DIN(sndData),
					.MISO(MISO),
					.SS(SS),
					.SCLK(SCLK),
					.MOSI(MOSI),
					.DOUT(jstkData)
			);
			


			//-----------------------------------------------
			//  		Seven Segment Display Controller
			//-----------------------------------------------
			ssdCtrl DispCtrl(
					.CLK(CLK),
					.RST(RST),
					.DIN(posData),
					.AN(AN),
					.SEG(SEG)
			);
			
			

			//-----------------------------------------------
			//  			 Send Receive Generator
			//-----------------------------------------------
			ClkDiv_5Hz genSndRec(
					.CLK(CLK),
					.RST(RST),
					.CLKOUT(sndRec)
			);
			
            always @(posedge CLK) begin
                x_pos_raw <= {jstkData[9:8], jstkData[23:16]};
                if (x_pos_raw < 470) begin
//                    if ((10'd470 - x_pos_raw) >= x_pos_reg)
//                        x_pos_reg <= 10'b0;
//                    else
//                        x_pos_reg <= x_pos_reg - (10'd470 - x_pos_raw);
                        if (x_pos_reg > 0)
                            x_pos_reg <= x_pos_reg - 10'd1;
                end
                if (x_pos_raw > 530) begin
//                    if ((x_pos_raw - 10'd530) >= (10'd1023 - x_pos_reg))
//                        x_pos_reg <= 10'd1023;
//                    else
//                        x_pos_reg <= x_pos_reg + (x_pos_raw - 10'd530);
                    if (x_pos_reg <1023)
                        x_pos_reg <= x_pos_reg + 10'd1;
                end
                
                y_pos_raw <= {jstkData[25:24], jstkData[39:32]};
                if (y_pos_raw < 470) begin
//                    if ((10'd470 - y_pos_raw) >= y_pos_reg)
//                        y_pos_reg <= 10'b0;
//                    else
                    if (y_pos_reg > 0)
                        y_pos_reg <= y_pos_reg - 10'd1;
                end
                if (y_pos_raw > 530) begin
//                    if ((y_pos_raw - 10'd530) >= (10'd1023 - y_pos_reg))
//                        y_pos_reg <= 10'd1023;
//                    else
                    if (y_pos_reg < 1023)
                        y_pos_reg <= y_pos_reg + 10'd1;
                end
            end

			// Use state of switch 0 to select output of X position or Y position data to SSD
			assign posData = (SW[0] == 1'b1) ? x_pos_reg : y_pos_reg;

			// Data to be sent to PmodJSTK, lower two bits will turn on leds on PmodJSTK
			assign sndData = {8'b100000, {SW[1], SW[2]}};

			// Assign PmodJSTK button status to LED[2:0]
			always @(sndRec or RST or jstkData) begin
					if(RST == 1'b1) begin
//					        x_pos_reg <= 10'd500;
//					        y_pos_reg <= 10'd500;
							LED <= 3'b000;
					end
					else begin
							LED <= {jstkData[1], {jstkData[2], jstkData[0]}};
					end
			end

endmodule
