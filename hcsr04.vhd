library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hcsr04 is
    port(
        clk               : in  std_logic;
        reset             : in  std_logic;
        start_measurement : in  std_logic;
        echo              : in  std_logic;
        trig              : out std_logic;
        distance_cm       : out unsigned(9 downto 0)
    );
end entity;

architecture rtl of hcsr04 is
    type state_type is (IDLE, SEND_TRIGGER, WAIT_FOR_ECHO, MEASURE_ECHO);
    signal state : state_type := IDLE;
    signal trig_counter : unsigned(8 downto 0) := (others => '0');
    signal echo_counter : unsigned(20 downto 0) := (others => '0');
    signal echo_meta : std_logic := '0';
    signal echo_sync : std_logic := '0';
begin
        
    trig <= '1' when state = SEND_TRIGGER else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            echo_meta <= echo;
            echo_sync <= echo_meta;
            if reset = '1' then
                trig_counter <= (others => '0');
                echo_counter <= (others => '0');
                distance_cm <= (others => '0');
                echo_meta <= '0';
                echo_sync <= '0';
                state <= IDLE;
            else
                case state is
                    when IDLE =>
                        trig_counter <= (others => '0');
                        if start_measurement = '1' then
                            state <= SEND_TRIGGER;
                        end if;

                    when SEND_TRIGGER =>
                        if trig_counter = 499 then -- 500 * 20 ns = 10 us
                            trig_counter <= (others => '0');
                            state <= WAIT_FOR_ECHO;
                        else
                            trig_counter <= trig_counter + 1;
                        end if;

                    when WAIT_FOR_ECHO =>
                        if echo_sync = '1' then
                            echo_counter <= (others => '0');
                            state <= MEASURE_ECHO;
                        elsif echo_counter = to_unsigned(1_499_999, echo_counter'length) then -- timeout 30 ms
                            echo_counter <= (others => '0');
                            distance_cm <= (others => '0');
                            state <= IDLE;
                        else
                            echo_counter <= echo_counter + 1;
                        end if;

                    when MEASURE_ECHO =>
                        if echo_sync = '0' then
                            distance_cm <= resize((echo_counter + 1450) / 2900, distance_cm'length);
                            -- 2900 = 58 us/cm / 20 ns = 2900 cykli/cm, 1450 = 2900/2 (zaokrąglenie do najbliższej liczby całkowitej)
                            echo_counter <= (others => '0');
                            state <= IDLE;
                        elsif echo_counter = to_unsigned(2_097_151, echo_counter'length) then -- timeout przepełnienie licznika (ok. 42 ms)
                            distance_cm <= (others => '0');
                            echo_counter <= (others => '0');
                            state <= IDLE;
                        else
                            echo_counter <= echo_counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;
