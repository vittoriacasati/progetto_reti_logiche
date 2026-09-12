library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SHIFTER is
    Port (
        TO_SHIFT    : in  STD_LOGIC_VECTOR(31 downto 0); --pre-shift value
        K           : in  STD_LOGIC_VECTOR(3 downto 0); --k (from 0 to 15)
        SHIFTED     : out STD_LOGIC_VECTOR(31 downto 0) --shifetd value
    );
end SHIFTER;

architecture STRUCT of SHIFTER is
    signal S : STD_LOGIC; -- sign bit for arithmetic shift
begin
    S <= TO_SHIFT(31);

    with K select
        SHIFTED <= 
            TO_SHIFT                                                        when "0000", -- shift 0
            (31 => S) & TO_SHIFT(31 downto 1)                               when "0001", -- shift 1
            (31 downto 30 => S) & TO_SHIFT(31 downto 2)                     when "0010", -- shift 2
            (31 downto 29 => S) & TO_SHIFT(31 downto 3)                     when "0011", -- shift 3
            (31 downto 28 => S) & TO_SHIFT(31 downto 4)                     when "0100", -- shift 4
            (31 downto 27 => S) & TO_SHIFT(31 downto 5)                     when "0101", -- shift 5
            (31 downto 26 => S) & TO_SHIFT(31 downto 6)                     when "0110", -- shift 6
            (31 downto 25 => S) & TO_SHIFT(31 downto 7)                     when "0111", -- shift 7
            (31 downto 24 => S) & TO_SHIFT(31 downto 8)                     when "1000", -- shift 8
            (31 downto 23 => S) & TO_SHIFT(31 downto 9)                     when "1001", -- shift 9
            (31 downto 22 => S) & TO_SHIFT(31 downto 10)                    when "1010", -- shift 10
            (31 downto 21 => S) & TO_SHIFT(31 downto 11)                    when "1011", -- shift 11
            (31 downto 20 => S) & TO_SHIFT(31 downto 12)                    when "1100", -- shift 12
            (31 downto 19 => S) & TO_SHIFT(31 downto 13)                    when "1101", -- shift 13
            (31 downto 18 => S) & TO_SHIFT(31 downto 14)                    when "1110", -- shift 14
            (others => S)                                                  when others; -- shift >= 15
end STRUCT;
