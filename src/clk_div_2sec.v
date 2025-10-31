//=====================================================================
// Module Name: clk_div_2sec
// Description: Clock divider that generates a slower clock pulse
//              (approximately every 2 seconds, depending on input clock).
//              Used for slower control or display shifting operations.
//=====================================================================
 
module clk_div_2sec(
    input clk, rstn,               // System clock and active-low reset
    output reg clk_out_disp2       // Divided clock output (toggles every 2 sec)
);
 
    // 26-bit counter for clock division
    reg [25:0] ct2;
    // Parameter: Number of input clock cycles before toggle
    // Example: For 50 MHz input clock, DISP = 50,000,000 → 1-second period per toggle
    // Since output toggles every time counter resets, total period ≈ 2 seconds
    parameter DISP = 50_000_000;
    //-----------------------------------------------------------------
    // Clock Divider Logic
    // Counts input clock cycles up to DISP-1, then toggles output.
    //-----------------------------------------------------------------
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            ct2 <= 26'd0;               // Reset counter to 0
            clk_out_disp2 <= 1'b0;      // Reset output clock
        end else begin
            if (ct2 == DISP-1) begin    // When counter reaches terminal value
                ct2 <= 26'd0;           // Reset counter
                clk_out_disp2 <= ~clk_out_disp2;  // Toggle output clock
            end else begin
                ct2 <= ct2 + 26'd1;     // Increment counter each clock cycle
            end
        end
    end
 
endmodule

