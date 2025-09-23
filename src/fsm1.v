
/*module fsm1(
    input clk,reset,
    input [3:0] lfsr_digit,
    input lfsr_latch,
    input [3:0] user_digit,
    input user_latch,
    output reg unlock,
    output reg reset_sys
    );
    
    reg [4:0] total_time;
    reg [1:0] wrng_atmpt;
    reg [1:0] current,next;
    reg [3:0] otp[0:3];
    reg [3:0] user_otp[0:3];
    reg [2:0] i;
    reg [2:0]j;//index of generated otp
    parameter IDLE = 2'B00,GENERATE_OTP = 2'B01, ENTER_OTP = 2'B10 ,UNLOCK = 2'B11;
    
    always @(posedge clk) begin
    if (reset) begin
        current    <= IDLE;
        total_time <= 0;
        wrng_atmpt <= 0;
        unlock     <= 0;
        reset_sys  <= 0;
        i          <= 0;
        j          <= 0;
    end 
    
    else begin
        current <= next;
        case (current)
            GENERATE_OTP: if (lfsr_latch && i < 4) begin
                              otp[i] <= lfsr_digit;
                              i <= i + 1;
                           end
            ENTER_OTP: begin
                total_time <= total_time + 1;
                if (user_latch ) begin //if (user_latch && j < 4) begin
                    user_otp[j] <= user_digit;
                    j <= j + 1;
                end
            end
            
            UNLOCK: begin
                if (!(otp[0] == user_otp[0] && otp[1] == user_otp[1] && otp[2] == user_otp[2] && otp[3] == user_otp[3] )) begin
                    i <= 0;
                    j <= 0;
                    total_time <= 0;
                    wrng_atmpt <= wrng_atmpt + 1;
                    
                end
            end
        endcase
    end
end
  
   always @(*) begin
    next = current; // default
    case (current)
        IDLE:        begin
            next = GENERATE_OTP;
            unlock <= 0;
            reset_sys <= 0;
        end 
        GENERATE_OTP: if (i > 3) next = ENTER_OTP;
        ENTER_OTP:   if (total_time > 30) next = IDLE;
                     else if (j > 3)    next = UNLOCK;
        UNLOCK:      if(otp[0] == user_otp[0] && otp[1] == user_otp[1] && otp[2] == user_otp[2] && otp[3] == user_otp[3] )  begin
                        next = IDLE;//change this part
                        unlock <= 1;
                     end
                     else  begin
                        if (wrng_atmpt == 2) begin
                            reset_sys <= 1; 
                            next <= IDLE;
                        end
                        else
                        next = ENTER_OTP ; // go back after check
                     end
    endcase
end

endmodule
*/


module fsm1(
    input clk,reset,
    input [15:0] lfsr_digit,
    input lfsr_latch,
    input [3:0] user_digit,
    input user_latch,
    //output reg unlock,
    //output reg reset_sys,
    //output reg expired,
    output [15:0] user_otp_out
    );
    reg unlock ,reset_sys,expired;
    reg [29:0] total_time;//[29:0] total_time
    reg [1:0] wrng_atmpt;
    reg [1:0] current,next;
    reg [15:0] otp;
    reg [3:0] user_otp[0:3];
    reg [2:0]j;//index of generated otp
    parameter IDLE = 2'B00,GENERATE_OTP = 2'B01, ENTER_OTP = 2'B10 ,UNLOCK = 2'B11;
    
    always @(posedge clk or negedge reset) begin
    if (!reset) begin
        current    <= IDLE;
        total_time <= 0;
        wrng_atmpt <= 0;
        unlock     <= 0;
        reset_sys  <= 0;
        expired    <= 0;
        j          <= 0;
    end 
    
    else begin
        current <= next;
        case (current)
        
            IDLE: begin
                unlock <= 0;
                reset_sys <= 0;   
                expired    <= 0;
            end
            
            GENERATE_OTP: if (lfsr_latch) begin
                                otp <= lfsr_digit;
                              //otp <= {{(lfsr_digit[3:0])%10},{(lfsr_digit[7:4])%10},{(lfsr_digit[11:8])%10},{(lfsr_digit[15:12])%10}};
                           end
                           
            ENTER_OTP: begin
                total_time <= total_time + 1;
                if(total_time > 750000000) begin 
                    reset_sys <= 1; //30 * 25,000,000(50 MHz clk)
                    expired   <= 1;
                end
                else if (user_latch ) begin //if (user_latch && j < 4) begin
                    user_otp[j] <= user_digit;
                    j <= j + 1;
                end
            end
            
            UNLOCK: begin
                if (otp == {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}}) begin
                    unlock <= 1;
                end else begin
                    j <= 0;
                    total_time <= 0;
                    wrng_atmpt <= wrng_atmpt + 1;
                    if (wrng_atmpt == 2) reset_sys <= 1;
                end
            end
        endcase
    end
end
  
   always @(*) begin
    next = current; // default
    case (current)
        IDLE:        next = GENERATE_OTP;
        GENERATE_OTP: if (lfsr_latch) next = ENTER_OTP;
        ENTER_OTP:   if (total_time > 750000000) next = IDLE;//>750000000
                     else if (j > 3)    next = UNLOCK;
        UNLOCK:      if ( otp == {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}} ) next = IDLE;//change this part
                     else if (wrng_atmpt == 2)  next = IDLE;
                     else next = ENTER_OTP ; // go back after check
    endcase
end
assign user_otp_out = {{user_otp[0]},{user_otp[1]},{user_otp[2]},{user_otp[3]}};
endmodule
