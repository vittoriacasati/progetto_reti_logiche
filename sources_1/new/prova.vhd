library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SECOND_ORDER_EXPONENTIAL_FILTER1 is
    generic (
            N : integer:=32
        );
        
    Port ( 
        X       :      in  std_logic_vector (N-1 downto 0);
        Y_OUT   :      out std_logic_vector (N-1 downto 0);
        CLK     :      in  std_logic;
        RST     :      in  std_logic;
        K       :      in  std_logic_vector (2 downto 0)
    
    );
end SECOND_ORDER_EXPONENTIAL_FILTER1;

architecture STRUCT of SECOND_ORDER_EXPONENTIAL_FILTER1 is


-------------------COMPONENTS-------------------------------
component MUX2_1 is
    
    generic (
            N : integer 
        );
        

   port(    
            IN_1:       in  std_logic_vector (N-1 downto 0);
            IN_2:       in  std_logic_vector (N-1 downto 0);
            VAL_OUT:    out std_logic_vector (N-1 downto 0);
            SEL:        in  std_logic
    );
    
end component;


component RCA is
    
    generic (
        N : integer
    );
    
    Port (
            A:          in std_logic_vector     (N-1 downto 0); --msb al posto 3. segnali a 4 bit
            B:          in std_logic_vector     (N-1 downto 0);
            CARRY_IN:   in std_logic;
            SUM:        out std_logic_vector    (N-1 downto 0);
            CARRY_OUT:  out std_logic
          );
end component;

component SHIFTER is
    Port (
        TO_SHIFT      : in  STD_LOGIC_VECTOR    (31 downto 0); --pre-shift value
        K             : in  STD_LOGIC_VECTOR    (3 downto 0); --k (from 0 to 15)
        SHIFTED       : out STD_LOGIC_VECTOR    (31 downto 0) --shifetd value
    );
end component;


component REG_PP_32_BIT is

    generic (
            N : integer
        );
        
    Port ( 
        SIGNAL_IN:  in      std_logic_vector (N-1 downto 0);
        SIGNAL_OUT: out     std_logic_vector (N-1 downto 0);
        CLK:        in      std_logic;
        RST:        in      std_logic
    );
end component;
---------------------------------------------------------------------------

--------------------------SIGNALS---------------------------------------------------------

--input value signals 
signal REG_X    :   std_logic_vector    (N-1 downto 0)  ;
signal REG_Y_1  :   std_logic_vector    (N-1 downto 0)  ;
signal REG_Y_2  :   std_logic_vector    (N-1 downto 0)  ;
signal REG_K    :   std_logic_vector    (2 downto 0)    ;

--all values that the shift might have
signal SHIFT_K          : std_logic_vector  (3 downto 0); --4 bit rappresentation here chosen to allow the shifter to have a single input interface
signal SHIFT_2K         : std_logic_vector  (3 downto 0);
signal SHIFT_K_MINUS_1  : std_logic_vector  (3 downto 0);

--signal to check if k is zero (edge case of X=Y)
signal K_IS_ZERO    :   std_logic;

--0 level of operation in the tree (32 bit, uscita diretta dagli shifter)
signal S1       : std_logic_vector (N-1 downto 0); --X*alpha
signal S2       : std_logic_vector (N-1 downto 0); --Y_t-1*alpha
signal S3       : std_logic_vector (N-1 downto 0); --Y_t-1*alpha^2
signal NOT_S3   : std_logic_vector (N-1 downto 0);
signal S4       : std_logic_vector (N-1 downto 0); --Y_t-2
signal S5       : std_logic_vector (N-1 downto 0); --Y_t-2*alpha^2
signal S6       : std_logic_vector (N-1 downto 0); --Y_t-2*2*alpha
signal NOT_S6   : std_logic_vector (N-1 downto 0);

--versioni estese a 33 bit (guard bit) degli operandi di livello 0, pronte per il livello 1
signal S1_EXT       : std_logic_vector (N downto 0); --33 bit
signal S2_EXT       : std_logic_vector (N downto 0);
signal S4_EXT       : std_logic_vector (N downto 0);
signal NOT_S3_EXT   : std_logic_vector (N downto 0);
signal S5_EXT       : std_logic_vector (N downto 0);
signal NOT_S6_EXT   : std_logic_vector (N downto 0);

--1ST level of operation in the tree (ora a 33 bit, N downto 0)
signal S1_S2: std_logic_vector (N downto 0); --signals summed
signal S3_S4: std_logic_vector (N downto 0); 
signal S5_S6: std_logic_vector (N downto 0); 

--versioni estese a 34 bit degli operandi di livello 1, pronte per il livello 2
signal S1_S2_EXT : std_logic_vector (N+1 downto 0); --34 bit
signal S3_S4_EXT : std_logic_vector (N+1 downto 0);

--2ND level of operation in the tree (ora a 34 bit, N+1 downto 0)
signal S1_S2_S3_S4: std_logic_vector (N+1 downto 0); --signals summed

--versioni estese a 35 bit per il livello 3
--S1_S2_S3_S4 è già a 34 bit: serve 1 solo bit di estensione
--S5_S6 è ancora a 33 bit: servono 2 bit di estensione
signal S1234_EXT : std_logic_vector (N+2 downto 0); --35 bit
signal S56_EXT    : std_logic_vector (N+2 downto 0); --35 bit

--3RD level of operation in the tree (ora a 35 bit, N+2 downto 0)
signal S_ALL: std_logic_vector (N+2 downto 0); --end result esteso

