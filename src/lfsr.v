`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2025 12:54:08 PM
// Design Name: 
// Module Name: lfsr
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


module lfsr(
    input  clk,
    input  reset,
    output reg [15:0] d_out
);
 
    reg [3:0] q_reg1, q_reg_next1;
    reg [3:0] q_reg2, q_reg_next2;
    reg [3:0] q_reg3, q_reg_next3;
    reg [3:0] q_reg4, q_reg_next4;
 
    wire tap1, tap2, tap3, tap4, tap5, tap6, tap7, tap8;
 
    // Sequential registers
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            q_reg1 <= 4'h2;
            q_reg2 <= 4'h3;
            q_reg3 <= 4'h5;
            q_reg4 <= 4'h9;   // seed values
        end
        else begin
            q_reg1 <= q_reg_next1;
            q_reg2 <= q_reg_next2;
            q_reg3 <= q_reg_next3;
            q_reg4 <= q_reg_next4;
        end
    end
 
    // Combinational next state logic
    always @(*) begin
        q_reg_next1 = {tap1, q_reg1[3], tap2, q_reg1[1]};
        q_reg_next2 = {q_reg2[1], tap3, q_reg2[3], tap4};
        q_reg_next3 = {tap5, tap6, q_reg3[2], q_reg3[0]};
        q_reg_next4 = {tap7, q_reg4[1], tap8, q_reg4[0]};
    end
 
    // Tap definitions
    assign tap1 = q_reg1[0];
    assign tap2 = q_reg1[3] ^ q_reg1[0];
    assign tap3 = q_reg2[0] ~^ q_reg2[2];
    assign tap4 = q_reg2[1] ^ q_reg2[0];
    assign tap5 = q_reg3[1] ^ q_reg3[3];
    assign tap6 = q_reg3[2] ~^ q_reg3[3];
    assign tap7 = q_reg4[3];
    assign tap8 = q_reg4[1] ^ q_reg4[2];
 
    // Concatenate into a single 16-bit output
    always @(*) begin
        d_out = {q_reg1, q_reg2, q_reg3, q_reg4};
    end
 
endmodule
