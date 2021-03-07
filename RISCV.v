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
	parameter DATA_WIDTH = 32
)
(
	input clk,
	input reset,
	input  [7:0]gpio_port_in,
	output [7:0]gpio_port_out
);
wire[(DATA_WIDTH-1):0]ReadData_w;
wire[(DATA_WIDTH-1):0]Addres_w;
wire[(DATA_WIDTH-1):0]WriteData_w;
wire Mem_Write_w;

wire[(DATA_WIDTH-1):0]Ctrl2ID_ReadData_w;
wire[(DATA_WIDTH-1):0]Ctrl2ID_Addres_w;
wire[(DATA_WIDTH-1):0]Ctrl2ID_WriteData_w;
wire[(DATA_WIDTH-1):0]GPIO_WriteData_w;
wire GPIO_enable;
wire Ctrl2ID_Mem_Write_w;

CORE CORE_i
(
	.clk(clk),
	.reset(reset),
	.ReadData_i(ReadData_w),
	.Address_o(Addres_w),
	.WriteData_o(WriteData_w),
	.MemWrite_o(Mem_Write_w)
);
MemControl X
(
   //CORE
	.Address(Addres_w),
	.WriteData(WriteData_w),
	.MemWrite(Mem_Write_w),
	.ReadData(ReadData_w),
	//ID MEM Interface
	.ID_Address(Ctrl2ID_Addres_w),
	.ID_WriteData(Ctrl2ID_WriteData_w),
	.ID_MemWrite(Ctrl2ID_Mem_Write_w),
	.ID_ReadData(Ctrl2ID_ReadData_w),
	//GPIOS
	.GPIO_WriteData(GPIO_WriteData_w),
	.GPIO_MemWrite(GPIO_enable),
	.GPIO_ReadData({24'b0000_0000_0000_0000_0000_0000,gpio_port_in})
);

Register GPIO
(
  .clk(clk),
  .reset(reset),
  .enable(GPIO_enable),
  .DataInput(GPIO_WriteData_w),
  .DataOutput(gpio_port_out)
  
);

Instruction_Data_Memory ID_MEM
(
	.Address(Ctrl2ID_Addres_w),
	.WriteData(Ctrl2ID_WriteData_w),
	.MemWrite(Ctrl2ID_Mem_Write_w),
	.clk(clk),
	.ReadData(Ctrl2ID_ReadData_w)
);
endmodule