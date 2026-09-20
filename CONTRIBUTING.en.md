# Contributing

[中文](CONTRIBUTING.md) | [English](CONTRIBUTING.en.md)

Keep a change in one module when you can. Open an Issue first for large interface changes (MCU, gear ratio, protocol).

| Content | Directory |
| --- | --- |
| CNC models, gears, mechanical BOM | `mechanical/` |
| Schematics, fabrication files, electronics BOM | `hardware/` |
| Embedded software | `firmware/` |
| Host SDK | `sdk/` |
| Calibration / tuning / flashing | `tools/` |

Binary design files should include an interchange format (STEP, Gerber, PDF). Do not commit build artifacts, secrets, or third-party files whose licenses are incompatible. Use Doxygen block comments in code.

By contributing you agree that mechanical and hardware work is licensed under CC BY-NC-SA 4.0, and software under GPLv3. The project is for non-commercial study only.
