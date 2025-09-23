module otp_to_bcd(
    input clk,
    input [15:0] user_otp, lfsr_otp,
    output reg [3:0] bcd1, bcd2,
    output reg an1, an2
);
    wire clk_out_disp;
    
    clk_div inst2(.clk(clk),
                       .clk_out_disp(clk_out_disp));
    
    reg [1:0] disp1 = 0;
    reg [1:0] disp2 = 0;
 
    always @(posedge clk_out_disp) begin
        disp1 <= disp1 + 2'd1;
        disp2 <= disp2 + 2'd1;
    end
     
    always @(*) begin
        case (disp1)
            2'd0: begin 
               an1 = 1'b0;
               bcd1 = user_otp[3:0];
            end
            2'd1: begin
               an1 = 1'b0;
               bcd1 = user_otp[7:4];
            end 
            2'd2: begin
                an1 = 1'b0;
                bcd1 = user_otp[11:8];
            end
            2'd3: begin
                an1 = 1'b0;
                bcd1 = user_otp[15:12];
            end
            default: begin
                    an1 = 1'b1;
                    bcd1 = 4'd0;
                    end
        endcase
    end
    
    always @(*) begin
        case (disp2)
            2'd0: begin 
               an2 = 1'b0;
               bcd2 = lfsr_otp[3:0];
            end
            2'd1: begin
               an2 = 1'b0;
               bcd2 = lfsr_otp[7:4];
            end 
            2'd2: begin
                an2 = 1'b0;
                bcd2 = lfsr_otp[11:8];
            end
            2'd3: begin
                an2 = 1'b0;
                bcd2 = lfsr_otp[15:12];
            end
            default: begin
                    an2 = 1'b1;
                    bcd2 = 4'd0;
                    end
        endcase
    end
endmodule