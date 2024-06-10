`timescale 1ns / 1ps

// CREDIT FOR THIS FILE GOES TO DEMO VGA CODE FROM BRUINLEARN (not sure how to link a zip file)
// We used the same parameters but modified it to fit our use cases

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
    input wire clk,
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
//	input wire [1:0] pos,
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [3:0] red,	//red vga output
	output reg [3:0] green, //green vga output
	output reg [3:0] blue,	//blue vga output
	input wire [9:0] X_POS,
    input wire [9:0] Y_POS,
    input wire [2:0] color,
    input wire tool_on,
    input wire size_sel
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

// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;
reg [6:0] cursor_X = 23;
reg [6:0] cursor_Y = 23;
reg [2:0] width = 1;


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
reg [3:0] buffer_pixels [0:47][0:47];
genvar i, j;
generate
    // Initialize buffer_red
    for (i = 0; i < 48; i = i + 1) begin : INIT_BUFFER_RED
        for (j = 0; j < 48; j = j + 1) begin : INIT_BUFFER_RED_COL
            initial begin
                buffer_pixels[i][j] = 3'd0; // Example value, replace with your desired initialization value
            end
        end
    end
endgenerate

always @(posedge size_sel) begin
    if (width == 3) begin
        width = 1;
    end
    else begin
        width = width + 1;
    end
end
reg [31:0] counter_cursor = 0;
reg clk_cursor = 0;
     always @(posedge clk)
     
     begin
        counter_cursor <= (counter_cursor == 1666666) ? 0 : counter_cursor + 1;
        if (counter_cursor == 0)
            clk_cursor <= ~clk_cursor;    
     end
 always @(posedge clk_cursor)
 begin
    if (X_POS < 350 && cursor_X >= width) begin
        cursor_X <= cursor_X - width;
    end
    if (Y_POS < 350 && cursor_Y >= width) begin
        cursor_Y <= cursor_Y - width;
    end
    if (X_POS > 650 && cursor_X <= (47-width)) begin
        cursor_X <= cursor_X + width;
    end
    if (Y_POS > 650 && cursor_Y <= (47-width)) begin
        cursor_Y <= cursor_Y + width;
    end
    if (tool_on == 1) begin
        buffer_pixels[cursor_X][cursor_Y] <= color;
//        if (width == 2) begin
//            buffer_pixels[cursor_X+1][cursor_Y] <= color;
//            buffer_pixels[cursor_X][cursor_Y+1] <= color;
//            buffer_pixels[cursor_X+1][cursor_Y+1] <= color;
//        end
//        else if (width == 3) begin
//            buffer_pixels[cursor_X+1][cursor_Y] <= color;
//            buffer_pixels[cursor_X][cursor_Y+1] <= color;
//            buffer_pixels[cursor_X+1][cursor_Y+1] <= color;
//            buffer_pixels[cursor_X+2][cursor_Y] <= color;
//            buffer_pixels[cursor_X+2][cursor_Y+1] <= color;
//            buffer_pixels[cursor_X+2][cursor_Y+2] <= color;
//            buffer_pixels[cursor_X+1][cursor_Y+2] <= color;
//            buffer_pixels[cursor_X][cursor_Y+2] <= color;
//        end
    end
end
// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
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
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// display 100% saturation colorbars
// ------------------------
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// display white canvas
        if (hc >= hbp && hc < hfp) begin
            if (clr == 1) begin
                red = color_r[0];
                green = color_g[0];
                blue = color_b[0];
            end
            else if (hc/10 - 31 == cursor_X && vc/10 - 3 == cursor_Y) begin
                    red = color_r[color];
                    green = color_g[color];
                    blue = color_b[color];
            end
            else begin
//                if (clr == 1) begin
//                    buffer_pixels[hc/10 - 31][vc/10 - 3] = 3'd0;
//                end
                red = color_r[buffer_pixels[hc/10 - 31][vc/10 - 3]];
                green = color_g[buffer_pixels[hc/10 - 31][vc/10 - 3]];
                blue = color_b[buffer_pixels[hc/10 - 31][vc/10 - 3]];
            end
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
	else begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule
