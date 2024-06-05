`timescale 1ns / 1ps

module color_selector(
    input clk,
    input [6:0] sw,
    input tool_sel,
    output reg [2:0] color
    );
    
    always @(posedge clk) begin
    if (tool_sel == 1)
        color <= 3'b111; //white (erase)
    else begin
        if (sw[0] == 1)
            color <= 3'b000; //black
        if (sw[1] == 1)
            color <= 3'b001; //red
        if (sw[2] == 1)
            color <= 3'b010; //orange
        if (sw[3] == 1)
            color <= 3'b011; //yellow
        if (sw[4] == 1)
            color <= 3'b100; //green
        if (sw[5] == 1)
            color <= 3'b101; //blue
        if (sw[6] == 1)
            color <= 3'b110; //purple
    end
    end
    
endmodule
