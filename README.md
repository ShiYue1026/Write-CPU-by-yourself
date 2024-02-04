# Write-CPU-by-yourself
**Introduction of this project:**
&ensp;&ensp;&ensp;&ensp;A pipelined CPU based on the MIPS architecture has been implemented with 52 basic instructions, 5 privileged instructions, and an exception handling mechanism. Additionally, a fast divider, AXI interface, and instruction cache have been added to enhance the performance of the CPU.
  
&ensp;&ensp;&ensp;&ensp;The project implementation process involves several steps. Firstly, the addition of 52 instructions is accomplished, including logical operation instructions, shift instructions, data movement instructions with HILO registers, arithmetic instructions, branch instructions, and memory access instructions. After completing this step, the total number of instructions is increased to 57, with the addition of CP0 registers, delay slots, and precise exceptions handling. The CP0 registers include BadVAddr, Count, Status, Cause, and EPC registers. Using the tools mentioned above, exception and interrupt handling are implemented. Then, the conversion from SRAM port to pseudo-SRAM port is achieved. Lastly, the implementation of AXI interface and instruction cache is completed.

&ensp;&ensp;&ensp;&ensp;The overall structure is as follows: The "mycpu_top" module invokes the "mmu" module for virtual address to physical address translation, invokes the "Cache" module for accessing the cache, and utilizes the provided conversion bridge, CPU, and AXI interface modules to implement the AXI interface. The "MIPS" module calls the "controller" module and "datapath" module, and utilizes the "inst(data)sram_like" module to implement the pseudo-SRAM interface.

**Architecture of MIPS SOC CPU:**
<div align=center>
<img src="https://github.com/ShiYue-HelloWorld/Write-CPU-by-yourself/blob/master/Architecture.png?raw=true"/>
</div>


**Instructions of the CPU:**
<div align=center>
<img src="https://github.com/ShiYue-HelloWorld/Write-CPU-by-yourself/blob/master/Instruction.png?raw=true"/>
</div>
