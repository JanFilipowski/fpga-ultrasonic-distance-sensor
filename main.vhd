library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    port(
        clk_50mhz: in std_logic;
        reset: in std_logic;
        seg: out std_logic_vector(7 downto 0);
        dig: out std_logic_vector(3 downto 0);
        echo : in  std_logic;
        trig : out std_logic
    );
end entity;

architecture rtl of main is
    signal tick_display : std_logic;
    signal tick_hcsr04 : std_logic;
    signal display_value : unsigned(9 downto 0);
    signal reset_int : std_logic;
begin
    reset_int <= not reset;
    tick_display_inst : entity work.tick_gen
        generic map(
            MAX_COUNT => 12_499
        )
        port map(
            clk => clk_50mhz,
            reset => '0',
            tick => tick_display
        );
    tick_hcsr04_inst : entity work.tick_gen
        generic map(
            MAX_COUNT => 49_999_999
        )
        port map(
            clk => clk_50mhz,
            reset => reset_int,
            tick => tick_hcsr04
        );
    display_mux_inst : entity work.display_mux
        port map(
            clk => clk_50mhz,
            reset => reset_int,
            refresh_tick => tick_display,
            value => display_value,
            seg => seg,
            dig => dig
        );
    hcsr04_inst : entity work.hcsr04
        port map(
            clk => clk_50mhz,
            reset => reset_int,
            start_measurement => tick_hcsr04,
            echo => echo,
            trig => trig,
            distance_cm => display_value
        );

end architecture;
