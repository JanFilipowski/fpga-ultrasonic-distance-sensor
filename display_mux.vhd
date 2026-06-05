library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_mux is
    port(
        clk: in std_logic;
        reset: in std_logic;
        refresh_tick: in std_logic;
        value: in unsigned(9 downto 0);
        seg: out std_logic_vector(7 downto 0);
        dig: out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of display_mux is
    constant BLANK: natural := 10;
    signal counter: unsigned(1 downto 0) := (others => '0');
    signal selected_digit: natural range 0 to 10;
    signal letter_c: std_logic := '0';
    signal value_integer: natural range 0 to 1023;
begin
    value_integer <= to_integer(value);

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter <= (others => '0');
            elsif refresh_tick = '1' then
                counter <= counter + 1;
            end if;
        end if;
    end process;

    process(counter, value_integer)
    begin
        letter_c <= '0';
        selected_digit <= BLANK;
        case counter is
            when "00" =>
                dig <= "0111";
                letter_c <= '1';

            when "01" =>
                dig <= "1011";
                selected_digit <= value_integer mod 10;

            when "10" =>
                dig <= "1101";
                if value_integer >= 10 then
                    selected_digit <= (value_integer / 10) mod 10;
                else
                    selected_digit <= BLANK;
                end if;

            when others =>
                dig <= "1110";
                if value_integer >= 100 then
                    selected_digit <= (value_integer / 100) mod 10;
                else
                    selected_digit <= BLANK;
                end if;
        end case;
    end process;

    digit_to_7seg_inst : entity work.digit_to_7seg
        port map(
            digit => selected_digit,
            letter_c => letter_c,
            dot => '0',
            seg => seg
        );
end architecture;
