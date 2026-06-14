module Alu (
	input wire[2:0] operation,
	input wire[15:0] in1, in2,
	output wire[15:0] result,
	output wire zero_flag,
	output wire overflow_flag
);

wire[15:0] alu_result;

assign alu_result = (operation == 3'b000) ? (in1 + in2) :
          	    (operation == 3'b001) ? (in1 - in2) :
          	    (operation == 3'b010) ? (in1 & in2) :
          	    (operation == 3'b011) ? (in1 | in2) :
          	    (operation == 3'b100) ? (~in2)   :
          	    (operation == 3'b101) ? (in1)       :
          	    (operation == 3'b110) ? (in2)       :
		     16'h0000;
assign result = alu_result;
assign zero_flag = ( alu_result == 16'h0000);

  // Overflow in ADD: signs same, result sign different
  // Overflow in SUB: signs different, result sign different from first operand
  wire add_overflow = (in1[15] == in2[15]) && (in1[15] != alu_result[15]) && (operation == 3'b000);
  wire sub_overflow = (in1[15] != in2[15]) && (in1[15] != alu_result[15]) && (operation == 3'b001);
  
  assign overflow_flag = add_overflow | sub_overflow;

endmodule