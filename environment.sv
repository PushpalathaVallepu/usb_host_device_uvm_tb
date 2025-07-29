
`ifndef USB_ENV_SV
  `define USB_ENV_SV 
  class usb_env extends uvm_env;
    `uvm_component_utils(usb_env)

    usb_host_agent hst_agent;
    usb_dev_agent  dev_agent;
    virtual_sequencer  vseqr;
    scoreboard scb;

    function new(string name = "", uvm_component parent);
      super.new(name,parent);
    endfunction
 	
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      hst_agent = usb_host_agent::type_id::create("hst_agent",this);
      dev_agent = usb_dev_agent::type_id::create("dev_agent",this);
      vseqr     = virtual_sequencer::type_id::create("vseqr", this);
      scb       = scoreboard #(usb_host_xfer_item)::type_id::create("scb",this);
    endfunction

    function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vseqr.host_seqr = hst_agent.hst_seqr;
    vseqr.dev_seqr  = dev_agent.dev_seqr;
    hst_agent.hst_mon.mon_ap.connect(scb.mon_host);
    dev_agent.dev_mon.pkt_ap.connect(scb.mon_dev);

  endfunction
  endclass
`endif

