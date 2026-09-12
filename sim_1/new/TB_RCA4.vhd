
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--TB nel nome sta per test bench
-- il tb è un componente di pura simulazione che non ha nè ingressi nè uscite
-- il tb genererà i segnali che andranno a finire nel componente sotto test

entity TB_RCA4 is
--  Port ( );
end TB_RCA4;

architecture BEH of TB_RCA4 is

   component RCA4 is
     Port (
            A:      in std_logic_vector (3 downto 0); --msb al posto 3. segnali a 4 bit
            B:      in std_logic_vector (3 downto 0);
            CARRY_IN:    in std_logic;
            SUM:      out std_logic_vector (3 downto 0);
            CARRY_OUT:   out std_logic
          );
   end component;
   
   --i segnali sono dichiarati con lo stesso nome delle porte di ingresso e uscita del componente sotto test,
   -- perchè sono segnali che andranno forzati sulle porte che si chiamano così
   signal A:           std_logic_vector (3 downto 0); 
   signal B:           std_logic_vector (3 downto 0);
   signal CARRY_IN:    std_logic;
   signal SUM:         std_logic_vector (3 downto 0);
   signal CARRY_OUT:   std_logic;

begin
    DUT: RCA4 port map( A, B, CARRY_IN, SUM, CARRY_OUT);
    
    GEN: process
    begin
        
        A        <= "0000";
        B        <= "0000";
        CARRY_IN <= '0';
        wait for 20ns;
        
        --somma 4+6
        A        <= "0100";
        B        <= "0110";
        CARRY_IN <= '0';
        wait for 20ns;
        
        --somma 4+6 con riporto 1
        A        <= "0100";
        B        <= "0110";
        CARRY_IN <= '1';
        wait for 20ns; --fa andare avanti la simulazione potenzialmente in loop
        
        --somma 12+8 (dovrebbe darmi carry_out 1)
        A        <= "1100";
        B        <= "1000";
        CARRY_IN <= '0';
        
        
        wait; --blocca la simuazione
        
        
    end process;

end BEH;
