class hs_pkt extends base_pkt;
        
	`uvm_object_utils_begin(hs_pkt)
	`uvm_field_int(pid, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name="hs_pkt");
		super.new(name);
		
	endfunction
	
	constraint hs_pkt_c {
		pid[3:0] inside {4'b0010, 4'b1010, 4'b1110, 4'b0110}; // ACK NAK STALL NYET
	}
	
endclass 
