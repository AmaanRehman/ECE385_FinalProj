module Me_Sprite_rom (
	input logic clock,
	input logic [9:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:767] /* synthesis ram_init_file = "./Me_Sprite/Me_Sprite.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
