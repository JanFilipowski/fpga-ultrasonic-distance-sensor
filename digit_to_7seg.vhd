library ieee;
use ieee.std_logic_1164.all;

entity digit_to_7seg is
    port(
        digit : in natural range 0 to 10; -- 0-9 for digits, 10 for blank
        letter_c : in std_logic; -- display 'C' if high, otherwise display digit
        dot : in std_logic; -- control for the decimal point
        seg : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of digit_to_7seg is
begin
    process(digit, letter_c, dot)
    begin
        if letter_c = '1' then
            seg <= "01011000"; -- 'C'
        else
            case digit is
                when 0      => seg <= "00111111";
                when 1      => seg <= "00000110";
                when 2      => seg <= "01011011";
                when 3      => seg <= "01001111";
                when 4      => seg <= "01100110";
                when 5      => seg <= "01101101";
                when 6      => seg <= "01111101";
                when 7      => seg <= "00000111";
                when 8      => seg <= "01111111";
                when 9      => seg <= "01101111";
                when others => seg <= "00000000";
            end case;
            if dot = '1' then
                seg(7) <= '1';
            end if;
        end if;
    end process;
end architecture;
