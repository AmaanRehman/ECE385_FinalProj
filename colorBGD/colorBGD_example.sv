module colorBGD_example (
	input logic Clk,
	input logic [7:0] keycode,
	
	input logic vga_clk,
	input logic [9:0] DrawX, DrawY,
	input logic blank,
	input logic [9:0] snakeX_pos,
	input logic [9:0] snakeY_pos,
	input logic [9:0] snake_size,
	
	output logic [3:0] red, green, blue
);

logic [18:0] rom_address;
logic [3:0] rom_q;

logic [18:0] rom_address_W, rom_address_S, rom_address_A, rom_address_D;
logic [3:0] rom_q_W, rom_q_S, rom_q_A, rom_q_D;

logic [3:0] palette_red, palette_green, palette_blue;
logic [3:0] snake_palette_red, snake_palette_green, snake_palette_blue;

logic negedge_vga_clk;

// read from ROM on negedge, set pixel on posedge
assign negedge_vga_clk = ~vga_clk;

// address into the rom = (x*xDim)/640 + ((y*yDim)/480) * xDim
// this will stretch out the sprite across the entire screen

assign rom_address = ((DrawX * 640) / 640) + (((DrawY * 480) / 480) * 640);



// ORIGINAL ADDRESS THAT SETS SNAKE HEAD TO FULL SCREEN:

assign rom_address_W = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); // Working
assign rom_address_S = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
assign rom_address_A = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 
assign rom_address_D = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24); 


int DistX, DistY, Size;
	 assign DistX = DrawX - snakeX_pos;
    assign DistY = DrawY - snakeY_pos;

    assign Size = snake_size;

logic snake_on;
	 
always_comb
begin:Snake_on_proc
    if ((DrawX >= snakeX_pos - 12) &&
		  (DrawX <= snakeX_pos + 12) &&
		  (DrawY >= snakeY_pos - 12) &&
       (DrawY <= snakeY_pos + 12)) begin
		 
//		  case(keycode)
//		 
//			8'h1A	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// W
//			8'h04	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// A
//			8'h16	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// S
//			8'h07	:	rom_address = ((DrawX-snakeX_pos+snake_size)) + ((DrawY-snakeY_pos+snake_size) * 24);	// D
//			
//			
//			default:	rom_address = ((DrawX * 640) / 640) + (((DrawY * 480) / 480) * 640);
//			
//		 endcase
		  
        snake_on = 1'b1;
	
		end
		
    else 
        snake_on = 1'b0;
 end 
	 
always_ff @ (posedge vga_clk) begin
	red <= 4'h0;
	green <= 4'h0;
	blue <= 4'h0;

	if (blank) begin
		
		if (snake_on == 1'b1) begin
		
			if ((redPaletteOut == 4'hF) &&
					(bluePaletteOut == 4'hF) && 
					(greenPaletteOut == 4'h0)) begin
				
				red <= palette_red;
				green <= palette_green;
				blue <= palette_blue;
				
			end
			
			else begin
		
				red <= redPaletteOut;
				green <= greenPaletteOut;
				blue <= bluePaletteOut;
				
			end
		
		end
		
		else begin
		
			red <= palette_red;
			green <= palette_green;
			blue <= palette_blue;
			
		end
	end
end


// Movement state maching

logic [1:0] motionFlag, motionFlagOut;
logic Load;

move_stateMachine m1(
					.Clk(Clk),
					.keycode(keycode),
					.motionFlag(motionFlag),
					.Load(Load)
			
				);
				
// Register to keep track of motion of snake
				
reg_unit #(2) snakeMotion(
					.Clk(Clk),
					.Reset(),
					.Din(motionFlag),
					.Load(Load),
					.Data_Out(motionFlagOut));

// Multiplexer to Choose Snake Palette

logic [3:0] w_palette_red;
logic [3:0] a_palette_red;
logic [3:0] s_palette_red;
logic [3:0] d_palette_red;

logic [3:0] w_palette_green;
logic [3:0] a_palette_green;
logic [3:0] s_palette_green;
logic [3:0] d_palette_green;

logic [3:0] w_palette_blue;
logic [3:0] a_palette_blue;
logic [3:0] s_palette_blue;
logic [3:0] d_palette_blue;

logic [3:0] redPaletteOut;
logic [3:0] greenPaletteOut;
logic [3:0] bluePaletteOut;



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


// Snake Data

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

endmodule
