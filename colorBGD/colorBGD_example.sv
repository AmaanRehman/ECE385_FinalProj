module colorBGD_example (
	input logic Clk,
	input logic frame_clk,
	input logic reset,
	input logic gameReset,
	input logic [15:0] keycode,
	
	input logic [19:0] randCord,
	
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	input logic [9:0] snakeX_pos,
	input logic [9:0] snakeY_pos,
	input logic [9:0] snake_size,
	
	input logic [9:0] snake2X_pos,
	input logic [9:0] snake2Y_pos,

	//Obstacle Outputs

	// output logic [1:0] snake1_dir;
	output logic [1:0] motionFlag1Out, motionFlag2Out,
	
	output logic OB1Flag, OB2Flag,
	output logic endGame,
	
	output logic [3:0] red, green, blue,
	output [9:0] LED
);

logic [18:0] rom_address;
logic [3:0] rom_q;

logic [18:0] rom_address_W, rom_address_S, rom_address_A, rom_address_D;
logic [18:0] rom_address_W1, rom_address_S1, rom_address_A1, rom_address_D1;
logic [3:0] rom_q_W, rom_q_S, rom_q_A, rom_q_D;
logic [3:0] rom_q_W1, rom_q_S1, rom_q_A1, rom_q_D1;

logic [3:0] palette_red, palette_green, palette_blue;
logic [3:0] snake_palette_red, snake_palette_green, snake_palette_blue;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// Snake 1 MotionFlag setting

assign motionFlag1Out = motionFlagOut;
assign motionFlag2Out = motionFlagOut1;
assign endGame =  endGameS1 | endGameS2;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen

assign rom_address = ((DrawX * 320) / 640) + (((DrawY * 240) / 480) * 320);

// ORIGINAL ADDRESS THAT SETS SNAKE HEAD TO FULL SCREEN:


logic [9:0] DistX, DistY, Size, DistX1, DistY1;
assign DistX = DrawX - snakeX_pos;
assign DistY = DrawY - snakeY_pos;

assign DistX1 = DrawX - snake2X_pos;
assign DistY1 = DrawY - snake2Y_pos;

assign Size = snake_size;

logic snake_on, snake2_on, Wall_on;


//always_comb
//begin:Snake_on_proc
//
// rom_address_W1= 0;
//
//    if ((DrawX >= snakeX_pos - 12) &&
//		 (DrawX <= snakeX_pos + 11)  &&
//		 (DrawY >= snakeY_pos - 12)  &&
//       (DrawY <= snakeY_pos + 11)) begin
//		 
////		  case(keycode)
////		 
////			8'h1A	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// W
////			8'h04	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// A
////			8'h16	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// S
////			8'h07	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// D
////			
////			
////			default:	rom_address = ((DrawX * 640) / 640) + (((DrawY * 480) / 480) * 640);
////			
////		 endcase
//		  
//         snake_on = 1'b1;
//			snake2_on = 1'b0;
//		  
//		  
//		  // Snake 1
//
//		  rom_address_W = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); // Working
//		  rom_address_S = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
//		  rom_address_A = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
//		  rom_address_D = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);
//	
//		end
//		  
//	 else if ((DrawX >= snake2X_pos - 12) &&
//				(DrawX <= snake2X_pos + 11)  &&
//				(DrawY >= snake2Y_pos - 12)  &&
//				(DrawY <= snake2Y_pos + 11)) begin
//				
//			snake_on = 1'b0;
//			snake2_on = 1'b1;
//			
//			// Snake 2
//			
//		  rom_address_W1 = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); // Working
//		  rom_address_S = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); 
//		  rom_address_A = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); 
//		  rom_address_D = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24);
//			
//	 end
//	 
//	 else begin
//	 
//        snake_on = 1'b0;
//		snake2_on = 1'b0;
//		  
//		  rom_address_W = 0; // Working
//		  rom_address_S = 0; 
//		  rom_address_A = 0; 
//		  rom_address_D = 0;
//		  
//	 end
//		  
//end 

// Instantiating ISDU (Main State Machine)

logic LD_MENU, LD_Map1;

ISDU isdu1 (.Clk(frame_clk),
				.Reset(reset),
				.keycode(keycode),
				.LD_MENU(LD_MENU),
				.LD_Map1(LD_Map1),
				.player1wins(player1wins),
				.player2wins(player2wins),
				.LD_S1ENDGAME(endGameS1),
				.LD_S2ENDGAME(endGameS2),
				.Pause_En(),
				.AnimationActive(snake2damage),
				.offset(offset1),
				.AnimationActive1(snake1damage),
				.offset1(offset2));
				
logic player1wins, endGameS1, endGameS2;

