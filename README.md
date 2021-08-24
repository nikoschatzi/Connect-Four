<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h3 align="center">Connect4</h3>
</p>



<p align="center">
<img src="https://github.com/nikoschatzi/Score4/blob/main/img.png" align="center" />
</p>


<!-- ABOUT THE PROJECT -->
## About The Project
The repository includes the implementation of [Connect Four game](https://en.wikipedia.org/wiki/Connect_Four) in SystemVerilog. 

The game can be played in one FPGA using the code in [code_for_one_FPGA](https://github.com/nikoschatzi/Connect-Four/tree/main/code_for_one_FPGA) folder or in two FPGAs using the code in [code_for_two_FPGAs](https://github.com/nikoschatzi/Connect-Four/tree/main/code_for_two_FPGAs) folder. A function `automatic_player()` implementing a "smart" automatic opponent, with whom you can play against, is also included in the code.


This project was implemented in the VLSI course of the 8th semester of ECE DUTh which was supervised by the Associate Professor George Dimitrakopoulos.


<!-- GETTING STARTED -->
## Getting Started
To get started make sure you have installed all the prerequisites in your computer.

### Prerequisites
To compile this implementation of Connect Four game you will need ModelSim-Intel® FPGA Edition Software.   
In ModelSim execute the following commands:   
- `cd c:/workspace/Connect-Four` (project's directory)  
- `vlib work`  
- `vlog score4.sv score4_tb.sv`  
- `vsim -novopt score4_tb`  
- `run -all`  


To visualize the frames produced by the code use the online [VGA simulator](https://www.ericeastwood.com/lab/vga-simulator/).


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to be, learn, inspire, and create.  
Contribute following the above steps:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b new_branch_name`)
3. Commit your Changes (`git commit -m 'Add some extra functionality'`)
4. Push to the Branch (`git push origin new_branch_name`)
5. Open a Pull Request  
