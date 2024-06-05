`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 12:27:13 PM
// Design Name: 
// Module Name: paint_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module paint_top(
    clk,
    clr,
    MISO,
    sw,
    swc,
    btnL,
    btnR,
    SS,
    MOSI,
    SCLK,
    led,
    ledc,
    an,
    seg,
    red,
    green,
    blue,
    hsync,
    vsync
    );
    
input clk;					// 100Mhz onboard clock
input clr;                    // Button D
input MISO;                    // Master In Slave Out, Pin 3, Port JA
input [2:0] sw;            // Switches 2, 1, and 0
input [6:0] swc;            // color switches
input btnL;
input btnR;
output SS;                    // Slave Select, Pin 1, Port JA
output MOSI;                // Master Out Slave In, Pin 2, Port JA
output SCLK;                // Serial Clock, Pin 4, Port JA
output [4:0] led;            // LEDs 2, 1, and 0
output [6:0] ledc;          // color leds
output [3:0] an;            // Anodes for Seven Segment Display
output [6:0] seg;            // Cathodes for Seven Segment Display
output [3:0] red;
output [3:0] blue;
output [3:0] green;
output hsync;
output vsync;
    
wire SS;						// Active low
wire MOSI;                    // Data transfer from master to slave
wire SCLK;                    // Serial clock that controls communication
wire [4:0] led;                // Status of PmodJSTK buttons displayed on LEDs
wire [3:0] an;                // Anodes for Seven Segment Display
wire [6:0] seg;            // Cathodes for Seven Segment Display
wire [9:0] x_pos;
wire [9:0] y_pos;
wire tool_on;
wire tool_sel;
wire size_sel;
wire [6:0] color_sel;
wire [2:0] color;

// controls
debouncer btn_tool_sel(.clk(clk), .btn(btnL), .button_out(tool_sel));
debouncer btn_size_sel(.clk(clk), .btn(btnR), .button_out(size_sel));
switch sw_tool_on(.clk(clk), .sw(sw[1]), .switch_out(tool_on)); //change to sw[0] in future
switch sw_blk(.clk(clk), .sw(swc[0]), .switch_out(color_sel[0]));
switch sw_red(.clk(clk), .sw(swc[1]), .switch_out(color_sel[1]));
switch sw_orange(.clk(clk), .sw(swc[2]), .switch_out(color_sel[2]));
switch sw_yel(.clk(clk), .sw(swc[3]), .switch_out(color_sel[3]));
switch sw_grn(.clk(clk), .sw(swc[4]), .switch_out(color_sel[4]));
switch sw_blue(.clk(clk), .sw(swc[5]), .switch_out(color_sel[5]));
switch sw_purp(.clk(clk), .sw(swc[6]), .switch_out(color_sel[6]));

color_selector colors(.clk(clk), .sw(color_sel), .tool_sel(tool_sel), .color(color));
PmodJSTK_Demo joystick(.CLK(clk),.RST(clr),.MISO(MISO),.SW(sw),.SS(SS),.MOSI(MOSI),.SCLK(SCLK),.AN(an),.SEG(seg), .X_POS(x_pos), .Y_POS(y_pos));
NERP_demo_top screen(.clk(clk),.clr(clr), .red(red),.green(green),.blue(blue),.hsync(hsync),.vsync(vsync));

assign led[1] = tool_on;
assign led[2] = tool_sel;
assign led[3] = size_sel;
assign ledc = color_sel;

endmodule
