# RISC-V Processor Design Project

本项目包含两个版本的 RISC-V 处理器设计：一个是参与第九届全国大学生集成电路创新创业大赛（竞业达杯）的**原始三级流水线版本**，另一个是在此基础上进行深度优化和扩展的**高性能五级流水线版本**。

## 📁 目录结构

| 目录 | 说明 | 架构特点 |
| :--- | :--- | :--- |
| **`CPU/`** | **原始参赛版本** | 经典 **3级流水线** (IF, ID/EX, MEM/WB) |
| **`cdp-tests/`** | **深度优化版本** | 高频 **5级+流水线** (IF, ID, EX, MEM1/2/3, WB) |

---

## 🏗️ 架构演进与详细设计

### 1. 原始版本 (`CPU/`)
该版本为比赛初期的基础设计，采用紧凑的三级流水线架构，主要用于验证 RV32I 指令集的功能正确性。

- **流水线级数**：3级
  - **IF (取指)**：PC 更新与指令读取。
  - **ID+EX (译码与执行)**：指令译码、操作数读取、ALU 运算在同一周期完成。
  - **MEM+WB (访存与写回)**：数据存储器读写与寄存器堆写回在同一周期完成。
- **特点**：
  - 结构简单，控制逻辑开销小。
  - 关键路径较长（ID+EX 级逻辑深度大），限制了最高运行频率。

### 2. 扩展优化版本 (`cdp-tests/`)
该版本在原始设计基础上进行了架构重构，旨在提升时序性能（Frequency）和吞吐率。通过流水线切分和关键路径优化，显著提高了处理器的综合频率。

- **流水线级数**：5级 (扩展至多级 MEM)
  - **IF (取指)**
  - **ID (译码)**
  - **EX (执行)**
  - **MEM (访存 - 流水线化)**：将访存阶段进一步细分为 `MEM1`, `MEM2`, `MEM3`，以适应高扇出和长路径延迟。
  - **WB (写回)**
- **核心优化点**：
  1.  **流水线深度切分**：将原有的 `ID+EX` 拆解，并将 `MEM` 阶段流水线化。
  2.  **关键路径优化 (Critical Path Optimization)**：
      - 针对 Vivado 时序报告中的高扇出网表（如 `Ex_result_addr_reg`），在 `LSU` 模块中引入了多级寄存器复制（Register Replication）。
      - 使用 `(* max_fanout = N *)` 综合属性，强制工具进行物理优化，降低路由延迟。
  3.  **高级冲突处理**：
      - 实现了完整的 **数据前递 (Data Forwarding)** 单元，解决 RAW 相关。
      - 增加了 **Load-Use 冒险检测**，支持流水线气泡插入（Stall）。
      - 优化了分支预测失败的流水线冲刷（Flush）机制。
  4.  **BRAM 适配准备**：架构上已预留对同步读 Block RAM 的支持（通过多级 MEM 延迟槽）。

---

## 🚀 快速开始

### 环境要求
- **OS**: Linux (推荐 Ubuntu/CentOS)
- **EDA**: Vivado 2023.2 或更高版本
- **Simulation**: Verilator (可选，用于 C++ 仿真) 或 Vivado Simulator
- **Python**: Python 3.x (用于运行测试脚本)

### 运行测试
本项目集成了自动化测试脚本，可一键运行所有指令测试用例。

1. **编译与运行**
   进入优化版本目录：
   ```bash
   cd cdp-tests
   ```

2. **执行测试**
   使用 `make` 编译仿真模型并运行 Python 测试脚本：
   ```bash
   make clean && make
   python run_all_tests.py
   ```
   *脚本将自动比对 Golden Model，并输出每个测试点（Testcase）的 Pass/Fail 状态。*

---

## 🛠️ 技术细节 (Technical Highlights)

### LSU (Load Store Unit) 的深度优化
在 `mySoC/LSU.sv` 中，为了解决地址总线的高扇出延迟问题，我们实施了以下改进：

```systemverilog
// 示例：使用 max_fanout 属性优化关键路径寄存器
(* max_fanout = 32 *) logic [31:0] Ex_result_addr_reg;
(* max_fanout = 8 *)  logic [31:0] Ex_result_addr_reg_pipe;

// 三级流水线处理，平摊逻辑延迟
always_ff @(posedge clock) begin
    // Stage 1
    Ex_result_addr_reg <= ...;
    // Stage 2
    Ex_result_addr_reg_pipe <= Ex_result_addr_reg;
    // Stage 3 (Output)
    addr <= {Ex_result_addr_reg_pipe[31:18], ...};
end
```

### 冲突检测 (Hazard Unit)
在 `mySoC/Data_hazard.sv` 中，新增了针对多级流水线的复杂冲突检测逻辑：
- 支持 `MEM_PIPE` 和 `MEM2` 阶段的数据前瞻。
- 精确的 `pipe_load_use` 信号生成，最大程度减少流水线停顿。

---

## 📜 版权说明
Project by **hongpengWu**.
Based on the 9th National University IC Innovation & Entrepreneurship Competition (Jingyeda Cup) platform.
