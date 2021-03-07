module MemControl
#(
	parameter DATA_WIDTH=32
)
(


	//CORE Interface
	input [(DATA_WIDTH-1):0] Address,
	input [(DATA_WIDTH-1):0] WriteData,
	input MemWrite,
	//input clk,
	output [(DATA_WIDTH-1):0] ReadData,
	
	//ID MEM Interface
	output [(DATA_WIDTH-1):0]ID_Address,
	output [(DATA_WIDTH-1):0]ID_WriteData,
	output ID_MemWrite,
	input [(DATA_WIDTH-1):0]ID_ReadData,
	
	//GPIO Interface
	//output [(DATA_WIDTH-1):0]GPIO_Address,
	output [(DATA_WIDTH-1):0]GPIO_WriteData,
	output GPIO_MemWrite,
	input [(DATA_WIDTH-1):0]GPIO_ReadData
	
);
localparam GPIO_IN_ADDR   = 32'h10010028;
localparam GPIO_OUT_ADDR  = 32'h10010024;

reg GPIO_or_IdMem;

always@(Address) begin
  GPIO_or_IdMem = ( (Address == GPIO_IN_ADDR) | (Address == GPIO_OUT_ADDR) ) ? 1'b1 : 1'b0;
end

assign  ID_Address     = (!GPIO_or_IdMem) ? Address     : 32'h0000_0000;
assign  ID_WriteData   = /*(!GPIO_or_IdMem) ?*/ WriteData   /*: 32'h0000_0000*/;
assign  ID_MemWrite    = (!GPIO_or_IdMem) ? MemWrite    : 1'b0;
assign  ReadData       = (!GPIO_or_IdMem) ? ID_ReadData : GPIO_ReadData;

assign  GPIO_WriteData = WriteData;
assign  GPIO_MemWrite  = (GPIO_or_IdMem)  ? MemWrite    : 1'b0;



endmodule 