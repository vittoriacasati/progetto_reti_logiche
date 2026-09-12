


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_REG_PP_32BIT is
--  Port ( );
end TB_REG_PP_32BIT;

architecture BEH of TB_REG_PP_32BIT is
component REG_PP_32_BIT is

    generic (
            N : integer := 4
        );
        
    Port ( 
        SIGNAL_IN:  in      std_logic_vector (N-1 downto 0);
        SIGNAL_OUT: out     std_logic_vector (N-1 downto 0);
        CLK:        in      std_logic;
        RST:        in      std_logic
    );
end component;

constant N : integer := 4; 

  signal      SIGNAL_IN:       std_logic_vector (N-1 downto 0);
  signal      SIGNAL_OUT:      std_logic_vector (N-1 downto 0);
  signal      CLK:             std_logic;
  signal      RST:             std_logic;

begin

    DUT: REG_PP_32_BIT port map(SIGNAL_IN, SIGNAL_OUT, CLK, RST);
   
    --clock with 40ns period
    CLK_GEN: process
        begin
         CLK <= '0';
         wait for 10ns;
         CLK<='1';
         wait for 10ns;  
       end process;
    
    
    
    GEN: process
        
        begin 
        
        SIGNAL_IN   <= "0000";    
        RST         <=  '0';   
        wait for 25ns;  
        
        SIGNAL_IN   <= "0001";     
        RST         <=  '0';   
        wait for 25ns;  
        
        SIGNAL_IN   <= "0001";   
        RST         <=  '1';   
        wait for 25ns;  
        
        SIGNAL_IN   <= "0010";   
        RST         <=  '0';   
        wait;
    
        
        
        end process;

end BEH;
