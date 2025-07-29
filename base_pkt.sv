// Base class
import uvm_pkg::*;
`include "uvm_macros.svh"

class base_pkt extends uvm_sequence_item;
	rand bit [7:0] pid;
	
	`uvm_object_utils(base_pkt)
	
	function new(string name="base_pkt");
		super.new(name);
	endfunction
	
	// Problem 1:
	// PID
	constraint pid_invert { 
		pid[7:4] == ~pid[3:0];
	}
	
	// Problem 2:
	constraint pid_range {
		pid[3:0] != 4'd0; 
	}

	// CRC5
	function bit [4:0] calculateCRC5(bit [10:0] data,bit [4:0] poly);
		int  i;
		bit [4:0]crc5 = 5'b11111;
		for(i=10;i>=0;i=i-1)
		begin
			
			if((crc5[4])!=(data[i]))
				crc5 = (crc5<<1)^(poly);
			else
				crc5<<=1;
			
		end
		crc5^=5'b11111;
		return crc5;
	endfunction


	
		// CRC16
	
         function bit [15:0] calculateCRC16(bit [7:0] data,bit [15:0] poly);
		int  i;
		bit [15:0]crc16 = 16'hffff;
		for(i=7;i>=0;i=i-1)
		begin
			
			if((crc16[15])!=(data[i]))
				crc16 = (crc16<<1)^(poly);
			else
				crc16<<=1;
			
		end
		crc16^=16'hffff;
		return crc16;
	endfunction

endclass
