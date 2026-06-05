# FPGA Ultrasonic Distance Sensor

VHDL implementation of an ultrasonic distance meter for a Cyclone IV FPGA. A project for "Digital microsystems design" course. 
The design drives an HC-SR04 ultrasonic sensor, measures the width of the `ECHO` pulse, converts the result to centimeters, and displays it on a 4-digit 5641AS 7-segment display.

## Project Overview

The system is built around a single 50 MHz clock domain. Timing helper modules generate one-clock-cycle enable pulses instead of creating additional clock domains:
- `tick_gen` for display refresh,
- `tick_gen` for starting a new HC-SR04 measurement about once per second,
- `hcsr04` for trigger generation, echo timing, synchronization, and distance calculation,
- `display_mux` and `digit_to_7seg` for multiplexed decimal display output.

The display shows three decimal digits and a small `c` suffix for centimeters.

## Hardware

| Component | Details |
| --- | --- |
| FPGA | Cyclone IV E EP4CE6E22C8 |
| Clock | 50 MHz |
| Sensor | HC-SR04, powered from 5 V |
| Display | 5641AS 4-digit 7-segment, common cathode |
| Segment polarity | Active HIGH |
| Digit select polarity | Active LOW |
| Echo protection | Resistor divider from 5 V logic to about 3.06 V |

The HC-SR04 `ECHO` output is a 5 V signal, so it must not be connected directly to the FPGA input. This project uses a resistor divider on the `ECHO` line and a common ground between the FPGA board and the sensor.

<img width="1684" height="1194" alt="Electrical connection diagram" src="https://github.com/user-attachments/assets/bae4dfb7-f2c6-4576-8a57-27658b8dbcaf" />

## Operation

After reset, the `hcsr04` FSM waits in `IDLE`. Every measurement cycle:

1. `SEND_TRIGGER` drives `TRIG` high for 10 us.
2. `WAIT_FOR_ECHO` waits for the synchronized `ECHO` signal to go high.
3. `MEASURE_ECHO` counts 50 MHz clock cycles while `ECHO` is high.
4. The counter value is converted to centimeters and sent to the display path.

The distance conversion used in the design is:

```vhdl
distance_cm <= resize((echo_counter + 1450) / 2900, distance_cm'length);
```

At 50 MHz, one clock period is 20 ns. Since the HC-SR04 echo pulse is commonly approximated as 58 us per centimeter, one centimeter corresponds to:

```text
58 us / 20 ns = 2900 clock cycles
```

Adding `1450` before division performs rounding to the nearest centimeter.

## State Machine

The HC-SR04 controller is implemented as a synchronous FSM with an asynchronous external input. The `ECHO` signal is passed through a two-flip-flop synchronizer before it is used by the state machine.

<img width="1464" height="548" alt="HC-SR04 FSM diagram" src="https://github.com/user-attachments/assets/58b4cb13-80a7-4cd7-bff2-da8ca26ea5eb" />

## RTL Structure

The top-level entity connects the timing generators, the HC-SR04 measurement unit, and the display controller. The design does not use PLLs or generated clocks for internal logic.

<img width="1978" height="736" alt="Top-level RTL view" src="https://github.com/user-attachments/assets/0f13057c-42b9-4785-b4d3-890bd93901a6" />

## Simulation

The repository includes a focused testbench for the `hcsr04` module:

- `simulation/hcsr04_tb.vhd`
- `simulation/run_hcsr04_tb.do`

The testbench verifies:

- reset behavior,
- 10 us `TRIG` pulse duration,
- echo pulse handling for a known target distance,
- correct `distance_cm` result.

Run the simulation in Questa from the project root:

```tcl
do simulation/run_hcsr04_tb.do
```

## FPGA Resource Usage

Resource usage from the final Quartus compilation for `EP4CE6E22C8`, with Signal Tap disabled:

| Resource | Usage |
| --- | --- |
| Logic elements | 914 / 6,272 (15%) |
| Combinational functions | 911 / 6,272 (15%) |
| Dedicated logic registers | 102 / 6,272 (2%) |
| Total registers | 102 |
| Pins | 16 / 92 (17%) |
| Memory bits | 0 / 276,480 (0%) |
| 9-bit multipliers | 0 / 30 (0%) |
| PLLs | 0 / 2 (0%) |

## Hardware Test

The design was programmed onto the FPGA board and tested with the HC-SR04 sensor and the multiplexed 7-segment display.

<img width="4032" height="3024" alt="Hardware test at about 18 cm" src="https://github.com/user-attachments/assets/0ff005e3-d3e4-478d-bbe5-d5e4bb0c1af8" />

## Main Source Files

| File | Purpose |
| --- | --- |
| `main.vhd` | Top-level integration |
| `hcsr04.vhd` | HC-SR04 FSM, echo timing, distance conversion |
| `tick_gen.vhd` | Generic one-cycle tick generator |
| `display_mux.vhd` | 4-digit display multiplexing and decimal digit selection |
| `digit_to_7seg.vhd` | Digit and `c` character to 7-segment decoder |
