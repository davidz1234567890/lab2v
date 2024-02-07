`default_nettype none

module MagComparator
(input logic [3:0] A,
input logic [3:0] B,
output logic AltB, AeqB, AgtB);
  //logic [7:0] diff;

    /*assign diff = (A - B);
      assign AeqB = (diff == 8'b0000_0000);
        assign AgtB = ((A[7] == 0 && B[7] == 1) ||
                        (A[7] == B[7] && diff[7] == 1'b0 && !AeqB));
                          assign AltB = ((A[7] == 1 && B[7] == 0) ||
                                          (A[7] == B[7] && diff[7] == 1'b1));*/
  //$display("here is AltB: %b\n", AltB);
  assign AeqB = (A == B);
  assign AgtB = (A > B);
  assign AltB = (A < B);
endmodule: MagComparator

/*module MapComparator_test;
logic [3:0] A, logic [3:0] B;
logic AltB, AeqB, AgtB;
MapComparator DUT(A, B, AltB, AeqB, AgtB);
initial begin

end

endmodule: MagComparator_test;
*/

module find_diff
(input logic paid_gt_cost, input logic [3:0] cost, input logic [3:0] paid,
output logic [3:0] diff);
always_comb
  if (paid_gt_cost==1)
    diff = paid - cost;
  else
    diff = 3'b000;

endmodule: find_diff


module firstcoin
(input logic [3:0] diff, input logic [1:0] Pentagon, input logic [1:0] Triangle, input logic [1:0] Circle,
 output logic [2:0] first, output logic [3:0] remaining_after_first, output logic [1:0] new_pentagon, output logic [1:0] new_triangle, output logic [1:0] new_circle);
 always_comb begin
   if (diff >= 4'd5 && Pentagon >= 2'd1) begin
     first = 3'b101;
     remaining_after_first = diff - 4'd5;
     new_pentagon = Pentagon - 2'd1;
     new_triangle = Triangle;
     new_circle = Circle;
     /*initial begin
       $display("here\n");
     end*/
   end
   else if (diff >= 4'd5 && Triangle >= 2'd1) begin
     first = 3'b011;
     remaining_after_first = diff - 4'b0011;
     new_pentagon = Pentagon;
     new_triangle = Triangle - 2'b01;
     new_circle = Circle;
   end
   else if (diff >= 4'd5 && Circle >= 2'd1) begin
     first = 3'b001;
     remaining_after_first = diff - 4'b0001;
     new_pentagon = Pentagon;
     new_triangle = Triangle;
     new_circle = Circle - 1;
   end
   else if (diff >= 4'd3 && Triangle >= 2'd1) begin
     first = 3'b011;
     remaining_after_first = diff - 4'b0011;
     new_pentagon = Pentagon;
     new_triangle = Triangle - 2'b01;
     new_circle = Circle;
   end
   else if (diff >= 4'd3 && Circle >= 2'd1) begin
     first = 3'b001;
     remaining_after_first = diff - 4'b0001;
     new_pentagon = Pentagon;
     new_triangle = Triangle;
     new_circle = Circle - 2'b01;

   end
   else if (diff >= 4'd1 && Circle >= 2'd1) begin
     first = 3'b001;
     remaining_after_first = diff - 4'b0001;
     new_pentagon = Pentagon;
     new_triangle = Triangle;
     new_circle = Circle - 2'b01;
   end
   else begin
     first = 3'b000;
     remaining_after_first = diff ;
     new_pentagon = Pentagon;
     new_triangle = Triangle;
     new_circle = Circle;
   end
  end
endmodule: firstcoin


module secondcoin
(input logic [3:0] remaining_after_first, input logic [1:0] new_pentagon, input logic [1:0] new_triangle, input logic [1:0] new_circle,
output logic [2:0] second, output logic [3:0] remaining);
  always_comb begin
    if (remaining_after_first>=4'd5 && new_pentagon >= 2'd1) begin
      second = 3'b101;
      remaining = remaining_after_first - 4'd5;

    end
    else if (remaining_after_first >= 4'd5 && new_triangle >= 2'd1) begin
      second = 3'b011;
      remaining = remaining_after_first - 4'd3;

    end
    else if (remaining_after_first >= 4'd5 && new_circle >= 2'd1) begin
      second = 3'b001;
      remaining = remaining_after_first - 4'd1;

    end
    else if (remaining_after_first>=4'd3 && new_triangle >= 2'd1) begin
      second = 3'b011;
      remaining = remaining_after_first - 4'd3;

    end
    else if (remaining_after_first >= 4'd3 && new_circle >= 2'd1) begin
      second = 3'b001;
      remaining = remaining_after_first - 4'd1;
    end
    else if (remaining_after_first>=4'd1 && new_circle >= 2'd1) begin
      second = 3'b001;
      remaining = remaining_after_first - 4'd1;
    end
    else if (remaining_after_first > 4'd0) begin
      second = 3'b000;
      remaining = remaining_after_first;
    end
    else begin


      second = 3'b000;
      remaining = 4'd0;
    end
  end



endmodule: secondcoin


module check_not_enough
(input logic [3:0] remaining, output logic NotEnoughChange);
always_comb
  if (remaining > 4'd0)
    NotEnoughChange = 1;
  else
    NotEnoughChange = 0;



endmodule: check_not_enough


module top
(input logic [3:0] Cost, input logic [3:0] Paid, input logic [1:0] Pentagons, input logic [1:0] Triangles, input logic [1:0] Circles,
output logic [2:0] FirstCoin, output logic [2:0] SecondCoin, output logic ExactAmount, output logic NotEnoughChange, output logic CoughUpMore, output logic [3:0] Remaining);
  logic [3:0] diff;
  logic [3:0] remaining_after_first;
  logic [1:0] new_pentagon , new_triangle, new_circle;
  logic paid_gt_cost;
  MagComparator dut1(.A(Paid), .B(Cost), .AltB(CoughUpMore), .AeqB(ExactAmount), .AgtB(paid_gt_cost));
  find_diff dut2(.paid_gt_cost(paid_gt_cost), .cost(Cost), .paid(Paid), .diff(diff));
  firstcoin dut3(diff, Pentagons, Triangles, Circles, FirstCoin, remaining_after_first, new_pentagon, new_triangle, new_circle);
  secondcoin dut4(remaining_after_first, new_pentagon, new_triangle, new_circle, SecondCoin, Remaining);
  check_not_enough dut5(Remaining, NotEnoughChange);
endmodule: top


module top_test;
  logic [3:0] Cost; logic [3:0] Paid; logic [1:0] Pentagons; logic [1:0] Triangles; logic [1:0] Circles;
  logic [2:0] FirstCoin; logic [2:0] SecondCoin; logic ExactAmount; logic NotEnoughChange; logic CoughUpMore; logic [3:0] Remaining;
  top dut(Cost, Paid, Pentagons, Triangles, Circles, FirstCoin, SecondCoin, ExactAmount, NotEnoughChange, CoughUpMore, Remaining);
  initial begin
    $monitor($time, "  Cost = %d, Paid = %d, NumPentagons = %d, NumTriangles = %d, NumCircles = %d, FirstCoin = %d, SecondCoin = %d, ExactAmount = %d, NotEnoughChange = %d, CoughUpMore = %d, Remaining = %d\n", Cost, Paid, Pentagons, Triangles, Circles, FirstCoin, SecondCoin, ExactAmount, NotEnoughChange, CoughUpMore, Remaining);
    Cost = 4'd13; Paid = 4'd13; Pentagons = 1; Triangles = 0; Circles = 0;
    #10 Paid = 4'd12;
    #10 Paid = 4'd15; Cost = 4'd10;
    #10 Cost = 4'd9;
    #10 Cost = 4'd12;

    #10 Circles = 2'd1;
    #10 Triangles = 2'd2;
    #10 Cost = 4'd1; Pentagons = 2'd2; Triangles = 2'd3; Circles = 2'd0;
    #10 Pentagons = 2'd1;
    #10 Paid = 4'd11; Pentagons = 2'd0;
    #10 Paid = 4'd11; Cost = 4'd10; Pentagons = 2'd0; Triangles = 2'd1; Circles = 2'd2;
    #10 Paid = 4'd5; Cost = 4'd10;
    #10 Cost = 4'd5;
  end



endmodule: top_test
