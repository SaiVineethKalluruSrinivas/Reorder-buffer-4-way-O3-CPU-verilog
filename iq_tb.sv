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
logic [2:0] shift_amount [31:0];
logic [3:0] is_valid_removed;
logic [6:0] issued_rob [3:0];

//execution wire logic
logic [31:0] executedReg1;
logic [31:0] executedReg2;
logic [31:0] busybitAcc;

// Full checking
assign full = full_reg;
assign full_reg = (full_count > 27);

// Insertion
assign inserted_0_reg = {robIdx0, srcReg0_1, srcReg0_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_1_reg = {robIdx1, srcReg1_1, srcReg1_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_2_reg = {robIdx2, srcReg2_1, srcReg2_2, 1'b0, 1'b0, 1'b1};      
assign inserted_3_reg = {robIdx3, srcReg3_1, srcReg3_2, 1'b0, 1'b0, 1'b1}; 
assign insert_amount = (full_reg) ? 0:({2'b0, inserted[0]} + {2'b0, inserted[1]} + {2'b0, inserted[2]} + {2'b0, inserted[3]});

// Reg Monitoring & Finding ready mask
always_comb begin
for(int i = 0; i <32; i++) begin
        if(executed && iq[i][0]) begin
            ready_mask[0][i] = (iq[i][2:1] == 2'b11) ? 1'b1 : 1'b0;
            executedReg1[i] = (executedReg == iq[i][18:11]) ? 1'b1 : 1'b0;
            executedReg2[i] = (executedReg == iq[i][10:3]) ? 1'b1 :1'b0;
        end
        else begin
            ready_mask[0][i] = iq[i][0];
            executedReg1[i] = iq[i][2];
            executedReg2[i] = iq[i][1];
        end
end
end
// Finding free mask
always_comb begin
for (int j = 0; j <= 31; j++) begin
    if(~iq[j][0]) begin
        free_mask[0][31-j] = 1'b1;
    end
    else begin
        free_mask[0][31-j] = 1'b0;
     end
 end
end

// Issuing
// Creating 4 issuing index array
always_comb begin
    four_index_array = '{default:6'd63};
    leastOneIndexMask[0] = ((ready_mask[0] - 1) ^ ready_mask[0] ) >> 1;
    four_index_array[0] = {5'b0,leastOneIndexMask[0][0]} + {5'b0,leastOneIndexMask[0][1]} + {5'b0,leastOneIndexMask[0][2]} + {5'b0,leastOneIndexMask[0][3]} + {5'b0,leastOneIndexMask[0][4]} + {5'b0,leastOneIndexMask[0][5]} + {5'b0,leastOneIndexMask[0][6]} + {5'b0,leastOneIndexMask[0][7]} + {5'b0,leastOneIndexMask[0][8]} + {5'b0,leastOneIndexMask[0][9]} + {5'b0,leastOneIndexMask[0][10]} + {5'b0,leastOneIndexMask[0][11]} + {5'b0,leastOneIndexMask[0][12]} + {5'b0,leastOneIndexMask[0][13]} + {5'b0,leastOneIndexMask[0][14]} + {5'b0,leastOneIndexMask[0][15]} + {5'b0,leastOneIndexMask[0][16]} + {5'b0,leastOneIndexMask[0][17]} + {5'b0,leastOneIndexMask[0][18]} + {5'b0,leastOneIndexMask[0][19]} + {5'b0,leastOneIndexMask[0][20]} + {5'b0,leastOneIndexMask[0][21]} + {5'b0,leastOneIndexMask[0][22]} + {5'b0,leastOneIndexMask[0][23]} + {5'b0,leastOneIndexMask[0][24]} + {5'b0,leastOneIndexMask[0][25]} + {5'b0,leastOneIndexMask[0][26]} + {5'b0,leastOneIndexMask[0][27]} + {5'b0,leastOneIndexMask[0][28]} + {5'b0,leastOneIndexMask[0][29]} + {5'b0,leastOneIndexMask[0][30]} + {5'b0,leastOneIndexMask[0][31]};
    ready_mask[1] = ready_mask[0] & (~(leastOneIndexMask[0] + 1));

    leastOneIndexMask[1] = ((ready_mask[1] - 1) ^ ready_mask[1] ) >> 1;
    four_index_array[1] = {5'b0,leastOneIndexMask[1][0]} + {5'b0,leastOneIndexMask[1][1]} + {5'b0,leastOneIndexMask[1][2]} + {5'b0,leastOneIndexMask[1][3]} + {5'b0,leastOneIndexMask[1][4]} + {5'b0,leastOneIndexMask[1][5]} + {5'b0,leastOneIndexMask[1][6]} + {5'b0,leastOneIndexMask[1][7]} + {5'b0,leastOneIndexMask[1][8]} + {5'b0,leastOneIndexMask[1][9]} + {5'b0,leastOneIndexMask[1][10]} + {5'b0,leastOneIndexMask[1][11]} + {5'b0,leastOneIndexMask[1][12]} + {5'b0,leastOneIndexMask[1][13]} + {5'b0,leastOneIndexMask[1][14]} + {5'b0,leastOneIndexMask[1][15]} + {5'b0,leastOneIndexMask[1][16]} + {5'b0,leastOneIndexMask[1][17]} + {5'b0,leastOneIndexMask[1][18]} + {5'b0,leastOneIndexMask[1][19]} + {5'b0,leastOneIndexMask[1][20]} + {5'b0,leastOneIndexMask[1][21]} + {5'b0,leastOneIndexMask[1][22]} + {5'b0,leastOneIndexMask[1][23]} + {5'b0,leastOneIndexMask[1][24]} + {5'b0,leastOneIndexMask[1][25]} + {5'b0,leastOneIndexMask[1][26]} + {5'b0,leastOneIndexMask[1][27]} + {5'b0,leastOneIndexMask[1][28]} + {5'b0,leastOneIndexMask[1][29]} + {5'b0,leastOneIndexMask[1][30]} + {5'b0,leastOneIndexMask[1][31]};
    ready_mask[2] = ready_mask[1] & (~(leastOneIndexMask[1] + 1));

    leastOneIndexMask[2] = ((ready_mask[2] - 1) ^ ready_mask[2] ) >> 1;
    four_index_array[2] = {5'b0,leastOneIndexMask[2][0]} + {5'b0,leastOneIndexMask[2][1]} + {5'b0,leastOneIndexMask[2][2]} + {5'b0,leastOneIndexMask[2][3]} + {5'b0,leastOneIndexMask[2][4]} + {5'b0,leastOneIndexMask[2][5]} + {5'b0,leastOneIndexMask[2][6]} + {5'b0,leastOneIndexMask[2][7]} + {5'b0,leastOneIndexMask[2][8]} + {5'b0,leastOneIndexMask[2][9]} + {5'b0,leastOneIndexMask[2][10]} + {5'b0,leastOneIndexMask[2][11]} + {5'b0,leastOneIndexMask[2][12]} + {5'b0,leastOneIndexMask[2][13]} + {5'b0,leastOneIndexMask[2][14]} + {5'b0,leastOneIndexMask[2][15]} + {5'b0,leastOneIndexMask[2][16]} + {5'b0,leastOneIndexMask[2][17]} + {5'b0,leastOneIndexMask[2][18]} + {5'b0,leastOneIndexMask[2][19]} + {5'b0,leastOneIndexMask[2][20]} + {5'b0,leastOneIndexMask[2][21]} + {5'b0,leastOneIndexMask[2][22]} + {5'b0,leastOneIndexMask[2][23]} + {5'b0,leastOneIndexMask[2][24]} + {5'b0,leastOneIndexMask[2][25]} + {5'b0,leastOneIndexMask[2][26]} + {5'b0,leastOneIndexMask[2][27]} + {5'b0,leastOneIndexMask[2][28]} + {5'b0,leastOneIndexMask[2][29]} + {5'b0,leastOneIndexMask[2][30]} + {5'b0,leastOneIndexMask[2][31]};
    ready_mask[3] = ready_mask[2] & (~(leastOneIndexMask[2] + 1));

    leastOneIndexMask[3] = ((ready_mask[3] - 1) ^ ready_mask[3] ) >> 1;
    four_index_array[3] = {5'b0,leastOneIndexMask[3][0]} + {5'b0,leastOneIndexMask[3][1]} + {5'b0,leastOneIndexMask[3][2]} + {5'b0,leastOneIndexMask[3][3]} + {5'b0,leastOneIndexMask[3][4]} + {5'b0,leastOneIndexMask[3][5]} + {5'b0,leastOneIndexMask[3][6]} + {5'b0,leastOneIndexMask[3][7]} + {5'b0,leastOneIndexMask[3][8]} + {5'b0,leastOneIndexMask[3][9]} + {5'b0,leastOneIndexMask[3][10]} + {5'b0,leastOneIndexMask[3][11]} + {5'b0,leastOneIndexMask[3][12]} + {5'b0,leastOneIndexMask[3][13]} + {5'b0,leastOneIndexMask[3][14]} + {5'b0,leastOneIndexMask[3][15]} + {5'b0,leastOneIndexMask[3][16]} + {5'b0,leastOneIndexMask[3][17]} + {5'b0,leastOneIndexMask[3][18]} + {5'b0,leastOneIndexMask[3][19]} + {5'b0,leastOneIndexMask[3][20]} + {5'b0,leastOneIndexMask[3][21]} + {5'b0,leastOneIndexMask[3][22]} + {5'b0,leastOneIndexMask[3][23]} + {5'b0,leastOneIndexMask[3][24]} + {5'b0,leastOneIndexMask[3][25]} + {5'b0,leastOneIndexMask[3][26]} + {5'b0,leastOneIndexMask[3][27]} + {5'b0,leastOneIndexMask[3][28]} + {5'b0,leastOneIndexMask[3][29]} + {5'b0,leastOneIndexMask[3][30]} + {5'b0,leastOneIndexMask[3][31]};

end


always_comb begin
for (int k = 0; k < 32; k++) begin
    if(k == four_index_array[0] || k== four_index_array[1] || k==four_index_array[2] || k==four_index_array[3]) begin
        busybitAcc[k] = 1'b0;
    end
    else begin
        busybitAcc[k] = iq[k][0];
    end
end
end

always_comb begin
    four_index_array_insert = '{default:6'd63};
    leastOneIndexMaskInsert[0] = ((free_mask[0] - 1) ^ free_mask[0] ) >> 1;
    four_index_array_insert[0] = 5'd31 - {5'b0,leastOneIndexMaskInsert[0][0]} + {5'b0,leastOneIndexMaskInsert[0][1]} + {5'b0,leastOneIndexMaskInsert[0][2]} + {5'b0,leastOneIndexMaskInsert[0][3]} + {5'b0,leastOneIndexMaskInsert[0][4]} + {5'b0,leastOneIndexMaskInsert[0][5]} + {5'b0,leastOneIndexMaskInsert[0][6]} + {5'b0,leastOneIndexMaskInsert[0][7]} + {5'b0,leastOneIndexMaskInsert[0][8]} + {5'b0,leastOneIndexMaskInsert[0][9]} + {5'b0,leastOneIndexMaskInsert[0][10]} + {5'b0,leastOneIndexMaskInsert[0][11]} + {5'b0,leastOneIndexMaskInsert[0][12]} + {5'b0,leastOneIndexMaskInsert[0][13]} + {5'b0,leastOneIndexMaskInsert[0][14]} + {5'b0,leastOneIndexMaskInsert[0][15]} + {5'b0,leastOneIndexMaskInsert[0][16]} + {5'b0,leastOneIndexMaskInsert[0][17]} + {5'b0,leastOneIndexMaskInsert[0][18]} + {5'b0,leastOneIndexMaskInsert[0][19]} + {5'b0,leastOneIndexMaskInsert[0][20]} + {5'b0,leastOneIndexMaskInsert[0][21]} + {5'b0,leastOneIndexMaskInsert[0][22]} + {5'b0,leastOneIndexMaskInsert[0][23]} + {5'b0,leastOneIndexMaskInsert[0][24]} + {5'b0,leastOneIndexMaskInsert[0][25]} + {5'b0,leastOneIndexMaskInsert[0][26]} + {5'b0,leastOneIndexMaskInsert[0][27]} + {5'b0,leastOneIndexMaskInsert[0][28]} + {5'b0,leastOneIndexMaskInsert[0][29]} + {5'b0,leastOneIndexMaskInsert[0][30]} + {5'b0,leastOneIndexMaskInsert[0][31]};
    free_mask[1] = free_mask[0] & (~(leastOneIndexMaskInsert[0] + 1));

    leastOneIndexMaskInsert[1] = ((free_mask[1] - 1) ^ free_mask[1] ) >> 1;
    four_index_array_insert[1] = 5'd31 - {5'b0,leastOneIndexMaskInsert[1][0]} + {5'b0,leastOneIndexMaskInsert[1][1]} + {5'b0,leastOneIndexMaskInsert[1][2]} + {5'b0,leastOneIndexMaskInsert[1][3]} + {5'b0,leastOneIndexMaskInsert[1][4]} + {5'b0,leastOneIndexMaskInsert[1][5]} + {5'b0,leastOneIndexMaskInsert[1][6]} + {5'b0,leastOneIndexMaskInsert[1][7]} + {5'b0,leastOneIndexMaskInsert[1][8]} + {5'b0,leastOneIndexMaskInsert[1][9]} + {5'b0,leastOneIndexMaskInsert[1][10]} + {5'b0,leastOneIndexMaskInsert[1][11]} + {5'b0,leastOneIndexMaskInsert[1][12]} + {5'b0,leastOneIndexMaskInsert[1][13]} + {5'b0,leastOneIndexMaskInsert[1][14]} + {5'b0,leastOneIndexMaskInsert[1][15]} + {5'b0,leastOneIndexMaskInsert[1][16]} + {5'b0,leastOneIndexMaskInsert[1][17]} + {5'b0,leastOneIndexMaskInsert[1][18]} + {5'b0,leastOneIndexMaskInsert[1][19]} + {5'b0,leastOneIndexMaskInsert[1][20]} + {5'b0,leastOneIndexMaskInsert[1][21]} + {5'b0,leastOneIndexMaskInsert[1][22]} + {5'b0,leastOneIndexMaskInsert[1][23]} + {5'b0,leastOneIndexMaskInsert[1][24]} + {5'b0,leastOneIndexMaskInsert[1][25]} + {5'b0,leastOneIndexMaskInsert[1][26]} + {5'b0,leastOneIndexMaskInsert[1][27]} + {5'b0,leastOneIndexMaskInsert[1][28]} + {5'b0,leastOneIndexMaskInsert[1][29]} + {5'b0,leastOneIndexMaskInsert[1][30]} + {5'b0,leastOneIndexMaskInsert[1][31]};
    free_mask[2] = free_mask[1] & (~(leastOneIndexMaskInsert[1] + 1));

    leastOneIndexMaskInsert[2] = ((free_mask[2] - 1) ^ free_mask[2] ) >> 1;
    four_index_array_insert[2] = 5'd31 - {5'b0,leastOneIndexMaskInsert[2][0]} + {5'b0,leastOneIndexMaskInsert[2][1]} + {5'b0,leastOneIndexMaskInsert[2][2]} + {5'b0,leastOneIndexMaskInsert[2][3]} + {5'b0,leastOneIndexMaskInsert[2][4]} + {5'b0,leastOneIndexMaskInsert[2][5]} + {5'b0,leastOneIndexMaskInsert[2][6]} + {5'b0,leastOneIndexMaskInsert[2][7]} + {5'b0,leastOneIndexMaskInsert[2][8]} + {5'b0,leastOneIndexMaskInsert[2][9]} + {5'b0,leastOneIndexMaskInsert[2][10]} + {5'b0,leastOneIndexMaskInsert[2][11]} + {5'b0,leastOneIndexMaskInsert[2][12]} + {5'b0,leastOneIndexMaskInsert[2][13]} + {5'b0,leastOneIndexMaskInsert[2][14]} + {5'b0,leastOneIndexMaskInsert[2][15]} + {5'b0,leastOneIndexMaskInsert[2][16]} + {5'b0,leastOneIndexMaskInsert[2][17]} + {5'b0,leastOneIndexMaskInsert[2][18]} + {5'b0,leastOneIndexMaskInsert[2][19]} + {5'b0,leastOneIndexMaskInsert[2][20]} + {5'b0,leastOneIndexMaskInsert[2][21]} + {5'b0,leastOneIndexMaskInsert[2][22]} + {5'b0,leastOneIndexMaskInsert[2][23]} + {5'b0,leastOneIndexMaskInsert[2][24]} + {5'b0,leastOneIndexMaskInsert[2][25]} + {5'b0,leastOneIndexMaskInsert[2][26]} + {5'b0,leastOneIndexMaskInsert[2][27]} + {5'b0,leastOneIndexMaskInsert[2][28]} + {5'b0,leastOneIndexMaskInsert[2][29]} + {5'b0,leastOneIndexMaskInsert[2][30]} + {5'b0,leastOneIndexMaskInsert[2][31]};
    free_mask[3] = free_mask[2] & (~(leastOneIndexMaskInsert[2] + 1));

    leastOneIndexMaskInsert[3] = ((free_mask[3] - 1) ^ free_mask[3] ) >> 1;
    four_index_array_insert[3] = 5'd31 - {5'b0,leastOneIndexMaskInsert[3][0]} + {5'b0,leastOneIndexMaskInsert[3][1]} + {5'b0,leastOneIndexMaskInsert[3][2]} + {5'b0,leastOneIndexMaskInsert[3][3]} + {5'b0,leastOneIndexMaskInsert[3][4]} + {5'b0,leastOneIndexMaskInsert[3][5]} + {5'b0,leastOneIndexMaskInsert[3][6]} + {5'b0,leastOneIndexMaskInsert[3][7]} + {5'b0,leastOneIndexMaskInsert[3][8]} + {5'b0,leastOneIndexMaskInsert[3][9]} + {5'b0,leastOneIndexMaskInsert[3][10]} + {5'b0,leastOneIndexMaskInsert[3][11]} + {5'b0,leastOneIndexMaskInsert[3][12]} + {5'b0,leastOneIndexMaskInsert[3][13]} + {5'b0,leastOneIndexMaskInsert[3][14]} + {5'b0,leastOneIndexMaskInsert[3][15]} + {5'b0,leastOneIndexMaskInsert[3][16]} + {5'b0,leastOneIndexMaskInsert[3][17]} + {5'b0,leastOneIndexMaskInsert[3][18]} + {5'b0,leastOneIndexMaskInsert[3][19]} + {5'b0,leastOneIndexMaskInsert[3][20]} + {5'b0,leastOneIndexMaskInsert[3][21]} + {5'b0,leastOneIndexMaskInsert[3][22]} + {5'b0,leastOneIndexMaskInsert[3][23]} + {5'b0,leastOneIndexMaskInsert[3][24]} + {5'b0,leastOneIndexMaskInsert[3][25]} + {5'b0,leastOneIndexMaskInsert[3][26]} + {5'b0,leastOneIndexMaskInsert[3][27]} + {5'b0,leastOneIndexMaskInsert[3][28]} + {5'b0,leastOneIndexMaskInsert[3][29]} + {5'b0,leastOneIndexMaskInsert[3][30]} + {5'b0,leastOneIndexMaskInsert[3][31]};

end

always_comb begin
for (int l = 0; l < 32; l++) begin
    if(l == four_index_array_insert[0]) begin
        iq_n[l][0] = inserted_0_reg[0];
        iq_n[l][25:3] = inserted_0_reg[25:3];
        iq_n[l][2] = inserted_0_reg[2];
        iq_n[l][1] = inserted_0_reg[1];
    end
    else if(l == four_index_array_insert[1]) begin
        iq_n[l][0] = inserted_1_reg[0];
        iq_n[l][25:3] = inserted_1_reg[25:3];
        iq_n[l][2] = inserted_1_reg[2];
        iq_n[l][1] = inserted_1_reg[1];
    end

    else if(l == four_index_array_insert[2]) begin
        iq_n[l][0] = inserted_2_reg[0];
        iq_n[l][25:3] = inserted_2_reg[25:3];
        iq_n[l][2] = inserted_2_reg[2];
        iq_n[l][1] = inserted_2_reg[1];
    end

    else if(l == four_index_array_insert[3]) begin
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


assign is_valid_removed[0] = (four_index_array[0] != 63) ? 1'b1 : 1'b0;
assign is_valid_removed[1] = (four_index_array[1] != 63) ? 1'b1 : 1'b0;
assign is_valid_removed[2] = (four_index_array[2] != 63) ? 1'b1 : 1'b0;
assign is_valid_removed[3] = (four_index_array[3] != 63) ? 1'b1 : 1'b0;
// Output Assignment
assign numIssued = ({2'b0, is_valid_removed[0]} + {2'b0, is_valid_removed[1]} + {2'b0, is_valid_removed[2]} + {2'b0, is_valid_removed[3]});
assign issued0 = (four_index_array[0] != 63) ? iq[four_index_array[0]][25:19] : 0; 
assign issued1 = (four_index_array[1] != 63) ? iq[four_index_array[1]][25:19] : 0;
assign issued2 = (four_index_array[2] != 63) ? iq[four_index_array[2]][25:19] : 0;
assign issued3 = (four_index_array[3] != 63) ? iq[four_index_array[3]][25:19] : 0;

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

module iq_tb;
    parameter  ClockDelay = 10;
                    

 logic clk,
 logic reset,
 logic [3:0] inserted;
 logic [6:0] robIdx0;
 logic [7:0] srcReg0_1;
 logic [7:0] srcReg0_2; 
  logic [6:0] robIdx1;
  logic [7:0] srcReg1_1;
  logic [7:0] srcReg1_2;
  logic [6:0] robIdx2;
  logic [7:0] srcReg2_1;
 logic [7:0] srcReg2_2;
 logic [6:0] robIdx3;
 logic [7:0] srcReg3_1;
 logic [7:0] srcReg3_2;
 logic executed;
 logic [7:0] executedReg;
 logic [2:0] numIssued;
 logic [6:0] issued0;
 logic [6:0] issued1;
 logic [6:0] issued2;
 logic [6:0] issued3;
 logic full;

    iq DUT (clk, reset, inserted, robIdx0, srcReg0_1, srcReg0_2, robIdx1, srcReg1_1, srcReg1_2, robIdx2, srcReg2_1, srcReg2_2, robIdx3, srcReg3_1, srcReg3_2,
        executed, executedReg, numIssued, issued0, issued1, issued2, issued3);

	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end

    
    initial
    begin

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
        archReg0 <= 5'd0;
        physReg0 <= 8'd0;
        opcode0 <= 11'd1;
        archReg1 <= 5'd0;
        physReg1 <= 8'd0;
        opcode1 <= 11'd2;
        archReg2 <= 5'd0;
        physReg2 <= 8'd0;
        opcode2 <= 11'd3;
        archReg3 <= 5'd0;
        physReg3 <= 8'd0;
        opcode3 <= 11'd4;
        @(posedge clk);
        inserted <= 4'b0011;
        @(posedge clk);
        inserted <= 4'b0111;
        @(posedge clk);
        inserted <= 4'b1111;
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
        // Test flush and exception
        flushIndex <= 7'd4;
        flushInst <= 1;
        exception <= 1;
        exceptionIndex <= 7'd5;
        @(posedge clk);
        flushInst <= 0;
        exception <= 0;
        @(posedge clk);
        // Test executed on non-commited and commited entry
        executed <= 4'b1111;
        executedIndex0 <= 7'd7;
        executedIndex1 <= 7'd8;
        executedIndex2 <= 7'd9;
        executedIndex3 <= 7'd6;
        @(posedge clk);
        executed <= 4'b0101;
        executedIndex0 <= 7'd4;
        executedIndex2 <= 7'd5;
        @(posedge clk);
        executed <= 4'b1111;
        executedIndex0 <= 7'd0;
        executedIndex1 <= 7'd1;
        executedIndex2 <= 7'd2;
        executedIndex3 <= 7'd3;
        @(posedge clk);
        executed <= 4'b0;
        @(posedge clk);
        inserted <= 4'b1111;
        archReg0 <= 5'd0;
        physReg0 <= 8'd0;
        opcode0 <= 11'd1;
        archReg1 <= 5'd0;
        physReg1 <= 8'd0;
        opcode1 <= 11'd2;
        archReg2 <= 5'd0;
        physReg2 <= 8'd0;
        opcode2 <= 11'd3;
        archReg3 <= 5'd0;
        physReg3 <= 8'd0;
        opcode3 <= 11'd4;
        @(posedge clk);
        // Insertion and Execution same time
        inserted <= 4'b1111;
        executed <= 4'b1111;
        executedIndex0 <= 7'd10;
        executedIndex1 <= 7'd11;
        executedIndex2 <= 7'd12;
        executedIndex3 <= 7'd13;
        @(posedge clk);
        // Filling the ROB
        executed <= 4'b0;
        inserted <= 4'b1111;
        @(posedge clk);
        inserted <= 4'b1111;
        @(posedge clk);
        inserted <= 4'b1111;
        @(posedge clk);
        inserted <= 4'b1111;
        @(posedge clk);
        inserted <= 4'b1111;
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
        @(posedge clk);
        @(posedge clk);
        // Escape from Full
        executed <= 4'b1111;
        executedIndex0 <= 7'd14;
        executedIndex1 <= 7'd15;
        executedIndex2 <= 7'd16;
        executedIndex3 <= 7'd17;
        @(posedge clk);
        // Enter full again
        executed <= 4'b0;
        inserted <= 4'b1111;
        archReg0 <= 5'd0;
        physReg0 <= 8'd0;
        opcode0 <= 11'd1;
        archReg1 <= 5'd0;
        physReg1 <= 8'd0;
        opcode1 <= 11'd2;
        archReg2 <= 5'd0;
        physReg2 <= 8'd0;
        opcode2 <= 11'd3;
        archReg3 <= 5'd0;
        physReg3 <= 8'd0;
        opcode3 <= 11'd4;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        $display ("FINISHED!!!!!!!!!!!!!!!!!!!");
        $finish;
    end

    

endmodule
