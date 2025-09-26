module clk_div(
    input clk, rstn,
    output reg clk_out_disp
);

    reg [14:0] ct2;
    
    parameter DISP = 25_000;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            ct2 <= 15'd0;
            clk_out_disp <= 1'b0;
        end else begin
            if (ct2 == DISP-1) begin
                ct2 <= 15'd0;
                clk_out_disp <= ~clk_out_disp;
            end else begin
                ct2 <= ct2 + 15'd1;
            end
        end
    end
endmodule