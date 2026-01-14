# -----------------------------------------------
# Project
# Implementation of a Small GPU Using Verilog
# -----------------------------------------------

## I. Program Documentation


### Introduction
Graphics Processing Units (GPUs) are computing devices designed to efficiently process large amounts of data in parallel. They are well suited for tasks that require many operations to be performed at the same time. Although GPUs were first developed for graphics rendering, they are now widely used in areas such as machine learning, scientific computation, and big data processing.

Compared to Central Processing Units (CPUs), which mainly execute instructions sequentially, GPUs are optimized for parallel execution. This is made possible by their architecture, which contains many small processing cores that operate concurrently. As a result, GPUs can process large datasets and perform complex calculations more efficiently than CPUs for parallel workloads.

This report examines the architecture of GPUs and simulates their main components using Verilog. Key modules such as the Arithmetic Logic Unit (ALU), decoder, fetch unit, scheduler, and compute core are modeled to illustrate how GPUs operate and support parallel computation.
### 1.1 GPU Architecture
The design of a GPU focuses on supporting large-scale parallel processing and high computational bandwidth. This is accomplished through the integration of many functional components that work together to execute operations in an efficient manner.

<img width="1106" height="1496" alt="image" src="https://github.com/user-attachments/assets/3d4e978b-55fa-499b-8422-cb2f6b6bd006" />


- **Device Control Register**: This unit is responsible for controlling and configuring the operational state of the GPU. It enables the host system to manage GPU execution and monitor its status.

- **Dispatcher**: The dispatcher distributes tasks among the Compute Cores. Its role is to balance workloads across the architecture in order to improve performance and reduce idle core time.

- **Cache**: The cache functions as a fast local storage layer within the GPU architecture, temporarily holding commonly used instructions and data. Its primary purpose is to shorten data retrieval time by reducing dependence on slower main memory.

- **Program Memory Controller and Data Memory Controller**: These units are responsible for regulating instruction and data movement between the compute resources and memory subsystems. By managing memory transactions and synchronizing read/write operations, they help maintain steady data throughput and prevent performance degradation caused by memory access delays.

#### 1.2 Global Memory
#### 1.3 Core Compute

đặt hình ảnh vào đây và giải thích ở dưới nhé


* **Instruction Decoder:**
  The instruction decoder is responsible for analyzing the fetched instruction stream and identifying the required execution parameters. It extracts key fields—including operation codes, operand source identifiers, destination registers, and immediate operands—and forwards this decoded information to the relevant computational units for processing.

* **Arithmetic Logic Unit (ALU):**
  The Arithmetic Logic Unit serves as the primary execution element for arithmetic and logical operations, including but not limited to addition, subtraction, multiplication, and comparison functions. To support parallel execution, each compute unit within the GPU architecture incorporates multiple ALUs, enabling simultaneous processing of multiple operations.


#### 1.4 Key Features of GPU Architecture

The GPU architecture is characterized by several key features that enable high computational performance:

1. **Massive Parallelism:**
   GPUs are composed of a large number of lightweight processing cores that execute thousands of threads concurrently. This design supports data-parallel workloads and follows a SIMD/SIMT execution model, allowing the same instruction to be applied to multiple data elements simultaneously.

2. **Scalability:**
   The modular organization of GPU architecture allows performance to scale by increasing the number of Compute Cores and execution units. This scalability makes GPUs adaptable to a wide range of performance requirements and application domains.

3. **Energy Efficiency:**
   GPUs are designed to maximize computational throughput per watt of power consumed. By executing many parallel operations with simple cores and efficient scheduling, GPUs achieve higher energy efficiency compared to general-purpose processors for parallel workloads.

4. **Thread Management and Scheduling:**
   Thread execution is efficiently controlled through hardware-based scheduling mechanisms. The Scheduler and Dispatcher coordinate thread allocation and context switching, enabling effective workload distribution and hiding memory latency by switching between active threads.

5. **Memory Hierarchy and Bandwidth:**
   GPUs employ a hierarchical memory system, including registers, cache, and global memory, to optimize data access. High memory bandwidth and fast on-chip storage reduce access latency and support sustained throughput for memory-intensive applications.
