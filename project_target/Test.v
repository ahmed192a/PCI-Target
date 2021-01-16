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

module Test0;

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
	
	initial begin
		// Initialize Inputs
		NFRAME = 1;
		NIRED = 1;
		C_BE = 0;
		Write_NRead = 0;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		reset = 1;
		
		#40
		reset = 0;
		
		#40
		reset = 1;
		
		// Write command
		#80
		Write_NRead = 1;
		NFRAME = 0;
		C_BE = 4'b0111;
		M_Data = 4294967284;

		#40
		NIRED = 0;
		M_Data = 32'hffffaaaa;
		C_BE = 4'b0011; 

		#80
		M_Data = 32'hfff11111;
		C_BE = 4'b1010;
		
		#40
		M_Data = 32'h12345678;
		C_BE = 4'b0110;

		#40
		M_Data = 32'h87654321;
		C_BE = 4'b1001;

		#40
		NFRAME = 1;
		C_BE = 4'b1011;
		M_Data = 32'h11111111;

		#40
		Write_NRead = 0;
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		
		 // NEXT COMMAND Read Command
		#40
		Write_NRead = 1;
		NFRAME = 0;
		C_BE = 4'b1110;
		M_Data = 4294967284;
		
		#40
		C_BE = 4'b1010;
		NIRED = 0;
		Write_NRead = 0;
		
		#80
		C_BE = 4'b0100;
		#40
		C_BE = 4'b0110;
		NIRED = 1;
		#40
		NIRED = 0;
		#40
		C_BE = 4'b0101;
		NFRAME = 1;
		#40
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;

		

		
		// Write command
		#80
		Write_NRead = 1;
		NFRAME = 0;
		C_BE = 4'b0111;
		M_Data = 4294967284;

		#40
		NIRED = 0;
		M_Data = 32'hffffaaaa;
		C_BE = 4'b0011; 

		#80
		M_Data = 32'hfff11111;
		C_BE = 4'b1010;
		
		#40
		M_Data = 32'h12345678;
		C_BE = 4'b0110;

		#40
		M_Data = 32'h87654321;
		C_BE = 4'b1001;

		#40
		NFRAME = 1;
		C_BE = 4'b1011;
		M_Data = 32'h11111111;


		#40
		Write_NRead = 0;
		NIRED = 1;
		C_BE = 4'bzzzz;
		M_Data = 32'bz;
		


	end
      
endmodule

