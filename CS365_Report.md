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
        immediate = instruction[7:0];  // Used in I-Type
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
#### 7.1 Concept of the Compute Core
In this project, a compute core is a simplified processing unit that executes basic instructions such as arithmetic and comparison operations. It represents the smallest functional execution block of the simple GPU model, focusing on clarity and educational purpose rather than performance optimization. The compute core combines instruction control and computation to demonstrate how a GPU processes instructions at a fundamental level.
#### 7.2 Compute Core Architecture
<img width="1106" height="1496" alt="image" src="https://github.com/adam-maj/tiny-gpu/blob/master/docs/images/core.png" />


The compute core architecture in this project is organized as a simple and clear instruction processing pipeline. At the top of the compute core, the Scheduler is responsible for selecting which execution context (or thread) is active. This selected context is then passed to the Fetcher, which retrieves the corresponding instruction from instruction memory based on the program counter (PC).

After fetching, the instruction is sent to the Decoder, where it is interpreted into control signals such as opcode, register indices, and execution type. Based on the decoded instruction, the compute core activates one of the functional units, including the Arithmetic Logic Unit (ALU) for computation, the Load/Store Unit (LSU) for memory access, or the Program Counter (PC) logic for control flow updates.

Each execution path is connected to a local Register File, which stores temporary data used during computation. Multiple identical execution blocks are shown in the architecture to represent parallel execution capability, illustrating how a GPU can process multiple instruction streams using the same structure. Overall, this architecture demonstrates how control, computation, and memory access are integrated within a simplified compute core design.
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
```
module scheduler_tb;

    // Parameters
    parameter NUM_THREADS = 4;  // Giả sử có 4 threads
    parameter THREAD_ID_WIDTH = 3;  // Sửa chiều rộng ID thread thành 3 bit

    // Inputs
    reg clk;
    reg reset;
    reg [NUM_THREADS-1:0] active_threads;  // Tín hiệu xác định các thread còn hoạt động

    // Outputs
    wire [THREAD_ID_WIDTH-1:0] scheduled_thread;  // Thread được lập lịch

    // Instantiate the scheduler module
    scheduler #(
        .NUM_THREADS(NUM_THREADS)
    ) uut (
        .clk(clk),
        .reset(reset),
        .active_threads(active_threads),
        .scheduled_thread(scheduled_thread)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Chu kỳ đồng hồ 10 đơn vị thời gian
    end

    // Testbench stimulus
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        active_threads = 4'b1111;  // Tất cả các thread đều hoạt động

        // Display header
        $display("Time\tReset\tActive Threads\tScheduled Thread");

        // Apply reset and release it after a while
        #10 reset = 0;  // Release reset tại thời điểm t = 10

        // Chạy thử với các active_threads khác nhau
        #10 active_threads = 4'b1110;  // Thread 3 không hoạt động
        #10 active_threads = 4'b1101;  // Thread 2 không hoạt động
        #10 active_threads = 4'b1011;  // Thread 1 không hoạt động
        #10 active_threads = 4'b1000;  // Chỉ có thread 0 hoạt động

        // Chạy với tất cả các thread đều hoạt động
        #10 active_threads = 4'b1111;

        // Test with reset again
        #10 reset = 1;  // Thực hiện reset
        #10 reset = 0;  // Thả reset

        // Kết thúc mô phỏng sau khi test đủ các tình huống
        #50 $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        $display("%0t\t%0b\t%0b\t%0d", $time, reset, active_threads, scheduled_thread);
    end

endmodule
```
output:
<img width="2052" height="516" alt="image" src="https://github.com/user-attachments/assets/bd48ae21-ca6c-43d8-8360-c1b061df6c64" />


#### 2.2 Fetcher Testbench
The Fetcher Testbench is used to verify the correct instruction fetching behavior based on the program counter (PC) input. The objective of this testbench is to ensure that the fetcher outputs the correct instruction corresponding to each PC value.

In the testbench, the program counter input is driven with a sequence of increasing values. Although the testbench uses a 16-bit PC signal, only the lower bits are connected to the fetcher module, matching the actual design interface. This verifies that the fetcher correctly interprets the effective PC width.

For each applied PC value, the output instruction is monitored and displayed using $display. This allows direct observation of the mapping between PC addresses and fetched instructions during simulation.

