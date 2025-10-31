//=====================================================================
// Top-Level Module: OTP Lock System
// Description: Integrates LFSR (OTP generator), FSM (lock logic),
//              7-segment display driver, and edge detectors.
//=====================================================================
module top(
    input clk, input reset_n,            // System clock and active-low reset
    input [3:0] user_in,                 // 4-bit user input
    input otp_latch, input user_latch,   // Button inputs for OTP/user entry latch
    output [6:0] lfsr_out,               // 7-segment display output for LFSR OTP
    output [6:0] user_out,               // 7-segment display output for User OTP
    output [1:0] an                      // Anode control for display multiplexing
);

    // Internal signals
    wire [15:0] d_out, user_otp, otp;    // 16-bit data buses for OTP and user input
    wire [1:0] wrng_atmpt;               // Wrong attempt counter (2 bits)
    wire lock, unlock, expire;           // FSM status outputs
    wire lfsr_button, user_button;       // Rising edge pulses for button presses

    //-----------------------------------------------------------------
    // Rising Edge Detector for OTP Latch Button
    //-----------------------------------------------------------------
    pos_edge edge1 (
        .clk(clk),
        .reset(reset_n),
        .sig_in(otp_latch),
        .rise_edge(lfsr_button)          // Generates single-cycle pulse on rising edge
    );
                
    //-----------------------------------------------------------------
    // Rising Edge Detector for User Latch Button
    //-----------------------------------------------------------------
    pos_edge edge2 (
        .clk(clk),
        .reset(reset_n),
        .sig_in(user_latch),
        .rise_edge(user_button)          // Generates single-cycle pulse on rising edge
    );
                
    //-----------------------------------------------------------------
    // LFSR Module: Generates 16-bit pseudo-random OTP
    //-----------------------------------------------------------------
    lfsr dut1(
        .clk(clk),
        .reset(reset_n),
        .d_out(d_out)                    // LFSR output connected to FSM
    );

    //-----------------------------------------------------------------
    // FSM Module: Controls lock/unlock/expire logic
    //-----------------------------------------------------------------
    fsm dut2(
        .clk(clk),
        .reset(reset_n),
        .lfsr_digit(d_out),              // OTP from LFSR
        .lfsr_latch(lfsr_button),        // Latch signal for OTP generation
        .user_digit(user_in),            // User-entered 4-bit input
        .user_latch(user_button),        // Latch signal for user input
        .unlock(unlock),                 // FSM output - unlock status
        .reset_sys(lock),                // FSM output - lock signal
        .expired(expire),                // FSM output - OTP expired
        .wrng_atmpt(wrng_atmpt),         // FSM output - wrong attempt count
        .user_otp_out(user_otp),         // Latched user-entered OTP
        .otp(otp)                        // Latched system OTP
    );
    
    //-----------------------------------------------------------------
    // 7-Segment Display Controller:
    // Displays OTP, user input, wrong attempts, and status messages
    //-----------------------------------------------------------------
    top_7_seg dut3(
        .clk(clk),
        .rstn(reset_n),
        .lock(lock),                     // Lock status
        .unlock(unlock),                 // Unlock status
        .expire(expire),                 // Expire status
        .wrng_att(wrng_atmpt),           // Wrong attempt input
        .user_otp(user_otp),             // User-entered OTP for display
        .lfsr_otp(otp),                  // Generated OTP for display
        .seg1(user_out),                 // Output to 7-seg for user input
        .seg2(lfsr_out),                 // Output to 7-seg for OTP
        .an(an)                          // Display anode control
    );
      
endmodule