--versione troncata a 32 bit, pronta per il mux/registro
signal S_ALL_TRUNC: std_logic_vector (N-1 downto 0);

--once the current Y value is calculated it is transferred to the register and becomes Y_t-1
--this specific signal is also the one that brings y1 to y2 register through a diramation
signal Yt_TO_REG: std_logic_vector (N-1 downto 0);

-------------------------------------------------------------------------------------------------

begin

----------------------------------REGISTERS----------------------------------------
INST_REG_X: REG_PP_32_BIT
    generic map(N)
    port map(
        X,
        REG_X,
        CLK,
        RST
    );
    
INST_REG_Y1: REG_PP_32_BIT
    generic map(N)
    port map(
        Yt_TO_REG,
        REG_Y_1,
        CLK,
        RST
    ); 

INST_REG_Y2: REG_PP_32_BIT
    generic map(N)
    port map(
        REG_Y_1,
        REG_Y_2,
        CLK,
        RST
    );   

INST_REG_K: REG_PP_32_BIT
    generic map(3)
    port map(
        K,
        REG_K,
        CLK,
        RST
    );

--at the end of the clock, the result is already in the register
Y_OUT  <=   REG_Y_1;

--------------------------SHIFTED SIGNALS------------------------------------
--checks if k == 0
--checks register and not k input because this module doesn't account 
--for the case where the k value is suddently changed during execution.
K_IS_ZERO <= '1' when REG_K = "000" else '0';

SHIFT_K <= '0' & REG_K; --need to have signals on 4 bit
SHIFT_2K <= REG_K & '0';

with REG_K select
        SHIFT_K_MINUS_1 <= "0000" when  "001", 
                           "0001" when  "010", 
                           "0010" when  "011", 
                           "0011" when  "100", 
                           "0100" when  "101", 
                           "0101" when  "110", 
                           "0110" when  "111", 
                           "0000" when  others; --default

------------------------SHIFTER INSTANCES--------------------------------
SHIFTER1: SHIFTER port map(
    REG_X,
    SHIFT_K,
    S1
);
SHIFTER2: SHIFTER port map(
    REG_Y_1,
    SHIFT_K,
    S2
);
SHIFTER3: SHIFTER port map(
    REG_Y_1,
    SHIFT_2K,
    S3
);

S4 <= REG_Y_2;

SHIFTER5: SHIFTER port map(
    REG_Y_2,
    SHIFT_2K,
    S5
);
SHIFTER6: SHIFTER port map(
    REG_Y_2,
    SHIFT_K_MINUS_1,
    S6
);

----------------------ADDEND TO REGISTER ASSOCIATION-----------------------------------------
---------------------------GUARD BIT: ESTENSIONE DI SEGNO A 33 BIT---------------------------
S1_EXT     <= S1(N-1) & S1;
S2_EXT     <= S2(N-1) & S2;
S4_EXT     <= S4(N-1) & S4;
NOT_S3     <= not(S3);
NOT_S3_EXT <= NOT_S3(N-1) & NOT_S3;
S5_EXT     <= S5(N-1) & S5;
NOT_S6     <= not(S6);
NOT_S6_EXT <= NOT_S6(N-1) & NOT_S6;

---------------------------1ST LEVEL (33 bit)---------------------------------------
ADDER1: RCA 
generic map(N+1)
port map(
    S1_EXT,
    S2_EXT,
    '0',
    S1_S2
);

SUBTRACTOR1: RCA 
generic map(N+1)
port map(
    S4_EXT,
    NOT_S3_EXT,
    '1',
    S3_S4
);

SUBTRACTOR2: RCA 
generic map(N+1)
port map(
    S5_EXT,
    NOT_S6_EXT,
    '1',
    S5_S6
);

---------------------------GUARD BIT: ESTENSIONE DI SEGNO A 34 BIT---------------------------
S1_S2_EXT <= S1_S2(N) & S1_S2;
S3_S4_EXT <= S3_S4(N) & S3_S4;

-----------------------------2ND LEVEL (34 bit)-------------------------------
ADDER2: RCA 
generic map(N+2)
port map(
    S1_S2_EXT,
    S3_S4_EXT,
    '0',
    S1_S2_S3_S4
);

---------------------------GUARD BIT: ESTENSIONE DI SEGNO A 35 BIT---------------------------
--S1_S2_S3_S4 è a 34 bit: serve 1 bit di estensione
S1234_EXT <= S1_S2_S3_S4(N+1) & S1_S2_S3_S4;
--S5_S6 è ancora a 33 bit: servono 2 bit di estensione
S56_EXT   <= (N+2 downto N+1 => S5_S6(N)) & S5_S6;

------------------------------3RD LEVEL (35 bit)-----------------------
ADDER3: RCA 
generic map(N+3)
port map(
    S1234_EXT,
    S56_EXT,
    '0',
    S_ALL
);

---------------------------TRONCAMENTO FINALE------------------------
--giustificato dalla proprietà di combinazione convessa dei coefficienti:
--il risultato vero è garantito rientrare in 32 bit
S_ALL_TRUNC <= S_ALL(N-1 downto 0);

---------------------------EDGE CASE K=0------------------------
--if k==0 then the result is Y_t=X_t

MUX_K0: MUX2_1 
generic map(N)
port map(
    S_ALL_TRUNC,
    REG_X,
    Yt_TO_REG,
    K_IS_ZERO
);

end STRUCT;