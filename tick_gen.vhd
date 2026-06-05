library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tick_gen is
    generic(
        MAX_COUNT : natural := 49_999_999
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        tick: out std_logic
    );
end entity;

architecture rtl of tick_gen is
    signal counter: unsigned(25 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset ='1' then
                counter <= (others => '0');
                tick <= '0';
            elsif counter = to_unsigned(MAX_COUNT, counter'length) then
                counter <= (others => '0');
                tick <= '1';
            else
                counter <= counter + 1;
                tick <= '0';
            end if;
        end if;
    end process;
end architecture;