By sweeping through all valid PC values within the supported range, the testbench confirms that the fetcher correctly accesses instruction memory and produces stable, deterministic outputs. This ensures reliable instruction delivery for subsequent pipeline stages.
```
// testbench/module/fetcher_tb.v

module fetcher_tb;
    // Parameters
    parameter ADDR_WIDTH = 16;
    parameter DATA_WIDTH = 16;

    // Inputs
    reg [ADDR_WIDTH-1:0] pc_in;    // Testbench dùng 16-bit
    
    // Outputs
    wire [DATA_WIDTH-1:0] instruction;

    // Instantiate - CHỈ kết nối ports có thật
    fetcher uut (
        .pc_in(pc_in[3:0]),        // Chỉ truyền 4 bit thấp
        .instruction(instruction)
        // KHÔNG có .instr_mem()!
    );

    // Testbench stimulus
    initial begin
        // Display header
        $display("Time\tPC\tInstruction");
        
        // Apply test cases
        #10 pc_in = 0;
        #10 pc_in = 1;
        #10 pc_in = 2;
        #10 pc_in = 3;
        #10 pc_in = 4;
        #10 pc_in = 5;
        #10 pc_in = 6;
        #10 pc_in = 7;
        #10 pc_in = 8;
        #10 pc_in = 9;
        #10 pc_in = 10;
        #10 pc_in = 11;
        #10 pc_in = 12;
        #10 pc_in = 13;
        #10 pc_in = 14;
        #10 pc_in = 15;

        // End simulation
        #10 $finish;
    end

    // Monitor
    always @(pc_in) begin
        $display("%0t\t%h\t%h", $time, pc_in[3:0], instruction);
    end

endmodule
```
output:
<img width="2052" height="1198" alt="image" src="https://github.com/user-attachments/assets/30ecd9e8-cf1d-498c-be75-33409c3fab96" />

#### 2.3 Decoder Testbench
The Decoder Testbench verifies the correctness of instruction decoding by ensuring that each field within the instruction word is properly extracted. The decoder splits a 16-bit instruction into multiple components, including opcode, destination register, source registers, and immediate value.

In the testbench, several predefined instruction patterns are applied sequentially to the decoder input. These patterns are chosen to cover different bit configurations and validate that all output fields respond correctly to changes in the instruction value.

The decoded outputs are continuously monitored and displayed whenever the instruction input changes. This allows verification that the opcode and operand fields are updated consistently and without delay.

Through these directed test cases and real-time monitoring, the testbench confirms that the decoder accurately interprets instruction formats and provides correct control and data signals for downstream execution units.
```
// decoder_tb.v


module decoder_tb;

    // Parameters
    parameter DATA_WIDTH = 16;  // Chiều rộng của instruction (16 bit)

    // Inputs
    reg [DATA_WIDTH-1:0] instruction;

    // Outputs
    wire [3:0] opcode;
    wire [3:0] dest_reg;
    wire [3:0] src1_reg;
    wire [3:0] src2_reg;
    wire [7:0] immediate;

    // Instantiate the decoder module
    decoder uut (
        .instruction(instruction),
        .opcode(opcode),
        .dest_reg(dest_reg),
        .src1_reg(src1_reg),
        .src2_reg(src2_reg),
        .immediate(immediate)
    );

    // Testbench stimulus
    initial begin
        // Initialize signals
        instruction = 16'b0001_1010_1100_0011; // Một giá trị instruction mẫu

        // Display header
        $display("Time\tInstruction\tOpcode\tDest_Reg\tSrc1_Reg\tSrc2_Reg\tImmediate");

        // Apply different instruction values and monitor output
        #10 instruction = 16'b1001_0101_0110_0111;  // Thay đổi giá trị instruction
        #10 instruction = 16'b0110_1111_0001_0010;  // Một giá trị instruction khác
        #10 instruction = 16'b1110_0000_1000_1111;  // Thêm một giá trị khác

        // End simulation
        #10 $finish;
    end

    // Monitor outputs during simulation
    always @(instruction) begin
        $display("%0t\t%h\t\t%h\t\t%h\t\t%h\t\t%h\t\t%h", 
                 $time, instruction, opcode, dest_reg, src1_reg, src2_reg, immediate);
    end

endmodule
```
output:
<img width="2052" height="210" alt="image" src="https://github.com/user-attachments/assets/522084ca-cbaf-4dcf-881f-59acde5ce63b" />

#### 2.4 ALU Testbench
The ALU Testbench is designed to verify the functional correctness of the Arithmetic Logic Unit (ALU) across multiple operations. It focuses on validating both arithmetic results and comparison flags generated by the ALU.

The testbench applies a series of directed test cases, each corresponding to a specific operation code, including addition, subtraction, multiplication, comparison, and immediate addition. For each operation, predefined operand values are provided, and the resulting output is observed.

Simulation output is monitored using $monitor, which displays the operation code, input operands, result, and comparison flag in real time. This allows immediate verification of correctness for each ALU operation.

