`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:28:23 12/19/2020 
// Design Name: 	 PCI BUS
// Module Name:    PCI_TARGET 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PCI_TARGET(
	 input reset,
	 input clk,
	 output reg stop,
    inout [31:0] Address_Data,
    input NFRAME,
    input NIRED,
    input [3:0] C_BE,
    output reg NTRED,
    output reg NDEVSEL
    );

/************************************************************
*						register decleration
**************************************************************/
	// mask the data with byte enable before write it in the memory
	reg [31:0] mask=32'bz;


	//parameter [31:0] target_addresses[0:4] = { 0, 1, 2 , 3, 4};
	parameter [31:0]target_addresses_0 = 0;
	parameter [31:0]target_addresses_1 = 1;
	parameter [31:0]target_addresses_2 = 2;
	parameter [31:0]target_addresses_3 = 3;
	parameter [31:0]target_addresses_4 = 4;
	
	// memories
	reg [31:0] IN_Memory[0:4];
	reg [31:0] buffer[0:4];
	
	reg [31:0]recieved_address; 
	reg [31:0] buffer_ptr = 5;
	reg buffer_flag = 0;
	
	reg [31:0]Data;
	
	reg [3:0]control;
	 
	reg Write_NRead = 0;

	// counter
	reg [11:0]counter = 0;
	reg counter_start ;
	
	// flag for DEVSEL
	reg  DEV_flag = 0;
	
	// assign the output data
	assign Address_Data = Write_NRead? Data:32'bz;
	 
	//stop flag
	reg stop_flag = 0;


	// counter block
	//	start the transition block
	always @(negedge clk)
	begin
			if(counter_start == 1)
			begin
				counter <= counter + 1;
				if((counter == 2) && (DEV_flag == 1))
				begin
					Write_NRead <= 1;
					NDEVSEL <= 0;
					NTRED <= 0;
				end
			end
			else
				counter <= 0;
	end
/************************************************************
*									Main code
**************************************************************/
	
	// check if the master select the target
	always @(posedge clk)
	begin
		if ((NFRAME == 0) && (DEV_flag == 0))
		begin   
			if ((Address_Data >= target_addresses_0) && (Address_Data <= target_addresses_4))
			begin
				recieved_address <= Address_Data;
				control <= C_BE;
				counter_start <= 1;
				DEV_flag <= 1;
			end
		end
	end

	// Write operations
	always @ (posedge clk)
	begin
		if (NTRED == 0 && NIRED == 0 && buffer_flag == 0)
		begin
			case(control) 
				4'b0111: //write
				begin
					mask = {{8{C_BE[3]}}, {8{C_BE[2]}}, {8{C_BE[1]}}, {8{C_BE[0]}}};
					IN_Memory [recieved_address] = Address_Data & mask; 
					recieved_address = recieved_address + 1;
					// Memory [address_C] <= (Memory [address_C] & ~mask) | (address & mask);
					
					if(recieved_address == target_addresses_4 && NFRAME == 0)
					begin
						if(buffer_ptr == 0)
						begin
							buffer_flag = 1;
							recieved_address = target_addresses_0;
						end
						else if(buffer_ptr == 5)
						begin
							//stop = 1;
							stop_flag = 1;
							counter_start = 0;
						end
					end
				end
			endcase
		end
	end
	
	
	//
	always @(negedge clk)
	begin
		if(stop_flag== 1)
		begin
			stop = 0;
			
			
		end
	end

	// read operations
	always @(negedge clk,negedge NTRED)
	begin
		if ((NTRED == 0) && (NIRED == 0))
		begin
			case(control) 
				4'b0110: // read
				begin
					Data = IN_Memory [recieved_address];
					recieved_address = recieved_address + 1;
				end
			endcase
		end
	 end




	// End the frame and the reset
	always @( NIRED, reset, clk)
	begin
		if((NFRAME == 1 && NIRED == 1) || (reset == 0) /*|| ((stop == 1) && (clk == 0))*/)
		begin
			NDEVSEL <= 1;
			NTRED <= 1;
			Write_NRead <= 0;
			Data <= {32{1'bz}};
			recieved_address <= {32{1'bz}};
			DEV_flag <= 0;
			control <= 4'bz;
			mask <= 32'bz;
			counter_start <= 0;
			//stop <= 0;
		end
	end
	

	// reset the memories to initial state
	genvar i;
	generate for (i = 0; i< 5;i=i+1)
		always @(negedge reset)
		begin
			IN_Memory[i] <=32'bz;
			buffer[i] <= 32'bz;
		end
	endgenerate
	
	genvar i;
	generate for (i = 0; i< 5;i=i+1)
		always @(negedge reset)
		begin
		if(NTRDY == 1)
			buffer[i] <= IN_Memory[i] ;
		end
	endgenerate

endmodule

