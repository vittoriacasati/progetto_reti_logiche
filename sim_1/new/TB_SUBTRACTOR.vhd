library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_SUBTRACTOR is
--  Port ( );
end TB_SUBTRACTOR;

architecture BEH of TB_SUBTRACTOR is

    component SUBTRACTOR is
        generic (
                WIDTH : integer := 32
            );
            
        Port (
                A:              in std_logic_vector     (WIDTH-1 downto 0); --msb al posto WIDTH-1
                B:              in std_logic_vector     (WIDTH-1 downto 0);
                DIFFERENCE:     out std_logic_vector    (WIDTH-1 downto 0);
                CARRY_OUT:      out std_logic
              );
    end component;
    
    constant WIDTH : integer := 32; 
    
    signal A:               std_logic_vector (WIDTH-1 downto 0); 
    signal B:               std_logic_vector (WIDTH-1 downto 0);
    signal DIFFERENCE:      std_logic_vector (WIDTH-1 downto 0);
    signal CARRY_OUT:       std_logic;

begin

    DUT: SUBTRACTOR port map( A, B, DIFFERENCE, CARRY_OUT);
    
    GEN: process
    begin
        
        A        <= "0000";
        B        <= "0000";
        wait for 20ns;
        
        --4-6
        A        <= "0100";
        B        <= "0110";
        wait for 20ns;
        
        --6-2
        A        <= "0110";
        B        <= "0010";
        wait for 20ns; --fa andare avanti la simulazione potenzialmente in loop
        
        --somma 12-8 
        A        <= "1000";
        B        <= "0001";
        
        wait; --blocca la simuazione
        
        
    end process;


end BEH;
