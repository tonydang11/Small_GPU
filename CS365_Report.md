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

3.3 Internal Operation and Scheduling Logic

Internally, the scheduler implements a Round Robin scheduling algorithm. The variable last_thread stores the ID of the thread that was scheduled in the previous clock cycle. This variable enables the scheduler to continue selection from the next thread in sequence, rather than restarting from the first thread each time.

Upon reset, last_thread is initialized to -1, allowing the scheduler to begin scheduling from thread 0 during the first active cycle. During normal operation, the scheduling logic executes inside an always block triggered on the rising edge of the clock.

At each cycle, the scheduler iterates through all threads using a for loop. The expression (last_thread + i) % NUM_THREADS ensures a circular search order, which is the core mechanism of the Round Robin policy. The scheduler checks each candidate thread’s corresponding bit in active_threads to determine whether it is active.

The control flag thread_found ensures that only one thread is selected per clock cycle. Once an active thread is found, the scheduler updates scheduled_thread, records the selected thread in last_thread, and prevents further selections in the same cycle. This mechanism guarantees fairness, prevents starvation, and maintains low hardware complexity.

#### 2.3 Results and Observations

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
### 2. Module-Level Testbenches
#### 2.1 Scheduler Testbench
#### 2.2 Fetcher Testbench
#### 2.3 Decoder Testbench
#### 2.4 ALU Testbench
### 3. Compute Core Simulation Using Cocotb
### 4. Simulation Results and Waveform Analysis

---

## III. Contribution

### 1. Task Distribution
### 2. Individual Contributions

---

## IV. Acknowledgements