### 3. Arithmetic Logic Unit (ALU)

The Arithmetic Logic Unit (ALU) represents a fundamental execution block within processor architectures, including Graphics Processing Units. Its primary function is to carry out arithmetic and logical computations on provided operands, thereby producing the results of computational operations. In this project, the ALU is modeled to support a set of core functionalities, including addition, subtraction, multiplication, and comparison. The simulation of these operations provides insight into the role of the ALU and its interaction with input operands throughout the GPU computation workflow.

#### 3.1 Alu replication description 
```
// alu.v
`include "definitions.vh"


module alu (
    input [3:0] opcode,
    input [`DATA_WIDTH-1:0] operand_a,
    input [`DATA_WIDTH-1:0] operand_b,
    output reg [`DATA_WIDTH-1:0] result,
    output reg cmp_flag
);
    always @(*) begin
        cmp_flag = 0;
        result = 0;
        case (opcode)
            `OP_ADD: result = operand_a + operand_b;
            `OP_SUB: result = operand_a - operand_b;
            `OP_MUL: result = operand_a * operand_b;
            `OP_CMP: begin
                if (operand_a < operand_b)
                    cmp_flag = 1;
                else
                    cmp_flag = 0;
            end
   
            default: result = 0;
        endcase
    end
endmodule
```

The ALU (Arithmetic Logic Unit) executes arithmetic and comparison operations based on a 4-bit opcode. It accepts two DATA_WIDTH (16-bit) operands, operand_a and operand_b, and produces a computation result along with a comparison flag cmp_flag.

The module is implemented as combinational logic using always @(*). Both result and cmp_flag are initialized to zero to avoid unintended latches. Arithmetic operations OP_ADD, OP_SUB, OP_MUL directly compute and assign the result. The OP_CMP instruction performs a comparison only; if operand_a is less than operand_b, cmp_flag is asserted. All unsupported opcodes are handled by the default case, which forces the result to zero.
#### 3.2 Testbench for ALU 


.... fetcher

### 5. Instruction Decoder Module
During GPU instruction execution, the decoding stage constitutes the initial step in the processing pipeline. Instructions are represented in a binary format, and the decoder extracts the relevant fields required for execution, including the operation code, source and destination register identifiers, and immediate operands. By performing this separation, the decoder enables the GPU to correctly interpret each instruction and determine the appropriate operations to be applied to the associated data.
#### 5.1 Decoder module
```
// decoder.v
`include "definitions.vh"

module decoder (
    input [`DATA_WIDTH-1:0] instruction,
    output reg [3:0] opcode,
    output reg [3:0] dest_reg,
    output reg [3:0] src1_reg,
    output reg [3:0] src2_reg,
    output reg [7:0] immediate
);
    always @(*) begin
        opcode = instruction[15:12];
        dest_reg = instruction[11:8];
        src1_reg = instruction[7:4];   // Used in R-Type
        src2_reg = instruction[3:0];   // Used in R-Type

    end
endmodule
```
The decoder module translates a 16-bit instruction into structured control fields. It extracts the opcode, destination register (dest_reg), and source registers (src1_reg, src2_reg) using fixed bit positions.

Implemented as combinational logic (always @(*)), the decoder assigns instruction[15:12] to the opcode, [11:8] to the destination register, and [7:4] and [3:0] to the source registers for R-type instructions. Although the immediate field is currently unused, the interface supports future I-type instruction expansion.
#### 5.2 Testbench for decoder




### 2. Scheduler in GPU
#### 2.1 Concept of the Scheduler

In parallel processing architectures such as Graphics Processing Units (GPUs), multiple threads are executed concurrently to improve computational throughput. However, because the number of execution units is limited, not all threads can be executed simultaneously in every clock cycle. Therefore, a scheduler is required to manage the execution order of threads and allocate computational resources efficiently.

In the Small GPU project, the scheduler is designed to select exactly one active thread per clock cycle and dispatch it to the compute core. The scheduler follows a Round Robin scheduling policy, in which threads are executed in a cyclic order. This approach ensures fairness by giving each active thread an equal opportunity to execute and prevents starvation. Additionally, the scheduler supports interleaved multithreading, allowing the GPU to hide latency caused by memory access or long-latency operations, thereby improving overall system throughput.

#### 2.2 Verilog Implementation of the Scheduler

The scheduler is implemented as a Verilog module and relies on shared architectural parameters defined in definitions.vh, such as the number of threads and the width of thread identifiers. The complete implementation of the scheduler module is shown below.
```
`include "definitions.vh"

module scheduler #(
    parameter NUM_THREADS = `NUM_THREADS
)(
    input clk,
    input reset,
    input [NUM_THREADS-1:0] active_threads,
    output reg [`THREAD_ID_WIDTH-1:0] scheduled_thread
);
    integer last_thread; 
    integer i;           
    integer thread;      
    reg thread_found;    

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            last_thread <= -1;
            scheduled_thread <= 0;
        end else begin
            thread_found = 0;
            
            // Iterate through all threads using Round Robin
            for (i = 1; i <= NUM_THREADS; i = i + 1) begin
                thread = (last_thread + i) % NUM_THREADS;
                
                // Select the first active thread found
                if (active_threads[thread] && !thread_found) begin
                    scheduled_thread <= thread;
                    last_thread <= thread;
                    thread_found = 1;
                end
            end
        end
    end
endmodule
```

#### 2.3 Explanation of the Scheduler Operation

To clearly describe the behavior of the scheduler, this section is organized into inputs, outputs, and internal operation, following the logical data flow of the module.

#### 2.3.1 Inputs

The scheduler receives three input signals: clk, reset, and active_threads.

The clk signal is the system clock that determines when scheduling decisions are made. The scheduler updates its internal state and selects a new thread only on the rising edge of the clock, ensuring synchronous and deterministic behavior.

The reset signal initializes the scheduler to a known state. When reset is asserted, the scheduler clears its internal state by setting the previously scheduled thread to an invalid value and initializing the output thread ID. This guarantees correct behavior during system startup or reset conditions.

The active_threads signal is a bitmask representing the execution status of all threads. Each bit corresponds to one thread: a value of 1 indicates that the thread is active and eligible for scheduling, while a value of 0 indicates that the thread has halted or completed execution. This input prevents inactive threads from being scheduled.

#### 2.3.2 Output

The scheduler produces a single output signal, scheduled_thread.

The scheduled_thread output specifies the ID of the thread selected for execution in the current clock cycle. This output is forwarded to the compute core, where it controls instruction fetch, decode, and execution for the selected thread. By generating exactly one thread ID per cycle, the scheduler enforces controlled and orderly execution within the GPU pipeline.

#### 2.3.3 Internal Operation and Scheduling Logic

Internally, the scheduler implements a Round Robin scheduling algorithm. The variable last_thread stores the ID of the thread that was scheduled in the previous clock cycle. This variable enables the scheduler to continue selection from the next thread in sequence, rather than restarting from the first thread each time.

Upon reset, last_thread is initialized to -1, allowing the scheduler to begin scheduling from thread 0 during the first active cycle. During normal operation, the scheduling logic executes inside an always block triggered on the rising edge of the clock.

At each cycle, the scheduler iterates through all threads using a for loop. The expression (last_thread + i) % NUM_THREADS ensures a circular search order, which is the core mechanism of the Round Robin policy. The scheduler checks each candidate thread’s corresponding bit in active_threads to determine whether it is active.

The control flag thread_found ensures that only one thread is selected per clock cycle. Once an active thread is found, the scheduler updates scheduled_thread, records the selected thread in last_thread, and prevents further selections in the same cycle. This mechanism guarantees fairness, prevents starvation, and maintains low hardware complexity.

#### 2.4 Results and Observations

Simulation results show that the scheduler correctly implements Round Robin scheduling. All active threads are executed in a cyclic order, and no thread experiences starvation as long as it remains active. When some threads stall due to memory access latency, other active threads continue to be scheduled, demonstrating effective interleaved multithreading.

However, because the scheduler does not support priority-based execution, all threads are treated equally regardless of workload characteristics. In scenarios with unbalanced workloads or latency-sensitive tasks, this may result in suboptimal performance. Despite this limitation, the simplicity, fairness, and low hardware overhead of the design make it well suited for the Small GPU project and educational purposes.

### 3. Fetcher in GPU
### 4. Decoder in GPU
### 5. ALU in GPU
### 6. GPU Compute Core
=======
### 1. Introduction
### 2. Overall GPU Architecture
#### 2.1 High-Level Architecture Overview
#### 2.2 Core Components and Data Flow
#### 2.3 Thread-Level Parallelism Model
#### 2.4 Global Memory Organization
#### 2.5 Key Features of the Proposed GPU

### 3. Scheduler Module
#### 3.1 Role of the Scheduler in GPU Execution
#### 3.2 Scheduling Strategy
#### 3.3 Interface and Control Signals

### 4. Instruction Fetcher Module
#### 4.1 Instruction Fetch Mechanism
#### 4.2 Program Counter Management
#### 4.3 Interaction with Instruction Memory

### 5. Instruction Decoder Module
#### 5.1 Instruction Format
#### 5.2 Decoding Process
#### 5.3 Control Signal Generation

### 6. Arithmetic Logic Unit (ALU)
#### 6.1 Purpose of the ALU
#### 6.2 Supported Operations
#### 6.3 ALU Input and Output Interface

### 7. Compute Core Integration
#### 7.1 Compute Core Architecture
#### 7.2 Integration of Scheduler, Fetcher, Decoder, and ALU
#### 7.3 Multi-thread Execution Flow
#### 7.4 Halt and Control Logic

---

## II. Testbench Documentation

### 1. Verification Methodology
The verification methodology used in this project focuses on module-level functional verification through simulation-based testbenches. Each hardware module is verified independently to ensure correct functionality before system integration.

A directed testing approach is applied, where predefined input patterns are manually provided to the design under test (DUT). This method allows precise control over test scenarios and makes it easier to validate expected outputs for each operation.

All testbenches are written in Verilog and use standard simulation constructs such as:

- $display and $monitor for observing signal behavior,

- clock and reset generation for sequential modules,

- timeout mechanisms to detect deadlock or incorrect halt conditions.

Verification correctness is evaluated by:

- Comparing output signals with expected results,

- Observing control signals such as halt and scheduling outputs,

- Monitoring internal states (e.g., program counters, registers, memory) when necessary.

This methodology ensures that each module behaves correctly in isolation, providing a reliable foundation for higher-level system verification.
### 2. Module-Level Testbenches
#### 2.1 Scheduler Testbench
The Scheduler Testbench is designed to verify the correct operation of the thread scheduling logic. Its main purpose is to ensure that the scheduler selects a valid thread based on the current set of active threads and responds correctly to clock and reset signals.

The testbench generates a periodic clock signal with a fixed time period and applies an initial reset to initialize the scheduler state. After releasing the reset, different combinations of the active_threads input are applied to simulate various thread activity scenarios, including cases where some threads are inactive and cases where all threads are active.

The output signal scheduled_thread is monitored at every rising edge of the clock. The testbench checks whether the scheduler always selects a thread that is marked as active and whether the scheduling behavior remains stable across clock cycles.

By testing multiple active thread patterns and reapplying reset during simulation, the testbench verifies both normal operation and reset recovery behavior of the scheduler. This confirms that the scheduler operates correctly under different runtime conditions.
#### 2.2 Fetcher Testbench
The Fetcher Testbench is used to verify the correct instruction fetching behavior based on the program counter (PC) input. The objective of this testbench is to ensure that the fetcher outputs the correct instruction corresponding to each PC value.

In the testbench, the program counter input is driven with a sequence of increasing values. Although the testbench uses a 16-bit PC signal, only the lower bits are connected to the fetcher module, matching the actual design interface. This verifies that the fetcher correctly interprets the effective PC width.

For each applied PC value, the output instruction is monitored and displayed using $display. This allows direct observation of the mapping between PC addresses and fetched instructions during simulation.

By sweeping through all valid PC values within the supported range, the testbench confirms that the fetcher correctly accesses instruction memory and produces stable, deterministic outputs. This ensures reliable instruction delivery for subsequent pipeline stages.
#### 2.3 Decoder Testbench
The Decoder Testbench verifies the correctness of instruction decoding by ensuring that each field within the instruction word is properly extracted. The decoder splits a 16-bit instruction into multiple components, including opcode, destination register, source registers, and immediate value.

In the testbench, several predefined instruction patterns are applied sequentially to the decoder input. These patterns are chosen to cover different bit configurations and validate that all output fields respond correctly to changes in the instruction value.

The decoded outputs are continuously monitored and displayed whenever the instruction input changes. This allows verification that the opcode and operand fields are updated consistently and without delay.

Through these directed test cases and real-time monitoring, the testbench confirms that the decoder accurately interprets instruction formats and provides correct control and data signals for downstream execution units.
#### 2.4 ALU Testbench
The ALU Testbench is designed to verify the functional correctness of the Arithmetic Logic Unit (ALU) across multiple operations. It focuses on validating both arithmetic results and comparison flags generated by the ALU.

The testbench applies a series of directed test cases, each corresponding to a specific operation code, including addition, subtraction, multiplication, comparison, and immediate addition. For each operation, predefined operand values are provided, and the resulting output is observed.

Simulation output is monitored using $monitor, which displays the operation code, input operands, result, and comparison flag in real time. This allows immediate verification of correctness for each ALU operation.

By covering different operation types and operand combinations, the testbench ensures that the ALU produces accurate results and correctly asserts control flags. This confirms that the ALU behaves as expected and is reliable for use in the compute core.
#### 2.5 Compute Core Testbench

The Compute Core Testbench verifies the overall behavior of the compute core at the system level. Unlike module-level testbenches, this testbench evaluates the interaction between multiple internal components, including instruction execution, register files, and data memory.

The testbench generates a periodic clock signal and applies a single reset pulse to initialize the system. After reset is released, the compute core executes instructions autonomously until the halt signal is asserted.

During simulation, the testbench monitors program counter values for all threads, enabling observation of control flow progression. A timeout mechanism is included to detect potential deadlock conditions in case the halt signal is never asserted.

Once execution completes, the testbench displays final register contents and data memory values for each thread. In addition, performance metrics such as total cycle count and average cycles per thread are reported.

This testbench confirms correct system-level execution, proper thread termination, and overall functional integration of the compute core.
### 3. Compute Core Simulation Using Cocotb
#### 3.1 Compute Core Testbench
The Compute Core represents the primary execution engine of the GPU, responsible for instruction processing, multi-threaded scheduling, arithmetic operations, memory access, and control flow. As all major GPU functionalities converge at the Compute Core, its successful verification provides strong evidence of the correctness of the overall GPU operation. Consequently, validating the Compute Core through simulation effectively demonstrates the functional behavior of the GPU architecture as a whole.
#### 3.2 Simulation Framework Overview
To verify the Compute Core and, by extension, the GPU’s operational behavior, the design is simulated using Cocotb, a Python-based verification framework, together with the Icarus Verilog simulator. This environment enables high-level, programmable test scenarios while preserving cycle-accurate interaction with the hardware description.

The simulation framework integrates the GPU hardware modules, memory initialization files, and a Cocotb-based testbench to form a complete end-to-end verification flow.
#### 3.3 Simulation Architecture and Setup
The hardware design includes the Compute Core and its supporting modules, such as the scheduler, fetcher, decoder, and arithmetic logic unit (ALU). An external Python-based assembler translates assembly programs into machine-code memory images, which are loaded into the instruction memory prior to simulation. Data memory is initialized from a hexadecimal file and shared across all executing threads.

The hardware design is compiled using Icarus Verilog, while Cocotb orchestrates the simulation by generating the clock signal, applying the reset sequence, and supervising program execution.

### 4. Simulation Results

---

## III. Contribution

### 1. Task Distribution
### 2. Individual Contributions

---

## IV. Acknowledgements















