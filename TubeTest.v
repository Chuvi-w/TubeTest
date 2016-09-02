module TubeTest(clk,Key,Sw,Dot,Seg,Led);

input clk;
input [3:0] Key;
input [7:0] Sw;
output Dot;
output [6:0] Seg;
output [7:0] Led ;
wire [3:0] Key;
wire [7:0] Sw;
wire Dot;
reg [6:0] Seg;
reg [7:0] Led ;

reg [7:0] CurLed;

	
assign Dot=1'b1;

always @ ( posedge clk )
 begin
  CurLed<=CurLed+1;  
 end
 
always @ ( posedge clk )
 begin
  Led<=(1<<CurLed);
  Seg<=CurLed;
 end

endmodule
