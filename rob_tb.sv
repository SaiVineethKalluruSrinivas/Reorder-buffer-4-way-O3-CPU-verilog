`timescale 1ns / 1ps

module rob(
    input clk,
    input reset,
    input logic [3:0] inserted,
    input logic [4:0] archReg0,
    input logic [7:0] physReg0,
    input logic [10:0] opcode0,
    input logic [4:0] archReg1,
    input logic [7:0] physReg1,
    input logic [10:0] opcode1,
    input logic [4:0] archReg2,
    input logic [7:0] physReg2,
    input logic [10:0] opcode2,
    input logic [4:0] archReg3,
    input logic [7:0] physReg3,
    input logic [10:0] opcode3,
    input logic flushInst,
    input logic [6:0] flushIndex,
    input logic exception,
    input logic [6:0] exceptionIndex,
    input logic [3:0] executed,
    input logic [6:0] executedIndex0,
    input logic [6:0] executedIndex1,
    input logic [6:0] executedIndex2,
    input logic [6:0] executedIndex3,
    output logic [2:0] numCommited,
    output logic full
);

    logic [26:0] Q[127:0];
    logic [6:0] head;
    logic [6:0] head_next;
    logic [6:0] tail;
    logic [6:0] tail_next;
    logic [6:0] sum_head;
    logic [6:0] sum_tail;
    logic [27:0] inserted_0_reg;
    logic [27:0] inserted_1_reg;
    logic [27:0] inserted_2_reg;
    logic [27:0] inserted_3_reg;
    logic executed_0_reg;
    logic executed_1_reg;
    logic executed_2_reg;
    logic executed_3_reg;
    logic flushbit;
    logic exceptionbit;
    logic [3:0] executedCommitTime;    
    logic [3:0] validCommitTime;
    logic [3:0] exceptionCommitTime;
    logic full_reg;

    assign full = full_reg;
    assign tail_next = (full_reg) ? tail:(tail + (({1'b0, inserted} + 1) >> 1));
    assign sum_head = {2'b0, head};
    assign sum_tail = {2'b0, tail} + 4;
    assign full_reg = (sum_tail - 1) >= sum_head;
    assign flushbit = (flushInst) ? 1'b0 : Q[flushIndex][0];
    assign exceptionbit = (exception) ? 1'b1 : Q[exceptionIndex][1];
    assign executedCommitTime = {Q[head+3][2], Q[head+2][2], Q[head+1][2], Q[head+0][2]};
    assign validCommitTime = {Q[head+3][0], Q[head+2][0], Q[head+1][0], Q[head+0][0]};
    assign exceptionCommitTime = {Q[head+3][1], Q[head+2][1], Q[head+1][1], Q[head+0][1]};

    assign inserted_0_reg = (full_reg) ? Q[tail+0]:{archReg0, physReg0, opcode0, 1'b0, 1'b0, 1'b1}; 
    assign inserted_1_reg = (full_reg) ? Q[tail+1]:{archReg1, physReg1, opcode1, 1'b0, 1'b0, 1'b1}; 
    assign inserted_2_reg = (full_reg) ? Q[tail+2]:{archReg2, physReg2, opcode2, 1'b0, 1'b0, 1'b1};      
    assign inserted_3_reg = (full_reg) ? Q[tail+3]:{archReg3, physReg3, opcode3, 1'b0, 1'b0, 1'b1}; 

    assign executed_0_reg = (executed[0]) ? 1'b1 : Q[executedIndex0][2];
    assign executed_1_reg = (executed[1]) ? 1'b1 : Q[executedIndex1][2];    
    assign executed_2_reg = (executed[2]) ? 1'b1 : Q[executedIndex2][2];
    assign executed_3_reg = (executed[3]) ? 1'b1 : Q[executedIndex3][2];
    
    //Commit engine 
    always_comb begin
        unique case (executedCommitTime)
            4'bxxx0:begin
            head_next = head + 0;
            numCommited = 0;
            end
            4'bxx01: begin
            head_next = head + 1;
            numCommited = {2'b0,validCommitTime[0] & (~exceptionCommitTime[0])};
            end
            4'bx011:begin
            head_next = head + 2;
            numCommited = {2'b0,validCommitTime[0] & (~exceptionCommitTime[0])} + {2'b0,validCommitTime[1] & (~exceptionCommitTime[1])}; 
            end
            4'b0111:begin
            head_next = head + 3;
            numCommited = {2'b0,validCommitTime[0] & (~exceptionCommitTime[0])} + {2'b0,validCommitTime[1] & (~exceptionCommitTime[1])} + {2'b0,validCommitTime[2] & (~exceptionCommitTime[2])};   
            end
            4'b1111:begin
            head_next = head + 4;            
            numCommited = {2'b0,validCommitTime[0] & (~exceptionCommitTime[0])} + {2'b0,validCommitTime[1] & (~exceptionCommitTime[1])} + {2'b0,validCommitTime[2] & (~exceptionCommitTime[2])} + {2'b0,validCommitTime[3] & (~exceptionCommitTime[3])};    
            end
            default:begin            
            head_next = head + 0;
            numCommited = 0;
            end
        endcase

    end



    always_ff @ (posedge clk, negedge reset) begin
        if(~reset) begin
           Q <= {27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 
                27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0}; 
           head <= 0;
           tail <= 0;
        end
        else begin
            //insertion
                Q[tail+0] <= inserted_0_reg;
                Q[tail+1] <= inserted_1_reg;
                Q[tail+2] <= inserted_2_reg;
                Q[tail+3] <= inserted_3_reg;
                tail <= tail_next;   
            //flush
            Q[flushIndex][0] <= flushbit;
            //exception
            Q[exceptionIndex][1] <= exceptionbit;
            //execution
            Q[executedIndex0][2] <= executed_0_reg;
            Q[executedIndex1][2] <= executed_1_reg;
            Q[executedIndex2][2] <= executed_2_reg;
            Q[executedIndex3][2] <= executed_3_reg;
            //commit 
            head <= head_next;
        end
    end

endmodule : rob

module rob_tb;

    parameter  ClockDelay = 10;

    logic clk;
    logic reset;
    logic [3:0] inserted;
    logic [4:0] archReg0;
    logic [7:0] physReg0;
    logic [10:0] opcode0;
    logic [4:0] archReg1;
    logic [7:0] physReg1;
    logic [10:0] opcode1;
    logic [4:0] archReg2;
    logic [7:0] physReg2;
    logic [10:0] opcode2;
    logic [4:0] archReg3;
    logic [7:0] physReg3;
    logic [10:0] opcode3;
    logic flushInst;
    logic [6:0] flushIndex;
    logic exception;
    logic [6:0] exceptionIndex;
    logic [3:0] executed;
    logic [6:0] executedIndex0;
    logic [6:0] executedIndex1;
    logic [6:0] executedIndex2;
    logic [6:0] executedIndex3;
    logic [2:0] numCommited;
    logic full;


    rob DUT (clk, reset, inserted, archReg0, physReg0, opcode0, archReg1, physReg1, opcode1, archReg2, physReg2,
      opcode2, archReg3, physReg3, opcode3, flushInst, flushIndex, exception, exceptionIndex, executed,
      executedIndex0, executedIndex1, executedIndex2, executedIndex3, numCommited, full);


	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

    
    initial
    begin

        /*
        $dumpfile("rob.vcd");
        $dumpvars(0, rob_tb);
        */
        
        // Reset ports
        reset <= 0;
        inserted <= 4'b0;
        archReg0 <= 5'b0;
        physReg0 <= 8'b0;
        opcode0 <= 11'b0;
        archReg1 <= 5'b0;
        physReg1 <= 8'b0;
        opcode1 <= 11'b0;
        archReg2 <= 5'b0;
        physReg2 <= 8'b0;
        opcode2 <= 11'b0;
        archReg3 <= 5'b0;
        physReg3 <= 8'b0;
        opcode3 <= 11'b0;
        flushInst <= 1'b0;
        flushIndex <= 7'b0;
        exception <= 1'b0;
        exceptionIndex <= 7'b0;
        executed <= 4'b0;
        executedIndex0 <= 7'b0;
        executedIndex1 <= 7'b0;
        executedIndex2 <= 7'b0;
        executedIndex3 <= 7'b0;
        @(posedge clk);
        @(posedge clk);
        reset <= 1;
        @(posedge clk);
        // Test insertion
        inserted <= 4'b0001;
        archReg0 <= 5'd1;
        physReg0 <= 8'd2;
        opcode0 <= 11'd3;
        archReg1 <= 5'd4;
        physReg1 <= 8'd5;
        opcode1 <= 11'd6;
        archReg2 <= 5'd7;
        physReg2 <= 8'd8;
        opcode2 <= 11'd9;
        archReg3 <= 5'd10;
        physReg3 <= 8'd11;
        opcode3 <= 11'd12;
        @(posedge clk);
        inserted <= 4'b0001;
        @(posedge clk);
        inserted <= 4'b0001;
        @(posedge clk);
        inserted <= 4'b0001;
        @(posedge clk);
        inserted <= 4'b0000;
        inserted <= 4'b0;
        archReg0 <= 5'b0;
        physReg0 <= 8'b0;
        opcode0 <= 11'b0;
        archReg1 <= 5'b0;
        physReg1 <= 8'b0;
        opcode1 <= 11'b0;
        archReg2 <= 5'b0;
        physReg2 <= 8'b0;
        opcode2 <= 11'b0;
        archReg3 <= 5'b0;
        physReg3 <= 8'b0;
        opcode3 <= 11'b0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $display ("FINISHED!!!!!!!!!!!!!!!!!!!");
        $finish;
    end

    

endmodule
