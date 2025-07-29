class data_pkt extends base_pkt;
	rand byte unsigned dataQ[$];
		 bit [15:0] crc, crc_t;
		 
	`uvm_object_utils_begin(data_pkt)
	`uvm_field_int(pid, UVM_ALL_ON)
	`uvm_field_queue_int(dataQ, UVM_ALL_ON)
	`uvm_field_int(crc, UVM_ALL_ON)
	`uvm_field_int(crc_t, UVM_ALL_ON)

	`uvm_object_utils_end

	function new(string name="data_pkt");
		super.new(name);
	endfunction
	
	constraint data_pid_c {
		pid[3:0] inside {4'b0011, 4'b1011, 4'b0111, 4'b1111}; // DATA0 DATA1 DATA2 MDATA
	}
	
	constraint dataQ_c{
		 dataQ.size() inside {8,16,32,64};
		
	}
	
	function void post_randomize();
		foreach(dataQ[i]) begin
			crc_t = calculateCRC16(dataQ[i],16'h8005);
			crc = crc_t;
		

		end 
	endfunction 
	
endclass
