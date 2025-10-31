//===============================================================
// Module: seven_seg
// Description:
//   Dual 7-segment display driver with optional character mode.
//   -----------------------------------------------------------
//   - Converts 4-bit BCD inputs (bcd1, bcd2) into 7-segment
//     display patterns.
//   - When `shift` = 0 → normal numeric display (0–9).
//   - When `shift` = 1 → alternate mode (can show letters/symbols).
//
// Inputs:
//   bcd1   : 4-bit input for first 7-segment display
//   bcd2   : 4-bit input for second 7-segment display
//   shift  : Mode select (0 = numeric, 1 = special characters)
//
// Outputs:
//   seg1   : 7-bit output pattern for first display
//   seg2   : 7-bit output pattern for second display
//
// Note:
//   - The bit order {a,b,c,d,e,f,g} → seg[6:0]
//   - ‘1’ turns segment OFF, ‘0’ turns segment ON
//   - Adjust bit polarity based on common-anode/cathode configuration
//===============================================================

module seven_seg(
    input  [3:0] bcd1, bcd2,
    input        shift,
    output reg [6:0] seg1, seg2
);

    //===========================================================
    // Display 1: Always shows numeric digits (0–9)
    //===========================================================
    always @(*) begin
        case (bcd1)
            4'b0000: seg1 = 7'b1000000; // 0
            4'b0001: seg1 = 7'b1111001; // 1
            4'b0010: seg1 = 7'b0100100; // 2
            4'b0011: seg1 = 7'b0110000; // 3
            4'b0100: seg1 = 7'b0011001; // 4
            4'b0101: seg1 = 7'b0010010; // 5
            4'b0110: seg1 = 7'b0000010; // 6
            4'b0111: seg1 = 7'b1111000; // 7
            4'b1000: seg1 = 7'b0000000; // 8
            4'b1001: seg1 = 7'b0010000; // 9
            default: seg1 = 7'b1111111; // Blank (OFF)
        endcase
    end

    //===========================================================
    // Display 2: Numeric mode or Special-character mode
    //===========================================================
    always @(*) begin
        if (shift) begin
            // Special-character mode (custom mapping)
            case (bcd2)
                4'b0001: seg2 = 7'b1111001; // 1
                4'b0010: seg2 = 7'b0100100; // 2
                4'b0011: seg2 = 7'b0110000; // 3
                4'b0110: seg2 = 7'b1000111; // L
                4'b0111: seg2 = 7'b1000001; // U
                4'b0101: seg2 = 7'b0000110; // E
                4'b1000: seg2 = 7'b0111111; // -
                4'b1111: seg2 = 7'b0001000; // A
                default: seg2 = 7'b1111111; // Blank
            endcase
        end
        else begin
            // Numeric mode (standard digits)
            case (bcd2)
                4'b0000: seg2 = 7'b1000000; // 0
                4'b0001: seg2 = 7'b1111001; // 1
                4'b0010: seg2 = 7'b0100100; // 2
                4'b0011: seg2 = 7'b0110000; // 3
                4'b0100: seg2 = 7'b0011001; // 4
                4'b0101: seg2 = 7'b0010010; // 5
                4'b0110: seg2 = 7'b0000010; // 6
                4'b0111: seg2 = 7'b1111000; // 7
                4'b1000: seg2 = 7'b0000000; // 8
                4'b1001: seg2 = 7'b0010000; // 9
                default: seg2 = 7'b1111111; // Blank
            endcase
        end
    end

endmodule
