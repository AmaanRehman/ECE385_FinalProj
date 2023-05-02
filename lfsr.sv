module LFSR(
    input Clk, Reset,
    input [8:0] seed, 
    input seed_in,
    output [8:0] outp,
    output seed_out
); 


logic [8:0] out;
logic [8:0] in; 
logic input0; 
always_comb 
    begin 
        if(seed_in)
            in[8:0] = seed[8:0]; 
        else    
            begin 
                in[0] = input0; 
                in[1] = out[0];
                in[2] = out[1];
                in[3] = out[2];                 
                in[4] = out[3];                
                in[5] = out[4];                
                in[6] = out[5];               
                in[7] = out[6];                
                in[8] = out[7];                 
            end
    end

bit_register bit_register0(
    .Clk(Clk), .Reset(Reset), .D(in[0]), .Q(out[0])
);
bit_register bit_register1(
    .Clk(Clk), .Reset(Reset), .D(in[1]), .Q(out[1])
);
bit_register bit_register2(
    .Clk(Clk), .Reset(Reset), .D(in[2]), .Q(out[2])
);
bit_register bit_register3(
    .Clk(Clk), .Reset(Reset), .D(in[3]), .Q(out[3])
);
bit_register bit_register4(
    .Clk(Clk), .Reset(Reset), .D(in[4]), .Q(out[4])
);
bit_register bit_register5(
    .Clk(Clk), .Reset(Reset), .D(in[5]), .Q(out[5])
);
bit_register bit_register6(
    .Clk(Clk), .Reset(Reset), .D(in[6]), .Q(out[6])
);
bit_register bit_register7(
    .Clk(Clk), .Reset(Reset), .D(in[7]), .Q(out[7])
);
bit_register bit_register8(
    .Clk(Clk), .Reset(Reset), .D(in[8]), .Q(out[8])
);

logic [3:0] clockcounter; 

// counts from 0 to 15 
always_ff @(posedge Clk or posedge Reset) 
    begin 
        if (Reset)
            clockcounter <= 4'h0; 
        else
            clockcounter <= clockcounter + 1; 
    end 

always_comb
    begin
        outp[8:0] = out[8:0];
        // if counter is >11, it is time to enable the next LFSR; since there 50mhZ>> 60hz, it will be certain that this will always generate platforms in time 
        if(clockcounter >= 4'd11)
            seed_out = 1; 
        else 
            seed_out = 0; 
        // make sure the seed always be produced will keep producing. 
        if(outp[8:0] == 9'b111111111)
            input0 = (out[3] ^ out[8]);
        else
            input0 = ~(out[3] ^ out[8]); 
    end 

endmodule 


module bit_register(
    input Clk, Reset, 
    input D, 
    output Q 
); 
always_ff @(posedge Clk)
    begin 
        Q <= D;
    end 

endmodule 