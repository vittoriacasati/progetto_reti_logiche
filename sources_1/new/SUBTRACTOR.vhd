library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SUBTRACTOR is
    generic (
            N : integer := 32
        );
        
    Port (
            A:              in std_logic_vector     (N-1 downto 0); --msb al posto N-1
            B:              in std_logic_vector     (N-1 downto 0);
            DIFFERENCE:     out std_logic_vector    (N-1 downto 0);
            CARRY_OUT:      out std_logic
          );
end SUBTRACTOR;

architecture STRUCT of SUBTRACTOR is

    component  RCA is
    
    generic (
        N : integer := 32
    );
    
    Port (
            A:          in std_logic_vector     (N-1 downto 0); --msb al posto 3. segnali a 4 bit
            B:          in std_logic_vector     (N-1 downto 0);
            CARRY_IN:   in std_logic;
            SUM:        out std_logic_vector    (N-1 downto 0);
            CARRY_OUT:  out std_logic
          );
    end component ;
    signal NOT_B: std_logic_vector (N-1 downto 0);
begin
    
    NOT_B<=not(B);
    
    RCA_inst: RCA port map(
        A,
        NOT_B,
        '1',
        DIFFERENCE,
        CARRY_OUT
    
    );




end STRUCT;
