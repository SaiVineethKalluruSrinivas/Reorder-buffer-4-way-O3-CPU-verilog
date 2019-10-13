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
    logic [26:0] inserted_0_reg;
    logic [26:0] inserted_1_reg;
    logic [26:0] inserted_2_reg;
    logic [26:0] inserted_3_reg;
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
    logic [6:0] full_count;
    logic [2:0] insert_amount;

    assign full = full_reg;
    //calculating number of insts to be inserted in this cycle
    assign insert_amount = (full_reg) ? 0:({2'b0, inserted[0]} + {2'b0, inserted[1]} + {2'b0, inserted[2]} + {2'b0, inserted[3]});
    //storing the new value for tail after insertion
    assign tail_next = (full_reg) ? tail:(tail + insert_amount);
    //checking for full (if counter > 125) because only less than insts would be possible to insert otherwise
    assign full_reg = (full_count > 125);
    //setting valid bit for inst to be flushed
    assign flushbit = (flushInst) ? 1'b0 : Q[flushIndex][0];
    //setting exeception bit for inst with exeception
    assign exceptionbit = (exception) ? 1'b1 : Q[exceptionIndex][1];
    //creating masks for executed bits, valid bits and commit bits for 4 insts from the head of queue
    assign executedCommitTime = {Q[head+3][2], Q[head+2][2], Q[head+1][2], Q[head+0][2]};
    assign validCommitTime = {Q[head+3][0], Q[head+2][0], Q[head+1][0], Q[head+0][0]};
    assign exceptionCommitTime = {Q[head+3][1], Q[head+2][1], Q[head+1][1], Q[head+0][1]};

    //creating temporary wires assigned to incoming inserted regs (not assigning them into rob yet)
    assign inserted_0_reg = (full_reg) ? Q[tail]:{archReg0, physReg0, opcode0, 1'b0, 1'b0, 1'b1}; 
    assign inserted_1_reg = (full_reg) ? Q[tail+1]:{archReg1, physReg1, opcode1, 1'b0, 1'b0, 1'b1}; 
    assign inserted_2_reg = (full_reg) ? Q[tail+2]:{archReg2, physReg2, opcode2, 1'b0, 1'b0, 1'b1};      
    assign inserted_3_reg = (full_reg) ? Q[tail+3]:{archReg3, physReg3, opcode3, 1'b0, 1'b0, 1'b1}; 

    //creating executed bits for instructions that have executed
    assign executed_0_reg = (executed[0]) ? 1'b1 : Q[executedIndex0][2];
    assign executed_1_reg = (executed[1]) ? 1'b1 : Q[executedIndex1][2];    
    assign executed_2_reg = (executed[2]) ? 1'b1 : Q[executedIndex2][2];
    assign executed_3_reg = (executed[3]) ? 1'b1 : Q[executedIndex3][2];
    
    //Combination module checks for different execution cases possible for 4 insts from head
    //Inst is popped if it is executed and head is incremented to 1
    //While popping inst is also checked if it is valid without exception -> then num committed variable is incremented
    //the case statement was designed to ensure that insts do not pop as soon as a executed zero bit (a.k.a not executed inst) is encountered while checking 4 isnts from head
    always_comb begin
        casex (executedCommitTime)
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


    //The main clock module which sets the right value at positive edge of the clock
    always_ff @ (posedge clk) begin
        if(~reset) begin
            //initializing ROB on reset
           Q <= {27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 
                27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0, 27'b0 ,27'b0 ,27'b0, 27'b0}; 
           //Head is initialized to zero, as popping happens from head
           head <= 0;
           //tail is initialized to zero, as insts are added from index 0
           tail <= 0;
           //full_count keeps track of total insts in queue, it is set to 0 on reset.
           full_count <= 0;
        end
        else begin
            //total insts in queue = num_of_insts calculated before cycle + num_inserted in this cycle - num_commited in this cycle
            full_count <= full_count + insert_amount - numCommited;
            //inserting temporary values from tail to tail+3;
            Q[tail+0] <= inserted_0_reg;
            Q[tail+1] <= inserted_1_reg;
            Q[tail+2] <= inserted_2_reg;
            Q[tail+3] <= inserted_3_reg;
            //assigning new tail to next cycle
            tail <= tail_next;   
            //assigning flush bit to inst to be flushed
            Q[flushIndex][0] <= flushbit;
            //assigning exception bit to exception causing inst;
            Q[exceptionIndex][1] <= exceptionbit;
            //assigning executed bit to indices that have been executed
            Q[executedIndex0][2] <= executed_0_reg;
            Q[executedIndex1][2] <= executed_1_reg;
            Q[executedIndex2][2] <= executed_2_reg;
            Q[executedIndex3][2] <= executed_3_reg;
            //assigning new value of head, after popping insts
            head <= head_next;
        end
    end

endmodule : rob
