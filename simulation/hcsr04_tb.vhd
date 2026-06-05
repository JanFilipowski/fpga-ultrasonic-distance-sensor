library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity hcsr04_tb is
end entity;

architecture sim of hcsr04_tb is
    constant CLK_PERIOD : time := 20 ns;
    constant TARGET_CM  : natural := 30;
    constant ECHO_TICKS : natural := TARGET_CM * 2900;

    signal clk               : std_logic := '0';
    signal reset             : std_logic := '1';
    signal start_measurement : std_logic := '0';
    signal echo              : std_logic := '0';
    signal trig              : std_logic;
    signal distance_cm       : unsigned(9 downto 0);
begin
    clk <= not clk after CLK_PERIOD / 2;

    dut : entity work.hcsr04
        port map(
            clk               => clk,
            reset             => reset,
            start_measurement => start_measurement,
            echo              => echo,
            trig              => trig,
            distance_cm       => distance_cm
        );

    stimulus : process
        variable trig_start : time;
        variable trig_stop  : time;
    begin
        wait for 5 * CLK_PERIOD;
        reset <= '0';
        wait for 2 * CLK_PERIOD;

        start_measurement <= '1';
        wait until trig = '1';
        start_measurement <= '0';
        trig_start := now;

        wait until trig = '0';
        trig_stop := now;

        assert trig_stop - trig_start = 10 us
            report "TRIG duration is not 10 us"
            severity failure;

        wait for 100 us;
        echo <= '1';
        wait for ECHO_TICKS * CLK_PERIOD;
        echo <= '0';

        wait for 20 * CLK_PERIOD;

        assert distance_cm = to_unsigned(TARGET_CM, distance_cm'length)
            report "distance_cm is not equal to expected 30 cm"
            severity failure;

        report "HC-SR04 testbench passed: distance_cm = "
            & integer'image(to_integer(distance_cm))
            & " cm";

        finish;
    end process;
end architecture;
