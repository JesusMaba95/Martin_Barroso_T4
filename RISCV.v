/******************************************************************
* Description
*	RISCV TOP MODULE
* Author:
*	Jesus Martin Barroso
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
wire [31:0]PC_w;
wire [31:0]Addr_w;

PC_Register
ProgramCounter
(
	//.clk(clk),
	.reset(reset),
	.enable(1'b1),
	//.NewPC(),
	.PCValue(PC_w)
);

Mux_2_1 Mux_IorD
(
	//.sel(),
	.In0(PC_w),
	//.In1(),
	.Output(Addr_w)

);

Instruction_Data_Memory
#(
	.INSTRUCTION_MEMORY_DEPTH(32),
	.DATA_MEMORY_DEPTH(32),
	.DATA_WIDTH(32)
)
IDMem
(
	.Address(Addr_w),
	//.WriteData,
	//.MemWrite,
	//.clk(clk)
	//.ReadData
);

endmodule