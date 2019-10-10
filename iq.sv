/* Search for issuing entries
// The whole IQ is a 26bit*32entries array

logic [31:0] busyMask
logic [31:0] busyMask1
logic [31:0] busyMask2
logic [4:0] 4indexArray [3:0];
logic [31:0] leastOneIndexMask [3:0];

leastOneIndexMask[0] = ((busyMask - 1) ^ busyMask )>> 1;
4indexArray[0] = {add every bit of leastOneIndexMask[0]};
busyMask1 = busyMask & (leastOneIndexMask[0] + 1);
//Do that 4 time to get the 4 index 

//set all indexed busy bit to 1, and output index
//fill the holes
for each begin
if (index != any of 4arrayindex) {
temp1 = index > 4arrayindex[0];
temp2 = index > 4arrayindex[1];
temp3 = index > 4arrayindex[2];
temp4 = index > 4arrayindex[3];
shiftamount = temp1 + temp2 + temp3 + temp4;
q_n[index-shiftamount] = q[index];
} else {

end

newest_n = newest - iussingamount;
*/