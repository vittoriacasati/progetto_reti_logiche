library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MUX2_1 is
    
    generic (
            N : integer 
        );
        

   port(    
            IN_1:       in  std_logic_vector (N-1 downto 0);
            IN_2:       in  std_logic_vector (N-1 downto 0);
            VAL_OUT:    out std_logic_vector (N-1 downto 0);
            SEL:        in  std_logic
    );
    
end MUX2_1;

architecture STRUCT of MUX2_1 is

begin
        
    MUX_GEN: for i in 0 to N-1 generate
        VAL_OUT(i) <= (IN_1(i) and not(SEL)) or (IN_2(i) and SEL);
    end generate;


end STRUCT;
