module EasterEgg_rom (
	input logic clock,
	input logic [6:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:99] /* synthesis ram_init_file = "./EasterEgg/EasterEgg.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
