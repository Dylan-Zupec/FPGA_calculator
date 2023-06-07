library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Generic ( wait_time : time := 100 ms;
              clock_period : time := 10 ns );
    Port ( I : in STD_LOGIC; -- input to be debounced
           O : buffer STD_LOGIC := '0'; -- debounced output
           clock : in STD_LOGIC;
           reset : in STD_LOGIC );
end debounce;

architecture Behavioral of debounce is  
    type clock_state_type is (idle, counting);
    signal clock_state : clock_state_type := idle;    
    constant cycles_needed : integer := wait_time/clock_period; 
    signal count : integer := 1;
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then -- synchronous reset
                O <= '0';
                clock_state <= idle;
                count <= 1;
            else
                case clock_state is
                    when idle => -- input has not changed
                        if I = '0' then
                            O <= '0'; -- do not need debounce for falling edge
                        elsif I = '1' and O = '0' then
                            clock_state <= counting; -- rising edge triggers debounce
                        end if;
                    when counting =>
                        count <= count + 1;
                        if I = '0' then -- chatter not done, reset counter
                            clock_state <= idle;
                            count <= 1;
                        elsif count = cycles_needed and I = '1' then -- no chatter for long enough period
                            O <= '1';
                            clock_state <= idle;
                            count <= 1;
                        end if;
                end case;
            end if;     
        end if;
    end process;  
end Behavioral;
