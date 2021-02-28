/******************************************************************
* Description
*	This is an 32-bit arithetic logic unit that can execute the next set of operations:
*		add
*		sub
*		or
*		and
*		nor
* This ALU is written by using behavioral description.
* Version:
*	1.0
* Author:
*	Dr. José Luis Pizano Escalante
* email:
*	luispizano@iteso.mx
* Date:
*	01/03/2014
******************************************************************/

module ALU 
(
	input [2:0] ALUOperation,
	input [31:0] A,
	input [31:0] B,
	output reg Zero,
	output reg [31:0]ALUResult
);
localparam AND  = 3'b000;
localparam OR   = 3'b001;
localparam ADD  = 3'b010;
localparam SUB  = 3'b011;
//localparam SLT = 3'b100;
localparam SLLI = 3'b100;
localparam NOR  = 3'b101;

   
   always @ (A or B or ALUOperation)
     begin
		case (ALUOperation)
		  AND: // and
			ALUResult = A & B;
	     OR: // or
			ALUResult = A | B;
		  ADD: // add
			ALUResult = A + B;
 		  SUB: // sub
			ALUResult = A - B;
		  NOR: // nor
			ALUResult = ~(A | B);
		  SLLI:
			ALUResult = A << B;
//		  SLT:
//			ALUResult = A < B ? 1'b1 : 1'b0;
		default:
			ALUResult= 0;
		endcase // case(control)
		Zero = (ALUResult==0) ? 1'b1 : 1'b0;
     end // always @ (A or B or control)
endmodule // ALU