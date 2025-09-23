`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2025 12:56:40 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
input clk, input reset,
input [3:0]user_in,
input otp_latch,input user_latch,
output [6:0] lfsr_out,
output [6:0] user_out,
output an1,an2//,unlock,reset_sys,expired
  );
    
wire [15:0]d_out,user_otp;
lfsr dut1(
    .clk(clk),
    .reset(reset),
    .d_out(d_out)
);

fsm1 dut2(.clk(clk),
    .reset(reset),
    .lfsr_digit(d_out),
    .lfsr_latch(otp_latch),
    .user_digit(user_in),
    .user_latch(user_latch),
   // .unlock(unlock),
   // .reset_sys(reset_sys),
    //.expired(expired),
    .user_otp_out(user_otp)
    );
    
 top_7_seg dut3(
    .clk(clk),
    .user_otp(user_otp), //
    .lfsr_otp(d_out),
    .seg1(lfsr_out),
    .seg2(user_out),
    .an1(an1), .an2(an2)
    );
endmodule