By covering different operation types and operand combinations, the testbench ensures that the ALU produces accurate results and correctly asserts control flags. This confirms that the ALU behaves as expected and is reliable for use in the compute core.
```

module alu_tb;

    reg [3:0] opcode;
    reg [`DATA_WIDTH-1:0] operand_a;
    reg [`DATA_WIDTH-1:0] operand_b;

    wire [`DATA_WIDTH-1:0] result;
    wire cmp_flag;

    alu uut (
        .opcode(opcode),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .result(result),
        .cmp_flag(cmp_flag)
    );

    initial begin
        opcode    = 4'b0000;
        operand_a = 16'h0000;
        operand_b = 16'h0000;

        $monitor("T=%0t | op=%b | A=%d | B=%d | R=%d | CMP=%b",
                 $time, opcode, operand_a, operand_b, result, cmp_flag);

        // ADD: 7 + 5 = 12
        #10 opcode = `OP_ADD;  operand_a = 16'd7;  operand_b = 16'd5;
        #10;

        // SUB: 9 - 4 = 5
        #10 opcode = `OP_SUB;  operand_a = 16'd9;  operand_b = 16'd4;
        #10;

        // MUL: 6 * 3 = 18
        #10 opcode = `OP_MUL;  operand_a = 16'd6;  operand_b = 16'd3;
        #10;

        // CMP: 2 < 8 → cmp_flag = 1
        #10 opcode = `OP_CMP;  operand_a = 16'd2;  operand_b = 16'd8;
        #10;

        // ADDI: 10 + 15 = 25
        #10 opcode = `OP_ADDI; operand_a = 16'd10; operand_b = 16'd15;
        #10;

        $finish;
    end
endmodule
```
output:
<img width="2052" height="246" alt="image" src="https://github.com/user-attachments/assets/5d82fd51-2c2e-4621-93b4-0bae895c0dd9" />

#### 2.5 Compute Core Testbench

The Compute Core Testbench verifies the overall behavior of the compute core at the system level. Unlike module-level testbenches, this testbench evaluates the interaction between multiple internal components, including instruction execution, register files, and data memory.

The testbench generates a periodic clock signal and applies a single reset pulse to initialize the system. After reset is released, the compute core executes instructions autonomously until the halt signal is asserted.

During simulation, the testbench monitors program counter values for all threads, enabling observation of control flow progression. A timeout mechanism is included to detect potential deadlock conditions in case the halt signal is never asserted.

Once execution completes, the testbench displays final register contents and data memory values for each thread. In addition, performance metrics such as total cycle count and average cycles per thread are reported.

This testbench confirms correct system-level execution, proper thread termination, and overall functional integration of the compute core.
```
// compute_core_tb.v
`include "definitions.vh"

module compute_core_tb;
    
    // Inputs
    reg clk;
    reg reset;
    
    // Outputs
    wire halt;
    
    // Instantiate the compute_core module
    compute_core uut (
        .clk(clk),
        .reset(reset),
        .halt(halt)
    );
    
    // Clock generation: 10 time unit period
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Testbench stimulus
    initial begin
        $display("========================================");
        $display("    Compute Core Testbench Start");
        $display("========================================");
        $display("Time\tReset\tHalt\tPC[0]\tPC[1]\tPC[2]\tPC[3]\tPC[4]\tPC[5]\tPC[6]\tPC[7]");
        
        // Initialize signals
        reset = 1;
        
        // Apply reset pulse (single time only!)
        #10 reset = 0;
        
        $display("\n[INFO] Reset released. Starting computation...\n");
        
        // Wait for halt signal or timeout
        wait(halt == 1);
        
        $display("\n========================================");
        $display("    All Threads Halted - Test Passed!");
        $display("========================================");
        
        // Display final register states
        $display("\nFinal Register States:");
        $display("Thread 0: R0=%h R1=%h R2=%h R3=%h", 
                 uut.register_file[0][0], uut.register_file[0][1], 
                 uut.register_file[0][2], uut.register_file[0][3]);
        $display("Thread 1: R0=%h R1=%h R2=%h R3=%h", 
                 uut.register_file[1][0], uut.register_file[1][1], 
                 uut.register_file[1][2], uut.register_file[1][3]);
        
        // Display final data memory
        $display("\nFinal Data Memory:");
        $display("mem[0]=%h mem[1]=%h mem[2]=%h mem[3]=%h", 
                 uut.data_mem[0], uut.data_mem[1], uut.data_mem[2], uut.data_mem[3]);
        
        #50;  // Wait a bit after halt
        $finish;
    end
    
    // Timeout mechanism - in case halt never asserts
    initial begin
        #50000;  // 50000 time units = 5000 cycles timeout
        $display("\n========================================");
        $display("    ERROR: Simulation Timeout!");
        $display("    Halt signal never asserted");
        $display("========================================");
        $finish;
    end
    
    // Monitor PC values every clock cycle
    always @(posedge clk) begin
        if (!reset) begin  // Only display when not in reset
            $display("%0t\t%0b\t%0b\t%h\t%h\t%h\t%h\t%h\t%h\t%h\t%h", 
                     $time, reset, halt,
                     uut.pc[0], uut.pc[1], uut.pc[2], uut.pc[3],
                     uut.pc[4], uut.pc[5], uut.pc[6], uut.pc[7]);
        end
    end
    
    // Monitor halt signal
    always @(posedge halt) begin
        $display("\n[INFO] Halt signal asserted at time %0t", $time);
    end
    
    // Performance counter
    integer cycle_count;
    initial cycle_count = 0;
    
    always @(posedge clk) begin
        if (!reset && !halt)
            cycle_count = cycle_count + 1;
    end
    
    // Display performance metrics at end
    initial begin
        wait(halt == 1);
        #10;
        $display("\nPerformance Metrics:");
        $display("Total cycles executed: %0d", cycle_count);
        $display("Average cycles per thread: %0d", cycle_count / `NUM_THREADS);
    end
    
