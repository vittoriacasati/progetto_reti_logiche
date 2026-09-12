library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SECOND_ORDER_EXPONENTIAL_FILTER is
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
end SECOND_ORDER_EXPONENTIAL_FILTER;

architecture STRUCT of SECOND_ORDER_EXPONENTIAL_FILTER is


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
            A:          in std_logic_vector     (N-1 downto 0); 
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

--0 level of operation in the tree
signal S1       : std_logic_vector (N-1 downto 0); --X*alpha
signal S2       : std_logic_vector (N-1 downto 0); --Y_t-1*alpha
signal S3       : std_logic_vector (N-1 downto 0); --Y_t-1*alpha^2
signal NOT_S3   : std_logic_vector (N-1 downto 0);
signal S4       : std_logic_vector (N-1 downto 0); --Y_t-2
signal S5       : std_logic_vector (N-1 downto 0); --Y_t-2*alpha^2
signal S6       : std_logic_vector (N-1 downto 0); --Y_t-2*2*alpha
signal NOT_S6   : std_logic_vector (N-1 downto 0); 
--Those signals need to be extended to 33 bit to avoid possible overflows
signal S1_33, S2_33, S3_33, S4_33, NOT_S3_33, S5_33, S6_33, NOT_S6_33 : std_logic_vector(N downto 0);


--1ST level of operation in the tree
signal S1_S2: std_logic_vector (N downto 0); --signals summed
signal S3_S4: std_logic_vector (N downto 0); 
signal S5_S6: std_logic_vector (N downto 0); 

signal S1_S2_34, S3_S4_34: std_logic_vector (N+1 downto 0);
signal S5_S6_35          : std_logic_vector (N+2 downto 0);

--2ND level of operation in the tree
signal S1_S2_S3_S4      : std_logic_vector (N+1 downto 0); --signals summed
signal S1_S2_S3_S4_35   : std_logic_vector (N+2 downto 0);

--3RD level of operation in the tree
signal S_ALL    : std_logic_vector (N+2 downto 0); --end result
signal S_ALL_32 : std_logic_vector (N-1 downto 0); --end result in 32 bit

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
---------------------------1ST LEVEL---------------------------------------

--Firstly we define the extended shifted signals 
S1_33       <= S1(N-1) & S1         ;
S2_33       <= S2(N-1) & S2         ;
S4_33       <= S4(N-1) & S4;
S3_33 <= S3(N-1) & S3        ;
        
NOT_S3_33   <= not(S3_33)   ;
S5_33       <= S5(N-1) & S5         ;
S6_33 <= S6(N-1) & S6        ;

NOT_S6_33   <= not(S6_33)     ;

ADDER1: RCA 
generic map(N+1)
port map(
    S1_33,
    S2_33,
    '0',
    S1_S2
);

SUBTRACTOR1: RCA 
generic map(N+1)
port map(
    S4_33,
    NOT_S3_33,
    '1',
    S3_S4
);

SUBTRACTOR2: RCA 
generic map(N+1)
port map(
    S5_33,
    NOT_S6_33,
    '1',
    S5_S6
);

-----------------------------2ND LEVEL-------------------------------
S1_S2_34 <= S1_S2(N) & S1_S2;
S3_S4_34 <= S3_S4(N) & S3_S4;
S5_S6_35 <= S5_S6(N) & S5_S6(N) & S5_S6;

ADDER2: RCA 
generic map(N+2)
port map(
    S1_S2_34,
    S3_S4_34,
    '0',
    S1_S2_S3_S4
);
------------------------------3RD LEVEL-----------------------
S1_S2_S3_S4_35 <= S1_S2_S3_S4(N+1) & S1_S2_S3_S4;
ADDER3: RCA 
generic map(N+3)
port map(
    S1_S2_S3_S4_35,
    S5_S6_35,
    '0',
    S_ALL
);

--result gets truncated
S_ALL_32 <= S_ALL(31 downto 0);


---------------------------EDGE CASE K=0------------------------
--if k==0 then the result is Y_t=X_t

MUX_K0: MUX2_1 
generic map(N)
port map(
    S_ALL_32,
    REG_X,
    Yt_TO_REG,
    K_IS_ZERO
);

end STRUCT;
