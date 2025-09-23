module top_7_seg(
    input wire clk,
    input wire [15:0] user_otp, lfsr_otp,
    output wire [6:0] seg1, seg2,
    output wire an1, an2
    );
    
    wire [3:0] bcd1, bcd2;
    
    otp_to_bcd U1 (.clk(clk),
                   .user_otp(user_otp),
                   .lfsr_otp(lfsr_otp),
                   .bcd1(bcd1),
                   .bcd2(bcd2),
                   .an1(an1),
                   .an2(an2));
                   
    seven_seg U2 (.bcd1(bcd1),
                  .bcd2(bcd2),
                  .seg1(seg1),
                  .seg2(seg2));
endmodule
