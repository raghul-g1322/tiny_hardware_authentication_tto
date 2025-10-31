//==========================================================
// Module: lfsr
// Description:
//   Linear Feedback Shift Register (LFSR) - 16-bit
//   -------------------------------------------------
//   This module generates pseudo-random numbers using a
//   16-bit LFSR polynomial. The generated sequence cycles
//   through a series of values before repeating.
//
//   Additionally, the 16-bit LFSR value is divided into four
//   4-bit segments (nibbles), each converted into a decimal
//   digit (0–9) using modulo operation. These four digits
//   are concatenated to form a 16-bit output (`d_out`).
//
// Inputs:
//   clk   : Clock input
//   reset : Active-low asynchronous reset
//
// Output:
//   d_out : 16-bit output formed from four pseudo-random digits
//
// Polynomial used:
//   x^16 + x^14 + x^13 + x^11 + x^9 + x^7 + 1
//==========================================================

module lfsr(
    input  clk,        // Input clock signal
    input  reset,      // Active-low reset
    output reg [15:0] d_out // Output containing 4 random digits
);
 
    // 16-bit registers for LFSR current and next state
    reg [15:0] lfsr, lfsr_next;

    // 4 registers to store each 4-bit digit
    reg [3:0] q_reg1, q_reg2, q_reg3, q_reg4;

    // XOR feedback bit (tap)
    reg tap;
 
    //======================================================
    // Sequential logic: updates LFSR on each clock edge
    //======================================================
    always @(posedge clk or negedge reset) begin
        if (!reset)
            // Initialize LFSR with a non-zero seed value
            // (If seed = 0, the LFSR would lock up permanently)
            lfsr <= 16'hACE1;
        else
            // Update the LFSR with next state on each clock
            lfsr <= lfsr_next;
    end
 
    //======================================================
    // Combinational logic: next state generation
    // Implements the feedback taps based on the polynomial
    //======================================================
    always @(*) begin
        // Feedback tap calculation (XOR of selected bits)
        // Polynomial: x^16 + x^14 + x^13 + x^11 + x^9 + x^7 + 1
        tap = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10] ^ lfsr[8] ^ lfsr[6];

        // Shift left by 1 and insert new tap at LSB
        lfsr_next = {lfsr[14:0], tap};
    end
 
    //======================================================
    // Extract four 4-bit sections and convert to digits (0–9)
    //======================================================
    always @(*) begin
        // Each nibble reduced modulo 10 to ensure a decimal digit
        q_reg1 = lfsr[15:12] % 10;
        q_reg2 = lfsr[11:8]  % 10;
        q_reg3 = lfsr[7:4]   % 10;
        q_reg4 = lfsr[3:0]   % 10;
    end
 
    //======================================================
    // Combine the four 4-bit digits into a single 16-bit output
    //======================================================
    always @(*) begin
        d_out = {q_reg1, q_reg2, q_reg3, q_reg4};
    end
 
endmodule
 
