library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sevseg_controller is
    Port ( I : in STD_LOGIC_VECTOR(15 DOWNTO 0); -- 4 digit hexadecimal value to be displayed
           anodes : out STD_LOGIC_VECTOR(3 DOWNTO 0) := X"F"; -- common anodes of each digit
           segments : out STD_LOGIC_VECTOR(7 DOWNTO 0) := X"FF"; -- cathodes of segments for every digit
           clock : in STD_LOGIC; 
           reset : in STD_LOGIC );
end sevseg_controller;

architecture Behavioral of sevseg_controller is
    component prescaler is
        Generic ( prescaler_val : integer);
        Port ( clock_in : in STD_LOGIC;
               clock_out : buffer STD_LOGIC;
               reset : in STD_LOGIC ); 
    end component;
    
    type hexcode_array is array (0 to 15) of STD_LOGIC_VECTOR(7 DOWNTO 0);
    constant sevseg_hexcodes : hexcode_array := ( X"C0", X"F9", X"A4", X"B0", 
                                                  X"99", X"92", X"82", X"F8", 
                                                  X"80", X"90", X"88", X"83", 
                                                  X"C6", X"A1", X"86", X"8E" );
    -- nth value corresponds to segments needed to display "n" on 7-seg
    -- segment lit on logic low
                                                  
    signal prescaled_clock : STD_LOGIC;
    -- prescaled clock is used because multiplexing of 7-seg does not work at too high frequency
    
    signal prev_prescaled_clock : STD_LOGIC := '0';
    -- used to determine rising edge
    
    signal digit_index : unsigned(1 DOWNTO 0) := "00";
    -- current 7-seg digit being lit
begin
    u1: prescaler
        generic map ( prescaler_val => 262143 ) 
        port map ( clock_in => clock,
                   clock_out => prescaled_clock, 
                   reset => reset );
    process(clock) 
        variable digit_val : STD_LOGIC_VECTOR(3 DOWNTO 0);
    begin
        if rising_edge(clock) then 
            if reset = '1' then -- synchronous reset
                anodes <= X"F";
                segments <= X"FF";
                prev_prescaled_clock <= '0';
                digit_index <= "00"; 
            else
                if prescaled_clock = '1' and prev_prescaled_clock = '0' then -- rising edge       
                    case digit_index is
                        when "00" => -- first digit
                            digit_val := I(3 DOWNTO 0);
                            anodes <= "1110";
                        when "01" => -- second digit
                            digit_val := I(7 DOWNTO 4);
                            anodes <= "1101";
                        when "10" => -- third digit
                            digit_val := I(11 DOWNTO 8);
                            anodes <= "1011";
                        when "11" => -- fourth digit
                            digit_val := I(15 DOWNTO 12);
                            anodes <= "0111"; 
                        when others => 
                            anodes <= X"F";
                    end case;
                    segments <= sevseg_hexcodes(to_integer(unsigned(digit_val))); 
                    -- use digit_val as index to get corresponding hexcode
                    
                    digit_index <= digit_index + 1;
                end if;
                
                prev_prescaled_clock <= prescaled_clock;
                -- used to detect rising edge
            end if;
        end if;
    end process;
end Behavioral;
