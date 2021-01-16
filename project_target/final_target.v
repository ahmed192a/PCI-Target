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
module PCI_TAR(
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
	integer i;
/************************************************
*						register decleration
*************************************************/
	// mask the data with byte enable before write it in the memory
	reg [31:0] mask = 32'bz;

	// memories
	reg [31:0] IN_Memory[0:15];
	reg [31:0] IO_Memory [0:15];
	reg [31:0] BAR_Memory[0:5];
	
	// extra memory to handle write overflow
	reg [31:0] buffer[0:15]; 
	
	// register to save the address in the address phase and act as index of the memory
	reg [63:0]recieved_address = 64'bz;

	// register to save the address in the dual address phase and act as index of the memory
	//reg [31:0]recieved_address_dual_low = 64'bz; 
	//reg [31:0]recieved_address_dual_high = 64'bz;

	// flag for the buffer to trace the process of transfer data from memory to buffer 
	// and to check if the buffer is full or empty
	reg [3:0] buffer_ptr = 4'b0;
	
	// register to get the data from the memory and place it on the address_data
	reg [31:0]Data=32'bz;
	
	// register to save the C/BE in the address phase
	reg [3:0]control;
	
	// flag  to control the address_data bus  (1 for write, 0 for read or idle state)
	reg Write_NRead;

	// flag for devselect to assert DEVSEL & TRDY after IRDY asserted by one cycle
	reg [3:0]Dev_flag;

	//stop flag to trace the process of stop the current transaction
	reg [4:0]stop_flag;
	
	// save the message in the special cycle
	reg [31:0]message;

	// save the configuration data in the configuration write
	reg [31:0]confg_data;
	
	// flag to check if the message saved only one time
	reg m_done;

	// flag to check if the configuration data saved only one time
	reg [4:0]confg_flag_write;

	// flag to check if the configuration data send only one time
	reg [4:0]confg_flag_read;

	// Check if the master is ready or not in the positive edge of the CLK
	reg mast_rdy;

	// check if it's dual cycle to read the address in two cycles
	reg dual_flag;
	

	
	
	


/*********************************
					Constant
**********************************/
	localparam SPECIAL_CYCLE			= 4'b0001;
	localparam IO_READ 					= 4'b0010;
	localparam IO_WRITE					= 4'b0011;
	localparam READ 						= 4'b0110;
	localparam WRITE						= 4'b0111;
	localparam CONFIGURATION_READ 	= 4'b1010;
	localparam CONFIGURATION_WRITE 	= 4'b1011;
	localparam READ_MULTIBLE 			= 4'b1100;
	localparam DUAL_ADDRESS_CYCLE 	= 4'b1101;
	localparam READ_LINE 				= 4'b1110;




	localparam [63:0]target_addresses_0 			= 64'd4294967284;
	localparam [63:0]target_addresses_last 		= 64'd4294967299;

	localparam [31:0]target_IO_addresses_0 		= 0;
	localparam [31:0]target_IO_addresses_last 	= 15;

	localparam [31:0]bar_addresses_0 				= 16;
	localparam [31:0]bar_addresses_last 			= 21;


//2pow(32) - 1 = 4294967295
//(2pow(32) - 1) - 11 = 4294967284 (start)
//(2pow(32) - 1) + 4 = 4294967299 (end)
	
/************************************************
				Wire decleration & assigning
*************************************************/
	// assign the output data
	assign Address_Data = Write_NRead? Data:32'bz;
	
	// set 1 after the irdy by one cycle
	wire dev_trdy = Dev_flag && control != SPECIAL_CYCLE;
	
	// end the transaction or no tansaction 
	wire end_trans = (NFRAME == 1 && NIRED == 1);
	
	// set 1 at any read operation 
	wire read_op = (NFRAME == 0) && (control== READ || control == READ_LINE || control == READ_MULTIBLE || control == IO_READ || control == CONFIGURATION_READ);
	
	// set 1 if the address is in the target addresses range
	wire add_valid = (NFRAME == 0) && (Address_Data >= target_addresses_0) && (Address_Data <= target_addresses_last) && (NDEVSEL == 1) ;
	
	// set 1 if the address is in the target input output addresses range
	wire add_IO_valid = (Address_Data >= target_IO_addresses_0) && (Address_Data <= target_IO_addresses_last) && (NFRAME == 0) && (NDEVSEL == 1);
	
	// set 1 if the address is in the bar addresses range
	wire add_bar_valid = (NFRAME == 0) && (Address_Data >= bar_addresses_0) && (Address_Data <= bar_addresses_last) ;
	
	// set to  in case special cycle
	wire special_cycle_start = (NFRAME == 0 && control == 4'b0001 && NIRED == 1);
	
	// set to 1 when both master and target are ready
	wire master_target_ready = (~NTRED && ~mast_rdy); //&& NIRED == 0);
	
	// set to 1 in case the memory is full and the buffer is empty
	wire mem_full_buffer_empty = (NFRAME == 0) && (buffer_ptr == 0 && recieved_address == target_addresses_last + 1);
	
	// set to 1 when both the memory and the buffer are full
	wire mem_full_buffer_full = (NFRAME == 0) && (buffer_ptr == 4 && recieved_address == target_addresses_last);
	
	// trigger the read block
	wire read_trigger = (clk | NTRED); 
	
	
	wire add_phase = ~NFRAME & NDEVSEL;
	//
	wire [31:0]index = recieved_address - target_addresses_0;

always @(posedge clk or negedge clk or negedge reset)
begin
	if(~reset)
	begin
		NDEVSEL <= 1;
		NTRED <= 1;
		Write_NRead <= 0;
		Data <= {32{1'bz}};
		recieved_address = {32{1'bz}};
		//control <= 4'bz;
		mask = 32'bz;
		stop <= 1;
		stop_flag <= 0;
		buffer_ptr <= 0;
		Dev_flag <= 0;
		dual_flag = 0;
	end
	else 
	begin
		if(clk)
		begin
			control <= C_BE;
			if(add_phase)
			begin
				control <= C_BE;
			end
		end
		if(!clk)
		begin
			
		end
		
	end
	
	
		
end



	



endmodule 