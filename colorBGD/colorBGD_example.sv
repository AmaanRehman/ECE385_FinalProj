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

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen

assign rom_address = ((DrawX * 320) / 640) + (((DrawY * 240) / 480) * 320);

// ORIGINAL ADDRESS THAT SETS SNAKE HEAD TO FULL SCREEN:


int DistX, DistY, Size;
assign DistX = DrawX - snakeX_pos;
assign DistY = DrawY - snakeY_pos;

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

ISDU isdu1 (.Clk(Clk),
				.Reset(reset),
				.keycode(keycode),
				.LD_MENU(LD_MENU),
				.LD_Map1(LD_Map1),
				.Pause_En());
				
// Create Venom:

logic [9:0] Venom1X, Venom1Y, Venom1S;
logic [9:0] Venom2X, Venom2Y, Venom2S;
logic [9:0] Venom3X, Venom3Y, Venom3S;
logic ballMovement;

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
 
// Venoms For Snake 1

logic key_Clk;

keyboard_posedge_detector (.keyboard_input(keycode),
									.posedge_detected(key_Clk));

logic [1:0] venomCount;
//assign LED[1:0] = venomCount;
assign LED[2] = venom1_movement;
assign LED[3] = venom2_movement;
assign LED[4] = venom3_movement;

venomCountMachine VenomCS1 (.Clk(Clk),
									 .Reset(reset),
									 .keycode(keycode),
									 .expectedKeycode(8'd44),
									 .venomCount(venomCount));

venom venomS1_1(.Reset(reset),
					 .frame_clk(frame_clk),
					 .vga_clk(vga_clk),
					 .keycode(keycode),
					 .expectedKeycode(8'd44),
					 .snakeX(snakeX_pos),
					 .snakeY(snakeY_pos),
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
					 .expectedKeycode(8'd44),
					 .snakeX(snakeX_pos),
					 .snakeY(snakeY_pos),
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
					 .expectedKeycode(8'd44),
					 .snakeX(snakeX_pos),
					 .snakeY(snakeY_pos),
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
assign  rom_address_W = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); // Working
assign  rom_address_S = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
assign  rom_address_A = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
assign  rom_address_D = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);

// Checking if snake should be drawn
always_comb
begin: snake1_on_proc

	if ((DrawX >= snakeX_pos - 12) &&
		(DrawX <= snakeX_pos + 11)  &&
		(DrawY >= snakeY_pos - 12)  &&
		(DrawY <= snakeY_pos + 11)  &&
		(redPaletteOut != 4'hF) 	 && 
      (bluePaletteOut != 4'hF) 	 &&
		(greenPaletteOut != 4'h0)) begin
		
		snake_on = 1'b1;
			
	 end
	 
	 else snake_on = 1'b0;

end

// Setting up Snake 2:

// Addresses for Sprite
assign  rom_address_W1 = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); // Working
assign  rom_address_S1 = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); 
assign  rom_address_A1 = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24); 
assign  rom_address_D1 = ((DrawX-snake2X_pos+snake_size)) + ((DrawY-snake2Y_pos+snake_size) * 24);

// Checking if snake should be drawn
always_comb
begin: snake2_on_proc

	if ((DrawX >= snake2X_pos - 12) &&
		(DrawX <= snake2X_pos + 11)  &&
		(DrawY >= snake2Y_pos - 12)  &&
		(DrawY <= snake2Y_pos + 11)  &&
		(redPaletteOut1 != 4'hF) 	  &&
		(bluePaletteOut1 != 4'hF) 	  &&
		(greenPaletteOut1 != 4'h0)) begin
				
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

always_comb
begin: Snake1Health

	if ((DrawX >= 10'd13   - 8) &&
		 (DrawX <=  10'd13  + 8)  &&
		 (DrawY >=  10'd470 - 8)  &&
		 (DrawY <=  10'd470 + 8)) begin
		
			heart1on = 1'b1;
			heart2on = 1'b0;
			heart3on = 1'b0;
		
	end
	
	else if ((DrawX >= 10'd28   - 8) &&
				(DrawX <=  10'd28  + 8)  &&
				(DrawY >=  10'd470 - 8)  &&
				(DrawY <=  10'd470 + 8))  begin
		
			heart1on = 1'b0;
			heart2on = 1'b1;
			heart3on = 1'b0;
		
	end
		
	else if ((DrawX >=  10'd43  - 8) &&
				(DrawX <=  10'd43  + 8)  &&
				(DrawY >=  10'd470 - 8)  &&
				(DrawY <=  10'd470 + 8)) begin
				
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
								.Reset(reset),
								.collision((venom1_on && snake2_on)||(venom2_on && snake2_on)||(venom3_on && snake2_on)),
								.healthCount(snake2HealthCount),
								.gameEnd(snake1Won));
								
assign LED[1:0] = snake2HealthCount;
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


//always_comb
//begin
//
//	if (snake_on == 1'b1 && Wall_on == 1'b1) begin
//
//		OB1Flag = 1'b1;
//		LED[2] = 1'b1;
//	
//	end
//
//	else begin
//	
//		OB1Flag = 1'b0;
//		LED[2] = 1'b0;
//		
//	end
//end
 
 
 /// Logic for Random BLock GENERATION


//logic [19:0] randCordOut [15];
//logic [3:0] i,j;
//
////logic [9:0] randX = randCordOut;
// 
//always_ff @ (posedge vga_clk) begin
//
//	if ((keycode[15:8] == 8'h15) || (keycode[7:0] == 8'h15)) begin
//	
//			LED[8] = 1'b1;
//		
//		for (j = 4'd0; j < 4'd15; j++) begin
//			
//			randCordOut[i] <= 20'd0;
//		
//		end
//	
//	end
//	
//	else LED[8] = 1'b0;
//
//	if ((keycode[15:8] == 8'h28) || (keycode[7:0] == 8'h28)) begin
//	
//		LED[6] = 1'b1;
//		
//		for (i = 4'd0; i < 4'd15; i++) begin
//			
//			if (randCordOut[i] == 20'd0) begin
//			
////				LED[4] = 1'b0;
//				randCordOut[i] <= randCord;
//			end
//			
////			else LED[4] = 1'b1;
//			
//		end 	
//		
//		
//	end
//	
//	else LED[6] = 1'b0;
//	
//end


//// COLORING LOGIC

	 
always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

//   if (DrawX == 0 && DrawY == 0) OB1Flag <= 1'b0;

	if (blank) begin

		if (LD_MENU) begin
			red <= palette_red_MM;
			green <= palette_green_MM;
			blue <= palette_blue_MM;
		end
		
		else if (LD_Map1) begin

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
		
			/// Random Block Generation

			//************** C - Code Method*************************//

//			if (((DrawX >= randCordOut[0][19:10] - 20) &&
//				(DrawX <= randCordOut[0][19:10] + 20)  &&
//				(DrawY >= randCordOut[0][9:0] - 12)  &&
//				(DrawY <= randCordOut[0][9:0] + 12))) begin
//				
//				if(randCordOut[0] != 20'b0) begin
//				
//				
//					red <= 4'h0;
//					green <= 4'h0;
//					blue <= 4'h0;
//					
//					LED[4] = 1'b1;
//					
//				end
//				
//				else LED[4] = 1'b0;
//		
//			end
			
			// ****************LSFR Method**************************//
			// if (((DrawX >= readyX4 - 20) &&
			// 	(DrawX <= readyX4 + 20)  &&
			// 	(DrawY >= readyX15 - 12)  &&
			// 	(DrawY <= readyX15 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
			// 	if (((DrawX >= readyX8 - 20) &&
			// 	(DrawX <= readyX8 + 20)  &&
			// 	(DrawY >= readyX9 - 12)  &&
			// 	(DrawY <= readyX9 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX11 - 20) &&
			// 	(DrawX <= readyX11 + 20)  &&
			// 	(DrawY >= readyX2 - 12)  &&
			// 	(DrawY <= readyX2 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX4 - 20) &&
			// 	(DrawX <= readyX4 + 20)  &&
			// 	(DrawY >= readyX1 - 12)  &&
			// 	(DrawY <= readyX1 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX3 - 20) &&
			// 	(DrawX <= readyX3 + 20)  &&
			// 	(DrawY >= readyX2 - 12)  &&
			// 	(DrawY <= readyX2 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX10 - 20) &&
			// 	(DrawX <= readyX10 + 20)  &&
			// 	(DrawY >= readyX8 - 12)  &&
			// 	(DrawY <= readyX8 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
			// 	if (((DrawX >= readyX12 - 20) &&
			// 	(DrawX <= readyX12 + 20)  &&
			// 	(DrawY >= readyX15 - 12)  &&
			// 	(DrawY <= readyX15 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX2 - 20) &&
			// 	(DrawX <= readyX2 + 20)  &&
			// 	(DrawY >= readyX8 - 12)  &&
			// 	(DrawY <= readyX8 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
				
			// 	if (((DrawX >= readyX7 - 20) &&
			// 	(DrawX <= readyX7 + 20)  &&
			// 	(DrawY >= readyX1 - 12)  &&
			// 	(DrawY <= readyX1 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
			// 	if (((DrawX >= readyX8 - 20) &&
			// 	(DrawX <= readyX8 + 20)  &&
			// 	(DrawY >= readyX3 - 12)  &&
			// 	(DrawY <= readyX3 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
			// 	if (((DrawX >= readyX4 - 20) &&
			// 	(DrawX <= readyX5 + 20)  &&
			// 	(DrawY >= readyX5 - 12)  &&
			// 	(DrawY <= readyX5 + 12))) begin
							
			// 		red <= 4'h0;
			// 		green <= 4'h0;
			// 		blue <= 4'h0;
					
			// 		LED[4] = 1'b1;
					
			// 	end
				
			// 	else LED[4] = 1'b0;
				
			////////////////////////////

			if ((paletteOb1_red != 4'hF) &&
					(paletteOb1_green != 4'h0) && 
					(paletteOb1_blue != 4'hF)) begin
						
						red <= paletteOb1_red;
						green <= paletteOb1_green;
						blue <= paletteOb1_blue;

					end

//			else begin
//				
//				LED[7] = 1'b0;
//				
//			end
			// Bullet Drawing
			
			if (venom1_on) begin
			
				red <= 4'h0;
				green <= 4'h0;
				blue <= 4'h0;
			
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
			
			
		end

	end // Blanking if END
	
end

// SETTING HIT OBSTACLE FLAG FOR SNAKE 1

 logic [9:0] snake1X, snake1Y;

 assign snake1X = DrawX - snakeX_pos;
 assign snake1Y = DrawY - snakeY_pos;

 always_ff @(posedge vga_clk) begin

 	if (DrawX == 0 && DrawY == 0) OB1Flag <= 1'b0;

 	if (paletteOb1_red != 4'hF && paletteOb1_green != 4'h0 && paletteOb1_blue != 4'hF) begin
		
 		case (motionFlagOut)

 			2'b00 : begin		// W

 						if (snake1X <= 13 && snake1Y == 10'b1111110100) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b01 :begin		// A

 						if ($signed(snake1X == 10'b1111110100) && snake1Y <= 12) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b10 :begin		// S

 						if (snake1X <= 13  && snake1Y == 13) begin
 							OB1Flag <= 1'b1;
 						end
 					end
 			2'b11 :begin		// D

 						if (snake1X == 13 && snake1Y <= 13) begin
 							OB1Flag <= 1'b1;
 						end
 					end

 			default: OB1Flag <= 1'b0;

 		endcase

 	end

 end
 
 
// SETTING HIT OBSTACLE FLAG FOR SNAKE 2

 logic [9:0] snake2X, snake2Y;

 assign snake2X = DrawX - snake2X_pos;
 assign snake2Y = DrawY - snake2Y_pos;

 always_ff @(posedge vga_clk) begin

 	if (DrawX == 0 && DrawY == 0) OB2Flag <= 1'b0;

 	if (paletteOb1_red != 4'hF && paletteOb1_green != 4'h0 && paletteOb1_blue != 4'hF) begin
		
 		case (motionFlagOut1)

 			2'b00 : begin		// W

 						if (snake2X <= 13 && snake2Y == 10'b1111110100) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b01 :begin		// A

 						if ($signed(snake2X == 10'b1111110100) && snake2Y <= 12) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b10 :begin		// S

 						if (snake2X <= 13  && snake2Y == 13) begin
 							OB2Flag <= 1'b1;
 						end
 					end
 			2'b11 :begin		// D

 						if (snake2X == 13 && snake2Y <= 13) begin
 							OB2Flag <= 1'b1;
 						end
 					end

 			default: OB2Flag <= 1'b0;

 		endcase

 	end

 end

// *********************************LSFR*****************************//

//logic [8:0] seedgen;   
//counter seedgenx(
//	.Reset(0), 
//	.enable(1), 
//    .Clk(Clk), 
//
//    .out(seedgen[8:0])
//);
//
//logic seed_en, seed_en1, seed_en2, seed_en3, seed_en4, seed_en5, seed_en6, seed_en7, seed_en8, seed_en9, seed_en10, seed_en11, seed_en12, seed_en13, seed_en14, seed_en15;
//logic res_LFSR; 
//LFSR LFSR(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX[8:0]), .seed(seedgen[8:0]), .seed_in(seed_en15), .seed_out(seed_en)
//);
//LFSR LFSR1(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX1[8:0]), .seed(testX[8:0]), .seed_in(seed_en), .seed_out(seed_en1)
//);
//LFSR LFSR2(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX2[8:0]), .seed(testX1[8:0]), .seed_in(seed_en1), .seed_out(seed_en2)
//);
//LFSR LFSR3(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX3[8:0]), .seed(testX2[8:0]), .seed_in(seed_en2), .seed_out(seed_en3)
//);
//LFSR LFSR4(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX4[8:0]), .seed(testX3[8:0]), .seed_in(seed_en3), .seed_out(seed_en4)
//);
//LFSR LFSR5(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX5[8:0]), .seed(testX4[8:0]), .seed_in(seed_en4), .seed_out(seed_en5)
//);
//LFSR LFSR6(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX6[8:0]), .seed(testX5[8:0]), .seed_in(seed_en5), .seed_out(seed_en6)
//);
//LFSR LFSR7(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX7[8:0]), .seed(testX6[8:0]), .seed_in(seed_en6), .seed_out(seed_en7)
//);
//LFSR LFSR8(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX8[8:0]), .seed(testX7[8:0]), .seed_in(seed_en7), .seed_out(seed_en8)
//);
//LFSR LFSR9(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX9[8:0]), .seed(testX8[8:0]), .seed_in(seed_en8), .seed_out(seed_en9)
//);
//LFSR LFSR10(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX10[8:0]), .seed(testX9[8:0]), .seed_in(seed_en9), .seed_out(seed_en10)
//);
//LFSR LFSR11(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX11[8:0]), .seed(testX10[8:0]), .seed_in(seed_en10), .seed_out(seed_en11)
//);
//LFSR LFSR12(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX12[8:0]), .seed(testX11[8:0]), .seed_in(seed_en11), .seed_out(seed_en12)
//);
//LFSR LFSR13(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX13[8:0]), .seed(testX12[8:0]), .seed_in(seed_en12), .seed_out(seed_en13)
//);
//LFSR LFSR14(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX14[8:0]), .seed(testX13[8:0]), .seed_in(seed_en13), .seed_out(seed_en14)
//);
//LFSR LFSR15(
//    .Clk(Clk), .Reset(res_LFSR), .outp(testX15[8:0]), .seed(testX14[8:0]), .seed_in(seed_en14), .seed_out(seed_en15)
//);
//
//
//logic [8:0] testX, testX1, testX2, testX3, testX4, testX5, testX6, testX7,  testX8, testX9, testX10, testX11, testX12, testX13, testX14, testX15;
//logic [8:0] readyX, readyX1, readyX2, readyX3, readyX4, readyX5, readyX6, readyX7,  readyX8, readyX9, readyX10, readyX11, readyX12, readyX13, readyX14, readyX15;
//
//always_ff@(posedge frame_clk)
//begin 
//	 
//		if ((keycode[15:8] == 8'h28) || (keycode[7:0] == 8'h28)) begin
//        if(testX > 9'h0 && testX <= 9'd100)
//            readyX <= testX + 9'd100;
//        else 
//            readyX <= testX;
//        if(testX1 > 9'h0 && testX1 <= 9'd100)
//            readyX1 <= testX1 + 9'd100;
//        else 
//            readyX1 <= testX1;        
//        if(testX2 > 9'h0 && testX2 <= 9'd100)
//            readyX2 <= testX2 + 9'd100;
//        else 
//            readyX2 <= testX2;  
//        if(testX3 > 9'h0 && testX3 <= 9'd100)
//            readyX3 <= testX3 + 9'd100;
//        else 
//            readyX3 <= testX3;
//        if(testX4 > 9'h0 && testX4 <= 9'd100)
//            readyX4 <= testX4 + 9'd100;
//        else 
//            readyX4 <= testX4;
//        if(testX5 > 9'h0 && testX5 <= 9'd100)
//            readyX5 <= testX5 + 9'd100;
//        else 
//            readyX5 <= testX5;
//        if(testX6 > 9'h0 && testX6 <= 9'd100)
//            readyX6 <= testX6 + 9'd100;
//        else 
//            readyX6 <= testX6;
//        if(testX7 > 9'h0 && testX7 <= 9'd100)
//            readyX7 <= testX7 + 9'd100;
//        else 
//            readyX7 <= testX7;
//        if(testX8 > 9'h0 && testX8 <= 9'd100)
//            readyX8 <= testX8 + 9'd100;  
//        else 
//            readyX8 <= testX8;
//        if(testX9 > 9'h0 && testX9 <= 9'd100)
//            readyX9 <= testX9 + 9'd100;
//        else 
//            readyX9 <= testX9;
//        if(testX10 > 9'h0 && testX10 <= 9'd100)
//            readyX10 <= testX10 + 9'd100;
//        else 
//            readyX10 <= testX10;
//        if(testX11 > 9'h0 && testX11 <= 9'd100)
//            readyX11 <= testX11 + 9'd100;
//        else 
//            readyX11 <= testX11;
//        if(testX12 > 9'h0 && testX12 <= 9'd100)
//            readyX12 <= testX12 + 9'd100;
//        else 
//            readyX12 <= testX12;
//        if(testX13 > 9'h0 && testX13 <= 9'd100)
//            readyX13 <= testX13 + 9'd100;
//        else 
//            readyX13 <= testX13;
//        if(testX14 > 9'h0 && testX14 <= 9'd100)
//            readyX14 <= testX14 + 9'd100;  
//        else 
//            readyX14 <= testX14;
//        if(testX15 > 9'h0 && testX15 <= 9'd100)
//            readyX15 <= testX15 + 9'd100;
//        else 
//            readyX15 <= testX15;
//    end
//	 
//end
//
//// Random Coordinate generation for obstacles
//
//logic [9:0] randX, randY;
//logic enable, clkout;

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


													

endmodule
