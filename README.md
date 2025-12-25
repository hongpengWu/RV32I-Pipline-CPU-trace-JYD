# RISC-V Processor Design Project

本项目包含两个版本的 RISC-V 处理器设计：一个是参与第九届全国大学生集成电路创新创业大赛（竞业达杯）的**原始三级流水线版本**，另一个是在此基础上进行深度优化和扩展的**高性能五级流水线版本**。

## 📁 目录结构

以下展示了两个核心目录的主要文件结构：

```text
.
├── CPU/                        # [原始版本] 三级流水线处理器设计
│   ├── myCPU.sv                # 处理器顶层模块
│   ├── Control.sv              # 集中式控制单元
│   ├── Data_hazard.sv          # 基础数据冲突检测
│   ├── IFU.sv                  # 取指单元 (Instruction Fetch)
│   ├── IDU.sv                  # 译码单元 (Instruction Decode)
│   ├── EXU.sv                  # 执行单元 (Execute)
│   ├── LSU.sv                  # 访存单元 (Load Store)
│   ├── WBU.sv                  # 写回单元 (Write Back)
│   ├── IFID_EX_Reg.sv          # 流水线寄存器：IF -> ID/EX
│   ├── EX_LSWB_Reg.sv          # 流水线寄存器：EX -> MEM/WB
│   └── ... (其他辅助模块：ALU, CSR, RegFile 等)
│
├── cdp-tests/                  # [优化版本] 五级流水线 SoC 及验证环境
│   ├── mySoC/                  # 核心 SoC 代码目录
│   │   ├── myCPU.sv            # 更新后的处理器顶层
│   │   ├── LSU.sv              # 深度优化的流水线化访存单元
│   │   ├── Data_hazard.sv      # 增强型冲突检测单元
│   │   ├── miniRV_SoC.v        # SoC 顶层集成封装
│   │   ├── dram_driver.sv      # 存储器驱动适配
│   │   └── ... (标准流水线级模块)
│   ├── golden_model/           # C++ 编写的指令集模拟器 (Golden Model)
│   ├── asm/                    # 汇编测试用例源码
│   ├── bin/                    # 编译后的二进制机器码
│   ├── vsrc/                   # 仿真用存储器模型
│   ├── run_all_tests.py        # 自动化回归测试脚本
│   └── Makefile                # 编译与仿真构建脚本
└── README.md
```

---

## �️ 1. CPU：原始三级流水线架构

位于 `CPU/` 目录下的代码是该项目的起源，采用了经典的**三级流水线**结构。该版本结构清晰，逻辑直观，主要用于验证指令集功能的正确性。

### 核心架构
- **Stage 1: IF (取指)**
  - 负责 PC 的维护与指令存储器（IROM）的访问。
- **Stage 2: ID + EX (译码与执行)**
  - 将译码（Decode）与执行（Execute）合并在同一个时钟周期内完成。
  - **特点**：这一级逻辑深度较大，包含立即数生成、寄存器堆读取、ALU 运算以及分支跳转判断。虽然减少了流水线级数，但也限制了主频的提升。
- **Stage 3: MEM + WB (访存与写回)**
  - 将数据存储器（DRAM）的读写与结果写回寄存器堆合并。
  - 通过 `EX_LSWB_Reg` 寄存器接收来自执行级的结果。

### 关键文件解析
- **`IFID_EX_Reg.sv` & `EX_LSWB_Reg.sv`**：显式的流水线寄存器模块，清晰地界定了流水线的边界。
- **`Control.sv`**：传统的集中式控制逻辑，根据 Opcode 生成各级的控制信号。
- **`Data_hazard.sv`**：处理基础的数据相关（RAW），主要负责生成 Stall 信号以解决冲突。

---

## 🚀 2. cdp-tests：高性能五级流水线架构

位于 `cdp-tests/` 目录下的设计代表了架构的深度进化。为了突破三级流水线的频率瓶颈并适配更复杂的 SoC 环境，我们将架构扩展为**五级+流水线**，并引入了大量时序优化技术。

### 核心架构与优化亮点
该版本将流水线细分为：**IF (取指) → ID (译码) → EX (执行) → MEM (访存) → WB (写回)**。

#### 1. LSU 的深度流水线化 (Pipelined LSU)
在 `cdp-tests/mySoC/LSU.sv` 中，访存阶段不再是一个简单的组合逻辑操作。
- **多级拆分**：为了应对高扇出（High Fan-out）和长路由延迟，MEM 阶段被内部拆分为 `MEM1`, `MEM2`, `MEM3` 等多个微流水级。
- **寄存器复制**：利用 `(* max_fanout *)` 属性，对关键路径上的地址和控制信号进行物理级别的寄存器复制，显著降低了布线拥塞和延迟。

#### 2. 增强型冲突检测 (Advanced Hazard Unit)
随着流水线加深，数据冒险的处理变得更加复杂。`cdp-tests/mySoC/Data_hazard.sv` 进行了全面升级：
- **全路径前递 (Forwarding)**：不仅支持 EX 级的前递，还实现了从 MEM 各个微流水级到 ID/EX 级的数据前递，最大程度减少流水线气泡。
- **Load-Use 优化**：能够精确检测 Load 指令后的使用冲突，并插入最小周期的 Stall。

#### 3. SoC 集成与总线适配
- **`miniRV_SoC.v`**：这是适配竞业达杯赛题的 SoC 顶层文件，集成了 CPU 核心与外设接口。
- **`dram_driver.sv`**：针对赛题提供的存储器接口进行了驱动层适配，处理字节/半字/字的不同读写模式。

#### 4. 自动化验证体系
为了确保优化后的正确性，该目录包含了一套完整的验证框架：
- **Golden Model (`golden_model/`)**：基于 C++ 实现的标准 RISC-V 指令集模拟器，作为“黄金标准”。
- **自动化脚本 (`run_all_tests.py`)**：能够批量运行 `asm/` 下的所有汇编用例，自动对比 Verilog 仿真结果与 Golden Model 的执行结果，并输出详细的 Pass/Fail 报告。

---

## 🛠️ 快速上手

### 运行环境
- **仿真工具**：Verilator (推荐) 或 Vivado Simulator
- **构建工具**：Make, Python 3

### 测试步骤
进入优化版本目录，一键运行所有测试：

```bash
cd cdp-tests
make clean && make      # 编译仿真模型
python run_all_tests.py # 运行回归测试
```

测试脚本将自动遍历所有指令用例（如 `add`, `beq`, `lw` 等），并在终端输出测试结果摘要。