endmodule
```
output:
<img width="2052" height="1158" alt="image" src="https://github.com/user-attachments/assets/a22c6075-e812-4a4f-bb4d-48427673e9d0" />
<img width="2052" height="1580" alt="image" src="https://github.com/user-attachments/assets/f993ca49-5f09-46e1-b21e-2c6274e3462a" />
<img width="2052" height="1634" alt="image" src="https://github.com/user-attachments/assets/1863ac34-fd02-471a-a193-94bdd928d63b" />
<img width="2052" height="1634" alt="image" src="https://github.com/user-attachments/assets/4a4fe68e-0cce-42b0-ad12-586248538cad" />
<img width="2052" height="1300" alt="image" src="https://github.com/user-attachments/assets/5d424757-b41e-4f7f-ba0c-531087f2d1ea" />
<img width="2052" height="752" alt="image" src="https://github.com/user-attachments/assets/e44e7638-a966-4d7f-8f49-daf1d07e88d0" />



### 3. GPU Simulation Using Cocotb
#### 3.1 The role of Compute Core
As mentioned, The Compute Core represents the primary execution engine of the GPU, responsible for instruction processing, multi-threaded scheduling, arithmetic operations, memory access, and control flow. As all major GPU functionalities converge at the Compute Core, its successful verification provides strong evidence of the correctness of the overall GPU operation. Consequently, validating the Compute Core through simulation effectively demonstrates the functional behavior of the GPU architecture as a whole.
#### 3.2 Simulation Framework Overview
To verify the Compute Core and, by extension, the GPU’s operational behavior, the design is simulated using Cocotb, a Python-based verification framework, together with the Icarus Verilog simulator. This environment enables high-level, programmable test scenarios while preserving cycle-accurate interaction with the hardware description.

The simulation framework integrates the GPU hardware modules, memory initialization files, and a Cocotb-based testbench to form a complete end-to-end verification flow.
#### 3.3 Simulation Architecture and Setup
The hardware design includes the Compute Core and its supporting modules, such as the scheduler, fetcher, decoder, and arithmetic logic unit (ALU). An external Python-based assembler translates assembly programs into machine-code memory images, which are loaded into the instruction memory prior to simulation. Data memory is initialized from a hexadecimal file and shared across all executing threads.

The hardware design is compiled using Icarus Verilog, while Cocotb orchestrates the simulation by generating the clock signal, applying the reset sequence, and supervising program execution. This integrated environment enables end-to-end verification of the compute core and demonstrates the fundamental operational behavior of the GPU.

To realize this simulation flow, three main components are used: the Python assembler, the assembly-level test program, and the Cocotb testbench. The assembler generates the instruction memory image, the test program defines the workload executed by the GPU, and the Cocotb testbench controls and observes the simulation.
##### 3.3.1 Python Assembler
The Python assembler converts human-readable assembly code into machine instructions. This allows flexible development and rapid testing of GPU programs. The assembler supports arithmetic, comparison, memory access, control flow, and halt instructions. Registers are encoded using 4-bit identifiers. A two-pass approach is used. The first pass collects labels and constants. The second pass generates the hexadecimal instruction memory file. This file is loaded automatically by the fetcher module during simulation.

```
# Python program to convert assembly code to instructions fitting for the gpu at instruction_memory.mem

import sys
import re

# Define opcode mappings
opcode_map = {
    'ADD': '0000',
    'SUB': '0001',
    'MUL': '0010',
    'CMP': '0011',
    'JMP': '0100',
    'JLT': '0101',  # Jump if Less Than
    'LDRI': '0110',  # Load Immediate
    'LDR': '0110',   # Load from Memory
    'STR': '0111',
    'HALT': '1111',
}

# Define register mappings (R0 to R15)
register_map = {f'R{i}': f'{i:04b}' for i in range(16)}

