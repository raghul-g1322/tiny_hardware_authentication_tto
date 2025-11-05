//=====================================================================
// Module Name: fsm
// Description: Finite State Machine (FSM) for OTP (One-Time Password)
//              generation, entry, validation, and system reset control.
//=====================================================================

`define HOLD_TIME   50_000_000     // Defines ~1-second duration (based on clock)
`define EXPIRE_TIME 50_000_000     // Defines ~1-second expiration count base

module fsm(
    input clk, reset,              // Clock and active-low reset
    input [15:0] lfsr_digit,       // Random OTP digits from LFSR
    input lfsr_latch,              // Latch signal for OTP generation
    input [3:0] user_digit,        // User-entered digit
    input user_latch,              // Latch signal for user entry
    output reg unlock,             // Unlock signal when OTP matches
    output reg reset_sys,          // System reset signal after multiple wrong attempts
    output reg expired,            // OTP expired flag
    output reg [1:0] wrng_atmpt,   // Wrong attempt counter
    output [15:0] user_otp_out,    // Combined user-entered OTP
    output reg [15:0] otp          // Generated OTP
);

    // Internal registers and states
    reg [31:0] total_time;         // Timer for OTP expiration
    reg [27:0] hold_time;          // Timer for hold delay after events
    reg [1:0] current, next;       // State registers
    (* mem2reg *) reg [3:0] user_otp[0:3];       // Stores 4 user digits
    reg [2:0] j;                   // Index for user input collection

    // FSM state encoding
    parameter IDLE = 2'B00, 
              GENERATE_OTP = 2'B01, 
              ENTER_OTP = 2'B10, 
              UNLOCK = 2'B11;
    
    //-----------------------------------------------------------------
    // Sequential block: state transitions and register updates
    //-----------------------------------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            otp         <= 16'b0;              // Clear OTP
            current     <= IDLE;               // Go to IDLE state
            total_time  <= 0;                  // Reset timers
            hold_time   <= 0;
            wrng_atmpt  <= 0;                  // Reset wrong attempt counter
            unlock      <= 0;                  // Clear unlock flag
            reset_sys   <= 0;                  // Clear system reset flag
            expired     <= 0;                  // Clear expired flag
            j           <= 0;                  // Reset user input index
            {user_otp[0], user_otp[1], user_otp[2], user_otp[3]} <= 16'd0;  // Clear user OTP
        end 
        else begin
            current <= next;                   // Update current state
            case (current)
            
                // ------------------------------------------------------
                // IDLE: System reset and wait for OTP generation
                // ------------------------------------------------------
                IDLE: begin
                    otp         <= 16'b0;
                    total_time  <= 0;
                    hold_time   <= 0;
                    unlock      <= 0;
                    reset_sys   <= 0;   
                    expired     <= 0;  
                    wrng_atmpt  <= 0; 
                    j           <= 0;     
                    {user_otp[0], user_otp[1], user_otp[2], user_otp[3]} <= 16'd0;   
                end
                
                // ------------------------------------------------------
                // GENERATE_OTP: Latch LFSR-generated OTP value
                // ------------------------------------------------------
                GENERATE_OTP: 
                    if (lfsr_latch) begin
                        otp <= lfsr_digit;     // Store generated OTP
                    end
                               
                // ------------------------------------------------------
                // ENTER_OTP: Wait for user input and track timeout
                // ------------------------------------------------------
                ENTER_OTP: begin
                    total_time <= total_time + 1;  // Increment total timer
                    if(total_time >= (`EXPIRE_TIME*50)) begin // Check 30 sec timeout
                        if(hold_time < (`HOLD_TIME*5)) begin  // 5 sec hold window
                            expired   <= 1;                   // OTP expired
                            hold_time <= hold_time + 1;
                        end else begin
                            expired   <= 0;
                            hold_time <= 0;
                        end
                    end
                    else if (user_latch) begin
                        user_otp[j[1:0]] <= user_digit; // Capture user digit
                        j <= j + 1;                     // Move to next index
                    end
                end
                
                // ------------------------------------------------------
                // UNLOCK: Verify OTP and manage wrong attempts
                // ------------------------------------------------------
                UNLOCK: begin  
                    if (otp == {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}}) begin
                        unlock    <= 1;              // Unlock success
                        hold_time <= hold_time + 1;
                    end 
                    else begin
                        j <= 0;                      // Reset input index
                        if (wrng_atmpt == 2) begin 
                            reset_sys <= 1;          // Too many wrong attempts → reset
                            hold_time <= hold_time + 1;
                        end
                        else begin
                            reset_sys  <= 0;
                            hold_time  <= 0;
                            wrng_atmpt <= wrng_atmpt + 1; // Increment wrong attempt count
                        end
                    end
                end
            endcase
        end
    end
  
    //-----------------------------------------------------------------
    // Combinational block: next state logic
    //-----------------------------------------------------------------
    always @(*) begin
        next = current; // Default: remain in current state
        case (current)
            IDLE:         next = GENERATE_OTP;  // Start OTP generation
            GENERATE_OTP: if (lfsr_latch) next = ENTER_OTP;
            ENTER_OTP: begin
                if (total_time >= (`EXPIRE_TIME*50) && hold_time == (`HOLD_TIME*5))
                    next = IDLE;                // OTP expired
                else if (total_time >= (`EXPIRE_TIME*50))
                    next = ENTER_OTP;           // Stay if time not complete
                else if (j > 3)
                    next = UNLOCK;              // All digits entered
            end
            UNLOCK: begin
                if ((otp == {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}}) 
                    && hold_time == (`HOLD_TIME*5))
                    next = IDLE;                // After unlock delay
                else if (otp == {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}})
                    next = UNLOCK;              // Stay unlocked
                else if (wrng_atmpt >= 2 && hold_time == (`HOLD_TIME*5))
                    next = IDLE;                // Reset after multiple failures
                else if (wrng_atmpt >= 2)
                    next = UNLOCK;              // Stay in unlock until hold done
                else
                    next = ENTER_OTP;           // Retry entry
            end
        endcase
    end

    //-----------------------------------------------------------------
    // Output assignment: Combine user digits into full 16-bit OTP
    //-----------------------------------------------------------------
    assign user_otp_out = {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}};

endmodule

