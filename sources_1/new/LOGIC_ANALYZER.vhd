library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity REG_PP_32_BIT is

    generic (
            N : integer:=32
        );
        
    Port ( 
        SIGNAL_IN:  in      std_logic_vector (N-1 downto 0);
        SIGNAL_OUT: out     std_logic_vector (N-1 downto 0);
        CLK:        in      std_logic;
        RST:        in      std_logic
    );
end REG_PP_32_BIT;

architecture STRUCT of REG_PP_32_BIT is

begin

    reg: process(CLK)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    SIGNAL_OUT <= (others => '0');
                else
                    SIGNAL_OUT <= SIGNAL_IN;
                end if;
            end if;
    end process;
end STRUCT;
