//==========================================================
// Module: otp_to_bcd
// Description:
//   OTP to BCD Display Controller
//   ---------------------------------------
//   This module controls the multiplexed 7-segment display
//   that shows both the user-entered OTP and the internally
//   generated LFSR-based OTP. It also displays mode/status
//   indicators such as "unlock", "lock", or "expire", and
//   wrong attempt count.
//
//   Two clock dividers are used:
//      1. clk_div       – for fast digit multiplexing
//      2. clk_div_2sec  – for slow toggling between OTP & status
//
// Inputs:
//   clk       : System clock
//   rstn      : Active-low reset
//   unlock    : High when user unlocks successfully
//   lock      : High when system is locked
//   expire    : High when OTP expires
//   wrng_att  : Number of wrong attempts (0–3)
//   user_otp  : 16-bit user-entered OTP
//   lfsr_otp  : 16-bit LFSR-generated OTP
//
// Outputs:
//   bcd1  : BCD digit to display user_otp
//   bcd2  : BCD digit to display lfsr_otp or status
//   an    : 2-bit display enable (anode select for multiplexing)
//   shft  : Indicates current display mode (0 = OTP, 1 = Status)
//
//==========================================================

module otp_to_bcd(
    input clk, rstn,
    input unlock, lock, expire,
    input [1:0] wrng_att,
    input [15:0] user_otp, lfsr_otp,
    output reg [3:0] bcd1, bcd2,
    output reg [1:0] an,
    output wire shft
);

    //======================================================
    // Clock divider instances
    //======================================================

    wire clk_out_disp;   // Fast clock for display refresh
    wire clk_out_disp2;  // Slow clock (~2s period) for shifting display modes
    
    // Clock divider for multiplexed display (fast switching)
    clk_div inst2(
        .clk(clk),
        .rstn(rstn),
        .clk_out_disp(clk_out_disp)
    );
    
    // Slow clock divider for toggling display between OTP and status
    clk_div_2sec inst3(
        .clk(clk),
        .rstn(rstn),
        .clk_out_disp2(clk_out_disp2)
    );
    
    //======================================================
    // Internal registers
    //======================================================
    reg [1:0] disp1;   // Controls which nibble of user_otp is displayed
    reg [1:0] disp2;   // Controls which nibble of lfsr_otp/status is displayed
    reg [3:0] mode;    // Mode indicator (lock/unlock/expire)
    reg shift;         // Toggles between showing OTP and status
    reg ON;            // Display ON flag

    //======================================================
    // Shift toggle control (slow clock)
    // Toggles every 2 seconds to alternate display between
    // OTP view and system status view
    //======================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            shift <= 0;
        else begin
            if(clk_out_disp2)
                shift <= ~shift;
            else
                shift <= shift;
        end
    end
    
    //======================================================
    // Mode encoding based on system state
    //======================================================
    always @(*) begin
        if (unlock)
            mode = 4'b0111;  // "Unlock" indication
        else if (lock)
            mode = 4'b0110;  // "Lock" indication
        else if (expire)
            mode = 4'b0101;  // "Expire" indication
        else
            mode = 4'd0;     // Default / idle
    end
    
    //======================================================
    // Fast clock domain: digit cycling for multiplexed display
    //======================================================
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            ON <= 0;
            disp1 <= 2'd0;
            disp2 <= 2'd0;
        end else begin
            if(clk_out_disp) begin
                ON <= 1;                      // Turn on display
                disp1 <= disp1 + 2'd1;        // Cycle through 4 digits
                disp2 <= disp2 + 2'd1;
            end
        end
    end
    
    //======================================================
    // Display user-entered OTP (bcd1)
    // Cycles through 4 digits of user_otp on each refresh
    //======================================================
    always @(*) begin
        if (!ON) begin
            bcd1 = 4'b1111; // Display blank when off
            an = 2'b00;
        end else begin
            case (disp1)
                2'd0: begin 
                    an = 2'b00;            // Digit select 0
                    bcd1 = user_otp[3:0];  // Least significant nibble
                end
                2'd1: begin
                    an = 2'b01;            // Digit select 1
                    bcd1 = user_otp[7:4];
                end 
                2'd2: begin
                    an = 2'b10;            // Digit select 2
                    bcd1 = user_otp[11:8];
                end
                2'd3: begin
                    an = 2'b11;            // Digit select 3
                    bcd1 = user_otp[15:12];
                end
                default: begin
                    an = 2'b11;
                    bcd1 = 4'd0;
                end
            endcase
        end
    end
    
    //======================================================
    // Display LFSR OTP or Status Info (bcd2)
    // Shift toggles the display mode every few seconds:
    //   shift = 0 → show LFSR OTP
    //   shift = 1 → show mode, wrong attempts, etc.
    //======================================================
    always @(*) begin
        if (!ON) begin
            bcd2 = 4'd10; // Blank display
        end else begin
            if (shift) begin
                // Display system status (mode / attempts)
                case (disp2)
                    2'd3: bcd2 = 4'b1111;                  // Blank
                    2'd2: bcd2 = {2'b00, wrng_att + 2'd1}; // Wrong attempt count
                    2'd1: bcd2 = 4'b1000;                  // Separator or indicator
                    2'd0: bcd2 = mode;                     // Mode display
                    default: bcd2 = 4'd0;
                endcase
            end else begin
                // Display LFSR-generated OTP
                case (disp2)
                    2'd0: bcd2 = lfsr_otp[3:0];
                    2'd1: bcd2 = lfsr_otp[7:4];
                    2'd2: bcd2 = lfsr_otp[11:8];
                    2'd3: bcd2 = lfsr_otp[15:12];
                    default: bcd2 = 4'd0;
                endcase
            end
        end
    end

    //======================================================
    // Output assignment
    //======================================================
    assign shft = shift;  // Expose shift flag externally

endmodule