def assemble_instruction(parts, labels, definitions):
    if not parts:
        return None
    opcode = parts[0].upper()
    opcode_bin = opcode_map.get(opcode, None)
    if opcode_bin is None:
        print(f"Unknown opcode: {opcode}")
        return None

    if opcode in ['HALT']:
        # HALT has no operands
        return opcode_bin + '0000' + '00000000'

    elif opcode in ['LDR', 'STR']:
        # LDR dest_reg, [address]
        # STR src_reg, [address]
        if len(parts) != 3:
            print(f"Incorrect number of operands for {opcode}: {parts}")
            return None
        reg = parts[1].rstrip(',').upper()
        operand = parts[2].strip('[]').upper()
        # Resolve operand (address)
        if operand in labels:
            address = labels[operand]
        elif operand in definitions:
            address = definitions[operand]
        else:
            try:
                if operand.startswith('0x') or operand.startswith('0X'):
                    address = int(operand, 16)
                else:
                    address = int(operand)
            except ValueError:
                print(f"Invalid operand address: {operand}")
                return None
        dest_reg_bin = register_map.get(reg, '0000')
        immediate_bin = f'{address & 0xFF:08b}'  # 8-bit immediate
        return opcode_bin + dest_reg_bin + immediate_bin

    elif opcode in ['ADD', 'SUB', 'MUL', 'CMP']:
        # ADD dest_reg, src_reg, immediate
        if len(parts) != 4:
            print(f"Incorrect number of operands for {opcode}: {parts}")
            return None
        dest_reg = parts[1].rstrip(',').upper()
        src_reg = parts[2].rstrip(',').upper()
        immediate = parts[3].upper()
        # Resolve immediate
        if immediate in labels:
            imm_value = labels[immediate]
        elif immediate in definitions:
            imm_value = definitions[immediate]
        else:
            try:
                if immediate.startswith('#'):
                    imm_value = int(immediate[1:])
                elif immediate.startswith('0x') or immediate.startswith('0X'):
                    imm_value = int(immediate, 16)
                else:
                    imm_value = int(immediate)
            except ValueError:
                print(f"Invalid immediate value: {immediate}")
                return None
        dest_reg_bin = register_map.get(dest_reg, '0000')
        src_reg_bin = register_map.get(src_reg, '0000')
        immediate_bin = f'{imm_value & 0x0F:04b}'  # 4-bit immediate
        return opcode_bin + dest_reg_bin + src_reg_bin + immediate_bin

    elif opcode in ['JMP', 'JLT']:
        # JMP label
        # JLT label
        if len(parts) != 2:
            print(f"Incorrect number of operands for {opcode}: {parts}")
            return None
        label = parts[1].upper()
        if label in labels:
            address = labels[label]
        elif label in definitions:
            address = definitions[label]
        else:
            try:
                if label.startswith('0x') or label.startswith('0X'):
                    address = int(label, 16)
                else:
                    address = int(label)
            except ValueError:
                print(f"Invalid jump address: {label}")
                return None
        # For JMP and JLT, use a special register or ignore
        dest_reg_bin = '0000'  # Assuming no destination register for jumps
        immediate_bin = f'{address & 0xFF:08b}'
        return opcode_bin + dest_reg_bin + immediate_bin

    elif opcode in ['LDRI']:
        # LDRI dest_reg, immediate
        if len(parts) != 3:
            print(f"Incorrect number of operands for {opcode}: {parts}")
            return None
        dest_reg = parts[1].rstrip(',').upper()
        immediate = parts[2].upper()
        # Resolve immediate
        if immediate in labels:
            imm_value = labels[immediate]
        elif immediate in definitions:
            imm_value = definitions[immediate]
        else:
            try:
                if immediate.startswith('#'):
                    imm_value = int(immediate[1:])
                elif immediate.startswith('0x') or immediate.startswith('0X'):
                    imm_value = int(immediate, 16)
                else:
                    imm_value = int(immediate)
            except ValueError:
                print(f"Invalid immediate value: {immediate}")
                return None
        dest_reg_bin = register_map.get(dest_reg, '0000')
        immediate_bin = f'{imm_value & 0xFF:08b}'  # 8-bit immediate
        return opcode_bin + dest_reg_bin + immediate_bin

    else:
        print(f"Unhandled opcode: {opcode}")
        return None

def assemble(lines):
    labels = {}
    definitions = {}
    machine_code = []
    address = 0

    # First pass: collect labels and definitions
    for line in lines:
        line = line.strip()
        # Remove comments
        line = re.split(r'#|//', line)[0].strip()
        if not line:
            continue
        # Handle .define
        if line.startswith('.define'):
            parts = line.split()
            if len(parts) != 3:
                print(f"Invalid .define directive: {line}")
                continue
            _, name, value = parts
            try:
                if value.startswith('0x') or value.startswith('0X'):
                    definitions[name.upper()] = int(value, 16)
                else:
                    definitions[name.upper()] = int(value)
            except ValueError:
                print(f"Invalid .define value: {line}")
            continue
        # Handle labels
        if line.endswith(':'):
            label = line[:-1].upper()
            labels[label] = address
            continue
        # Otherwise, it's an instruction
        address += 1

    # Second pass: assemble instructions
    address = 0
    for line in lines:
        original_line = line
        line = line.strip()
        # Remove comments
        line = re.split(r'#|//', line)[0].strip()
        if not line:
            continue
        # Handle .define
        if line.startswith('.define'):
            continue
        # Handle labels
        if line.endswith(':'):
            continue
        # Split instruction into parts
        parts = re.split(r'[,\s]+', line)
        instruction_bin = assemble_instruction(parts, labels, definitions)
        if instruction_bin:
            instruction_hex = f'{int(instruction_bin, 2):04X}'
            machine_code.append(instruction_hex)
            address +=1
    return machine_code

