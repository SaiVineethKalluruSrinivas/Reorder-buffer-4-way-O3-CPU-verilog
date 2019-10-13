`timescale 1ns / 1ps

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
logic [25:0] iq [31:0];
logic [2:0] insert_amount;
logic [25:0] inserted_0_reg;
logic [25:0] inserted_1_reg;
logic [25:0] inserted_2_reg;
logic [25:0] inserted_3_reg;
logic [31:0] free_mask [3:0];
logic [5:0] four_index_array_insert[3:0];
logic [31:0] leastOneIndexMaskInsert[3:0]; 

// Full checking wires
logic full_reg;
logic [4:0] full_count;

// Tag match wires
logic [25:0] iq_n [31:0];

// issuing wires
logic [31:0] ready_mask [3:0];
logic [5:0] four_index_array [3:0];
logic [31:0] leastOneIndexMask [3:0];
logic [3:0] is_valid_removed;
logic [6:0] issued_rob [3:0];
logic [3:0] empty_array_check;

//execution wire logic
logic [31:0] executedReg1;
logic [31:0] executedReg2;
logic [31:0] busybitAcc;

// Full checking
assign full = full_reg;
assign full_reg = (full_count > 27);

//assigning temporary wires for incoming instructions (not inserting them yet)
assign inserted_0_reg = {robIdx0, srcReg0_1, srcReg0_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_1_reg = {robIdx1, srcReg1_1, srcReg1_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_2_reg = {robIdx2, srcReg2_1, srcReg2_2, 1'b0, 1'b0, 1'b1};      
assign inserted_3_reg = {robIdx3, srcReg3_1, srcReg3_2, 1'b0, 1'b0, 1'b1};
//calculating number of instructions to be inserted in this cycle
assign insert_amount = (full_reg) ? 0:({2'b0, inserted[0]} + {2'b0, inserted[1]} + {2'b0, inserted[2]} + {2'b0, inserted[3]});


//Combination module below sweeps through the entire IQ and performs the following
//1) Performs tag match of each operand1 and sets bit in executedReg1 (not changing the iq yet)
//2) Performs tag match of each operand2 and sets bit in executedReg2 (not changing the iq yet)
//3) If no execution has happened in this cycle, set bits to value from previous cycle's iq
//4) Look if both operands are set (from the iq of previous cycle) for all IQ slots and create a mask of ready bits
//5) Look if top bit is '0' (from the iq of previous cycle) for all IQ slots and create a mask of free slots
// both free_mask and ready_mask are calculated for each cycle
always_comb begin
for(int i = 0; i <32; i++) begin
        if(executed && iq[i][0]) begin
            executedReg1[i] = (executedReg == iq[i][18:11]) ? 1'b1 : iq[i][2];
            executedReg2[i] = (executedReg == iq[i][10:3]) ? 1'b1 :iq[i][1];
        end
        else begin
            executedReg1[i] = iq[i][2];
            executedReg2[i] = iq[i][1];
        end
        ready_mask[0][i] = ((iq[i][2:1] == 2'b11) && iq[i][0]) ? 1'b1 : 1'b0;
        free_mask[0][31-i] = (iq[i][0]) ? 1'b0:1'b1; // Finding free mask
end
end

// Issuing
// Creating 4 issuing index array
always_comb begin
    leastOneIndexMask[0] = (ready_mask[0]) ? (((ready_mask[0] - 1) ^ ready_mask[0] ) >> 1) : 32'b0;
    four_index_array[0] = (ready_mask[0]) ? ({5'b0,leastOneIndexMask[0][0]} + {5'b0,leastOneIndexMask[0][1]} + {5'b0,leastOneIndexMask[0][2]} + {5'b0,leastOneIndexMask[0][3]} + {5'b0,leastOneIndexMask[0][4]} + {5'b0,leastOneIndexMask[0][5]} + {5'b0,leastOneIndexMask[0][6]} + {5'b0,leastOneIndexMask[0][7]} + {5'b0,leastOneIndexMask[0][8]} + {5'b0,leastOneIndexMask[0][9]} + {5'b0,leastOneIndexMask[0][10]} + {5'b0,leastOneIndexMask[0][11]} + {5'b0,leastOneIndexMask[0][12]} + {5'b0,leastOneIndexMask[0][13]} + {5'b0,leastOneIndexMask[0][14]} + {5'b0,leastOneIndexMask[0][15]} + {5'b0,leastOneIndexMask[0][16]} + {5'b0,leastOneIndexMask[0][17]} + {5'b0,leastOneIndexMask[0][18]} + {5'b0,leastOneIndexMask[0][19]} + {5'b0,leastOneIndexMask[0][20]} + {5'b0,leastOneIndexMask[0][21]} + {5'b0,leastOneIndexMask[0][22]} + {5'b0,leastOneIndexMask[0][23]} + {5'b0,leastOneIndexMask[0][24]} + {5'b0,leastOneIndexMask[0][25]} + {5'b0,leastOneIndexMask[0][26]} + {5'b0,leastOneIndexMask[0][27]} + {5'b0,leastOneIndexMask[0][28]} + {5'b0,leastOneIndexMask[0][29]} + {5'b0,leastOneIndexMask[0][30]} + {5'b0,leastOneIndexMask[0][31]}):6'd63;
    ready_mask[1] = ready_mask[0] & (~(leastOneIndexMask[0] + 1));

    leastOneIndexMask[1] = (ready_mask[1]) ? (((ready_mask[1] - 1) ^ ready_mask[1] ) >> 1) : 32'b0;
    four_index_array[1] = (ready_mask[1]) ? ({5'b0,leastOneIndexMask[1][0]} + {5'b0,leastOneIndexMask[1][1]} + {5'b0,leastOneIndexMask[1][2]} + {5'b0,leastOneIndexMask[1][3]} + {5'b0,leastOneIndexMask[1][4]} + {5'b0,leastOneIndexMask[1][5]} + {5'b0,leastOneIndexMask[1][6]} + {5'b0,leastOneIndexMask[1][7]} + {5'b0,leastOneIndexMask[1][8]} + {5'b0,leastOneIndexMask[1][9]} + {5'b0,leastOneIndexMask[1][10]} + {5'b0,leastOneIndexMask[1][11]} + {5'b0,leastOneIndexMask[1][12]} + {5'b0,leastOneIndexMask[1][13]} + {5'b0,leastOneIndexMask[1][14]} + {5'b0,leastOneIndexMask[1][15]} + {5'b0,leastOneIndexMask[1][16]} + {5'b0,leastOneIndexMask[1][17]} + {5'b0,leastOneIndexMask[1][18]} + {5'b0,leastOneIndexMask[1][19]} + {5'b0,leastOneIndexMask[1][20]} + {5'b0,leastOneIndexMask[1][21]} + {5'b0,leastOneIndexMask[1][22]} + {5'b0,leastOneIndexMask[1][23]} + {5'b0,leastOneIndexMask[1][24]} + {5'b0,leastOneIndexMask[1][25]} + {5'b0,leastOneIndexMask[1][26]} + {5'b0,leastOneIndexMask[1][27]} + {5'b0,leastOneIndexMask[1][28]} + {5'b0,leastOneIndexMask[1][29]} + {5'b0,leastOneIndexMask[1][30]} + {5'b0,leastOneIndexMask[1][31]}):6'd63;
    ready_mask[2] = ready_mask[1] & (~(leastOneIndexMask[1] + 1));

    leastOneIndexMask[2] = (ready_mask[2]) ? (((ready_mask[2] - 1) ^ ready_mask[2] ) >> 1) : 32'b0;
    four_index_array[2] = (ready_mask[2]) ? ({5'b0,leastOneIndexMask[2][0]} + {5'b0,leastOneIndexMask[2][1]} + {5'b0,leastOneIndexMask[2][2]} + {5'b0,leastOneIndexMask[2][3]} + {5'b0,leastOneIndexMask[2][4]} + {5'b0,leastOneIndexMask[2][5]} + {5'b0,leastOneIndexMask[2][6]} + {5'b0,leastOneIndexMask[2][7]} + {5'b0,leastOneIndexMask[2][8]} + {5'b0,leastOneIndexMask[2][9]} + {5'b0,leastOneIndexMask[2][10]} + {5'b0,leastOneIndexMask[2][11]} + {5'b0,leastOneIndexMask[2][12]} + {5'b0,leastOneIndexMask[2][13]} + {5'b0,leastOneIndexMask[2][14]} + {5'b0,leastOneIndexMask[2][15]} + {5'b0,leastOneIndexMask[2][16]} + {5'b0,leastOneIndexMask[2][17]} + {5'b0,leastOneIndexMask[2][18]} + {5'b0,leastOneIndexMask[2][19]} + {5'b0,leastOneIndexMask[2][20]} + {5'b0,leastOneIndexMask[2][21]} + {5'b0,leastOneIndexMask[2][22]} + {5'b0,leastOneIndexMask[2][23]} + {5'b0,leastOneIndexMask[2][24]} + {5'b0,leastOneIndexMask[2][25]} + {5'b0,leastOneIndexMask[2][26]} + {5'b0,leastOneIndexMask[2][27]} + {5'b0,leastOneIndexMask[2][28]} + {5'b0,leastOneIndexMask[2][29]} + {5'b0,leastOneIndexMask[2][30]} + {5'b0,leastOneIndexMask[2][31]}):6'd63;
    ready_mask[3] = ready_mask[2] & (~(leastOneIndexMask[2] + 1));

    leastOneIndexMask[3] = (ready_mask[3]) ? (((ready_mask[3] - 1) ^ ready_mask[3] ) >> 1) : 32'b0;
    four_index_array[3] = (ready_mask[3]) ? ({5'b0,leastOneIndexMask[3][0]} + {5'b0,leastOneIndexMask[3][1]} + {5'b0,leastOneIndexMask[3][2]} + {5'b0,leastOneIndexMask[3][3]} + {5'b0,leastOneIndexMask[3][4]} + {5'b0,leastOneIndexMask[3][5]} + {5'b0,leastOneIndexMask[3][6]} + {5'b0,leastOneIndexMask[3][7]} + {5'b0,leastOneIndexMask[3][8]} + {5'b0,leastOneIndexMask[3][9]} + {5'b0,leastOneIndexMask[3][10]} + {5'b0,leastOneIndexMask[3][11]} + {5'b0,leastOneIndexMask[3][12]} + {5'b0,leastOneIndexMask[3][13]} + {5'b0,leastOneIndexMask[3][14]} + {5'b0,leastOneIndexMask[3][15]} + {5'b0,leastOneIndexMask[3][16]} + {5'b0,leastOneIndexMask[3][17]} + {5'b0,leastOneIndexMask[3][18]} + {5'b0,leastOneIndexMask[3][19]} + {5'b0,leastOneIndexMask[3][20]} + {5'b0,leastOneIndexMask[3][21]} + {5'b0,leastOneIndexMask[3][22]} + {5'b0,leastOneIndexMask[3][23]} + {5'b0,leastOneIndexMask[3][24]} + {5'b0,leastOneIndexMask[3][25]} + {5'b0,leastOneIndexMask[3][26]} + {5'b0,leastOneIndexMask[3][27]} + {5'b0,leastOneIndexMask[3][28]} + {5'b0,leastOneIndexMask[3][29]} + {5'b0,leastOneIndexMask[3][30]} + {5'b0,leastOneIndexMask[3][31]}):6'd63;

end

//Combination module below assigns the busy bit of all IQ entry for next cycle.
//Accumulates busybit for IQ entry as 1'b0 if the IQ entry is chosen to be issued else sets it to previous cycle's IQ[0] value
//The busybits accumulated are not assigned to next cycle IQ yet.
always_comb begin
for (int k = 0; k < 32; k++) begin
    busybitAcc[k] = (k == four_index_array[0] || k== four_index_array[1] || k==four_index_array[2] || k==four_index_array[3]) ? 1'b0:iq[k][0];
end
end

always_comb begin
    leastOneIndexMaskInsert[0] = (free_mask[0]) ? (((free_mask[0] - 1) ^ free_mask[0] ) >> 1) : 32'b0;
    four_index_array_insert[0] = (free_mask[0]) ? (6'd31 - ({5'b0,leastOneIndexMaskInsert[0][0]} + {5'b0,leastOneIndexMaskInsert[0][1]} + {5'b0,leastOneIndexMaskInsert[0][2]} + {5'b0,leastOneIndexMaskInsert[0][3]} + {5'b0,leastOneIndexMaskInsert[0][4]} + {5'b0,leastOneIndexMaskInsert[0][5]} + {5'b0,leastOneIndexMaskInsert[0][6]} + {5'b0,leastOneIndexMaskInsert[0][7]} + {5'b0,leastOneIndexMaskInsert[0][8]} + {5'b0,leastOneIndexMaskInsert[0][9]} + {5'b0,leastOneIndexMaskInsert[0][10]} + {5'b0,leastOneIndexMaskInsert[0][11]} + {5'b0,leastOneIndexMaskInsert[0][12]} + {5'b0,leastOneIndexMaskInsert[0][13]} + {5'b0,leastOneIndexMaskInsert[0][14]} + {5'b0,leastOneIndexMaskInsert[0][15]} + {5'b0,leastOneIndexMaskInsert[0][16]} + {5'b0,leastOneIndexMaskInsert[0][17]} + {5'b0,leastOneIndexMaskInsert[0][18]} + {5'b0,leastOneIndexMaskInsert[0][19]} + {5'b0,leastOneIndexMaskInsert[0][20]} + {5'b0,leastOneIndexMaskInsert[0][21]} + {5'b0,leastOneIndexMaskInsert[0][22]} + {5'b0,leastOneIndexMaskInsert[0][23]} + {5'b0,leastOneIndexMaskInsert[0][24]} + {5'b0,leastOneIndexMaskInsert[0][25]} + {5'b0,leastOneIndexMaskInsert[0][26]} + {5'b0,leastOneIndexMaskInsert[0][27]} + {5'b0,leastOneIndexMaskInsert[0][28]} + {5'b0,leastOneIndexMaskInsert[0][29]} + {5'b0,leastOneIndexMaskInsert[0][30]} + {5'b0,leastOneIndexMaskInsert[0][31]})):6'd63;
    free_mask[1] = free_mask[0] & (~(leastOneIndexMaskInsert[0] + 1));

    leastOneIndexMaskInsert[1] = (free_mask[1]) ? (((free_mask[1] - 1) ^ free_mask[1] ) >> 1) : 32'b0;
    four_index_array_insert[1] = (free_mask[1]) ? (6'd31 - ({5'b0,leastOneIndexMaskInsert[1][0]} + {5'b0,leastOneIndexMaskInsert[1][1]} + {5'b0,leastOneIndexMaskInsert[1][2]} + {5'b0,leastOneIndexMaskInsert[1][3]} + {5'b0,leastOneIndexMaskInsert[1][4]} + {5'b0,leastOneIndexMaskInsert[1][5]} + {5'b0,leastOneIndexMaskInsert[1][6]} + {5'b0,leastOneIndexMaskInsert[1][7]} + {5'b0,leastOneIndexMaskInsert[1][8]} + {5'b0,leastOneIndexMaskInsert[1][9]} + {5'b0,leastOneIndexMaskInsert[1][10]} + {5'b0,leastOneIndexMaskInsert[1][11]} + {5'b0,leastOneIndexMaskInsert[1][12]} + {5'b0,leastOneIndexMaskInsert[1][13]} + {5'b0,leastOneIndexMaskInsert[1][14]} + {5'b0,leastOneIndexMaskInsert[1][15]} + {5'b0,leastOneIndexMaskInsert[1][16]} + {5'b0,leastOneIndexMaskInsert[1][17]} + {5'b0,leastOneIndexMaskInsert[1][18]} + {5'b0,leastOneIndexMaskInsert[1][19]} + {5'b0,leastOneIndexMaskInsert[1][20]} + {5'b0,leastOneIndexMaskInsert[1][21]} + {5'b0,leastOneIndexMaskInsert[1][22]} + {5'b0,leastOneIndexMaskInsert[1][23]} + {5'b0,leastOneIndexMaskInsert[1][24]} + {5'b0,leastOneIndexMaskInsert[1][25]} + {5'b0,leastOneIndexMaskInsert[1][26]} + {5'b0,leastOneIndexMaskInsert[1][27]} + {5'b0,leastOneIndexMaskInsert[1][28]} + {5'b0,leastOneIndexMaskInsert[1][29]} + {5'b0,leastOneIndexMaskInsert[1][30]} + {5'b0,leastOneIndexMaskInsert[1][31]})):6'd63;
    free_mask[2] = free_mask[1] & (~(leastOneIndexMaskInsert[1] + 1));

    leastOneIndexMaskInsert[2] = (free_mask[2]) ? (((free_mask[2] - 1) ^ free_mask[2] ) >> 1) : 32'b0;
    four_index_array_insert[2] = (free_mask[2]) ? (6'd31 - ({5'b0,leastOneIndexMaskInsert[2][0]} + {5'b0,leastOneIndexMaskInsert[2][1]} + {5'b0,leastOneIndexMaskInsert[2][2]} + {5'b0,leastOneIndexMaskInsert[2][3]} + {5'b0,leastOneIndexMaskInsert[2][4]} + {5'b0,leastOneIndexMaskInsert[2][5]} + {5'b0,leastOneIndexMaskInsert[2][6]} + {5'b0,leastOneIndexMaskInsert[2][7]} + {5'b0,leastOneIndexMaskInsert[2][8]} + {5'b0,leastOneIndexMaskInsert[2][9]} + {5'b0,leastOneIndexMaskInsert[2][10]} + {5'b0,leastOneIndexMaskInsert[2][11]} + {5'b0,leastOneIndexMaskInsert[2][12]} + {5'b0,leastOneIndexMaskInsert[2][13]} + {5'b0,leastOneIndexMaskInsert[2][14]} + {5'b0,leastOneIndexMaskInsert[2][15]} + {5'b0,leastOneIndexMaskInsert[2][16]} + {5'b0,leastOneIndexMaskInsert[2][17]} + {5'b0,leastOneIndexMaskInsert[2][18]} + {5'b0,leastOneIndexMaskInsert[2][19]} + {5'b0,leastOneIndexMaskInsert[2][20]} + {5'b0,leastOneIndexMaskInsert[2][21]} + {5'b0,leastOneIndexMaskInsert[2][22]} + {5'b0,leastOneIndexMaskInsert[2][23]} + {5'b0,leastOneIndexMaskInsert[2][24]} + {5'b0,leastOneIndexMaskInsert[2][25]} + {5'b0,leastOneIndexMaskInsert[2][26]} + {5'b0,leastOneIndexMaskInsert[2][27]} + {5'b0,leastOneIndexMaskInsert[2][28]} + {5'b0,leastOneIndexMaskInsert[2][29]} + {5'b0,leastOneIndexMaskInsert[2][30]} + {5'b0,leastOneIndexMaskInsert[2][31]})):6'd63;
    free_mask[3] = free_mask[2] & (~(leastOneIndexMaskInsert[2] + 1));

    leastOneIndexMaskInsert[3] = (free_mask[3]) ? (((free_mask[3] - 1) ^ free_mask[3] ) >> 1) : 32'b0;
    four_index_array_insert[3] = (free_mask[3]) ? (6'd31 - ({5'b0,leastOneIndexMaskInsert[3][0]} + {5'b0,leastOneIndexMaskInsert[3][1]} + {5'b0,leastOneIndexMaskInsert[3][2]} + {5'b0,leastOneIndexMaskInsert[3][3]} + {5'b0,leastOneIndexMaskInsert[3][4]} + {5'b0,leastOneIndexMaskInsert[3][5]} + {5'b0,leastOneIndexMaskInsert[3][6]} + {5'b0,leastOneIndexMaskInsert[3][7]} + {5'b0,leastOneIndexMaskInsert[3][8]} + {5'b0,leastOneIndexMaskInsert[3][9]} + {5'b0,leastOneIndexMaskInsert[3][10]} + {5'b0,leastOneIndexMaskInsert[3][11]} + {5'b0,leastOneIndexMaskInsert[3][12]} + {5'b0,leastOneIndexMaskInsert[3][13]} + {5'b0,leastOneIndexMaskInsert[3][14]} + {5'b0,leastOneIndexMaskInsert[3][15]} + {5'b0,leastOneIndexMaskInsert[3][16]} + {5'b0,leastOneIndexMaskInsert[3][17]} + {5'b0,leastOneIndexMaskInsert[3][18]} + {5'b0,leastOneIndexMaskInsert[3][19]} + {5'b0,leastOneIndexMaskInsert[3][20]} + {5'b0,leastOneIndexMaskInsert[3][21]} + {5'b0,leastOneIndexMaskInsert[3][22]} + {5'b0,leastOneIndexMaskInsert[3][23]} + {5'b0,leastOneIndexMaskInsert[3][24]} + {5'b0,leastOneIndexMaskInsert[3][25]} + {5'b0,leastOneIndexMaskInsert[3][26]} + {5'b0,leastOneIndexMaskInsert[3][27]} + {5'b0,leastOneIndexMaskInsert[3][28]} + {5'b0,leastOneIndexMaskInsert[3][29]} + {5'b0,leastOneIndexMaskInsert[3][30]} + {5'b0,leastOneIndexMaskInsert[3][31]})):6'd63;
end


//Combination module below assigns IQ values to be updated for the next cycle
always_comb begin
for (int l = 0; l < 32; l++) begin
    //if index matches first free index then insert first reg here
    if(l == four_index_array_insert[0] && inserted[0]) begin
        iq_n[l][0] = inserted_0_reg[0];
        iq_n[l][25:3] = inserted_0_reg[25:3];
        iq_n[l][2] = inserted_0_reg[2];
        iq_n[l][1] = inserted_0_reg[1];
    end
    //if index matches second free index then insert second reg here
    else if(l == four_index_array_insert[1] && inserted[1]) begin
        iq_n[l][0] = inserted_1_reg[0];
        iq_n[l][25:3] = inserted_1_reg[25:3];
        iq_n[l][2] = inserted_1_reg[2];
        iq_n[l][1] = inserted_1_reg[1];
    end

    //if index matches third free index then insert third reg here
    else if(l == four_index_array_insert[2] && inserted[2]) begin
        iq_n[l][0] = inserted_2_reg[0];
        iq_n[l][25:3] = inserted_2_reg[25:3];
        iq_n[l][2] = inserted_2_reg[2];
        iq_n[l][1] = inserted_2_reg[1];
    end

    //if index matches fourth  free index then insert fourth reg here
    else if(l == four_index_array_insert[3] && inserted[3]) begin
        iq_n[l][0] = inserted_3_reg[0];
        iq_n[l][25:3] = inserted_3_reg[25:3];
        iq_n[l][2] = inserted_3_reg[2];
        iq_n[l][1] = inserted_3_reg[1];
    end
    else begin
    //if the index is not an insert index, then use all the accumulation registers created uptill now and assign the value for IQ_next cycle to be
    //value accumulated from IQ_previous cycle
       iq_n[l][0] = busybitAcc[l]; 
       iq_n[l][25:3] = iq[l][25:3];
       iq_n[l][2] = executedReg1[l];
       iq_n[l][1] = executedReg2[l];
    end

end
end

assign empty_array_check[0] = (four_index_array[0] != 63);
assign empty_array_check[1] = (four_index_array[1] != 63);
assign empty_array_check[2] = (four_index_array[2] != 63);
assign empty_array_check[3] = (four_index_array[3] != 63);

//If any of the indices chosen for issue is 63, then it is not valid and hence should not be counted towards num issued
//the numIssued for next cycle is directly issued here
assign is_valid_removed[0] = (empty_array_check[0]) ? 1'b1 : 1'b0;
assign is_valid_removed[1] = (empty_array_check[1]) ? 1'b1 : 1'b0;
assign is_valid_removed[2] = (empty_array_check[2]) ? 1'b1 : 1'b0;
assign is_valid_removed[3] = (empty_array_check[3]) ? 1'b1 : 1'b0;
assign numIssued = ({2'b0, is_valid_removed[0]} + {2'b0, is_valid_removed[1]} + {2'b0, is_valid_removed[2]} + {2'b0, is_valid_removed[3]});

// Assigining issued IQ entry's ROB index directly to outputs, making right ROB output values available on clock
assign issued0 = (empty_array_check[0]) ? iq[four_index_array[0]][25:19] : 0; 
assign issued1 = (empty_array_check[1]) ? iq[four_index_array[1]][25:19] : 0;
assign issued2 = (empty_array_check[2]) ? iq[four_index_array[2]][25:19] : 0;
assign issued3 = (empty_array_check[3]) ? iq[four_index_array[3]][25:19] : 0;

// Set new IQ (or IQ for next cycle) on positive edge of the clock
// Update full_count (keeps track of number of isnts in the IQ) also on clock
always_ff @ (posedge clk) begin
if (~reset) begin
    iq <= '{default:0};
    full_count <= 5'b0;
end else begin
    iq <= iq_n;
    full_count <= full_count + insert_amount - numIssued;
end
end

endmodule: iq
