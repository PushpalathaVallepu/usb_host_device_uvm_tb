`ifndef USB_TEST_SV
  `define USB_TEST_SV

  class usb_test extends uvm_test;

    `uvm_component_utils(usb_test)

    usb_env env; 
    usb_virtual_sequence virt_seq;

    function new(string name = "usb_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      env = usb_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    
    // Print component topology
    uvm_top.print_topology();

    // Print port connections (custom)
    show_connectivity(uvm_top, 0);
  endfunction
    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      #100ns;

      virt_seq = usb_virtual_sequence::type_id::create("virt_seq");
      virt_seq.start(env.vseqr); // Run on virtual sequencer
      #1000ns;

      phase.drop_objection(this);
    endtask
    
    function automatic void show_connectivity(uvm_component c = null, int depth = 0);
    uvm_component children[$];
    string type_name = "Component";
    string name = c.get_full_name();
    if (c == null)
      return;
    $display("%s+ %s: %s", {depth{" "}}, type_name, name);
    c.get_children(children);
    foreach (children[i]) begin
      uvm_port_component_base port_component_base;
      if ($cast(port_component_base, children[i])) begin
        uvm_port_list connected_to_list;
        uvm_port_list provided_to_list;
        port_component_base.get_connected_to(connected_to_list);
        port_component_base.get_provided_to(provided_to_list);
        if ((connected_to_list.size() > 0) || (provided_to_list.size() > 0)) begin
          $display("%s Port: %s", {depth+2{" "}}, children[i].get_full_name());
        end
        foreach (connected_to_list[j])
          $display("%s Connected to Port: %s", {(depth+4){" "}}, connected_to_list[j].get_full_name());
        foreach (provided_to_list[j])
          $display("%s Provided to Port: %s", {(depth+4){" "}}, provided_to_list[j].get_full_name());
      end else begin
        show_connectivity(children[i], depth+2);
      end
    end
  endfunction
  endclass

`endif

