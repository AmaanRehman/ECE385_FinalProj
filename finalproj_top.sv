//-------------------------------------------------------------------------
//                                                                       --
//                                                                       --
//      For use with ECE 385 Lab 62                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module finalproj_top (

      ///////// Clocks /////////
      input     MAX10_CLK1_50, 

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

      ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5,

      ///////// SDRAM /////////
      output             DRAM_CLK,
      output             DRAM_CKE,
      output   [12: 0]   DRAM_ADDR,
      output   [ 1: 0]   DRAM_BA,
      inout    [15: 0]   DRAM_DQ,
      output             DRAM_LDQM,
      output             DRAM_UDQM,
      output             DRAM_CS_N,
      output             DRAM_WE_N,
      output             DRAM_CAS_N,
      output             DRAM_RAS_N,

      ///////// VGA /////////
      output             VGA_HS,
      output             VGA_VS,
      output   [ 3: 0]   VGA_R,
      output   [ 3: 0]   VGA_G,
      output   [ 3: 0]   VGA_B,


      ///////// ARDUINO /////////
      inout    [15: 0]   ARDUINO_IO,
      inout              ARDUINO_RESET_N 

);




	logic Reset_h, vssig, blank, sync, VGA_Clk;


//=======================================================
//  REG/WIRE declarations
//=======================================================
	logic SPI0_CS_N, SPI0_SCLK, SPI0_MISO, SPI0_MOSI, USB_GPX, USB_IRQ, USB_RST;
	logic [3:0] hex_num_4, hex_num_3, hex_num_1, hex_num_0; //4 bit input hex digits
	logic [1:0] signs;
	logic [1:0] hundreds;
	logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig, snakexsig2, snakeysig2, snake2Size;
	logic [7:0] Red, Blue, Green;
	logic [15:0] keycode;
	logic [19:0] randCord;
	logic endGame;

