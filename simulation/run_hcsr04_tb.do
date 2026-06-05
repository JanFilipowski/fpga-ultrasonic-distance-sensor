transcript on

if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

vcom -2008 hcsr04.vhd
vcom -2008 simulation/hcsr04_tb.vhd

vsim -voptargs=+acc work.hcsr04_tb -fsmdebug

add wave sim:/hcsr04_tb/clk
add wave sim:/hcsr04_tb/reset
add wave sim:/hcsr04_tb/start_measurement
add wave sim:/hcsr04_tb/echo
add wave sim:/hcsr04_tb/trig
add wave -position end -radix unsigned sim:/hcsr04_tb/dut/distance_cm

run 3 ms