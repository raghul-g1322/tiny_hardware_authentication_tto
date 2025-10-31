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
    reg [13:0] ct2;
    
    // Parameter to set the division ratio
    // When ct2 counts up to (DISP - 1), output toggles
    parameter DISP = 12_500;
    
    // Sequential logic: triggered on rising edge of clk or falling edge of rstn
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // Reset condition: clear counter and output
            ct2 <= 14'd0;
            clk_out_disp <= 1'b0;
        end else begin
            if (ct2 == DISP - 1) begin
                // When counter reaches the limit, reset and toggle output clock
                ct2 <= 14'd0;
                clk_out_disp <= ~clk_out_disp;
            end else begin
                // Otherwise, keep counting
                ct2 <= ct2 + 14'd1;
            end
        end
    end

endmodule 
