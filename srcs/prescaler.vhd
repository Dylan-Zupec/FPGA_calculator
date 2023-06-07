library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prescaler is
    Generic ( prescaler_val : integer := 65535 );
    Port ( clock_in : in STD_LOGIC; 
           clock_out : buffer STD_LOGIC := '0'; -- prescaled clock
           reset : in STD_LOGIC ); 
end prescaler;

architecture Behavioral of prescaler is
    signal count : integer := 1;
begin
    process(clock_in)
    begin
        if rising_edge(clock_in) then
            if reset = '1' then -- synchronous reset    
                clock_out <= '0';
                count <= 1;
            else
                count <= count + 1;
                if count = prescaler_val/2 then -- half of desired clock period
                    clock_out <= not clock_out; 
                    count <= 1;
                end if;
            end if;           
        end if;
    end process;
end Behavioral;
