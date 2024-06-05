`timescale 1ns / 1ps

module switch(
    input wire clk,
    input wire sw,
    output reg switch_out
);

    reg intermediate;
       
    always @(posedge clk) begin
        intermediate <= sw;
        switch_out <= intermediate;
    end
endmodule