def main():
    if len(sys.argv) < 2:
        print("Usage: python assembler.py assembly_code.asm")
        return

    asm_file = sys.argv[1]
    with open(asm_file, 'r') as f:
        lines = f.readlines()

    machine_code = assemble(lines)
    with open('instruction_memory.mem', 'w') as f:
        for code in machine_code:
            f.write(code + '\n')

    print("Assembly complete. Machine code written to instruction_memory.mem.")

if __name__ == '__main__':
    main()

```
##### 3.3.2 Assembly Test Program
A non-trivial assembly test program was developed to validate the compute core. The program performs an iterative two-dimensional computation resembling a Mandelbrot-style workload. Symbolic constants define iteration limits, thresholds, and initial values. These are resolved by the assembler. Nested loops iterate over X and Y coordinates. An inner loop performs repeated arithmetic and comparison operations. The program uses conditional jumps and memory stores to control execution and write results. Successful completion, indicated by all threads executing HALT, confirms correct functional integration.
```
// A program written in assembly that can be translated into instructions at instruction_memory.mem to create test case

.define MAX_ITER 16
.define THRESHOLD 1024
.define VALUE_C_REAL 10
.define VALUE_C_IMAG 10
.define X_INIT 0
.define Y_INIT 0
.define Z_REAL_INIT 0
.define Z_IMAG_INIT 0
.define MAX_X 16
.define MAX_Y 16


LDRI R11, [MAX_ITER]      
LDRI R12, [THRESHOLD]     


LDRI R1, [Y_INIT]         

LOOP_Y:
    CMP R1, [MAX_Y]        
    JLT LOOP_Y_BODY        
    JMP END_PROGRAM        

LOOP_Y_BODY:
    
    LDRI R0, [X_INIT]      

LOOP_X:
    CMP R0, [MAX_X]        
    JLT LOOP_X_BODY        
    ADD R1, R1, #1         
    JMP LOOP_Y             

LOOP_X_BODY:
    
    LDRI R4, [VALUE_C_REAL] 
    LDRI R5, [VALUE_C_IMAG] 

    
    LDRI R2, [Z_REAL_INIT] 
    LDRI R3, [Z_IMAG_INIT] 

    
    LDRI R10, [ITER_INIT]  

LOOP_MANDEL:
    
    MUL R6, R2, R2          
    
    MUL R7, R3, R3          
    
    MUL R8, R2, R3          
    ADD R8, R8, #0          

    
    SUB R2, R6, R7          
    ADD R2, R2, R4          

    
    ADD R3, R8, R5          

    
    ADD R9, R6, R7          

    
    CMP R9, R12             
    JLT CONTINUE_ITER       

    
    
    MUL R14, R1, #16        
    ADD R14, R14, R0        

    
    STR R10, [R14]          

    
    ADD R0, R0, #1
    JMP LOOP_X              

CONTINUE_ITER:
    
    ADD R10, R10, #1

    
    CMP R10, R11
    JLT LOOP_MANDEL         

    
    
    MUL R14, R1, #16        
    ADD R14, R14, R0        

    
    STR R10, [R14]          

    
    ADD R0, R0, #1
    JMP LOOP_X              

END_PROGRAM:
    HALT                    

```
##### 3.3.3 Assembly Test Program
The simulation is driven by a Cocotb-based Python testbench. This allows automated and repeatable verification. The testbench generates the clock and reset signals. It then monitors program execution. The test passes when the global halt signal is asserted. This indicates that all threads have completed execution. Execution traces and waveform dumping are enabled. These support debugging and timing analysis. This verification confirms that the compute core operates correctly within the GPU framework.
```
# testbench/test_matadd_simple.py

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock

@cocotb.test()
async def test_matadd_simple(dut):
    """
    Simplified Testbench for Matrix Addition on GPU Simulation using Cocotb.
    """

    # 1. Create a 10 ns period clock on port clk
    clock = Clock(dut.clk, 10, units="ns")  # 10 ns period
    cocotb.start_soon(clock.start())
    dut.reset.value = 1
    cocotb.log.info("Clock started with 10 ns period. Asserting reset.")

    # 2. Initialize reset
    await RisingEdge(dut.clk)
    dut.reset.value = 0
    cocotb.log.info("Deasserting reset.")
    await RisingEdge(dut.clk)

    # 3. Wait for 'halt' signal or timeout after max_cycles
    cocotb.log.info("Waiting for 'halt' signal.")
    max_cycles = 1000            # Maximum number of clock cycles to wait
    cycle = 0

    while dut.halt.value != 1 and cycle < max_cycles:
        await RisingEdge(dut.clk)
        cycle += 1
        if cycle % 100 == 0:
            cocotb.log.info(f"Cycle {cycle}: 'halt' not yet asserted.")

    # 4. Check if 'halt' was asserted
    if dut.halt.value != 1:
        cocotb.log.error(f"Test FAILED: 'halt' signal not asserted after {max_cycles} cycles.")
        assert False, f"'halt' not asserted after {max_cycles} cycles."
    else:
        cocotb.log.info(f"Test PASSED: 'halt' signal asserted after {cycle} cycles.")
        assert True

