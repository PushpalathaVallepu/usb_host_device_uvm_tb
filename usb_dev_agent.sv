`ifndef USB_DEV_AGENT_SV
  `define USB_DEV_AGENT_SV
  class usb_dev_agent extends uvm_agent;

    `uvm_component_utils(usb_dev_agent)
    
    usb_dev_sequencer dev_seqr;
    usb_dev_driver    dev_drvr;
    usb_dev_monitor   dev_mon;

    function new(string name ="", uvm_component parent);

      super.new(name,parent);
    endfunction



    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      `uvm_info(get_type_name(),$sformatf("Build Phase of %s",get_type_name()),UVM_HIGH);
      
      dev_seqr = usb_dev_sequencer::type_id::create("dev_seqr",this);
      dev_drvr = usb_dev_driver::type_id::create("dev_drvr",this);
      dev_mon = usb_dev_monitor::type_id::create("dev_mon",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      `uvm_info(get_type_name(),$sformatf("Connect Phase of %s",get_type_name()),UVM_HIGH);

      dev_drvr.seq_item_port.connect(dev_seqr.seq_item_export);
      dev_mon.pkt_ap.connect(dev_seqr.port_from_mon);	
	
    endfunction

  endclass
`endif

