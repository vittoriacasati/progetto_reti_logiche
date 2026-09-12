


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity FA is
    Port (
        X:      in std_logic;
        Y:      in std_logic;
        CIN:    in std_logic;
        S:      out std_logic;
        COUT:   out std_logic
      );
end FA;

architecture RTL of FA is

begin

    S <= X xor Y xor CIN;
    COUT <= (X and Y) or (Y and CIN) or (X and CIN);

end RTL;
