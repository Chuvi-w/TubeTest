

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

parameter LedSwitchBit = 10; //бит счётчика, при изменении которого происходит переключение индикатора.
parameter LedBlinkBit=16;//бит счётчика для мигания настраеваемого светодиода.
wire  SegEnabled;
wire [3:0]DispNum;//Число, отображаемое идикатором. (0-F)

reg [2:0] CurrentActiveLed;
reg [1:0] CurrentEditGroup;
reg EditMode;
reg [31:0] ClockCount;
reg [31:0]StoredNum;
reg [3:0]OldKey;
reg [3:0]ButtonLock;
assign Dot=1'b1;//Точка не нужна.

assign Seg[0]= ~(DispNum[3]|DispNum[1])&(DispNum[2]^DispNum[0])|(DispNum[3]&DispNum[0])&(DispNum[2]^DispNum[1]);
assign Seg[1]= (~(DispNum[3]|DispNum[1])&DispNum[2]|DispNum[3]&DispNum[1])&DispNum[0]|(DispNum[3]|DispNum[1])&DispNum[2]&~DispNum[0];
assign Seg[2]= ~(DispNum[3]|DispNum[2]|DispNum[0])&DispNum[1]|DispNum[3]&DispNum[2]&(~DispNum[0]|DispNum[1]);
assign Seg[3]= ~(DispNum[3]|DispNum[1])&(DispNum[2]^DispNum[0])|DispNum[1]&(DispNum[2]&DispNum[0]|DispNum[3]&~DispNum[2]&~DispNum[0]);
assign Seg[4]= ~DispNum[3]&(DispNum[0]|DispNum[2]&~DispNum[1])|~DispNum[2]&~DispNum[1]&DispNum[0];
assign Seg[5]= ~(DispNum[3]|DispNum[2])&(DispNum[1]|DispNum[0])|DispNum[0]&(~DispNum[3]&DispNum[1]|DispNum[3]&DispNum[2]&~DispNum[1]);
assign Seg[6]= ~DispNum[3]&(~(DispNum[2]|DispNum[1])|DispNum[2]&DispNum[1]&DispNum[0])|DispNum[3]&DispNum[2]&~(DispNum[0]|DispNum[1]);
//assign Led=8'b0;
assign SegEnabled=ClockCount[LedSwitchBit+1];
assign Led=~(SegEnabled<<CurrentActiveLed);
assign DispNum=(StoredNum&4'hF<<(4*CurrentActiveLed))>>(4*CurrentActiveLed);

initial                                                
begin                                                  
  //SegEnabled = 1'b1;
  CurrentActiveLed=3'b0;
  ClockCount=32'b0;                                        
  StoredNum=32'h0A1B2C3D;
  OldKey=4'b1111; //
  ButtonLock=3'b0000;
  CurrentEditGroup=2'b00;
  EditMode=1'b0
end      

always @ ( posedge clk ) ClockCount<=ClockCount+1;
 

always @ ( negedge ClockCount[LedSwitchBit] ) 
begin
	if(!SegEnabled)
		CurrentActiveLed=CurrentActiveLed+1;
end


always @ (posedge ClockCount[15])	ButtonLock<=4'b0000;
always @ (posedge clk )
begin
	if(OldKey[3]!=Key[3])
	begin
		OldKey[3]=Key[3];
		if(!Key[3])
		begin
			CurrentEditGroup=CurrentEditGroup-1;
			ButtonLock[3]=1'b1;
		end
	end
	else if(OldKey[2]!=Key[2])
	begin
		OldKey[2]=Key[2];
		if(!Key[2])
		begin
			CurrentEditGroup=CurrentEditGroup+1;
			ButtonLock[2]=1'b1;
		end
	end
	else if(OldKey[1]!=Key[1])
	begin
		OldKey[1]=Key[1];
		if(!Key[1])
		begin
			EditMode=!EditMode;
		end
	end
end
	

endmodule
