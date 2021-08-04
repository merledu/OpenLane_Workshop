

# MACRO PLACEMENT IN OPENLANE FLOW

## Table of Contents

1. [Adding a Design](#adding-a-design)
2. [Preparing a Design](#preparing-a-design)
3. [Synthesis](#synthesis)
4. [Floorplan](#floorplanning)
    * [Macro Placement](#macro-placement)
    * [IO Placement and Decap Cell Insertion](#io-placement-and-decap-cell-insertion)
5. [Power Distribution Network](#power-distribution-network)
6. [Placement](#placement)
7. [Clock Tree Synthesis](#clock-tree-synthesis-cts) 
8. [Routing](#routing)
9. [GDSII Formation and Checkers](#gdsii-formation-and-checkers)


## Adding a Design

```bash
./flow.tcl -design manual_macro_placement_test -init_design_config
```
This will create the following directory structure
```bash 
designs/manual_macro_placement_test
├── config.tcl
├── src

```
In the above configuration file (config.tcl), You should add the avariable according to your design's requirement. Varaible list can be found [here](https://openlane-docs.readthedocs.io/en/rtd-develop/configuration/README.html) and in src folder you have to place verilog files here. Create a folder named "macros" ,places gds and lef file of macro to hardened it.The directory structure will be look like this.
```bash 
designs/manual_macro_placement_test
├── config.tcl
├── src
    ├── design.v
├── macros
    ├── gds
    ├── lef

```
## Preparing a Design

```bash
./flow.tcl -interactive
```
This command run design in an interactive mode. You can find a version of openlane here too


```bash
package require openlane
```
To access the all required package of openlane
```bash
prep  -design picorv32a -tag run1
```
Prep is used to make file structure for our design and merges the technology LEF and cell LEF information for auto place and route flow

After preparing the design,This will create the following directory structure


```bash
designs/picorv32a
├── config.tcl
├── src
|   ├── picorv32a.v
├── macros
    ├── gds
    ├── lef
├── runs
│   ├── run1
│   │   ├── config.tcl
│   │   ├── logs
│   │   │   ├── cts
│   │   │   ├── cvc
│   │   │   ├── floorplan
│   │   │   ├── klayout
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   ├── reports
│   │   │   ├── cts
│   │   │   ├── cvc
│   │   │   ├── floorplan
│   │   │   ├── klayout
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   ├── results
│   │   │   ├── cts
│   │   │   ├── cvc
│   │   │   ├── floorplan
│   │   │   ├── klayout
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   └── tmp
│   │       ├── cts
│   │       ├── cvc
│   │       ├── floorplan
│   │       ├── klayout
│   │       ├── magic
│   │       ├── placement
│   │       ├── routing
│   │       └── synthesis

```
## Synthesis

Synthesis is a process by which the RTL or the logical design is converted into a circuit using the components of standard cell library (SCL). This results in a gate level netlist. The other factors responsible for specifying design intent includes the timing, clock definition, false path, power and area constraints for the synthesis step are defined in the configuration file.

RTL synthesis is defined in two steps:

1. Translation from RTL description into logic gates and wires
2. Optimization of Logic

```bash
run_synthesis
```
run_synthesis comprises of these two commands:
```bash
run_yosys
run_sta
```
The design is synthesized into a gate-level netlist using yosys and static timing analysis is performed on the resulting netlist using OpenSTA

This flow will also report out the design statistics.

Note:Ensure the WNS and TNS is an acceptable number, if not please adjust the clock period, change synthesis strategy or change the library to fix STA errors.
TNS and WNS must be zero or any positive number, negative is not acceptable.



## Floorplanning

Floorplanning is the art of any physical design to establishing the die and core size of your chip. IO ports locations, pre-place cells planning, power-distribution networks. A well and perfect floorplan leads to an ASIC design with higher performance and optimum area.
```bash
init_floorplan
```
Floorplanning can be challenging in that it deals with the placement of I/O pads and macros as well as power and ground structure.
### Macro Placement
```
add_macro_placement spm_inst_0 5.59000 168.23 N

add_macro_placement spm_inst_1 179.87 168.23 N

manual_macro_placement f
```
### IO Placement and Decap Cell Insertion
```
place_io
tap_decap_or
```
This command place random ioplacement in the design

## Power Distribution Network

To run PDN network use command
```
gen_pdn
write_powered_verilog
set_netlist $::env(lvs_result_file_tag).powered.v
 ```
If your design is a core then set these variable in configuration file 
```
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1
```

If your design is a macro ,that it doesn’t have a core ring. Also, prohibit the router from using metal 5 by setting the maximum routing layer to met4 (layer 5).Set these variable in configuration file 

```
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5
```



Three levels of Power Distribution:

**Rings** Carries VDD and VSS around the chip

**Stripes** Carries VDD and VSS from Rings across the chip

**Rails**
Connect VDD and VSS to the standard cell VDD and VSS.

Note: The pitch of the metal 1 power rails defines the height of the standard cells.
Metal 4 and 5 is used as a power straps.


 ## Placement

Once the floorplanning stage is satisfactory, we can now legally place the standard cells on the pre-defined site-rows. This will also ensure the standard-cell power will line up to the pdn network grids. 
```bash
run_placement
```
Placement is comprises on three steps
1. Global Placement
2. Optimizations
3. Detailed Placement.

### Global Placement
The Detailed Placement ensures  that  each  and every cell is placed properly inside the rows. There is no overlapping of cells.This step is perfomed through *Replace*.
### Optimizations
This step is performed through *Resize* ,to resize the cell to meet the target requirement e.g the timing ,power and area and
*OpenPhySyn* helps to minimize ASIC area and the interconnect wire length to improve the quality of placement
### Detailed Placement.
This step is perfomed through *OpenDP*, helps to complete the placement process which is already defined in above two stages (Global placement and Optimzation) and make sure to meet the all design requiremnts/constraints.

run_placement comprises of these two commands:
```bash
global_placement_or
detailed_placement_or
```
## Clock tree synthesis CTS
You can disable it by setting 
```
CLOCK_TREE_SYNTH to 0.
```

If you don’t want all the clock ports to be used in clock tree synthesis, then you can use set CLOCK_NET to specify those ports. Otherwise, CLOCK_NET will be defaulted to the value of CLOCK_PORT.



## Routing
Routing is comprises on three steps
1. Global Routing
2. Detailed Routing.

### Global routing 

Parameters we are looking in global routing are
1. Analyze congestion
2. Identifier available path
3. Minimize detouring

and Global Routing is done by *fastroute*
### Detailed routing

Detailed routing complete the track of determining short available path and connection of vias for net and it is done by *Tritonroute*

run_routing comprises of these two commands:
```bash
global_routing
detailed_routing
```
## GDSII Formation and Checkers

Final steps of the flow ends with GDSII file physical verification. GDSII file formed by running this command
```
run_magic
```

After formation of GDSII verification is required 
Three Design checkers are
1. Design Rule Check (DRC) 
2. Layout vs Schematic (LVS)
3. Antenna checks

**DRC**  DRC check involves two steps
1. Rule along with PDKs.
2. Rule violation used by magic.

```
run_magic_drc
```

**LVS**  LVS use NETGEN tool ,comprises two process 
1. Extraction 
2. comparison.

Extracted spice by magic vs  netlist(made after cts buffer) compare both file and check the simmalarity.
```
puts $::env(CURRENT_NETLIST)
run_magic_spice_export
run_lvs
```

**Antenna checks** Antenna check if any antenna violation occurs, it totally depend on length of the wire and the problem of etching.
```
run_antenna_check
```

You can also see the report of total run time of the design by using this command 
```
calc_total_runtime
```

 To produced a final summary reports in csv format to summaries all the reports by using this command 
```
generate_final_summary_report
```








