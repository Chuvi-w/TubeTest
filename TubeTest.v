

/*
Тэкс. Clk у нас 50 МГц, то есть 20 нс.
1 секунда это 50000000 тиков, и это... эм... дофига.
Ладно, у нас есть 8 7-и сегментных индикатора. (Ну, вообще-то 8-и сегментых, но точку пока не используем).
Сегменты всех индикаторов управляются одними и теми же линиями, то есть, чтобы отобразить разные числа на индикаторах,
нам нужно подсвечивать их по очереди.
При одновременном переключении подсвечиваемого индикатора и подсвечиваемых сегментов на индикаторе почему-то видно слабое свечение от предыдущего индикатора,
что нехорошо. Поэтому, в момент переключения сегментов индикаторы надо гасить.

Логика подсветки сегментов: A,B,C,D - соотв. биты отображаемого числа.
1. ~(A|C)&(B^D)|(A&D)&(B^C)
2. (~(A|C)&B|A&C)&D|(A|C)&B&~D
3. ~(A|B|D)&C|A&B&(~D|C)
4. ~(A|C)&(B^D)|C&(B&D|A&~B&~D)
5. ~A&(D|B&~C)|~B&~C&D
6. ~(A|B)&(C|D)|D&(~A&C|A&B&~C)
7. ~A&(~(B|C)|B&C&D)|A&B&~(D|C)
*/

module TubeTest
(
input clk,
input wire [3:0] Key, //4 кнопочки
input wire[7:0] Sw, //Переключатели
output wire Dot, //Точка 
output wire [6:0] Seg,//7 сегментов индикатора. Как и точка, светятся при 0, не светятся при 1.
output wire [7:0] Led //Сами индикаторы. Светятся те, которые в 0.
);

wire  SegEnabled;
wire [3:0]DispNum;//Число, отображаемое идикатором. (0-F)

reg [2:0] CurLed;
reg [31:0] ClockCount;
reg [31:0]StoredNum;

assign Dot=1'b1;//Точка не нужна.

assign Seg[0]= ~(DispNum[3]|DispNum[1])&(DispNum[2]^DispNum[0])|(DispNum[3]&DispNum[0])&(DispNum[2]^DispNum[1]);
assign Seg[1]= (~(DispNum[3]|DispNum[1])&DispNum[2]|DispNum[3]&DispNum[1])&DispNum[0]|(DispNum[3]|DispNum[1])&DispNum[2]&~DispNum[0];
assign Seg[2]= ~(DispNum[3]|DispNum[2]|DispNum[0])&DispNum[1]|DispNum[3]&DispNum[2]&(~DispNum[0]|DispNum[1]);
assign Seg[3]= ~(DispNum[3]|DispNum[1])&(DispNum[2]^DispNum[0])|DispNum[1]&(DispNum[2]&DispNum[0]|DispNum[3]&~DispNum[2]&~DispNum[0]);
assign Seg[4]= ~DispNum[3]&(DispNum[0]|DispNum[2]&~DispNum[1])|~DispNum[2]&~DispNum[1]&DispNum[0];
assign Seg[5]= ~(DispNum[3]|DispNum[2])&(DispNum[1]|DispNum[0])|DispNum[0]&(~DispNum[3]&DispNum[1]|DispNum[3]&DispNum[2]&~DispNum[1]);
assign Seg[6]= ~DispNum[3]&(~(DispNum[2]|DispNum[1])|DispNum[2]&DispNum[1]&DispNum[0])|DispNum[3]&DispNum[2]&~(DispNum[0]|DispNum[1]);
//assign Led=8'b0;
assign SegEnabled=ClockCount[10];
assign Led=~(SegEnabled<<CurLed);
assign DispNum=(StoredNum&4'hF<<(4*CurLed))>>(4*CurLed);

initial                                                
begin                                                  
  //SegEnabled = 1'b1;
  CurLed=3'b0;
  ClockCount=32'b0;                                        
  StoredNum=32'h0A1B2C3D;
end      

always @ ( posedge clk ) ClockCount<=ClockCount+1;
 
//always @ (posedge Key[3])CurLed <= CurLed+1;
/*ToDo: Сделать вычитание по 2-й кнопке*/

/*
always @ ( negedge ClockCount[25] ) //Приблизительно каждые 0,67 сек.
 begin
  DispNum<=DispNum+1;
 end
*/

 always @ ( negedge ClockCount[12] ) CurLed<=CurLed+1;

endmodule