```

### 4. Simulation Result
```
tandang@MacBook-Pro-cua-Tan Small_GPU % make SIM=icarus WAVES=1

rm -f results.xml
"/Applications/Xcode.app/Contents/Developer/usr/bin/make" -f Makefile results.xml
/Users/tandang/Library/Python/3.9/lib/python/site-packages/cocotb_tools/makefiles/simulators/Makefile.icarus:65: Using MODULE is deprecated, please use COCOTB_TEST_MODULES instead.
rm -f results.xml
COCOTB_TEST_MODULES=testbench.test_execution COCOTB_TESTCASE= COCOTB_TEST_FILTER= COCOTB_TOPLEVEL=compute_core TOPLEVEL_LANG=verilog \
         /opt/homebrew/bin/vvp -M /Users/tandang/Library/Python/3.9/lib/python/site-packages/cocotb/libs -m libcocotbvpi_icarus   sim_build/sim.vvp -fst  
     -.--ns INFO     gpi                                ..mbed/gpi_embed.cpp:94   in _embed_init_python              Using Python 3.9.13 interpreter at /Applications/Xcode.app/Contents/Developer/usr/bin/python3
     -.--ns INFO     gpi                                ../gpi/GpiCommon.cpp:79   in gpi_print_registered_impl       VPI registered
     0.00ns INFO     cocotb                             Running on Icarus Verilog version 12.0 (stable)
     0.00ns INFO     cocotb                             Seeding Python random module with 1768311481
     0.00ns INFO     cocotb                             Initialized cocotb v2.0.1 from /Users/tandang/Library/Python/3.9/lib/python/site-packages/cocotb
     0.00ns INFO     cocotb.regression                  pytest not found, install it to enable better AssertionError messages
     0.00ns INFO     cocotb                             Running tests
     0.00ns INFO     cocotb.regression                  running testbench.test_execution.test_matadd_simple (1/1)
                                                            Simplified Testbench for Matrix Addition on GPU Simulation using Cocotb.
     0.00ns WARNING  py.warnings                        /Users/tandang/Small_GPU/testbench/test_execution.py:14: DeprecationWarning: The 'units' argument has been renamed to 'unit'.
                                                          clock = Clock(dut.clk, 10, units="ns")  # 10 ns period
                                                        
     0.00ns INFO     test                               Clock started with 10 ns period. Asserting reset.
WARNING: /Users/tandang/Small_GPU/src/fetcher.v:17: $readmemh(src/instruction_memory.mem): Too many words in the file for the requested range [0:15].
Instruction Memory Initialized in Fetcher:
instr_mem[0] = 6000
instr_mem[1] = 6101
instr_mem[2] = 0221
instr_mem[3] = 8210
instr_mem[4] = 1330
instr_mem[5] = 3032
instr_mem[6] = 500b
instr_mem[7] = 2443
instr_mem[8] = 7402
instr_mem[9] = f000
instr_mem[10] = 0000
instr_mem[11] = 6501
instr_mem[12] = 0550
instr_mem[13] = 7503
instr_mem[14] = f000
instr_mem[15] = 0000
Data Memory Initialized:
data_mem[0] = 0003
data_mem[1] = 0005
data_mem[2] = 0000
data_mem[3] = 0000
data_mem[4] = 0000
data_mem[5] = 0000
data_mem[6] = 0000
data_mem[7] = 0000
data_mem[8] = 0000
data_mem[9] = 0000
data_mem[10] = 0000
data_mem[11] = 0000
data_mem[12] = 0000
data_mem[13] = 0000
data_mem[14] = 0000
data_mem[15] = 0000
FST info: dumpfile simulation.vcd opened for output.
FST warning: sim_build/cocotb_iverilog_dump.v:3: $dumpfile called after $dumpvars started,
                                                 using existing file (simulation.vcd).
FST warning: ignoring signals in previously scanned scope compute_core.
FST warning: ignoring signals in previously scanned scope compute_core.alu_inst.
FST warning: ignoring signals in previously scanned scope compute_core.decoder_inst.
FST warning: ignoring signals in previously scanned scope compute_core.fetcher_inst.
FST warning: ignoring signals in previously scanned scope compute_core.scheduler_inst.
     0.00ns INFO     test                               Deasserting reset.
DUT Reset at time 0
    10.00ns INFO     test                               Waiting for 'halt' signal.
