# OpenLANE NOn-Interactive Flow of design spm


## Adding a Design

```bash
./flow.tcl -design spm -init_design_config
```
This will create the following directory structure
```bash 
designs/spm
├── config.tcl
├── src

```
In the above configuration file (config.tcl), You should add the avariable according to your design's requirement. Varaible list can be found [here](https://openlane-docs.readthedocs.io/en/rtd-develop/configuration/README.html) and in src folder you have to place verilog files here.The directory structure will be look like this.
```bash 
designs/spm
├── config.tcl
├── src
    ├── spm

```
## Run a Design from RTL to GDSII

```bash
./flow.tcl -design spm -tag run1
```
This command run the whole design by using its own script named as ***flow.tcl***

The description of RTL to GDSII design run flow can be found [here](https://github.com/merledu/OpenLane_Workshop/blob/main/picorv32a/README.md)