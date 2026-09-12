

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TB_FA is
end TB_FA;

architecture BEH of TB_FA is


    component FA is
        Port (
            X:      in std_logic;
            Y:      in std_logic;
            CIN:    in std_logic;
            S:      out std_logic;
            COUT:   out std_logic
          );
    end component;
    
    signal X:       std_logic;
    signal Y:       std_logic;
    signal CIN:     std_logic;
    signal S:       std_logic;
    signal COUT:    std_logic;
    
    signal T:       std_logic_vector (2 downto 0);
    
    signal CLK:     std_logic ;

begin
    DUT: FA port map(X, Y, CIN, S, COUT);
    --ci sono 3 ingressi da un bit quindi 8 casi, li provo tutti usando il segnale T
    
    X   <= T(2);
    Y   <= T(1);
    CIN <= T(0);
    
    --clock con 20ns di periodo
    CLK_GEN: process
    begin
       CLK <= '0';
       wait for 10ns;
       CLK <= '1';
       wait for 10ns; 
    end process;
   
    GEN: process
    begin
        T <= "000"; wait for 10 ns;
        T <= "001"; wait for 10 ns;
        T <= "010"; wait for 10 ns;
        T <= "011"; wait for 10 ns;
        T <= "100"; wait for 10 ns;
        T <= "101"; wait for 10 ns;
        T <= "110"; wait for 10 ns;
        T <= "111"; wait;
    end process;



end BEH;
