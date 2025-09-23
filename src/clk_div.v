module clk_div(
    input clk,
    output reg clk_out_disp
);

    reg [14:0] ct2;
    
    parameter DISP = 12_500;
    
    always @(posedge clk) begin
        if (ct2 == DISP-1) begin
            ct2 <= 15'd0;
            clk_out_disp <= ~clk_out_disp;
        end else begin
            ct2 <= ct2 + 15'd1;
        end
    end
endmodule