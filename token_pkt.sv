
class token_pkt extends base_pkt;
	rand bit [6:0] addr;
	rand bit [3:0] ep_no;
		 bit [4:0] crc;
		 
	`uvm_object_utils_begin(token_pkt)
	`uvm_field_int(pid, UVM_ALL_ON)
	`uvm_field_int(addr, UVM_ALL_ON)
	`uvm_field_int(ep_no, UVM_ALL_ON)
	`uvm_field_int(crc, UVM_ALL_ON)
       
	`uvm_object_utils_end
	
	constraint token_pid_c {
		pid[3:0] inside {4'b0101, 4'b1001, 4'b0001, 4'b1101}; // SOF,IN, OUT, SETUP 
	}
	
	function new(string name="token_pkt");
		super.new(name);
	endfunction
	
	function void post_randomize();
		crc = calculateCRC5({addr,ep_no},5'd05);
	
	endfunction
	

endclass
