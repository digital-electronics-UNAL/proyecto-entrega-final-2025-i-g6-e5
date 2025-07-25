module BCD #(parameter Maxcount = 100000)(
    input [7:0] Seconds,
    input [7:0] Minutes,
    input [7:0] Hours,
    input [2:0]  Acknowledge,
    input clk,
    output reg [3:0] bcd,
    output reg [7:0] c
  );
  // maxcount 100000 para quartus || 25 para test
  //reg  algo = 0; esto se cambia por el rst
  reg [1:0]algo;
  reg [$clog2(Maxcount):0] count;
  reg clk2;
  initial begin
		algo <= 2'b00;
		c <= 0;
    bcd <= 0;
    count <= 0;
  end
  
  initial begin
    clk2 = 0;
  end

  always @(posedge clk) begin
    if (count == Maxcount) begin
      count <= 0;
      clk2 <= ~clk2;
    end else begin
      count <= count +1;
    end
  end


  always@(posedge clk2) begin
      case(algo)
        0:begin
			 	 bcd<=Seconds[3:0];
				 algo <= 1;
				 c <= 8'b11111110;
          end
        1:begin
          bcd<=Seconds[7:4];
          algo <= 2;
			   c <= 8'b11111101;
          end
        2:begin
          bcd<=Minutes[3:0];
          algo <= 3;
			   c <= 8'b11111011;
        end
        3:begin
          bcd<=Minutes[7:4];
          algo <= 4;
			   c <= 8'b11110111;
        end
        4:begin
          bcd<=Hours[3:0];
          algo <= 5;
			   c <= 8'b11101111;
        end
        5:begin
          bcd<=Hours[7:4];
          algo <= 0;
			   c <= 8'b11011111;
        end
      endcase
  end
endmodule
