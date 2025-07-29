// Start of Frame
class sof_pkt extends base_pkt;
// pid, CRC5, CRC16 are automatically part of this class

	rand bit [10:0] frame_no;
		bit [4:0] crc;
		
	`uvm_object_utils_begin(sof_pkt)
	`uvm_field_int(pid, UVM_ALL_ON)
	`uvm_field_int(frame_no, UVM_ALL_ON)
	`uvm_field_int(crc, UVM_ALL_ON)
	`uvm_object_utils_end 
	
	function new(string name="sof_pkt");
		super.new(name);
	endfunction
	
	constraint sof_pid {
			pid[3:0] == 4'b0101; 
	}
	
	function void post_randomize();
		crc = calculateCRC5(frame_no,5'b00101); // Poly = 00101
	
	
	endfunction 

endclass
