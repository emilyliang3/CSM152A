`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga640x480 
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
module vga640x480(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
//	input wire [1:0] pos,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [3:0] red,	//red vga output
	output reg [3:0] green, //green vga output
	output reg [3:0] blue,	//blue vga output
	input wire [9:0] X_POS,
    input wire [9:0] Y_POS
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter hbp = 310; 	// end of horizontal back porch
parameter hfp = 790; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
//assign X_POS = X_POS + 38;
//assign Y_POS = Y_POS - 241;
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

//wire [1:0] pos;

//assign pos = {550,271};
// Define color lists
reg [3:0] color_r [0:7];   // Red color list
reg [3:0] color_g [0:7];   // Green color list
reg [3:0] color_b [0:7];   // Blue color list

// Initialize color lists with desired colors
initial begin
    //white
    color_r[0] = 4'b1111;  // Red
    color_g[0] = 4'b1111;  // Green
    color_b[0] = 4'b1111;  // Blue

    //red
    color_r[1] = 4'b1111;  // Red
    color_g[1] = 4'b0000;  // Green
    color_b[1] = 4'b0000;  // Blue

    //orange
    color_r[2] = 4'b1111;  // Red
    color_g[2] = 4'b1000;  // Green
    color_b[2] = 4'b0000;  // Blue
    
    //yellow
    color_r[3] = 4'b1111;  // Red
    color_g[3] = 4'b1111;  // Green
    color_b[3] = 4'b0000;  // Blue
    
    //green
    color_r[4] = 4'b0000;  // Red
    color_g[4] = 4'b1111;  // Green
    color_b[4] = 4'b0000;  // Blue
    
    //blue
    color_r[5] = 4'b0000;  // Red
    color_g[5] = 4'b0000;  // Green
    color_b[5] = 4'b1111;  // Blue
    
    //purple
    color_r[6] = 4'b1100;  // Red
    color_g[6] = 4'b0000;  // Green
    color_b[6] = 4'b1100;  // Blue
    
    //black
    color_r[7] = 4'b0000;  // Red
    color_g[7] = 4'b0000;  // Green
    color_b[7] = 4'b0000;  // Blue
end

// block ram
reg [3:0] buffer_red [0:479][0:479];
reg [3:0] buffer_green [0:479][0:479];
reg [3:0] buffer_blue [0:479][0:479];
//genvar i, j;
//generate
//    // Initialize buffer_red
//    for (i = 0; i < 480; i = i + 1) begin : INIT_BUFFER_RED
//        for (j = 0; j < 480; j = j + 1) begin : INIT_BUFFER_RED_COL
//            initial begin
//                buffer_red[i][j] = color_r[0]; // Example value, replace with your desired initialization value
//            end
//        end
//    end
//        // Initialize buffer_green
//    for (i = 0; i < 480; i = i + 1) begin : INIT_BUFFER_GREEN
//        for (j = 0; j < 480; j = j + 1) begin : INIT_BUFFER_GREEN_COL
//            initial begin
//                buffer_green[i][j] = color_g[0]; // Example value, replace with your desired initialization value
//            end
//        end
//    end
    
//    // Initialize buffer_blue
//    for (i = 0; i < 480; i = i + 1) begin : INIT_BUFFER_BLUE
//        for (j = 0; j < 480; j = j + 1) begin : INIT_BUFFER_BLUE_COL
//            initial begin
//                buffer_blue[i][j] = color_b[0]; // Example value, replace with your desired initialization value
//            end
//        end
//    end
//    endgenerate
// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
    
	if (vc >= vbp && vc < vfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		// display white bar
        if (hc >= hbp && hc < hfp)
		begin
            red = buffer_red[hc - 310][vc - 31];
            green = buffer_green[hc - 310][vc - 31];
            blue = buffer_blue[hc - 310][vc - 31];

		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
	if (vc >= Y_POS - 241 - 5 && vc < Y_POS - 241 +5 && hc >= X_POS + 38 - 5 && hc < X_POS + 38 +5)
    begin
        buffer_red[hc - 310][vc - 31] = color_r[2];
        buffer_red[hc - 310][vc - 31] = color_g[2];
        buffer_red[hc - 310][vc - 31] = color_b[2];
    end
end

endmodule
