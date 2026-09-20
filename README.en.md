# YHorizon-JM

[中文](README.md) | [English](README.en.md)

Open-source joint motor. The firmware, SDK, and tools in this repository target the first prototype: voltage-mode servo, Classic CAN, GD32F303 driver board.

> **This project is for study and technical exchange only.**
> It does not guarantee reliability or safety, and it is not a product certification or quality commitment.
> **Commercial use of the designs, firmware, SDK, or documentation in this repository by others is prohibited.**
> Anyone who uses this project assumes the risk of personal injury, equipment damage, and other loss. See [SECURITY.en.md](SECURITY.en.md).

<p align="center">
  <img src="images/Front.jpeg" alt="Output flange / front" width="48%"/>
  <img src="images/Back.jpeg" alt="Rear cover / wiring" width="48%"/>
</p>
<p align="center">
  <img src="images/Side.jpeg" alt="Side" width="48%"/>
  <img src="images/Inside.jpeg" alt="Driver board inside" width="48%"/>
</p>

<p align="center">
  Front (output flange) · Rear (power and LEDs) · Side · Internal driver board
</p>

<p align="center">
  <img src="images/CAD.jpeg" alt="Mechanical CAD" width="70%"/>
</p>
<p align="center">
  Mechanical layout (CAD)
</p>

## Current actuator

Integrated joint with a planetary gearbox. First-revision mechanics and electronics:

| Item | Status |
| --- | --- |
| Envelope | Diameter 57 mm, thickness 52 mm |
| Mass | About 300 g |
| Motor | WK4310 parameters, 14 pole pairs |
| Gear | Planetary, ratio 8 |
| Torque | 3 Nm continuous, 6 Nm peak |
| Supply | Up to 48 V |
| Encoder | Dual MT6701 vernier (30/31 teeth); multi-turn motor shaft is recovered, then divided by the gear ratio for the output shaft |
| MCU | GD32F303CCT6, 112 MHz |
| Power stage | FD6288 three-phase driver |
| Bus | Classic CAN 2.0, 1 Mbps, Motor Protocol V1.0 |
| Control | Voltage inner loop by default; current inner loop optional. Motion / velocity / position modes |

After power-on calibration or loading Flash parameters, the drive enters motion control. Protocol: [`sdk/protocol/Motor CAN Protocol V1.0.en.md`](sdk/protocol/Motor%20CAN%20Protocol%20V1.0.en.md).

Test video: [Stage-1 joint motor complete | D57 H52, 8:1, 3 Nm continuous](https://www.bilibili.com/video/BV1CEtB6QELB/)

The MCU is planned to move to **GD32C113** for **CAN FD** and multi-axis sync. Mechanical interfaces and the gear train should stay compatible where possible; electronics and protocol will change with CAN FD.

## Build one

Start with the two BOMs for sourcing parts and fabricating the board. Do not order from other files first:

- Mechanical parts and purchased hardware: [`mechanical/bom/组装购买清单.xlsx`](mechanical/bom/组装购买清单.xlsx)
- Driver electronics: [`hardware/bom/BOM_YHorizon-JM.xlsx`](hardware/bom/BOM_YHorizon-JM.xlsx)

Gerber files: [`hardware/fabrication/Gerber_YHorizon-JM.zip`](hardware/fabrication/Gerber_YHorizon-JM.zip). Schematic: [`hardware/schematic/SCH_YHorizon-JM.pdf`](hardware/schematic/SCH_YHorizon-JM.pdf). CNC models are in `mechanical/cnc/`. **CNC parts are not guaranteed to match ours; try fits and adjust hole positions to your own machining.**

There is also a convenience kit of leftover parts from the authors: a finished driver board, reducer gears, and some screws, so you do not have to fabricate the PCB or source those pieces yourself. Presale is on Xianyu (code **CZ225**): [kit listing](https://m.tb.cn/h.8FFGGjp?tk=cgNcTkelna0).

You also need tools that are not on the BOM, including:

- An arbor press (bearings, planet carrier, and similar fits)
- Loctite threadlocker / retaining compound
- Hex keys (Allen wrenches)

Videos:

- Test: [Stage-1 joint motor complete | D57 H52, 8:1, 3 Nm continuous](https://www.bilibili.com/video/BV1CEtB6QELB/)
- Full assembly: _TBD_

Replication is for study only. Commercial use is not allowed. Read [SECURITY.en.md](SECURITY.en.md) before assembly or power-up.

## Layout

| Path | Contents |
| --- | --- |
| `mechanical/cnc/` | CNC models |
| `mechanical/gears/` | Gears |
| `mechanical/bom/` | Mechanical BOM |
| `hardware/schematic/` | Schematics |
| `hardware/fabrication/` | Board fabrication files |
| `hardware/bom/` | Electronics BOM |
| `firmware/` | GD32F303 firmware |
| `sdk/python/` | Host Python SDK / GUI |
| `sdk/protocol/` | CAN protocol |
| `tools/` | Setup, build, and flash scripts |
| `images/` | Prototype photos and CAD |

## Firmware

Requires `arm-none-eabi-gcc` plus CMake and Ninja. Output: `firmware/build/gd32f303/YHorizon-JM.elf`. In CLion, open `firmware/` and select preset `gd32f303`.

Windows:

```powershell
.\tools\setup-env.ps1
.\tools\build.ps1
.\tools\flash.ps1
```

Ubuntu:

```bash
./tools/setup-env.sh
./tools/build.sh
./tools/flash.sh
./tools/run-gui.sh
```

`setup-env.sh` installs missing packages with apt and creates `sdk/python/.venv`. The debug probe is CMSIS-DAP over SWD. Distro OpenOCD usually has no `gd32f30x` driver; the script falls back to `tools/openocd-gd32f303-stm32f1x.cfg` (256 KB, no `mass_erase`).

## Host tools

On Ubuntu, run `./tools/run-gui.sh` after `./tools/setup-env.sh`. Or set up the venv by hand:

```bash
cd sdk/python
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
python servo_gui.py
```

CLI example: `python servo_host.py --interface socketcan --channel can0 --id 1 --listen`. Protocol files live in `sdk/protocol/`.

## License

Dual license, see [`LICENSE`](LICENSE). **Regardless of which license applies to a given path, this project is for study and exchange only. Commercial use by others is prohibited.**

| Content | License | Notes |
| --- | --- | --- |
| `mechanical/`, `hardware/` | [CC BY-NC-SA 4.0](LICENSES/CC-BY-NC-SA-4.0.txt) | Non-commercial; derivatives must use the same license and give credit |
| `firmware/`, `sdk/`, `tools/` | [GPLv3](LICENSES/GPL-3.0.txt) | Study, modify, and share; derivatives must remain GPLv3 |

## Safety

Full disclaimer: [SECURITY.en.md](SECURITY.en.md). A joint motor can produce high torque. Do not run at full power near people until limits, over-current protection, and e-stop have been verified.

## Contributing

See [CONTRIBUTING.en.md](CONTRIBUTING.en.md).
