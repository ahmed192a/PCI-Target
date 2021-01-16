`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:39:46 12/26/2020
// Design Name:   PCI_TARGET
// Module Name:   F:/study/3rd computer/CO2/Xilinx/project_target/Special_cycle.v
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

module Special_cycle;

	// Inputs
	reg reset;
	//reg clk;
	reg NFRAME;
	reg NIRED;
	reg [3:0] C_BE;

	// Outputs
	wire stop;
	wire NTRED;
	wire NDEVSEL;

	// Bidirs
	wire [31:0] Address_Data;


	// Clock instance
	clock clock (clk);
	assign Address_Data = Write_NRead? M_Data :32'bz;
	
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
        
		//special cycle command
		#40
		Write_NRead = 1;
		NFRAME = 0;
		M_Data = 32'h11111111;
		C_BE = 4'b0001;
		
		#40
		M_Data = 32'h00000000;
		C_BE = 4'b1111;
		NFRAME = 1;
		NIRED = 0;
		
		#200
		NIRED = 1;
		C_BE = 4'bzzzz;
		Write_NRead = 0;

	end
      
endmodule