//=======================================================
//  Structural coding
//=======================================================
	assign ARDUINO_IO[10] = SPI0_CS_N;
	assign ARDUINO_IO[13] = SPI0_SCLK;
	assign ARDUINO_IO[11] = SPI0_MOSI;
	assign ARDUINO_IO[12] = 1'bZ;
	assign SPI0_MISO = ARDUINO_IO[12];
	
	assign ARDUINO_IO[9] = 1'bZ; 
	assign USB_IRQ = ARDUINO_IO[9];
		
	//Assignments specific to Circuits At Home UHS_20
	assign ARDUINO_RESET_N = USB_RST;
	assign ARDUINO_IO[7] = USB_RST;//USB reset 
	assign ARDUINO_IO[8] = 1'bZ; //this is GPX (set to input)
	assign USB_GPX = 1'b0;//GPX is not needed for standard USB host - set to 0 to prevent interrupt
	
	//Assign uSD CS to '1' to prevent uSD card from interfering with USB Host (if uSD card is plugged in)
	assign ARDUINO_IO[6] = 1'b1;
	
	//HEX drivers to convert numbers to HEX output
	HexDriver hex_driver4 (hex_num_4, HEX4[6:0]);
	assign HEX4[7] = 1'b1;
	
	HexDriver hex_driver3 (hex_num_3, HEX3[6:0]);
	assign HEX3[7] = 1'b1;
	
	HexDriver hex_driver1 (hex_num_1, HEX1[6:0]);
	assign HEX1[7] = 1'b1;
	
	HexDriver hex_driver0 (hex_num_0, HEX0[6:0]);
	assign HEX0[7] = 1'b1;
	
	//fill in the hundreds digit as well as the negative sign
	assign HEX5 = {1'b1, ~signs[1], 3'b111, ~hundreds[1], ~hundreds[1], 1'b1};
	assign HEX2 = {1'b1, ~signs[0], 3'b111, ~hundreds[0], ~hundreds[0], 1'b1};
	
	
	//Assign one button to reset
	assign {Reset_h}=~ (KEY[0]);

	//Our A/D converter is only 12 bit
	assign VGA_R = Red;
	assign VGA_B = Blue;
	assign VGA_G = Green;
	
	
	logic [8:0] x_velocity;
	logic [8:0] y_velocity;


	// Obstacle Flags

	logic OB1Flag, OB2Flag;
	logic [1:0] motionFlag1, motionFlag2;
	
	finalprojsoc u0 (
		.clk_clk                           (MAX10_CLK1_50),  //clk.clk
		.reset_reset_n                     (1'b1),           //reset.reset_n
		.altpll_0_locked_conduit_export    (),               //altpll_0_locked_conduit.export
		.altpll_0_phasedone_conduit_export (),               //altpll_0_phasedone_conduit.export
		.altpll_0_areset_conduit_export    (),               //altpll_0_areset_conduit.export
		.key_external_connection_export    (KEY),            //key_external_connection.export

		//SDRAM
		.sdram_clk_clk(DRAM_CLK),                            //clk_sdram.clk
		.sdram_wire_addr(DRAM_ADDR),                         //sdram_wire.addr
		.sdram_wire_ba(DRAM_BA),                             //.ba
		.sdram_wire_cas_n(DRAM_CAS_N),                       //.cas_n
		.sdram_wire_cke(DRAM_CKE),                           //.cke
		.sdram_wire_cs_n(DRAM_CS_N),                         //.cs_n
		.sdram_wire_dq(DRAM_DQ),                             //.dq
		.sdram_wire_dqm({DRAM_UDQM,DRAM_LDQM}),              //.dqm
		.sdram_wire_ras_n(DRAM_RAS_N),                       //.ras_n
		.sdram_wire_we_n(DRAM_WE_N),                         //.we_n

		//USB SPI	
		.spi0_SS_n(SPI0_CS_N),
		.spi0_MOSI(SPI0_MOSI),
		.spi0_MISO(SPI0_MISO),
		.spi0_SCLK(SPI0_SCLK),
		
		//USB GPIO
		.usb_rst_export(USB_RST),
		.usb_irq_export(USB_IRQ),
		.usb_gpx_export(USB_GPX),
		
		//LEDs and HEX
		.hex_digits_export({hex_num_4, hex_num_3, hex_num_1, hex_num_0}),
		.leds_export({hundreds, signs, /*LEDR*/}),
		.keycode_export(keycode),
		
		// Velocities for mouse
		.x_velocity_export(x_velocity),
		.y_velocity_export(y_velocity),
		
		// Random Coordinate
		
		.rand_cord_export(randCord)
		
	 );
	 
	 
	 


//instantiate a vga_controller, ball, and color_mapper here with the ports.

	vga_controller vga (
		.Clk(MAX10_CLK1_50),
		.Reset(Reset_h),
		.hs(VGA_HS),
		.vs(VGA_VS),
		.pixel_clk(VGA_Clk),
		.blank(blank),
		.sync(sync),
		.DrawX(drawxsig),
		.DrawY(drawysig)
	);
	
	snake s_main (
		.Reset(Reset_h | endGame),
		.frame_clk(VGA_VS),
		.keycode(keycode),
		.BallX(ballxsig),
		.BallY(ballysig),
		.BallS(ballsizesig),
		
		.x_velocity(x_velocity),
		.y_velocity(y_velocity),

		// Obstacle Flag Inputs
		
		.motionFlag(motionFlag1),
		.OB1Flag(OB1Flag)	,
		.LEDR()
	);
	
	snake2 s_enemy (
		.Reset(Reset_h | endGame),
		.frame_clk(VGA_VS),
		.keycode(keycode),
		
		.BallX(snakexsig2),
		.BallY(snakeysig2),
		.BallS(snake2Size),
		
		.x_velocity(x_velocity),
		.y_velocity(y_velocity),
		
		.motionFlag(motionFlag2),
		.OB2Flag(OB2Flag)
	);
	

	
//	color_mapper cm (
//		.BallX(ballxsig),
//		.BallY(ballysig),
//		.DrawX(drawxsig),
//		.DrawY(drawysig),
//		.Ball_size(ballsizesig),
//		.Red(Red),
//		.Green(Green),
//		.Blue(Blue)
//	);
	
	colorBGD_example (
		.Clk(MAX10_CLK1_50),
		.reset(Reset_h),
		.keycode(keycode),
		.vga_clk(VGA_Clk),
		.frame_clk(VGA_VS),
		.DrawX(drawxsig),
		.DrawY(drawysig),
		.blank(blank),
		.red(Red),
		.green(Green),
		.blue(Blue),
		
		.snakeX_pos(ballxsig),
		.snakeY_pos(ballysig),
		.snake2X_pos(snakexsig2),
		.snake2Y_pos(snakeysig2),
		.snake_size(ballsizesig),
		
		.endGame(endGame),
		
		.randCord(randCord),

		// Obstacle Flag Outputs
		
		
		.motionFlag1Out(motionFlag1),
		.motionFlag2Out(motionFlag2),
		.OB1Flag(OB1Flag),
		.OB2Flag(OB2Flag),
		.LED(LEDR)
		
	);

endmodule
