`ifndef USB_HOST_AGENT_SV
  `define USB_HOST_AGENT_SV
  class usb_host_agent extends uvm_agent;

    `uvm_component_utils(usb_host_agent)
    
    usb_hst_sequencer hst_seqr;
    usb_hst_driver    hst_drvr;
    usb_host_monitor   hst_mon;

    function new(string name ="", uvm_component parent);

      super.new(name,parent);
    endfunction



    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),$sformatf("Build Phase of %s",get_type_name()),UVM_HIGH);
      
      hst_seqr = usb_hst_sequencer::type_id::create("hst_seqr",this);
      hst_drvr = usb_hst_driver::type_id::create("hst_drvr",this);
      hst_mon = usb_host_monitor::type_id::create("hst_mon",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),$sformatf("Connect Phase of %s",get_type_name()),UVM_HIGH);

      hst_drvr.seq_item_port.connect(hst_seqr.seq_item_export);
	
	
    endfunction

  endclass
`endif
