`timescale 1ns / 1ns
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:49:31 12/19/2020
// Design Name:   PCI_TARGET
// Module Name:   F:/study/3rd computer/CO2/Xilinx/project_target/Test.v
// Project Name:  project_target
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PCI_TARGET
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Test1;

	// Inputs
	reg NFRAME;
	reg NIRED;
	reg [3:0] C_BE;
	reg reset;

	// Outputs
	wire NTRED;
	wire NDEVSEL;
	wire stop;

	// Bidirs
	wire [31:0] Address_Data;
	
	//local control
	reg Write_NRead;
	reg [31:0]M_Data;

	// Instantiate the Unit Under Test (UUT)
	PCI_TARGET uut (
		.reset(reset),
		.clk(clk),
		.stop(stop),
		.Address_Data(Address_Data), 
		.NFRAME(NFRAME), 
		.NIRED(NIRED), 
		.C_BE(C_BE), 
		.NTRED(NTRED), 
		.NDEVSEL(NDEVSEL)
	);
	// Clock instance
	clock clock (clk);
	assign Address_Data = Write_NRead? M_Data :32'bz;
	integer i;
	initial begin 
		NFRAME = 1;
		NIRED = 1;
		C_BE = 0;
		Write_NRead = 0;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		reset = 1;
		#40
		// Wait 100 ns for global reset to finish
		//#400;

		reset = 0;
		
		#40
		reset = 1;
		
		// Write command
		#80
		Write_NRead = 1;
		NFRAME = 0;
		C_BE = 4'b0111;
		M_Data = 32'd4294967284;
	
		//1
		#40						
		NIRED = 0;
		M_Data = 32'hffffaaaa;
		C_BE = 4'b0011; 

		//2
		#80
		M_Data = 32'hfff11111;
		C_BE = 4'b1010;
	
		
		for(i = 0; i< 30; i=i+1)
		begin
		if(i == 15)
		begin
		#40;
		end
			#40
			M_Data = M_Data + 20;
			C_BE = C_BE + 2;
		end

	
		#40
		NFRAME = 1;
		C_BE = 4'b1011;
		M_Data = 32'h11111111;

		//the end
		#40
		Write_NRead = 0;
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		
		
	

// read 2 byte
		#120
		NFRAME = 0;
		M_Data = 32'd4294967284;
		C_BE = 4'b0110;
		Write_NRead = 1;
		
		#40
		Write_NRead = 0;
		NIRED = 0;
		C_BE = C_BE + 2;
		
		#80
		C_BE = C_BE + 2;
		NFRAME = 1;
		#40
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;

// read 3 to 12
		#160
		NFRAME = 0;
		M_Data = 32'd4294967284;
		C_BE = 4'b0110;
		Write_NRead = 1;
		
		#40
		Write_NRead = 0;
		NIRED = 0;
		C_BE = C_BE + 2;
		
		#80
		C_BE = C_BE + 2;
		#40
		C_BE = 4'b0001;
		#40
		C_BE = 4'b0010;
		#40
		C_BE = 4'b0011;
		#40
		C_BE = 4'b0111;
		#40
		C_BE = 4'b0110;
		#40
		C_BE = 4'b0101;
		NFRAME = 1;
		#40
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
//read multiple
		#160
		NFRAME = 0;
		M_Data = 32'd4294967284;
		C_BE = 4'b1100;
		Write_NRead = 1;
		
		#40
		Write_NRead = 0;
		NIRED = 0;
		C_BE = C_BE + 2;
		
		#80
		C_BE = C_BE + 2;
	for(i=0;i<13;i=i+1) begin
		#40
		C_BE = C_BE + 2;
	end
		
		#40
		C_BE = 4'b0101;
		NFRAME = 1;
		#40
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		
	
	end
      
endmodule
