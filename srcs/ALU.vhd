library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR(7 DOWNTO 0); -- operand 1
           B : in STD_LOGIC_VECTOR(7 DOWNTO 0); -- operand 2
           control : in STD_LOGIC_VECTOR(3 DOWNTO 0); -- operation
           latch : in STD_LOGIC; -- perform operation on rising edge
           Y : out STD_LOGIC_VECTOR(7 DOWNTO 0) := X"00"; -- result
           carry : buffer STD_LOGIC := '0'; -- carry or borrow for additon/subtraction
           clock: in STD_LOGIC; 
           reset : in STD_LOGIC );
end ALU;

architecture Behavioral of ALU is
    signal prev_latch : STD_LOGIC := '0';
    -- used to detect rising edge
begin
    process(clock)  
        variable result : STD_LOGIC_VECTOR(7 DOWNTO 0); 
    begin
        if rising_edge(clock) then
            if reset = '1' then -- synchronous reset
                Y <= X"00";
                carry <= '0';
                prev_latch <= '0';
            else
                if latch = '1' and prev_latch = '0' then -- rising edge
                    case control is
                        when X"0" => -- Add
                            result := STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
                            carry <= (A(7) and B(7)) or (A(7) and not result(7)) or (B(7) and not result(7));
                        when X"1" => -- Add with Carry
                            result := STD_LOGIC_VECTOR(unsigned(A) + unsigned(B));
                            if carry = '1' then
                                result := STD_LOGIC_VECTOR(unsigned(result) + 1);
                            end if;
                            carry <= (A(7) and B(7)) or (A(7) and not result(7)) or (B(7) and not result(7));                
                        when X"2" => -- Subtract
                            result := STD_LOGIC_VECTOR(unsigned(B) - unsigned(A));
                            carry <= (not B(7) and A(7)) or (A(7) and result(7)) or (not B(7) and result(7)); 
                        when X"3" => -- Subtract with Borrow
                            result := STD_LOGIC_VECTOR(unsigned(B) - unsigned(A));
                            if carry = '1' then
                                result := STD_LOGIC_VECTOR(unsigned(result) - 1);
                            end if;
                            carry <= (not B(7) and A(7)) or (A(7) and result(7)) or (not B(7) and result(7));  
                        when X"4" => -- NOT
                            result := not A;            
                        when X"5" => -- AND
                            result := A and B;
                        when X"6" => -- OR
                            result := A or B;    
                        when X"7" => -- XOR
                            result := A xor B;       
                        when X"8" => -- Increment
                            result := STD_LOGIC_VECTOR(unsigned(A) + 1); 
                        when X"9" => -- Decrement
                            result := STD_LOGIC_VECTOR(unsigned(A) - 1);      
                        when X"A" => -- Rotate Left
                            result := A(6 DOWNTO 0) & A(7);   
                        when X"B" => -- Rotate Right
                            result := A(0) & A(7 DOWNTO 1);     
                        when others => -- Pass Through
                            result := A;
                    end case;
                    Y <= result;   
                end if;
                prev_latch <= latch;
                -- used to detect rising edge
            end if;
        end if;
    end process;
end Behavioral;
