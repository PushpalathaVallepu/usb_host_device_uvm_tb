`ifndef USB_DEV_XFER_ITEM_SV
`define USB_DEV_XFER_ITEM_SV

class usb_dev_xfer_item extends uvm_sequence_item;

  usb_xfer_type_e xfer_type;

  // Packet handles
  rand data_pkt data;
  rand hs_pkt   hs;

  rand data_pkt dataQ[$];
  rand hs_pkt   hsQ[$];


  // Serialized response bytes for TxValid/DataOut
  byte unsigned tx_bytes[$];

  // ----------------------------------------------------------
  // Factory registration
  // ----------------------------------------------------------
  `uvm_object_utils_begin(usb_dev_xfer_item)
    `uvm_field_enum        (usb_xfer_type_e, xfer_type, UVM_DEFAULT)
    `uvm_field_object      (data,    UVM_DEFAULT)
    `uvm_field_object      (hs,      UVM_DEFAULT)
    `uvm_field_queue_object(dataQ,  UVM_DEFAULT)
    `uvm_field_queue_object(hsQ,    UVM_DEFAULT)
  `uvm_object_utils_end

  // ----------------------------------------------------------
  function new(string name="usb_dev_xfer_item");
    super.new(name);
    data = data_pkt::type_id::create("data");
    hs   = hs_pkt  ::type_id::create("hs");
  endfunction

  function void pre_randomize();

    dataQ.delete();
    hsQ.delete();

    // Fill queues (default: 1 each)
    dataQ.push_back(data_pkt::type_id::create("dataQ[0]"));
    hsQ.push_back(hs_pkt::type_id::create("hsQ[0]"));
  endfunction

 // ----------------------------------------------------------
  virtual function string convert2string();
    string s;
    s = $sformatf("xfer_type=%s | ", xfer_type.name());
    if (dataQ.size() > 0)
      s = {s, $sformatf("data: pid=0x%0h len=%0d", data.pid, data.dataQ.size())};
    else
      s = {s, "data: N/A"};
    return s;
  endfunction

  // ----------------------------------------------------------
  // Pack bytes for the device response
  // ----------------------------------------------------------
  function void pack_for_dev();
    tx_bytes.delete();

    case (xfer_type)
      USB_IN: begin
        // Send a data packet: PID + payload + CRC
        pack_data(data);
      end

      USB_OUT,
      USB_SETUP: begin
        // Respond with handshake (e.g., ACK)
        tx_bytes.push_back(hs.pid); // usually ACK = 8'hD2
      end
    endcase
  `uvm_info(get_type_name(),$sformatf("%p",tx_bytes),UVM_LOW)
  endfunction

  // ----------------------------------------------------------
  // Helper: pack data_pkt to tx_bytes
  // ----------------------------------------------------------
  function void pack_data(data_pkt d);
    tx_bytes.push_back(d.pid);
    foreach (d.dataQ[i])
      tx_bytes.push_back(d.dataQ[i]);
    tx_bytes.push_back(d.crc[7:0]);
    tx_bytes.push_back(d.crc[15:8]);
  endfunction

endclass

`endif

