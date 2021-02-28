/******************************************************************
* Description
*	RISCV TOP MODULE
* Author:
*	Jesus MArtin Barroso
* email:
*	jesus.martin@iteso.mx
* Date:
*	20/02/2021
******************************************************************/

module RISCV
#(
	parameter MEMORY_DEPTH = 32,
	parameter PC_INCREMENT = 4,
	parameter DATA_WIDTH = 32
)
(
	input clk,
	input reset,
	output [7:0]gpio_port_in,
	output [7:0]gpio_port_out
);
wire[31:0]ReadData_w;
wire[31:0]Addres_w;
wire[31:0]WriteData_w;
wire Mem_Write_w;

CORE CORE_i
(
	.clk(clk),
	.reset(reset),
	.ReadData_i(ReadData_w),
	.Address_o(Addres_w),
	.WriteData_o(WriteData_w),
	.MemWrite_o(Mem_Write_w)
);
Instruction_Data_Memory ID_MEM
(
	.Address(Addres_w),
	.WriteData(WriteData_w),
	.MemWrite(Mem_Write_w),
	.clk(clk),
	.ReadData(ReadData_w)
);
endmodule