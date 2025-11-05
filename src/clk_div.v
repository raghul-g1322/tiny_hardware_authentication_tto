//==========================================================
// Module: clk_div
// Description: 
//   Clock divider module that generates a slower clock signal
//   (clk_out_disp) from a faster input clock (clk). The division
//   factor is controlled by the parameter DISP.
//
// Inputs:
//   - clk   : Input clock signal
//   - rstn  : Active-low reset signal
//
// Outputs:
//   - clk_out_disp : Divided clock output
//
//==========================================================

module clk_div(
    input clk,       // Input clock
    input rstn,      // Active-low reset
    output reg clk_out_disp  // Output divided clock signal
);

    // 14-bit counter register
    reg [14:0] ct2;
    
    // Parameter to set the division ratio
    // When ct2 counts up to (DISP - 1), output toggles
    parameter DISP = 25_000;
    
    // Sequential logic: triggered on rising edge of clk or falling edge of rstn
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // Reset condition: clear counter and output
            ct2 <= 15'd0;
            clk_out_disp <= 1'b0;
        end else begin
            if (ct2 == DISP - 1) begin
                // When counter reaches the limit, reset and toggle output clock
                ct2 <= 15'd0;
                clk_out_disp <= 1'b1;
            end else begin
                // Otherwise, keep counting
                clk_out_disp <= 1'b0;
                ct2 <= ct2 + 15'd1;
            end
        end
    end

endmodule 


