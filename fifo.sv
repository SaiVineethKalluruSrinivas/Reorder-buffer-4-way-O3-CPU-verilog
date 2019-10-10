
module FIFO 
    input logic clk,
    input logic reset_n,
    input logic [27:0] data_in [3:0],
    input logic we,
    input logic re,
    output logic [27:0] data_out,
    output logic [27:0] index_out,
    output logic full,
    output logic empty
);

    
    logic [32-1:0] Q[4];
    logic [1:0] re_ptr;
    logic [1:0] we_ptr;
    logic near_full;
    logic match;
    logic [1:0] sum_re;
    logic [1:0] sum_we;

    assign sum_re = {1'b0, re_ptr};
    assign sum_we = {1'b0, we_ptr} + 1;

    assign near_full = (sum_re[1:0] == sum_we[1:0]);
    assign match = (re_ptr == we_ptr);


    assign empty = match & ~full;
    assign data_out = (re) ? Q[re_ptr] : 'd0;
    assign index_out = (indexe) ? Q[index] : 'd0;

    always_ff @ (posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            re_ptr <= 'd0;
            we_ptr <= 'd0;
            full <= 'd0;
        end else begin
            if (re & we & ~empty) begin
                Q[we_ptr] <= data_in;
                we_ptr <= we_ptr + 'd1;
                re_ptr <= re_ptr + 'd1;
            end

            else if (re& ~empty) begin
                re_ptr <= re_ptr +'d1;
                full <= 1'b0;
            end

            else if (we & ~full) begin
                Q[we_ptr] <= data_in;
                we_ptr <= we_ptr + 'd1;
                if(near_full) begin
                    full <= 'b1;
                end
            end
        end
    end

endmodule : FIFO




