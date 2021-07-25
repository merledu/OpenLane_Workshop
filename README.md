![](images/logo2.png)
# OpenLANE Workshop
Welcome to OpenLANE Workshop github. Here you have access to some of the designs that are passed through the flow during the scope of this workshop. The files that come along with the designs are: 
1. Register Transfer Level (RTL).
2. The generated gate-level netlist.
3. Scripts to run on OpenLane.
4. Library Exchange Format (LEF) from < steps >.
5. Magic files for viewing
6. Design Exchange Format (DEF) from < steps >.
7. Final GDSII layout.

## OpenLANE_with_Google-Sky130-PDK

OpenLANE is an automated RTL2GDS flow that uses multiple open-source tools to perform the auto place and route of an ASIC design. Tools used in the OpenLANE flows are listed below:

![](images/OpenLane_tools.PNG "OpenLANE-tools")

**Overall RTL2GDS OpenLane Flow**

![](images/openlane.flow.1.png "OpenLANE-flow")

## Pre-Requisites
First you need to download script from [here](https://gist.github.com/zeeshanrafique23/11dbef9b83075b06b9ec90fddb8dc96f) and after pulling up the terminal, type

```bash
./openlane_setup.sh
```
and press Enter.

To ensure that all installation is upto date run this command in OpenLANE path
```
make test
```
## Directory Structure
The following directory structure

    ├── images
    ├── picorv32a
    |   ├── src
    |   ├── def
    |   ├── gds
    |   ├── scripts
    ├── reports
    ├── spm
    |   ├── src
    |   ├── def
    |   ├── gds
    |   ├── scripts
    ├──manual_macro_placement_test
    |   ├── src
    |   ├── def
    |   ├── gds
    |   ├── scripts
    ├── BRISC-V_single_cycle
    |   ├── src
    |   ├── def
    |   ├── gds
    |   ├── scripts
    

Design are:
1. picorv32a have a description of an Interactive flow
2. spm have a description of Non-interactive flow
3. manual_macro_placement_test have a description of macro placement
4. BRISC-V_single_cycle is a task for thi workshop