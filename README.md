# usb_host_device_uvm_tb
📁 USB Host-Device UVM Verification Environment
This is a UVM-based testbench developed from scratch to verify an encrypted USB PHY DUT during my career break. The environment simulates USB host-to-device communication at the PHY level and validates packet-level transactions.

Key Features:

🧪 Host-driven stimulus covering token, data, handshake, and SOF packets

🔁 Bidirectional monitoring of TX and RX paths for both host and device

🧩 Protocol-aware scoreboard for transaction checking and packet matching

🔄 UVM-compliant components (driver, sequencer, monitor, scoreboard) for both host and device sides

🔒 Encrypted DUT (no RTL shared) — the focus is on testbench design and methodology

This project is intended for learning and hands-on practice with UVM and USB protocol fundamentals.
