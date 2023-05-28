module n_bit_bcd_op_multiplier(
        clock,
        reset,
        a_in, 
        b_in, 
        start,  
        finish, 
        bcd,
        out
	);
	
parameter N = 8;

// Outputs
output [(((((N * 2) / 3) + 1) * 4) - 1) : 0] bcd; 
output [((N * 2) - 1) : 0] out;
output finish;

// Inputs
input start;
input clock;
input reset;
input [(N-1) : 0] a_in;
input [(N - 1) : 0] b_in;

// Reference registers
reg [(((((N * 2) / 3) + 1) * 4) - 1) : 0] bcd_reg = 0;
reg [((N * 2) - 1) : 0] out_reg;
reg finish_reg = 0;
reg [((N * 2) - 1) : 0] a_in_reg;
reg [((N * 2) - 1) : 0] b_in_reg;
reg [8:0] bits;

// Continuous assignment
assign bcd = bcd_reg; 
assign out = out_reg;
assign finish = finish_reg;

integer i, j;  

// Reset clock and inputs
always @(negedge reset)
begin
	out_reg = 0;
	a_in_reg = 0;
	b_in_reg = 0;
end

always @(posedge clock) begin
	if (!reset) begin
		case (start)
			1'b0: begin
				a_in_reg = a_in;
				b_in_reg = b_in;
				bits = N;
				finish_reg = 0;
				out_reg = 0;
				bcd_reg = 0; 
			end
			
			1'b1: begin
				if (b_in_reg[0] == 1) out_reg = (out_reg + a_in_reg);
				bits = (bits - 1);
				a_in_reg = a_in_reg << 1;
				b_in_reg = b_in_reg >> 1;				
			end
		endcase

		if(bits == 0) begin
			finish_reg = 1'b1;
			
			//----------------------------------------------------------------------
			// conversion of binary to bcd
			for(i = 0; i < (N * 2); i = (i + 1))
			begin
				if ((3 <= (((((N * 2) / 3) + 1) * 4) - 1)) && (bcd_reg[3:0] >= 5)) bcd_reg[3:0] = bcd_reg[3:0] + 3;		
				if ((7 <= (((((N * 2) / 3) + 1) * 4) - 1)) && (bcd_reg[7:4] >= 5)) bcd_reg[7:4] = bcd_reg[7:4] + 3;
				if ((11 <= (((((N * 2) / 3) + 1) * 4) - 1)) && (bcd_reg[11:8] >= 5)) bcd_reg[11:8] = bcd_reg[11:8] + 3;
				if ((15 <= (((((N * 2) / 3) + 1) * 4) - 1)) && (bcd_reg[15:12] >= 5)) bcd_reg[15:12] = bcd_reg[15:12] + 3;
				if ((19 <= (((((N * 2) / 3) + 1) * 4) - 1)) && (bcd_reg[19:16] >= 5)) bcd_reg[19:13] = bcd_reg[19:13] + 3;
				bcd_reg = {bcd_reg[(((N*2)/3)+1)*4-2:0],out_reg[(N*2)-1-i]};
			end
			//----------------------------------------------------------------------
		end
	end
end
endmodule

module N_Bit_BCD_op_Multiplier_Test_Bench;
   parameter n_bits = 5;
	
	// Inputs
    reg clock;
	reg start;
	reg [(n_bits - 1) : 0] a_in;
	reg [(n_bits - 1) : 0] b_in;
	reg reset;

	// Outputs
	wire [((n_bits * 2) - 1) : 0] out;
	wire finish;
	wire [(((((n_bits * 2) / 3) + 1) * 4) - 1) : 0] bcd;

	// Instantiate the Unit Under Test (UUT)
	n_bit_bcd_op_multiplier uut (
        .clock(clock),
        .reset(reset),
		.out(out), 
		.a_in(a_in), 
		.b_in(b_in),  
		.start(start),  
		.finish(finish),
		.bcd(bcd)
	);
   defparam uut.N = n_bits;

   
	initial
	begin
	forever 
		#50 clock= ~clock;
	end
	
	initial begin
		// Initialize Inputs
		a_in = 0;
		b_in = 0;
		clock = 0;
		start = 0;
		reset = 1;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 0;
        a_in = 'd09;
		b_in = 'd27;
		start = 0;
		#200
		start = 1;
		#(100 * n_bits)
		a_in = 'd2;
		b_in = 'd41;
		start = 0;
		#200
		start = 1;
		#(100 * n_bits)
		$finish;
	end
endmodule