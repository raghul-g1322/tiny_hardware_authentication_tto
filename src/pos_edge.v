//==========================================================
// Module: pos_edge
// Description:
//   Positive Edge Detector
//   -----------------------
//   This module detects a *rising edge* on the input signal
//   `sig_in` and generates a **one clock-cycle pulse** on
//   `rise_edge` whenever a transition from 0 → 1 occurs.
//
// Usage Notes:
//   - The input `sig_in` must be synchronized to `clk` before
//     feeding it into this module (especially if it comes from
//     a pushbutton or asynchronous source) to avoid metastability.
//
// Inputs:
//   clk       : System clock
//   reset     : Active-low asynchronous reset
//   sig_in    : Input signal to detect rising edge
//
// Outputs:
//   rise_edge : Output pulse (high for one clock cycle on rising edge)
//==========================================================

module pos_edge(
    input  clk,          // Clock input
    input  reset,        // Active-low reset
    input  sig_in,       // Input signal to monitor
    output reg rise_edge // Output pulse on rising edge
);

    // Register to hold the previous value of sig_in
    reg sig_d;  

    //======================================================
    // Sequential logic
    // - Stores the delayed version of sig_in
    // - Detects the rising edge
    //======================================================
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // On reset, clear registers
            sig_d     <= 1'b0;
            rise_edge <= 1'b0;
        end else begin
            // Store current signal value
            sig_d <= sig_in;

            // Detect rising edge:
            // If sig_in = 1 and previous value (sig_d) = 0,
            // then output a one-cycle pulse
            rise_edge <= sig_in & ~sig_d;
        end
    end

endmodule