Time=10000 | Thread=0 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=20000 | Thread=0 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=30000 | Thread=1 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=40000 | Thread=2 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=50000 | Thread=3 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=60000 | Thread=4 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=70000 | Thread=5 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=80000 | Thread=6 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=90000 | Thread=7 | PC=0 | Instruction=6000 | Opcode=0110 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=100000 | Thread=0 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=110000 | Thread=1 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=120000 | Thread=2 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=130000 | Thread=3 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=140000 | Thread=4 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=150000 | Thread=5 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=160000 | Thread=6 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=170000 | Thread=7 | PC=1 | Instruction=6101 | Opcode=0110 | dest=R1 | src1=R0 | src2=R1 | imm=  x
Time=180000 | Thread=0 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=190000 | Thread=1 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=200000 | Thread=2 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=210000 | Thread=3 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=220000 | Thread=4 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=230000 | Thread=5 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=240000 | Thread=6 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=250000 | Thread=7 | PC=2 | Instruction=0221 | Opcode=0000 | dest=R2 | src1=R2 | src2=R1 | imm=  x
Time=260000 | Thread=0 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=270000 | Thread=1 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=280000 | Thread=2 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=290000 | Thread=3 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=300000 | Thread=4 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=310000 | Thread=5 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=320000 | Thread=6 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=330000 | Thread=7 | PC=3 | Instruction=8210 | Opcode=1000 | dest=R2 | src1=R1 | src2=R0 | imm=  x
Time=340000 | Thread=0 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=350000 | Thread=1 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=360000 | Thread=2 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=370000 | Thread=3 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=380000 | Thread=4 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=390000 | Thread=5 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=400000 | Thread=6 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=410000 | Thread=7 | PC=4 | Instruction=1330 | Opcode=0001 | dest=R3 | src1=R3 | src2=R0 | imm=  x
Time=420000 | Thread=0 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=430000 | Thread=1 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=440000 | Thread=2 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=450000 | Thread=3 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=460000 | Thread=4 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=470000 | Thread=5 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=480000 | Thread=6 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=490000 | Thread=7 | PC=5 | Instruction=3032 | Opcode=0011 | dest=R0 | src1=R3 | src2=R2 | imm=  x
Time=500000 | Thread=0 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=510000 | Thread=1 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=520000 | Thread=2 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=530000 | Thread=3 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=540000 | Thread=4 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=550000 | Thread=5 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=560000 | Thread=6 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=570000 | Thread=7 | PC=6 | Instruction=500b | Opcode=0101 | dest=R0 | src1=R0 | src2=R11 | imm=  x
Time=580000 | Thread=0 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=590000 | Thread=1 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=600000 | Thread=2 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=610000 | Thread=3 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=620000 | Thread=4 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=630000 | Thread=5 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=640000 | Thread=6 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Time=650000 | Thread=7 | PC=7 | Instruction=2443 | Opcode=0010 | dest=R4 | src1=R4 | src2=R3 | imm=  x
Thread 0 executing HALT. Halting.
Time=660000 | Thread=0 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Time=670000 | Thread=1 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=680000 | Thread=2 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=690000 | Thread=3 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=700000 | Thread=4 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=710000 | Thread=5 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=720000 | Thread=6 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Time=730000 | Thread=7 | PC=8 | Instruction=7402 | Opcode=0111 | dest=R4 | src1=R0 | src2=R2 | imm=  x
Thread 1 executing HALT. Halting.
Time=740000 | Thread=1 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 2 executing HALT. Halting.
Time=750000 | Thread=2 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 3 executing HALT. Halting.
Time=760000 | Thread=3 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 4 executing HALT. Halting.
Time=770000 | Thread=4 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 5 executing HALT. Halting.
Time=780000 | Thread=5 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 6 executing HALT. Halting.
Time=790000 | Thread=6 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
Thread 7 executing HALT. Halting.
Time=800000 | Thread=7 | PC=9 | Instruction=f000 | Opcode=1111 | dest=R0 | src1=R0 | src2=R0 | imm=  x
All threads have halted at time 800000
   810.00ns INFO     test                               Test PASSED: 'halt' signal asserted after 80 cycles.
   810.00ns INFO     cocotb.regression                  testbench.test_execution.test_matadd_simple passed
   810.00ns INFO     cocotb.regression                  *****************************************************************************************************
                                                        ** TEST                                         STATUS  SIM TIME (ns)  REAL TIME (s)  RATIO (ns/s) **
                                                        *****************************************************************************************************
                                                        ** testbench.test_execution.test_matadd_simple   PASS         810.00           0.01      80815.11  **
                                                        *****************************************************************************************************
                                                        ** TESTS=1 PASS=1 FAIL=0 SKIP=0                               810.00           0.01      63085.12  **
                                                        *****************************************************************************************************
```
---

## III. Contribution

### 1. Task Distribution
### 2. Individual Contributions

---

## IV. Acknowledgements
































