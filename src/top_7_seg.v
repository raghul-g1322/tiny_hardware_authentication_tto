//=====================================================================
// Module Name: top_7_seg
// Description: Top-level module for handling 7-segment display control.
//              It converts OTP and user input data into BCD format and 
//              drives two 7-segment displays accordingly.
//=====================================================================

module top_7_seg(
    input wire clk, rstn, unlock, lock, expire,   // System clock, reset, and status signals
    input [1:0] wrng_att,                        // Wrong attempt count
    input wire [15:0] user_otp, lfsr_otp,        // 16-bit OTP values: user-entered & generated
    output wire [6:0] seg1, seg2,                // Segment outputs for both displays
    output wire [1:0] an                         // Anode selection for multiplexed display
);
    
    // Internal connections between submodules
    wire [3:0] bcd1, bcd2;                       // BCD digits for display
    wire shift;                                  // Shift control signal (toggles display mode)
    
    //-----------------------------------------------------------------
    // Submodule 1: otp_to_bcd
    // Function: Converts OTPs and status signals to BCD format
    //            and generates control signals for display multiplexing.
    //-----------------------------------------------------------------
    otp_to_bcd U1 (
        .clk(clk),
        .rstn(rstn),
        .lock(lock),
        .unlock(unlock),
        .expire(expire),
        .wrng_att(wrng_att),
        .user_otp(user_otp),
        .lfsr_otp(lfsr_otp),
        .bcd1(bcd1),
        .bcd2(bcd2),
        .an(an),
        .shft(shift)                            // Output signal to control display shift
    );
                   
    //-----------------------------------------------------------------
    // Submodule 2: seven_seg
    // Function: Converts 4-bit BCD inputs to 7-segment display codes.
    //            Also handles character display during special modes
    //            (lock/unlock/expire) using the shift control signal.
    //-----------------------------------------------------------------
    seven_seg U2 (
        .bcd1(bcd1),
        .bcd2(bcd2),
        .seg1(seg1),
        .seg2(seg2),
        .shift(shift)
    );

endmodule