always_comb
begin

	if (snake2HealthCount == 2'b00) begin
	
		player1wins = 1'b1;
	
	end
	
	else player1wins = 1'b0;

end

always_comb
begin

	if (snake1HealthCount == 2'b00) begin
	
		player2wins = 1'b1;
	
	end
	
	else player2wins = 1'b0;

end
				
// Create Venom for Snake 1:

logic [9:0] Venom1X, Venom1Y, Venom1S;
logic [9:0] Venom2X, Venom2Y, Venom2S;
logic [9:0] Venom3X, Venom3Y, Venom3S;

int Dist_Venom1X, Dist_Venom1Y, V1_Size;
int Dist_Venom2X, Dist_Venom2Y, V2_Size;
int Dist_Venom3X, Dist_Venom3Y, V3_Size;

assign Dist_Venom1X = DrawX - Venom1X;
assign Dist_Venom1Y = DrawY - Venom1Y;

assign Dist_Venom2X = DrawX - Venom2X;
assign Dist_Venom2Y = DrawY - Venom2Y;

assign Dist_Venom3X = DrawX - Venom3X;
assign Dist_Venom3Y = DrawY - Venom3Y;

assign V1_Size = Venom1S;
assign V2_Size = Venom2S;
assign V3_Size = Venom3S;


logic venom1_on, venom2_on, venom3_on, venom1_movement, venom2_movement, venom3_movement;
 
always_comb
begin:Ball_on_proc1
    if ( (( Dist_Venom1X*Dist_Venom1X + Dist_Venom1Y*Dist_Venom1Y) <= (V1_Size * V1_Size)) && venom1_movement) 
        venom1_on = 1'b1;
    else 
        venom1_on = 1'b0;
end 

always_comb
begin:Ball_on_proc2
    if ( (( Dist_Venom2X*Dist_Venom2X + Dist_Venom2Y*Dist_Venom2Y) <= (V2_Size * V2_Size)) && venom2_movement) 
        venom2_on = 1'b1;
    else 
        venom2_on = 1'b0;
end 

always_comb
begin:Ball_on_proc3
    if ( (( Dist_Venom3X*Dist_Venom3X + Dist_Venom3Y*Dist_Venom3Y) <= (V3_Size * V3_Size)) && venom3_movement) 
        venom3_on = 1'b1;
    else 
        venom3_on = 1'b0;
end 
 

logic [1:0] venomCount;
//assign LED[1:0] = venomCount;
//assign LED[2] = venom1_movement;
//assign LED[3] = venom2_movement;
//assign LED[4] = venom3_movement;

venomCountMachine VenomCS1 (.Clk(Clk),
									 .Reset(reset | endGameS1 | endGameS2),
									 .keycode(keycode),
									 .expectedKeycode(8'h2C),
									 .venomCount(venomCount),
									 .reload(S1_ateApple));

venom venomS1_1(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h2C),
					 .snakeX(snakeX_pos+12),
					 .snakeY(snakeY_pos+12),
					 .motionFlag(motionFlagOut),
					 .collision((venom1_on && Wall_on) || (venom1_on && snake2_on)),
					 .venomMovement(venom1_movement),
					 .venomCount(2'b00),
					 .venomCountState(venomCount),
					 
					 .VenomX(Venom1X),
					 .VenomY(Venom1Y),
					 .VenomS(Venom1S),
					 .venom_on(venom1_on),
					 .LED());
					 
venom venomS1_2(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h2C),
					 .snakeX(snakeX_pos+12),
					 .snakeY(snakeY_pos+12),
					 .motionFlag(motionFlagOut),
					 .collision((venom2_on && Wall_on) || (venom2_on && snake2_on)),
					 .venomMovement(venom2_movement),
					 .venomCount(2'b01),
					 .venomCountState(venomCount),
					 
					 .VenomX(Venom2X),
					 .VenomY(Venom2Y),
					 .VenomS(Venom2S),
					 .venom_on(venom2_on),
					 .LED());
					 
venom venomS1_3(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h2C),
					 .snakeX(snakeX_pos+12),
					 .snakeY(snakeY_pos+12),
					 .motionFlag(motionFlagOut),
					 .collision((venom3_on && Wall_on) || (venom3_on && snake2_on)),
					 .venomMovement(venom3_movement),
					 .venomCount(2'b10),
					 .venomCountState(venomCount),
					 
					 .VenomX(Venom3X),
					 .VenomY(Venom3Y),
					 .VenomS(Venom3S),
					 .venom_on(venom3_on),
					 .LED());
					 

// Creating Venom for Second Snake

logic [9:0] Venom1X1, Venom1Y1, Venom1S1;
logic [9:0] Venom2X1, Venom2Y1, Venom2S1;
logic [9:0] Venom3X1, Venom3Y1, Venom3S1;

int Dist_Venom1X1, Dist_Venom1Y1, V1_Size1;
int Dist_Venom2X1, Dist_Venom2Y1, V2_Size1;
int Dist_Venom3X1, Dist_Venom3Y1, V3_Size1;

assign Dist_Venom1X1 = DrawX - Venom1X1;
assign Dist_Venom1Y1 = DrawY - Venom1Y1;

assign Dist_Venom2X1 = DrawX - Venom2X1;
assign Dist_Venom2Y1 = DrawY - Venom2Y1;

assign Dist_Venom3X1 = DrawX - Venom3X1;
assign Dist_Venom3Y1 = DrawY - Venom3Y1;

assign V1_Size1 = Venom1S1;
assign V2_Size1 = Venom2S1;
assign V3_Size1 = Venom3S1;


logic venom1_on1, venom2_on1, venom3_on1, venom1_movement1, venom2_movement1, venom3_movement1;
 
always_comb
begin:Ball_on_proc12
    if ( (( Dist_Venom1X1*Dist_Venom1X1 + Dist_Venom1Y1*Dist_Venom1Y1) <= (V1_Size1 * V1_Size1)) && venom1_movement1) 
        venom1_on1 = 1'b1;
    else 
        venom1_on1 = 1'b0;
end 

always_comb
begin:Ball_on_proc22
    if ( (( Dist_Venom2X1*Dist_Venom2X1 + Dist_Venom2Y1*Dist_Venom2Y1) <= (V2_Size1 * V2_Size1)) && venom2_movement1) 
        venom2_on1 = 1'b1;
    else 
        venom2_on1 = 1'b0;
end 

always_comb
begin:Ball_on_proc32
    if ( (( Dist_Venom3X1*Dist_Venom3X1 + Dist_Venom3Y1*Dist_Venom3Y1) <= (V3_Size1 * V3_Size1)) && venom3_movement1) 
        venom3_on1 = 1'b1;
    else 
        venom3_on1 = 1'b0;
end 		

logic [1:0] venomCount1; 

venomCountMachine VenomCS2 (.Clk(Clk),
									 .Reset(reset | endGameS1 | endGameS2),
									 .keycode(keycode),
									 .expectedKeycode(8'h28),
									 .venomCount(venomCount1),
									 .reload(S2_ateApple));

venom venomS2_1(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h28),
					 .snakeX(snake2X_pos+12),
					 .snakeY(snake2Y_pos+12),
					 .motionFlag(motionFlagOut1),
					 .collision((venom1_on1 && Wall_on) || (venom1_on1 && snake_on)),
					 .venomMovement(venom1_movement1),
					 .venomCount(2'b00),
					 .venomCountState(venomCount1),
					 
					 .VenomX(Venom1X1),
					 .VenomY(Venom1Y1),
					 .VenomS(Venom1S1),
					 .venom_on(venom1_on1),
					 .LED());
					 
venom venomS2_2(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h28),
					 .snakeX(snake2X_pos+12),
					 .snakeY(snake2Y_pos+12),
					 .motionFlag(motionFlagOut1),
					 .collision((venom2_on1 && Wall_on) || (venom2_on1 && snake_on)),
					 .venomMovement(venom2_movement1),
					 .venomCount(2'b01),
					 .venomCountState(venomCount1),
					 
					 .VenomX(Venom2X1),
					 .VenomY(Venom2Y1),
					 .VenomS(Venom2S1),
					 .venom_on(venom2_on1),
					 .LED());
					 
venom venomS2_3(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'h28),
					 .snakeX(snake2X_pos+12),
					 .snakeY(snake2Y_pos+12),
					 .motionFlag(motionFlagOut1),
					 .collision((venom3_on1 && Wall_on) || (venom3_on1 && snake_on)),
					 .venomMovement(venom3_movement1),
					 .venomCount(2'b10),
					 .venomCountState(venomCount1),
					 
					 .VenomX(Venom3X1),
					 .VenomY(Venom3Y1),
					 .VenomS(Venom3S1),
					 .venom_on(venom3_on1),
					 .LED());
		 
//always_ff @ (posedge vga_clk) begin
//
//	if (keycode[15:8] == 8'd44 || keycode[7:0] == 8'd44) begin
//	
//		venom1_movement <= 1'b1;	
//		
////		LED[2] = 1'b1;
//		
//	end
//	
////	else venom1_movement <= 1'b0;
//	
//	else if (venom1_on && Wall_on) begin
//	
//		venom1_movement <= 1'b0;
////		LED[2] = 1'b0;
//		
//	end
//	
//	
//end


// Setting up Snake 1:

// Addresses for Sprite
//assign  rom_address_W = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);
//assign  rom_address_S = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
//assign  rom_address_A = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
//assign  rom_address_D = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);

assign  rom_address_W = DistX + DistY*24; // Working
assign  rom_address_S = rom_address_W; 
assign  rom_address_A = rom_address_W; 
assign  rom_address_D = rom_address_W;

// Checking if snake should be drawn
always_comb
begin: snake1_on_proc

	if ((DistX < 24 && DistY < 24) &&
		((redPaletteOut != 4'hF) 	 || 
      (bluePaletteOut != 4'hF) 	 ||
		(greenPaletteOut != 4'h0))) begin
		
		snake_on = 1'b1;
			
	 end
	 
	 else snake_on = 1'b0;

end

// Setting up Snake 2:

// Addresses for Sprite
assign  rom_address_W1 = DistX1 + DistY1*24; // Working
assign  rom_address_S1 = rom_address_W1; 
assign  rom_address_A1 = rom_address_W1; 
assign  rom_address_D1 = rom_address_W1;

// Checking if snake should be drawn
always_comb
begin: snake2_on_proc

	if ((DistX1 < 24 && DistY1 < 24)  &&
		((redPaletteOut1 != 4'hF) 	   ||
		(bluePaletteOut1 != 4'hF) 	   ||
		(greenPaletteOut1 != 4'h0))) begin
				
			snake2_on = 1'b1;
			
	 end
	 
	 else snake2_on = 1'b0;

end

// Wall Detection and Flag setting
 
always_comb
begin: Wall_detection

 	if ((paletteOb1_red != 4'hF) &&
			(paletteOb1_green != 4'h0) && 
			(paletteOb1_blue != 4'hF)) begin

				Wall_on = 1'b1;

	end

	else begin
	
		Wall_on = 1'b0;

	end

end

logic heart1on, heart2on, heart3on;
logic heart4on, heart5on, heart6on;

logic [1:0] snake1HealthCount;
logic snake2Won;

health_stateMachine S1 (.Clk(vga_clk),
								.Reset(reset | endGameS1 | endGameS2),
								.collision((venom1_on1 && snake_on)||(venom2_on1 && snake_on)||(venom3_on1 && snake_on)),
								.healthCount(snake1HealthCount),
								.gameEnd(snake2Won));

always_comb
begin: Snake1Health

	if ((DrawX >= 10'd13   - 8) &&
		 (DrawX <=  10'd13  + 8)  &&
		 (DrawY >=  10'd470 - 8)  &&
		 (DrawY <=  10'd470 + 8)&&
		 (snake1HealthCount == 2'b11)) begin
		
			heart1on = 1'b1;
			heart2on = 1'b0;
			heart3on = 1'b0;
		
	end
	
	else if ((DrawX >= 10'd28   - 8) &&
				(DrawX <=  10'd28  + 8) &&
				(DrawY >=  10'd470 - 8) &&
				(DrawY <=  10'd470 + 8) &&
				((snake1HealthCount == 2'b11)||
				(snake1HealthCount == 2'b10)))  begin
		
			heart1on = 1'b0;
			heart2on = 1'b1;
			heart3on = 1'b0;
		
	end
		
	else if ((DrawX >=  10'd43  - 8) &&
				(DrawX <=  10'd43  + 8) &&
				(DrawY >=  10'd470 - 8) &&
				(DrawY <=  10'd470 + 8) &&
				((snake1HealthCount == 2'b11)||
				(snake1HealthCount == 2'b10)||
				(snake1HealthCount == 2'b01))) begin
				
			heart1on = 1'b0;
			heart2on = 1'b0;
			heart3on = 1'b1;
				
	end
	
	else begin
	
			heart1on = 1'b0;
			heart2on = 1'b0;
			heart3on = 1'b0;
	
	end
		
end

logic [1:0] snake2HealthCount;
logic snake1Won;

health_stateMachine S2 (.Clk(vga_clk),
								.Reset(reset | endGameS1 | endGameS2),
								.collision((venom1_on && snake2_on)||(venom2_on && snake2_on)||(venom3_on && snake2_on)),
								.healthCount(snake2HealthCount),
								.gameEnd(snake1Won));
								
//assign LED[1:0] = snake2HealthCount;
//assign LED[2] = venom1_on;
//assign LED[3] = snake2_on;

always_comb
begin: Snake2Health

	if ((DrawX >= 10'd597 - 8)  &&
		 (DrawX <= 10'd597 + 8)  &&
		 (DrawY >= 10'd470 - 8)  &&
		 (DrawY <= 10'd470 + 8) &&
		 (snake2HealthCount == 2'b11)) begin
		
			heart4on = 1'b1;
			heart5on = 1'b0;
			heart6on = 1'b0;
		
	end
	
	else if ((DrawX >= 10'd612  - 8) &&
				(DrawX <= 10'd612 + 8)  &&
				(DrawY >= 10'd470 - 8)  &&
				(DrawY <= 10'd470 + 8) &&
				((snake2HealthCount == 2'b11)||
				 (snake2HealthCount == 2'b10))) begin
		
			heart4on = 1'b0;
			heart5on = 1'b1;
			heart6on = 1'b0;
		
	end
		
	else if ((DrawX >=  10'd627 - 8)  &&
				(DrawX <=  10'd627 + 8)  &&
				(DrawY >=  10'd470 - 8)  &&
				(DrawY <=  10'd470 + 8) &&
			   ((snake2HealthCount == 2'b01)||
				 (snake2HealthCount == 2'b10)||
				 (snake2HealthCount == 2'b11)))	begin
				
			heart4on = 1'b0;
			heart5on = 1'b0;
			heart6on = 1'b1;
				
	end
	
	else begin
	
			heart4on = 1'b0;
			heart5on = 1'b0;
			heart6on = 1'b0;
	
	end
		
end

// *********************************LSFR*****************************//

logic [9:0] x,y, x_out, y_out;
logic LoadX, LoadY;



VGA_Random_Coords XCoord1 (.Clk(vga_clk),
								  .reset(reset),
								  .seedIn(randCord[7]),
								  .rnd(x));
								  
VGA_Random_Coords YCoord1 (.Clk(vga_clk),
								  .reset(reset),
								  .seedIn(randCord[3]),
								  .rnd(y));
								  

reg_unit #(10) randomX(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset						
					.Din(x),
					.Load(LoadX),
					.Data_Out(x_out));
					
reg_unit #(10) randomY(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset						
					.Din(y),
					.Load(LoadY),
					.Data_Out(y_out));
					
					
always_comb begin

	LoadX = 1'b0;
	LoadY = 1'b0;

	if (x_out >= 10'd600 || y_out >= 10'd400) begin 
		
		LoadX = 1'b1;
		LoadY = 1'b1;
		
	end
	
	else begin

		if (((DrawX == x_out) && (DrawY == y_out))) begin
		
			if (x_out >= 10'd600 || y_out >= 10'd400) begin 
			
				LoadX = 1'b1;
				LoadY = 1'b1;
			
			end
		
			else if ((Wall_on || snake_on || snake2_on)) begin
			
				LoadX = 1'b1;
				LoadY = 1'b1;

			end 
			
			else if (x == x_out || y == y_out) begin
			
				LoadX = 1'b1;
				LoadY = 1'b1;
				
			end
			
			else begin
			
				LoadX = 1'b0;
				LoadY = 1'b0;
				
			
			end
		end
	end
end

logic apple_on;

always_comb
begin

	if ((DrawX >= x_out - 8)  &&
		 (DrawX <= x_out + 8)  &&
		 (DrawY >= y_out - 8)  &&
		 (DrawY <= y_out + 8)) begin
		
			apple_on = 1'b1;
		
	end
	
	else apple_on = 1'b0;
	
end

logic S1_ateApple, S2_ateApple;

always_comb
begin

	if (apple_on && snake_on) begin
	
		S1_ateApple = 1'b1;
	
	end
	
	else S1_ateApple = 1'b0;
	

end

always_comb
begin

	if (apple_on && snake2_on) begin
	
		S2_ateApple = 1'b1;
	
	end
	
	else S2_ateApple = 1'b0;
	

end
					
logic [31:0] counter;
logic [9:0] egg_x, egg_y, egg_xOut, egg_yOut;
logic load_eggX, load_eggY;
						 
Second_Counter (.clk_60Hz(frame_clk),
					 .reset(reset | endGameS1 | endGameS2),
					 .count(counter));
					 
VGA_Random_Coords eggXCoord1 (.Clk(frame_clk),
										.reset(reset),
										.seedIn(randCord[13]),
										.rnd(egg_x));
								  
VGA_Random_Coords eggYCoord1 (.Clk(frame_clk),
										.reset(reset),
										.seedIn(randCord[17]),
										.rnd(egg_y));
								  

reg_unit #(10) eggX(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset						
					.Din(x),
					.Load(LoadX),
					.Data_Out(egg_xOut));
					
reg_unit #(10) eggY(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset						
					.Din(y),
					.Load(LoadY),
					.Data_Out(egg_yOut));

logic easterEggOn;

			 
always_ff @ (posedge Clk)
begin

	if (counter == 25) begin
		
		easterEggOn <= 1'b1;
	
	end
	
	else if (EggOn && (snake_on || snake2_on)) begin
	
		easterEggOn <= 1'b0;
	
	end
	
	else if (counter == 28) begin
		
		easterEggOn <= 1'b0;
	
	end
	
end

logic show_me;

always_ff @ (posedge Clk) begin

	if (reset) show_me = 1'b0;
	
	if (EggOn && (snake_on || snake2_on)) begin
	
		show_me <= 1'b1;
	
	end


end

always_comb begin

	load_eggX = 1'b0;
	load_eggY = 1'b0;
	
	if (counter == 8) begin
	
		if (egg_xOut >= 10'd600 || egg_yOut >= 10'd400) begin 
		
			load_eggX = 1'b1;
			load_eggY = 1'b1;
		
		end
	
		else begin

			if (((DrawX == egg_xOut) && (DrawY == egg_yOut))) begin
		
				if (egg_xOut >= 10'd600 || egg_yOut >= 10'd400) begin 
			
					load_eggX = 1'b1;
					load_eggY = 1'b1;
			
				end
		
				else if ((Wall_on || snake_on || snake2_on)) begin
			
					load_eggX = 1'b1;
					load_eggY = 1'b1;

				end 
			
				else begin
			
					load_eggX = 1'b0;
					load_eggY = 1'b0;
				
				end
		end

	end
end
end



assign LED[0] = show_me;
assign LED[1] = EggOn;
	

//// COLORING LOGIC

	 
always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

	if (blank) begin

		if (LD_MENU) begin
			red <= palette_red_MM;
			green <= palette_green_MM;
			blue <= palette_blue_MM;
		end
		
		else if (LD_Map1) begin

			
		// Snake 1 Drawing

		if (snake_on == 1'b1) begin
		
			if ((redPaletteOut == 4'hF) &&
					(bluePaletteOut == 4'hF) && 
					(greenPaletteOut == 4'h0)) begin
				
				red <= palette_red;									//// Printing Background
				green <= palette_green;
				blue <= palette_blue;
				
			end
			
			else begin
		
				red <= redPaletteOut;								//// Drawing Snake 1
				green <= greenPaletteOut;
				blue <= bluePaletteOut;
				
			end
						
		end
		
		
		// Snake 2 Drawing
		
		else if (snake2_on == 1'b1) begin
			
			if ((redPaletteOut1 == 4'hF) &&
					(bluePaletteOut1 == 4'hF) && 
					(greenPaletteOut1 == 4'h0)) begin
				
				red <= palette_red;
				green <= palette_green;
				blue <= palette_blue;
				
			end
			
			else begin
			
				red <= redPaletteOut1;
				green <= greenPaletteOut1;
				blue <= bluePaletteOut1;
				
			end	
		end
		
		else begin
		
			red <= palette_red;
			green <= palette_green;
			blue <= palette_blue;
			
		end
		
		
			if ((paletteOb1_red != 4'hF) &&
					(paletteOb1_green != 4'h0) && 
					(paletteOb1_blue != 4'hF)) begin
						
						red <= paletteOb1_red;
						green <= paletteOb1_green;
						blue <= paletteOb1_blue;

					end
			
			// Venom Drawing Under Snake
			
			if (venom1_on) begin
				
					red <= VS1_1_red;
					green <= VS1_1_green;
					blue <= VS1_1_blue;
				
				end
				
			else if (venom2_on) begin
				
					red <= 4'h0;
					green <= 4'h0;
					blue <= 4'h0;
				
				end
				
			else if (venom3_on) begin
			
				red <= 4'h0;
				green <= 4'h0;
				blue <= 4'h0;
			
			end
			
			if (venom1_on1) begin
				
					red <=   4'h0;
					green <= 4'h0;
					blue <=  4'h0;
				
				end
				
			else if (venom2_on1) begin
				
					red <=   4'h0;
					green <= 4'h0;
					blue <=  4'h0;
				
				end
				
			else if (venom3_on1) begin
			
				red <= 4'h0;
				green <= 4'h0;
				blue <= 4'h0;
			
			end
			
			if (heart1on) begin
			
				if ((paletteHeart_red != 4'h0) ||
					(paletteHeart_green != 4'h0) || 
					(paletteHeart_blue != 4'h0)) begin
						
						red <= paletteHeart_red;
						green <= paletteHeart_green;
						blue <= paletteHeart_blue;
				end			
			end
			
			if (heart2on) begin
			
				if ((paletteHeart_red1 != 4'h0) ||
					(paletteHeart_green1 != 4'h0) || 
					(paletteHeart_blue1 != 4'h0)) begin
						
						red <= paletteHeart_red1;
						green <= paletteHeart_green1;
						blue <= paletteHeart_blue1;
				end			
			end
			
			if (heart3on) begin
			
				if ((paletteHeart_red2 != 4'h0) ||
					(paletteHeart_green2 != 4'h0) || 
					(paletteHeart_blue2 != 4'h0)) begin
						
						red <= paletteHeart_red2;
						green <= paletteHeart_green2;
						blue <= paletteHeart_blue2;
				end			
			end
			
			if (heart4on) begin
			
				if ((paletteHeart_red3 != 4'h0) ||
					(paletteHeart_green3 != 4'h0) || 
					(paletteHeart_blue3 != 4'h0)) begin
						
						red <= paletteHeart_red3;
						green <= paletteHeart_green3;
						blue <= paletteHeart_blue3;
				end			
			end
			
			if (heart5on) begin
			
				if ((paletteHeart_red4 != 4'h0) ||
					(paletteHeart_green4 != 4'h0) || 
					(paletteHeart_blue4 != 4'h0)) begin
						
						red <= paletteHeart_red4;
						green <= paletteHeart_green4;
						blue <= paletteHeart_blue4;
				end			
			end
			
			if (heart6on) begin
			
				if ((paletteHeart_red5 != 4'h0) ||
					(paletteHeart_green5 != 4'h0) || 
					(paletteHeart_blue5 != 4'h0)) begin
						
						red <= paletteHeart_red5;
						green <= paletteHeart_green5;
						blue <= paletteHeart_blue5;
				end			
			end
			
			if (apple_on) begin
			
				if ((apple_red != 4'h0) ||
					(apple_green != 4'h0) || 
					(apple_blue != 4'h0)) begin
							
					red <= apple_red;
					green <= apple_green;
					blue <= apple_blue;
					
				end
			
			end
			
			if (S1VenomCountDisplay) begin
			
				if (actual_data1 == 1'b1) begin
		
					red <=   4'h0;
					green <= 4'h0;
					blue <=  4'hF;
			
				end
				
				else begin
				
					red <=   4'hF;
					green <= 4'hF;
					blue <=  4'hF;
				
				end
				
			end
			
			if (S2VenomCountDisplay) begin
			
				if (actual_data2 == 1'b1) begin
		
					red <=   4'hF;
					green <= 4'h0;
					blue <=  4'h0;
			
				end
				
				else begin
				
					red <=   4'hF;
					green <= 4'hF;
					blue <=  4'hF;
				
				end
				
			end

			if (ani1on && snake2damage) begin

				if ((ani_palette_red != 4'hF) ||
					(ani_palette_green != 4'h0) || 
					(ani_palette_blue != 4'hF)) begin

						red <= ani_palette_red;
						green <= ani_palette_green;
						blue <= ani_palette_blue;

				end

			end
			
			if (ani2on && snake1damage) begin

				if ((ani_palette_red1 != 4'hF) ||
					(ani_palette_green1 != 4'h0) || 
					(ani_palette_blue1 != 4'hF)) begin

						red <= ani_palette_red1;
						green <= ani_palette_green1;
						blue <= ani_palette_blue1;

				end
			end
			
			if (EggOn) begin
			
				if ((egg_palette_red != 4'hF) ||
					(egg_palette_green != 4'h0) || 
					(egg_palette_blue != 4'hF)) begin

						red <= egg_palette_red;
						green <= egg_palette_green;
						blue <= egg_palette_blue;

				end
			
			end
			
			if (me_on) begin
			
				if ((palette_red_me != 4'hF) ||
					(palette_green_me != 4'h0) || 
					(palette_blue_me != 4'hF)) begin

						red <= palette_red_me;
						green <= palette_green_me;
						blue <= palette_blue_me;

				end			
			end
			
		end // LDMap1 END
		
		else if (endGameS1) begin
		
			red <= palette_red_P1W;
			green <= palette_green_P1W;
			blue <= palette_blue_P1W;

		end // S1 wins screen END
		
		else if (endGameS2) begin
		
			red <= palette_red_P2W;
			green <= palette_green_P2W;
			blue <= palette_blue_P2W;

		end // S2 wins screen END

	end // Blanking if END
	
end

// SETTING HIT OBSTACLE FLAG FOR SNAKE 1

 logic [9:0] snake1X, snake1Y;

 
 assign snake1X = DrawX - snakeX_pos;
 assign snake1Y = DrawY - snakeY_pos;

 always_ff @(posedge vga_clk) begin

 	if (DrawX == 0 && DrawY == 0) OB1Flag <= 1'b0;

 	if (!(paletteOb1_red == 4'hF && paletteOb1_green == 4'h0 && paletteOb1_blue == 4'hF)) begin
		
 		case (motionFlagOut)

 			2'b00 : begin		// W

 						if (snake1X < 24 && snake1Y == '1) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b01 :begin		// A

 						if (snake1X == '1 && snake1Y < 24) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b10 :begin		// S

 						if (snake1X < 24  && snake1Y == 24) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b11 :begin		// D

 						if (snake1X == 24 && snake1Y < 24) begin
 							OB1Flag <= 1'b1;
 						end
 					end

// 			default: OB1Flag <= 1'b0;

 		endcase

 	end

 end
 
 
// SETTING HIT OBSTACLE FLAG FOR SNAKE 2

 logic [9:0] snake2X, snake2Y;

 assign snake2X = DrawX - snake2X_pos;
 assign snake2Y = DrawY - snake2Y_pos;

 always_ff @(posedge vga_clk) begin

 	if (DrawX == 0 && DrawY == 0) OB2Flag <= 1'b0;

 	if (!(paletteOb1_red == 4'hF && paletteOb1_green == 4'h0 && paletteOb1_blue == 4'hF)) begin
		
 		case (motionFlagOut1)

 			2'b00 : begin		// W

 						if (snake2X <= 24 && snake2Y == '1) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b01 :begin		// A

 						if (snake2X == '1 && snake2Y < 24) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b10 :begin		// S

 						if (snake2X < 24  && snake2Y == 24) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b11 :begin		// D

 						if (snake2X == 24 && snake2Y < 24) begin
 							OB2Flag <= 1'b1;
 						end
 					end

 			default: OB2Flag <= 1'b0;

 		endcase

 	end

 end



// Movement state maching

logic [1:0] motionFlag, motionFlag1, motionFlagOut, motionFlagOut1;
logic Load, Load1;

move_stateMachineS1 s1(
					.Clk(Clk),
					.keycode(keycode),
					.motionFlag(motionFlag),
					.Load(Load)
			
				);
				
move_stateMachineS2 s2(
					.Clk(Clk),
					.keycode(keycode),
					.motionFlag(motionFlag1),
					.Load(Load1)
			
				);
				
// Register to keep track of motion of snake
				
reg_unit #(2) snake1Motion(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset						
					.Din(motionFlag),
					.Load(Load),
					.Data_Out(motionFlagOut));
					
reg_unit #(2) snake2Motion(
					.Clk(Clk),
					.Reset(reset),							/// Might have to change this to game reset
					.Din(motionFlag1),
					.Load(Load1),
					.Data_Out(motionFlagOut1));

// Multiplexer to Choose Snake Palette

logic [3:0] w_palette_red, w_palette_red1;
logic [3:0] a_palette_red, a_palette_red1;
logic [3:0] s_palette_red, s_palette_red1;
logic [3:0] d_palette_red, d_palette_red1;

logic [3:0] w_palette_green, w_palette_green1;
logic [3:0] a_palette_green, a_palette_green1;
logic [3:0] s_palette_green, s_palette_green1;
logic [3:0] d_palette_green, d_palette_green1;

logic [3:0] w_palette_blue, w_palette_blue1;
logic [3:0] a_palette_blue, a_palette_blue1;
logic [3:0] s_palette_blue, s_palette_blue1;
logic [3:0] d_palette_blue, d_palette_blue1;

logic [3:0] redPaletteOut, redPaletteOut1;
logic [3:0] greenPaletteOut, greenPaletteOut1;
logic [3:0] bluePaletteOut, bluePaletteOut1;


// Snake 1

mux_4_1_16	redPaletteMux(.A(w_palette_red),
								   .B(a_palette_red),
								   .C(s_palette_red),
								   .D(d_palette_red),
								   .SelectBit(motionFlagOut),
								   .Out(redPaletteOut));
								
mux_4_1_16	greenPaletteMux(.A(w_palette_green),
								     .B(a_palette_green),
								     .C(s_palette_green),
								     .D(d_palette_green),
								     .SelectBit(motionFlagOut),
								     .Out(greenPaletteOut));
								  
mux_4_1_16	bluePaletteMux(.A(w_palette_blue),
								    .B(a_palette_blue),
								    .C(s_palette_blue),
								    .D(d_palette_blue),
								    .SelectBit(motionFlagOut),
								    .Out(bluePaletteOut));
								  
								  
// Snake 2

mux_4_1_16	redPaletteMux1(.A(w_palette_red1),
								   .B(a_palette_red1),
								   .C(s_palette_red1),
								   .D(d_palette_red1),
								   .SelectBit(motionFlagOut1),
								   .Out(redPaletteOut1));
								 
mux_4_1_16	greenPaletteMux1(.A(w_palette_green1),
								     .B(a_palette_green1),
								     .C(s_palette_green1),
								     .D(d_palette_green1),
								     .SelectBit(motionFlagOut1),
								     .Out(greenPaletteOut1));
								  
mux_4_1_16	bluePaletteMux1(.A(w_palette_blue1),
								    .B(a_palette_blue1),
								    .C(s_palette_blue1),
								    .D(d_palette_blue1),
								    .SelectBit(motionFlagOut1),
								    .Out(bluePaletteOut1));
	
// Main Menu Sprite

logic [14:0] rom_address_MM;
logic [1:0] rom_q_MM;

logic [3:0] palette_red_MM, palette_green_MM, palette_blue_MM;

assign rom_address_MM = ((DrawX * 160) / 640) + (((DrawY * 120) / 480) * 160);

mainMenu_rom mainMenu_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_MM),
	.q       (rom_q_MM)
);

mainMenu_palette mainMenu_palette (
	.index (rom_q_MM),
	.red   (palette_red_MM),
	.green (palette_green_MM),
	.blue  (palette_blue_MM)
);

// Background Data

colorBGD_rom colorBGD_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address),
	.q       (rom_q)
);

colorBGD_palette colorBGD_palette (
	.index (rom_q),
	.red   (palette_red),
	.green (palette_green),
	.blue  (palette_blue)
);


// Snake 1 Data

up_head_p1_rom SnakeHead_W_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_S),
	.q       (rom_q_W)
);

up_head_p1_palette SnakeHead_W_palette (
	.index (rom_q_W),
	.red   (w_palette_red),
	.green (w_palette_green),
	.blue  (w_palette_blue)
);

down_head_p1_rom SnakeHead_S_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_S),
	.q       (rom_q_S)
);

down_head_p1_palette SnakeHead_S_palette (
	.index (rom_q_S),
	.red   (s_palette_red),
	.green (s_palette_green),
	.blue  (s_palette_blue)
);

left_head_p1_rom SnakeHead_A_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_A),
	.q       (rom_q_A)
);

left_head_p1_palette SnakeHead_A_palette (
	.index (rom_q_A),
	.red   (a_palette_red),
	.green (a_palette_green),
	.blue  (a_palette_blue)
);

right_head_p1_rom SnakeHead_D_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_D),
	.q       (rom_q_D)
);

right_head_p1_palette SnakeHead_D_palette (
	.index (rom_q_D),
	.red   (d_palette_red),
	.green (d_palette_green),
	.blue  (d_palette_blue)
);


// Snake 2 Data

up_head_p2_rom up_head_p2_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_W1),
	.q       (rom_q_W1)
);

up_head_p2_palette up_head_p2_palette (
	.index (rom_q_W1),
	.red   (w_palette_red1  ),
	.green (w_palette_green1),
	.blue  (w_palette_blue1 )
);	

down_head_p2_rom down_head_p2_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_S1),
	.q       (rom_q_S1)
);

down_head_p2_palette down_head_p2_palette (
	.index (rom_q_S1),
	.red   (s_palette_red1  ),
	.green (s_palette_green1),
	.blue  (s_palette_blue1 )
);

left_head_p2_rom left_head_p2_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_A1),
	.q       (rom_q_A1)
);

left_head_p2_palette left_head_p2_palette (
	.index (rom_q_A1),
	.red   (a_palette_red1  ),
	.green (a_palette_green1),
	.blue  (a_palette_blue1 )
);

right_head_p2_rom right_head_p2_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_D1),
	.q       (rom_q_D1)
);

right_head_p2_palette right_head_p2_palette (
	.index (rom_q_D1),
	.red   (d_palette_red1  ),
	.green (d_palette_green1),
	.blue  (d_palette_blue1 )
);


// Obstacle Data

logic [18:0] rom_addressOB1;
assign rom_addressOB1 = ((DrawX * 320) / 640) + (((DrawY * 240) / 480) * 320);
logic [3:0] rom_OB1;
logic [3:0] paletteOb1_red, paletteOb1_green, paletteOb1_blue;

Obstacle_Set1_rom Obstacle_Set1_rom (
	.clock   (negedge_vga_clk),
	.address (rom_addressOB1),
	.q       (rom_OB1)
);

Obstacle_Set1_palette Obstacle_Set1_palette (
	.index (rom_OB1),
	.red   (paletteOb1_red),
	.green (paletteOb1_green),
	.blue  (paletteOb1_blue)
);

// Heart Data

// Set 1

logic [18:0] rom_addressHeart, rom_addressHeart1, rom_addressHeart2;
assign rom_addressHeart = ((DrawX-13+16)) +  ((DrawY-470+16) * 32);
assign rom_addressHeart1 = ((DrawX-28+16)) + ((DrawY-470+16) * 32);
assign rom_addressHeart2 = ((DrawX-43+16)) + ((DrawY-470+16) * 32);


logic [3:0] rom_Heart, rom_Heart1, rom_Heart2;
logic [3:0] paletteHeart_red, paletteHeart_green, paletteHeart_blue;
logic [3:0] paletteHeart_red1, paletteHeart_green1, paletteHeart_blue1;
logic [3:0] paletteHeart_red2, paletteHeart_green2, paletteHeart_blue2;

heart_rom heart_rom (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart),
	.q       (rom_Heart)
);

heart_palette heart_palette (
	.index (rom_Heart),
	.red   (paletteHeart_red),
	.green (paletteHeart_green),
	.blue  (paletteHeart_blue)
);

heart_rom heart_rom1 (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart1),
	.q       (rom_Heart1)
);

heart_palette heart_palette1 (
	.index (rom_Heart1),
	.red   (paletteHeart_red1),
	.green (paletteHeart_green1),
	.blue  (paletteHeart_blue1)
);

heart_rom heart_rom2 (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart2),
	.q       (rom_Heart2)
);

heart_palette heart_palette2 (
	.index (rom_Heart2),
	.red   (paletteHeart_red2),
	.green (paletteHeart_green2),
	.blue  (paletteHeart_blue2)
);

// Set 2

logic [18:0] rom_addressHeart3, rom_addressHeart4, rom_addressHeart5;
assign rom_addressHeart3 = ((DrawX-597+16)) +  ((DrawY-470+16) * 32);
assign rom_addressHeart4 = ((DrawX-612+16)) + ((DrawY-470+16) * 32);
assign rom_addressHeart5 = ((DrawX-627+16)) + ((DrawY-470+16) * 32);

logic [3:0] rom_Heart3, rom_Heart4, rom_Heart5;
logic [3:0] paletteHeart_red3, paletteHeart_green3, paletteHeart_blue3;
logic [3:0] paletteHeart_red4, paletteHeart_green4, paletteHeart_blue4;
logic [3:0] paletteHeart_red5, paletteHeart_green5, paletteHeart_blue5;

heart_rom heart_rom3 (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart3),
	.q       (rom_Heart3)
);

heart_palette heart_palette3 (
	.index (rom_Heart3),
	.red   (paletteHeart_red3),
	.green (paletteHeart_green3),
	.blue  (paletteHeart_blue3)
);

heart_rom heart_rom4 (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart4),
	.q       (rom_Heart4)
);

heart_palette heart_palette4 (
	.index (rom_Heart4),
	.red   (paletteHeart_red4),
	.green (paletteHeart_green4),
	.blue  (paletteHeart_blue4)
);

heart_rom heart_rom5 (
	.clock   (negedge_vga_clk),
	.address (rom_addressHeart5),
	.q       (rom_Heart5)
);

heart_palette heart_palette5 (
	.index (rom_Heart5),
	.red   (paletteHeart_red5),
	.green (paletteHeart_green5),
	.blue  (paletteHeart_blue5)
);


// Venom Data

logic [5:0] venomS1_1_romAddress;
logic [2:0] rom_VS1_1;

assign venomS1_1_romAddress = ((DrawX-Venom1X+4)) + ((DrawY-Venom1Y+4) * 8);

logic [3:0] VS1_1_red, VS1_1_green, VS1_1_blue;

Venom_rom Venom_rom (
	.clock   (negedge_vga_clk),
	.address (venomS1_1_romAddress),
	.q       (rom_VS1_1)
);

Venom_palette Venom_palette (
	.index (rom_VS1_1),
	.red   (VS1_1_red),
	.green (VS1_1_green),
	.blue  (VS1_1_blue)
);


// Apple Data

logic [7:0] apple_romAddress;
logic [2:0] rom_apple;

assign apple_romAddress = ((DrawX-x_out+8)) + ((DrawY-y_out+8) * 16);

logic [3:0] apple_red, apple_green, apple_blue;

apple_rom apple_rom (
	.clock   (negedge_vga_clk),
	.address (apple_romAddress),
	.q       (rom_apple)
);

apple_palette apple_palette (
	.index (rom_apple),
	.red   (apple_red),
	.green (apple_green),
	.blue  (apple_blue)
);

// Winner P1/P2 Data

logic [14:0] rom_address_P1W;
logic [14:0] rom_address_P2W;
logic [2:0] rom_q_P1W;
logic [2:0] rom_q_P2W;

logic [3:0] palette_red_P1W, palette_green_P1W, palette_blue_P1W;
logic [3:0] palette_red_P2W, palette_green_P2W, palette_blue_P2W;

assign rom_address_P1W = ((DrawX * 160) / 640) + (((DrawY * 120) / 480) * 160);
assign rom_address_P2W = ((DrawX * 160) / 640) + (((DrawY * 120) / 480) * 160);

WinnerP1_rom WinnerP1_roms (
	.clock   (negedge_vga_clk),
	.address (rom_address_P1W),
	.q       (rom_q_P1W)
);

WinnerP1_palette WinnerP1_palette (
	.index (rom_q_P1W),
	.red   (palette_red_P1W),
	.green (palette_green_P1W),
	.blue  (palette_blue_P1W)
);


WinnerP2_rom WinnerP2_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_P2W),
	.q       (rom_q_P2W)
);

WinnerP2_palette WinnerP2_palette (
	.index (rom_q_P2W),
	.red   (palette_red_P2W),
	.green (palette_green_P2W),
	.blue  (palette_blue_P2W)
);

// Bullet Count
logic [10:0] sprite_addr1;
logic [10:0] sprite_addr2;
logic [7:0] sprite_data1;
logic [7:0] sprite_data2;
logic [7:0] actual_data1;
logic [7:0] actual_data2;

logic [6:0] charCodeS1, charCodeS2;

font_rom (.addr(sprite_addr1), .data(sprite_data1));
font_rom (.addr(sprite_addr2), .data(sprite_data2));

mux_4_1_16	charcode1	(.A(7'h33),
							 .B(7'h32),
							 .C(7'h31),
							 .D(7'h30),
							 .SelectBit(venomCount),
							 .Out(charCodeS1));	
							 
mux_4_1_16	charcode2(.A(7'h33),
							 .B(7'h32),
							 .C(7'h31),
							 .D(7'h30),
							 .SelectBit(venomCount1),
							 .Out(charCodeS2));	
									
logic [9:0] VS1TextDistX;
assign VS1TextDistX = DrawX - 25;

logic [9:0] VS1TextDistY;
assign VS1TextDistY = DrawY - 445;

logic [9:0] VS2TextDistX;
assign VS2TextDistX = DrawX - 610;

logic [9:0] VS2TextDistY;
assign VS2TextDistY = DrawY - 445;

logic S1VenomCountDisplay, S2VenomCountDisplay;

always_comb begin

	S1VenomCountDisplay = 1'b0;
	S2VenomCountDisplay = 1'b0;

	if (VS1TextDistX < 8 &&
		 VS1TextDistY < 13) begin
		
			S1VenomCountDisplay = 1'b1;

	end
	
	else if (VS2TextDistX < 8 &&
				VS2TextDistY < 13) begin
		
			S2VenomCountDisplay = 1'b1;
		
	end
	
	else begin
	
		S1VenomCountDisplay = 1'b0;
		S2VenomCountDisplay = 1'b0;
		
	end

end

						
always_comb begin

	sprite_addr1 = charCodeS1 * 16 + VS1TextDistY[3:0];
	sprite_addr2 = charCodeS2 * 16 + VS2TextDistY[3:0];
	
	actual_data1 = sprite_data1[7-VS1TextDistX[2:0]];
	actual_data2 = sprite_data2[7-VS2TextDistX[2:0]];

end

// Animation Data

logic [2:0] offset1, offset2;
logic snake2damage, ani1on;
								
logic [12:0] ani_rom_address;
logic [3:0] ani_rom_q;

logic [12:0] ani_rom_address1;
logic [3:0] ani_rom_q1;

assign ani_rom_address = (900 * offset1) + (DistX1 + (DistY1*30));
assign ani_rom_address1 = (900 * offset2) + (DistX + (DistY*30));

logic [3:0] ani_palette_red, ani_palette_green, ani_palette_blue;
logic [3:0] ani_palette_red1, ani_palette_green1, ani_palette_blue1;
								

VenomAnimationSprite_rom VenomAnimationSprite_rom (
	.clock   (negedge_vga_clk),
	.address (ani_rom_address),
	.q       (ani_rom_q)
);

VenomAnimationSprite_palette VenomAnimationSprite_palette (
	.index (ani_rom_q),
	.red   (ani_palette_red),
	.green (ani_palette_green),
	.blue  (ani_palette_blue)
);

assign ani1on = (DistX1 < 30 && DistY1 < 30);
assign ani2on = (DistX < 30 && DistY < 30);

VenomAnimationSprite_rom VenomAnimationSprite_rom1 (
	.clock   (negedge_vga_clk),
	.address (ani_rom_address1),
	.q       (ani_rom_q1)
);

VenomAnimationSprite_palette VenomAnimationSprite_palette1 (
	.index (ani_rom_q1),
	.red   (ani_palette_red1),
	.green (ani_palette_green1),
	.blue  (ani_palette_blue1)
);

// Easter Egg Data

logic [6:0] rom_address_egg;
logic [3:0] rom_q_egg;

logic [9:0] EggDistX, EggDistY;

assign EggDistX = DrawX - 325;
assign EggDistY = DrawY - 405;

//assign EggDistX = DrawX - egg_xOut;
//assign EggDistY = DrawY - egg_yOut;

logic EggOn;

assign EggOn = EggDistX < 10 && EggDistY < 10 && easterEggOn;
assign rom_address_egg = EggDistX + EggDistY*10;

logic [3:0] egg_palette_red, egg_palette_green, egg_palette_blue;

EasterEgg_rom EasterEgg_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_egg),
	.q       (rom_q_egg)
);

EasterEgg_palette EasterEgg_palette (
	.index (rom_q_egg),
	.red   (egg_palette_red),
	.green (egg_palette_green),
	.blue  (egg_palette_blue)
);

// Me Sprite

logic [9:0] rom_address_me;
logic [3:0] rom_q_me;

logic [9:0] MeDistX, MeDistY;

assign MeDistX = DrawX - 318;
assign MeDistY = DrawY - 425;

assign me_on = MeDistX < 24 && MeDistY < 32 && show_me;

assign rom_address_me = MeDistX + MeDistY*24;

logic [3:0] palette_red_me, palette_green_me, palette_blue_me;

Me_Sprite_rom Me_Sprite_rom (
	.clock   (negedge_vga_clk),
	.address (rom_address_me),
	.q       (rom_q_me)
);

Me_Sprite_palette Me_Sprite_palette (
	.index (rom_q_me),
	.red   (palette_red_me),
	.green (palette_green_me),
	.blue  (palette_blue_me)
);

endmodule
