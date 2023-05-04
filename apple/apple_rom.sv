module apple_rom (
	input logic clock,
	input logic [7:0] address,
	output logic [2:0] q
);

logic [2:0] memory [0:255] /* synthesis ram_init_file = "./apple/apple.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
