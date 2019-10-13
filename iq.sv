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
logic [4:0] tail;
logic [4:0] tail_n;
logic [2:0] insert_amount;
logic [25:0] inserted_0_reg;
logic [25:0] inserted_1_reg;
logic [25:0] inserted_2_reg;
logic [25:0] inserted_3_reg;

// Full checking wires
logic full_reg;
logic [4:0] full_count;

// Tag match wires
logic [25:0] iq_n [31:0];
logic [25:0] iq_nn [31:0];

// issuing wires
logic [31:0] ready_mask [3:0];
logic [5:0] four_index_array [3:0];
logic [31:0] leastOneIndexMask [3:0];
logic [2:0] shift_amount [31:0];
logic [4:0] head;
logic [4:0] head_n;
logic [2:0] remove_amount;
logic [6:0] issued_rob [3:0];

// Full checking
assign full = full_reg;
assign full_reg = (full_count > 27);

// Insertion
assign inserted_0_reg = (full_reg) ? iq[tail]:{robIdx0, srcReg0_1, srcReg0_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_1_reg = (full_reg) ? iq[tail+1]:{robIdx1, srcReg1_1, srcReg1_2, 1'b0, 1'b0, 1'b1}; 
assign inserted_2_reg = (full_reg) ? iq[tail+2]:{robIdx2, srcReg2_1, srcReg2_2, 1'b0, 1'b0, 1'b1};      
assign inserted_3_reg = (full_reg) ? iq[tail+3]:{robIdx3, srcReg3_1, srcReg3_2, 1'b0, 1'b0, 1'b1}; 
assign insert_amount = (full_reg) ? 0:({2'b0, inserted[0]} + {2'b0, inserted[1]} + {2'b0, inserted[2]} + {2'b0, inserted[3]});
assign tail_n = (full_reg) ? tail:(tail + insert_amount);


// Reg Monitoring & Finding ready mask
always_comb begin
    if (executed) begin
        for(int i = 0; i < tail; i++) begin
            ready_mask[0][i] = (iq[i][2:1] == 2'b11);
            if ((i != four_index_array[0]) && (i != four_index_array[1]) && (i != four_index_array[2]) && (i != four_index_array[3])) begin
                if (i > four_index_array[3]) begin
                    shift_amount[i] = 3'd4;
                end else if (i > four_index_array[2]) begin
                    shift_amount[i] = 3'd3;
                end else if (i > four_index_array[1]) begin
                    shift_amount[i] = 3'd2;
                end else if (i > four_index_array[0]) begin
                    shift_amount[i] = 3'd1;
                end else begin 
                    shift_amount[i] = 3'd0;
                end
            end
            iq_n[i-shift_amount[i]][0] = iq[i][0];
            iq_n[i-shift_amount[i]][25:3] = iq[i][25:3];
            iq_n[i-shift_amount[i]][2:1] = {(executedReg == iq[i][18:11]), (executedReg == iq[i][10:3])};
        end
        //iq_n[31:tail] = iq[31:tail];
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

    remove_amount = 0;
    foreach (four_index_array[j]) begin
        if (four_index_array[j] != 63) begin
            issued_rob[j] = iq[four_index_array[j]][25:19];
            remove_amount = remove_amount + 1;
        end else begin
            issued_rob[j] = 0;
            remove_amount = remove_amount;
        end
    end
end

// Output Assignment
assign numIssued = remove_amount;
assign issued0 = issued_rob[0];
assign issued1 = issued_rob[1];
assign issued2 = issued_rob[2];
assign issued3 = issued_rob[3];

always_ff @ (posedge clk) begin
if (~reset) begin
    iq <= '{default:0};
    tail <= 5'b0;
    full_count <= 5'b0;
end else begin
    tail <= tail_n;
    iq <= iq_nn;
    full_count <= full_count + insert_amount - remove_amount;
end
end

endmodule: iq