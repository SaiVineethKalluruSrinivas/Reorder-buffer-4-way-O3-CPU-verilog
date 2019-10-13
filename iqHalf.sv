`timescale 1ns / 1ps
/*
* Author: Sai Vineeth Kalluru Srinivas, Jiachen Zou
* 16 Entries low-reset Issue Queue with Issue/insert width of 4
* Utilize a queue that does simple see-and-issue policy, which always
* seach for the first ready entry from the begin of the queue
* IQ entry: 7-bit ROB index, two 8-bit destination physical register numbers 
* (one for each source), two ready bits (one for each source), and
* a valid bit. 
*/
module iq (
 input clk,
 input reset,
 input logic [3:0] inserted,
 input logic [6:0] robIdx0,
 input logic [7:0] srcReg0_1,
 input logic [7:0] srcReg0_2, 
 input logic [6:0] robIdx1,
 input logic [7:0] srcReg1_1,
 input logic [7:0] srcReg1_2,
 input logic [6:0] robIdx2,
 input logic [7:0] srcReg2_1,
 input logic [7:0] srcReg2_2,
 input logic [6:0] robIdx3,
 input logic [7:0] srcReg3_1,
 input logic [7:0] srcReg3_2,
 input logic executed,
 input logic [7:0] executedReg,
 output logic [2:0] numIssued,
 output logic [6:0] issued0,
 output logic [6:0] issued1,
 output logic [6:0] issued2,
 output logic [6:0] issued3,
 output logic full
); 

// Insertion wires
logic [25:0] iq [15:0];
logic [2:0] insert_amount;
logic [25:0] inserted_0_reg;
logic [25:0] inserted_1_reg;
logic [25:0] inserted_2_reg;
logic [25:0] inserted_3_reg;
logic [15:0] free_mask [3:0];
logic [4:0] four_index_array_insert[3:0];
logic [15:0] leastOneIndexMaskInsert[3:0]; 

// Full checking wires
logic full_reg;
logic [3:0] full_count;

// Tag match wires
logic [25:0] iq_n [15:0];

// issuing wires
logic [15:0] ready_mask [3:0];
logic [4:0] four_index_array [3:0];
logic [15:0] leastOneIndexMask [3:0];
logic [3:0] is_valid_removed;
logic [6:0] issued_rob [3:0];
logic [3:0] empty_array_check;

//execution wire logic
logic [15:0] executedReg1;
logic [15:0] executedReg2;
logic [15:0] busybitAcc;

// Full checking
assign full = full_reg;
assign full_reg = (full_count > 12);

// Insertion
assign inserted_0_reg = {robIdx0, srcReg0_1, srcReg0_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_1_reg = {robIdx1, srcReg1_1, srcReg1_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_2_reg = {robIdx2, srcReg2_1, srcReg2_2, 1'b0, 1'b0, 1'b1};      
assign inserted_3_reg = {robIdx3, srcReg3_1, srcReg3_2, 1'b0, 1'b0, 1'b1}; 
assign insert_amount = (full_reg) ? 0:({2'b0, inserted[0]} + {2'b0, inserted[1]} + {2'b0, inserted[2]} + {2'b0, inserted[3]});

// Reg Monitoring & Finding ready mask
always_comb begin
for(int i = 0; i <16; i++) begin
        if(executed && iq[i][0]) begin
            executedReg1[i] = (executedReg == iq[i][18:11]) ? 1'b1 : iq[i][2];
            executedReg2[i] = (executedReg == iq[i][10:3]) ? 1'b1 :iq[i][1];
        end
        else begin
            executedReg1[i] = iq[i][2];
            executedReg2[i] = iq[i][1];
        end
        ready_mask[0][i] = ((iq[i][2:1] == 2'b11) && iq[i][0]) ? 1'b1 : 1'b0;
        free_mask[0][i] = (iq[i][0]) ? 1'b0:1'b1; // Finding free mask
end
end

// Issuing
// Creating 4 issuing index array
always_comb begin
    leastOneIndexMask[0] = (ready_mask[0]) ? (((ready_mask[0] - 1) ^ ready_mask[0] ) >> 1) : 16'b0;
    four_index_array[0] = (ready_mask[0]) ? ({4'b0,leastOneIndexMask[0][0]} + {4'b0,leastOneIndexMask[0][1]} + {4'b0,leastOneIndexMask[0][2]} + {4'b0,leastOneIndexMask[0][3]} + {4'b0,leastOneIndexMask[0][4]} + {4'b0,leastOneIndexMask[0][5]} + {4'b0,leastOneIndexMask[0][6]} + {4'b0,leastOneIndexMask[0][7]} + {4'b0,leastOneIndexMask[0][8]} + {4'b0,leastOneIndexMask[0][9]} + {4'b0,leastOneIndexMask[0][10]} + {4'b0,leastOneIndexMask[0][11]} + {4'b0,leastOneIndexMask[0][12]} + {4'b0,leastOneIndexMask[0][13]} + {4'b0,leastOneIndexMask[0][14]} + {4'b0,leastOneIndexMask[0][15]}):5'd31;
    ready_mask[1] = ready_mask[0] & (~(leastOneIndexMask[0] + 1));

    leastOneIndexMask[1] = (ready_mask[1]) ? (((ready_mask[1] - 1) ^ ready_mask[1] ) >> 1) : 16'b0;
    four_index_array[1] = (ready_mask[1]) ? ({4'b0,leastOneIndexMask[1][0]} + {4'b0,leastOneIndexMask[1][1]} + {4'b0,leastOneIndexMask[1][2]} + {4'b0,leastOneIndexMask[1][3]} + {4'b0,leastOneIndexMask[1][4]} + {4'b0,leastOneIndexMask[1][5]} + {4'b0,leastOneIndexMask[1][6]} + {4'b0,leastOneIndexMask[1][7]} + {4'b0,leastOneIndexMask[1][8]} + {4'b0,leastOneIndexMask[1][9]} + {4'b0,leastOneIndexMask[1][10]} + {4'b0,leastOneIndexMask[1][11]} + {4'b0,leastOneIndexMask[1][12]} + {4'b0,leastOneIndexMask[1][13]} + {4'b0,leastOneIndexMask[1][14]} + {4'b0,leastOneIndexMask[1][15]}):5'd31;
    ready_mask[2] = ready_mask[1] & (~(leastOneIndexMask[1] + 1));

    leastOneIndexMask[2] = (ready_mask[2]) ? (((ready_mask[2] - 1) ^ ready_mask[2] ) >> 1) : 16'b0;
    four_index_array[2] = (ready_mask[2]) ? ({4'b0,leastOneIndexMask[2][0]} + {4'b0,leastOneIndexMask[2][1]} + {4'b0,leastOneIndexMask[2][2]} + {4'b0,leastOneIndexMask[2][3]} + {4'b0,leastOneIndexMask[2][4]} + {4'b0,leastOneIndexMask[2][5]} + {4'b0,leastOneIndexMask[2][6]} + {4'b0,leastOneIndexMask[2][7]} + {4'b0,leastOneIndexMask[2][8]} + {4'b0,leastOneIndexMask[2][9]} + {4'b0,leastOneIndexMask[2][10]} + {4'b0,leastOneIndexMask[2][11]} + {4'b0,leastOneIndexMask[2][12]} + {4'b0,leastOneIndexMask[2][13]} + {4'b0,leastOneIndexMask[2][14]} + {4'b0,leastOneIndexMask[2][15]}):5'd31;
    ready_mask[3] = ready_mask[2] & (~(leastOneIndexMask[2] + 1));

    leastOneIndexMask[3] = (ready_mask[3]) ? (((ready_mask[3] - 1) ^ ready_mask[3] ) >> 1) : 16'b0;
    four_index_array[3] = (ready_mask[3]) ? ({4'b0,leastOneIndexMask[3][0]} + {4'b0,leastOneIndexMask[3][1]} + {4'b0,leastOneIndexMask[3][2]} + {4'b0,leastOneIndexMask[3][3]} + {4'b0,leastOneIndexMask[3][4]} + {4'b0,leastOneIndexMask[3][5]} + {4'b0,leastOneIndexMask[3][6]} + {4'b0,leastOneIndexMask[3][7]} + {4'b0,leastOneIndexMask[3][8]} + {4'b0,leastOneIndexMask[3][9]} + {4'b0,leastOneIndexMask[3][10]} + {4'b0,leastOneIndexMask[3][11]} + {4'b0,leastOneIndexMask[3][12]} + {4'b0,leastOneIndexMask[3][13]} + {4'b0,leastOneIndexMask[3][14]} + {4'b0,leastOneIndexMask[3][15]}):5'd31;

end


always_comb begin
for (int k = 0; k < 16; k++) begin
    busybitAcc[k] = (k == four_index_array[0] || k== four_index_array[1] || k==four_index_array[2] || k==four_index_array[3]) ? 1'b0:iq[k][0];
end
end

always_comb begin
    leastOneIndexMaskInsert[0] = (free_mask[0]) ? (((free_mask[0] - 1) ^ free_mask[0] ) >> 1) : 16'b0;
    four_index_array_insert[0] = (free_mask[0]) ? (({4'b0,leastOneIndexMaskInsert[0][0]} + {4'b0,leastOneIndexMaskInsert[0][1]} + {4'b0,leastOneIndexMaskInsert[0][2]} + {4'b0,leastOneIndexMaskInsert[0][3]} + {4'b0,leastOneIndexMaskInsert[0][4]} + {4'b0,leastOneIndexMaskInsert[0][5]} + {4'b0,leastOneIndexMaskInsert[0][6]} + {4'b0,leastOneIndexMaskInsert[0][7]} + {4'b0,leastOneIndexMaskInsert[0][8]} + {4'b0,leastOneIndexMaskInsert[0][9]} + {4'b0,leastOneIndexMaskInsert[0][10]} + {4'b0,leastOneIndexMaskInsert[0][11]} + {4'b0,leastOneIndexMaskInsert[0][12]} + {4'b0,leastOneIndexMaskInsert[0][13]} + {4'b0,leastOneIndexMaskInsert[0][14]} + {4'b0,leastOneIndexMaskInsert[0][15]})):5'd31;
    free_mask[1] = free_mask[0] & (~(leastOneIndexMaskInsert[0] + 1));

    leastOneIndexMaskInsert[1] = (free_mask[1]) ? (((free_mask[1] - 1) ^ free_mask[1] ) >> 1) : 16'b0;
    four_index_array_insert[1] = (free_mask[1]) ? (({4'b0,leastOneIndexMaskInsert[1][0]} + {4'b0,leastOneIndexMaskInsert[1][1]} + {4'b0,leastOneIndexMaskInsert[1][2]} + {4'b0,leastOneIndexMaskInsert[1][3]} + {4'b0,leastOneIndexMaskInsert[1][4]} + {4'b0,leastOneIndexMaskInsert[1][5]} + {4'b0,leastOneIndexMaskInsert[1][6]} + {4'b0,leastOneIndexMaskInsert[1][7]} + {4'b0,leastOneIndexMaskInsert[1][8]} + {4'b0,leastOneIndexMaskInsert[1][9]} + {4'b0,leastOneIndexMaskInsert[1][10]} + {4'b0,leastOneIndexMaskInsert[1][11]} + {4'b0,leastOneIndexMaskInsert[1][12]} + {4'b0,leastOneIndexMaskInsert[1][13]} + {4'b0,leastOneIndexMaskInsert[1][14]} + {4'b0,leastOneIndexMaskInsert[1][15]})):5'd31;
    free_mask[2] = free_mask[1] & (~(leastOneIndexMaskInsert[1] + 1));

    leastOneIndexMaskInsert[2] = (free_mask[2]) ? (((free_mask[2] - 1) ^ free_mask[2] ) >> 1) : 16'b0;
    four_index_array_insert[2] = (free_mask[2]) ? (({4'b0,leastOneIndexMaskInsert[2][0]} + {4'b0,leastOneIndexMaskInsert[2][1]} + {4'b0,leastOneIndexMaskInsert[2][2]} + {4'b0,leastOneIndexMaskInsert[2][3]} + {4'b0,leastOneIndexMaskInsert[2][4]} + {4'b0,leastOneIndexMaskInsert[2][5]} + {4'b0,leastOneIndexMaskInsert[2][6]} + {4'b0,leastOneIndexMaskInsert[2][7]} + {4'b0,leastOneIndexMaskInsert[2][8]} + {4'b0,leastOneIndexMaskInsert[2][9]} + {4'b0,leastOneIndexMaskInsert[2][10]} + {4'b0,leastOneIndexMaskInsert[2][11]} + {4'b0,leastOneIndexMaskInsert[2][12]} + {4'b0,leastOneIndexMaskInsert[2][13]} + {4'b0,leastOneIndexMaskInsert[2][14]} + {4'b0,leastOneIndexMaskInsert[2][15]})):5'd31;
    free_mask[3] = free_mask[2] & (~(leastOneIndexMaskInsert[2] + 1));

    leastOneIndexMaskInsert[3] = (free_mask[3]) ? (((free_mask[3] - 1) ^ free_mask[3] ) >> 1) : 16'b0;
    four_index_array_insert[3] = (free_mask[3]) ? (({4'b0,leastOneIndexMaskInsert[3][0]} + {4'b0,leastOneIndexMaskInsert[3][1]} + {4'b0,leastOneIndexMaskInsert[3][2]} + {4'b0,leastOneIndexMaskInsert[3][3]} + {4'b0,leastOneIndexMaskInsert[3][4]} + {4'b0,leastOneIndexMaskInsert[3][5]} + {4'b0,leastOneIndexMaskInsert[3][6]} + {4'b0,leastOneIndexMaskInsert[3][7]} + {4'b0,leastOneIndexMaskInsert[3][8]} + {4'b0,leastOneIndexMaskInsert[3][9]} + {4'b0,leastOneIndexMaskInsert[3][10]} + {4'b0,leastOneIndexMaskInsert[3][11]} + {4'b0,leastOneIndexMaskInsert[3][12]} + {4'b0,leastOneIndexMaskInsert[3][13]} + {4'b0,leastOneIndexMaskInsert[3][14]} + {4'b0,leastOneIndexMaskInsert[3][15]})):5'd31;
end

always_comb begin
for (int l = 0; l < 16; l++) begin
    if(l == four_index_array_insert[0] && inserted[0]) begin
        iq_n[l][0] = inserted_0_reg[0];
        iq_n[l][25:3] = inserted_0_reg[25:3];
        iq_n[l][2] = inserted_0_reg[2];
        iq_n[l][1] = inserted_0_reg[1];
    end
    else if(l == four_index_array_insert[1] && inserted[1]) begin
        iq_n[l][0] = inserted_1_reg[0];
        iq_n[l][25:3] = inserted_1_reg[25:3];
        iq_n[l][2] = inserted_1_reg[2];
        iq_n[l][1] = inserted_1_reg[1];
    end

    else if(l == four_index_array_insert[2] && inserted[2]) begin
        iq_n[l][0] = inserted_2_reg[0];
        iq_n[l][25:3] = inserted_2_reg[25:3];
        iq_n[l][2] = inserted_2_reg[2];
        iq_n[l][1] = inserted_2_reg[1];
    end

    else if(l == four_index_array_insert[3] && inserted[3]) begin
        iq_n[l][0] = inserted_3_reg[0];
        iq_n[l][25:3] = inserted_3_reg[25:3];
        iq_n[l][2] = inserted_3_reg[2];
        iq_n[l][1] = inserted_3_reg[1];
    end
    else begin
       iq_n[l][0] = busybitAcc[l]; 
       iq_n[l][25:3] = iq[l][25:3];
       iq_n[l][2] = executedReg1[l];
       iq_n[l][1] = executedReg2[l];
    end

end
end

assign empty_array_check[0] = (four_index_array[0] != 31);
assign empty_array_check[1] = (four_index_array[1] != 31);
assign empty_array_check[2] = (four_index_array[2] != 31);
assign empty_array_check[3] = (four_index_array[3] != 31);

assign is_valid_removed[0] = (empty_array_check[0]) ? 1'b1 : 1'b0;
assign is_valid_removed[1] = (empty_array_check[1]) ? 1'b1 : 1'b0;
assign is_valid_removed[2] = (empty_array_check[2]) ? 1'b1 : 1'b0;
assign is_valid_removed[3] = (empty_array_check[3]) ? 1'b1 : 1'b0;

// Output Assignment
assign numIssued = ({2'b0, is_valid_removed[0]} + {2'b0, is_valid_removed[1]} + {2'b0, is_valid_removed[2]} + {2'b0, is_valid_removed[3]});
assign issued0 = (empty_array_check[0]) ? iq[four_index_array[0]][25:19] : 0; 
assign issued1 = (empty_array_check[1]) ? iq[four_index_array[1]][25:19] : 0;
assign issued2 = (empty_array_check[2]) ? iq[four_index_array[2]][25:19] : 0;
assign issued3 = (empty_array_check[3]) ? iq[four_index_array[3]][25:19] : 0;

always_ff @ (posedge clk) begin
if (~reset) begin
    iq <= '{default:0};
    full_count <= 4'b0;
end else begin
    iq <= iq_n;
    full_count <= full_count + insert_amount - numIssued;
end
end

endmodule: iq
