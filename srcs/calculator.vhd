library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator is
    Port ( A : in STD_LOGIC_VECTOR(7 DOWNTO 0); -- operand 1  
           B : in STD_LOGIC_VECTOR(7 DOWNTO 0); -- operand 2
           func_sel_up : in STD_LOGIC; -- increment selected_func
           func_sel_down : in STD_LOGIC; -- decrement selected_func
           selected_func : buffer STD_LOGIC_VECTOR(3 DOWNTO 0) := X"0"; -- index for selected operation
           latch : in STD_LOGIC; -- perform operation on rising edge
           sevseg_anodes : out STD_LOGIC_VECTOR(3 DOWNTO 0); -- common anodes of each digit
           sevseg_segments : out STD_LOGIC_VECTOR(7 DOWNTO 0); -- cathodes of segments for every digit
           clock: in STD_LOGIC; 
           reset : in STD_LOGIC );
end calculator;

architecture Behavioral of calculator is 
    component debounce is
        Generic ( wait_time : time;
                  clock_period : time);
        Port ( I : in STD_LOGIC;
               O : out STD_LOGIC;
               clock : in STD_LOGIC;
               reset : in STD_LOGIC );
    end component;
    component ALU is
        Port ( A : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               B : in STD_LOGIC_VECTOR(7 DOWNTO 0);
               control : in STD_LOGIC_VECTOR(3 DOWNTO 0);
               latch : in STD_LOGIC;
               Y : out STD_LOGIC_VECTOR(7 DOWNTO 0);
               carry : buffer STD_LOGIC;
               clock : in STD_LOGIC; 
               reset : in STD_LOGIC );
    end component;
    component sevseg_controller is
        Port ( I : in STD_LOGIC_VECTOR(15 DOWNTO 0); 
               anodes : out STD_LOGIC_VECTOR(3 DOWNTO 0);
               segments : out STD_LOGIC_VECTOR(7 DOWNTO 0);
               clock : in STD_LOGIC;
               reset : in STD_LOGIC );
    end component;
    
    signal Y : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal carry : STD_LOGIC; 
    -- intermediate signals from ALU to sevseg_controller
   
    signal db_latch : STD_LOGIC; 
    signal db_func_sel_up : STD_LOGIC; 
    signal db_func_sel_down : STD_LOGIC;
    -- debounced inputs
    
    signal prev_func_sel_up : STD_LOGIC := '0'; 
    signal prev_func_sel_down : STD_LOGIC := '0';
    -- used to detect rising edge
    
    constant debounce_wait : time := 20 ms;
    constant clock_period : time := 10 ns;
begin
    latch_db: debounce 
        generic map ( wait_time => debounce_wait,
                      clock_period => clock_period )
        port map ( I => latch,
                   O => db_latch,
                   clock => clock, 
                   reset => reset );
    func_sel_up_db: debounce 
        generic map ( wait_time => debounce_wait,
                      clock_period => clock_period )
        port map ( I => func_sel_up,
                   O => db_func_sel_up,
                   clock => clock, 
                   reset => reset );
    func_sel_down_db: debounce 
        generic map ( wait_time => debounce_wait,
                      clock_period => clock_period )
        port map ( I => func_sel_down,
                   O => db_func_sel_down,
                   clock => clock, 
                   reset => reset );
    ALU_u1: ALU  
        port map ( A => A,
                   B => B,
                   control => selected_func,
                   latch => db_latch,
                   Y => Y, 
                   carry => carry,
                   clock => clock,
                   reset => reset );
    sevseg_output: sevseg_controller 
        port map ( I(15 DOWNTO 9) => 7UX"0", -- last digit not needed / third digit only needs 1 bit
                   I(8) => carry, -- third digit is carry
                   I(7 DOWNTO 0) => Y, -- first and second digits are output in hexadecimal
                   anodes => sevseg_anodes,
                   segments => sevseg_segments,
                   clock => clock,
                   reset => reset );
    process(clock)  
    begin
        if rising_edge(clock) then
            if reset = '1' then -- synchronous reset   
                selected_func <= X"0";
                prev_func_sel_up <= '0';
                prev_func_sel_down <= '0';        
            else
                if db_func_sel_up = '1' and prev_func_sel_up = '0' then -- rising edge
                    selected_func <= STD_LOGIC_VECTOR(unsigned(selected_func) + 1);
                    -- increment selected_func
                elsif db_func_sel_down = '1' and prev_func_sel_down = '0' then -- rising edge
                    selected_func <= STD_LOGIC_VECTOR(unsigned(selected_func) - 1);  
                    -- decrement selected_func  
                end if;
                prev_func_sel_up <= db_func_sel_up;
                prev_func_sel_down <= db_func_sel_down;
                -- used to detect rising edge
            end if;
        end if;
    end process;
end Behavioral;
