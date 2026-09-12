
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RCA is
    
    generic (
        N : integer 
    );
    
    Port (
            A:          in std_logic_vector     (N-1 downto 0);
            B:          in std_logic_vector     (N-1 downto 0);
            CARRY_IN:   in std_logic;
            SUM:        out std_logic_vector    (N-1 downto 0);
            CARRY_OUT:  out std_logic
          );
end RCA;

architecture STRUCT of RCA is
    component FA is
        Port (
            X:      in  std_logic;
            Y:      in  std_logic;
            CIN:    in  std_logic;
            S:      out std_logic;
            COUT:   out std_logic
          );
    end component;
    
    -- un RCA sono N FA collegati tra di loro tramite i segnali di uscita
    signal  CARRY_CHAIN: std_logic_vector (N downto 0);
   
begin
    
    CARRY_CHAIN(0) <= CARRY_IN;
    CARRY_OUT      <= CARRY_CHAIN(N);
    
    --32 istanze del full adder
    bit_adders: for i in 0 to N-1 generate
    FA_inst: FA port map (
        A(i),               --X
        B(i),               --Y
        CARRY_CHAIN(i),     --CIN
        SUM(i),             --S
        CARRY_CHAIN(i+1)    --COUT
    );
end generate bit_adders;   
end STRUCT;






