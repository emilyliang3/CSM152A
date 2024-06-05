`timescale 1ns / 1ps

module debouncer(
    input clk,
    input btn,
    output button_out
    );
   
    parameter DEBOUNCING_LIMIT = 16'hffff;
    reg [15:0] counter = 0;
    reg intermediate = 0;
       
    always @(posedge clk) begin
        if(btn == 0) begin
            counter <= 0;
            intermediate <= 0;
            end
        else begin
            counter <= counter + 1'b1;
            if(counter >= DEBOUNCING_LIMIT) begin
                intermediate <= 1;
                counter <= 0;
            end
        end
    end
    assign button_out = intermediate;
    
endmodule