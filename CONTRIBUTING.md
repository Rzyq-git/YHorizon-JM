# 贡献指南

[中文](CONTRIBUTING.md) | [English](CONTRIBUTING.en.md)

一次改动尽量只动一个模块。较大的接口变化（MCU、减速比、通信协议）请先开 Issue 讨论。

| 内容 | 目录 |
| --- | --- |
| CNC 模型、齿轮、零件 BOM | `mechanical/` |
| 原理图、制板文件、元器件 BOM | `hardware/` |
| 嵌入式软件 | `firmware/` |
| 上位机 SDK | `sdk/` |
| 标定 / 调参 / 烧录 | `tools/` |

二进制设计文件请同时提供可交换格式（STEP、Gerber、PDF）。不要提交编译产物、密钥或许可证不兼容的第三方文件。

向本仓库提交即表示：机械和硬件贡献按 CC BY-NC-SA 4.0 授权，软件贡献按 GPLv3 授权。
