module clk_div_2sec(
    input clk, rstn,
    output reg clk_out_disp2
);

    reg [26:0] ct2;
    
    parameter DISP = 100_000_000;
    
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            ct2 <= 27'd0;
            clk_out_disp2 <= 1'b0;
        end else begin
            if (ct2 == DISP-1) begin
                ct2 <= 27'd0;
                clk_out_disp2 <= ~clk_out_disp2;
            end else begin
                ct2 <= ct2 + 27'd1;
            end
        end
    end
endmodule