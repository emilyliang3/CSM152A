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
    SS,
    MOSI,
    SCLK,
    led,
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
output SS;                    // Slave Select, Pin 1, Port JA
output MOSI;                // Master Out Slave In, Pin 2, Port JA
output SCLK;                // Serial Clock, Pin 4, Port JA
output [2:0] led;            // LEDs 2, 1, and 0
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
wire [2:0] led;                // Status of PmodJSTK buttons displayed on LEDs
wire [3:0] an;                // Anodes for Seven Segment Display
wire [6:0] seg;            // Cathodes for Seven Segment Display

PmodJSTK_Demo joystick(.CLK(clk),.RST(clr),.MISO(MISO),.SW(sw),.SS(SS),.MOSI(MOSI),.SCLK(SCLK),.LED(led),.AN(an),.SEG(seg));
NERP_demo_top screen(.clk(clk),.clr(clr), .red(red),.green(green),.blue(blue),.hsync(hsync),.vsync(vsync));


endmodule
