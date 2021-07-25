# Design Description

This is a version of the singly cycle processor designed for synthesis. It is
identical to the single_cycle_base_513 version except for the "In-System
Programer" inputs and the current_PC outputs that force the whole design to be
synthesized. Additionally, the memory size has been reduced so that the design
will fit on an FPGA. No peripherals are included. No pipelining has been
implemented.

# OpenLane Flow
[here](#../picorv32a/README.md)

