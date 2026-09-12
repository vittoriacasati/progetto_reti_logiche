
library IEEE;

use IEEE.STD_LOGIC_1164.ALL;


entity TB_SECOND_ORDER_EXP_FILTER is

--  Port ( );

end TB_SECOND_ORDER_EXP_FILTER;
architecture BEH of TB_SECOND_ORDER_EXP_FILTER is

component SECOND_ORDER_EXPONENTIAL_FILTER is

    Port ( 

        X       : in  std_logic_vector (31 downto 0);
        Y_OUT   : out std_logic_vector (31 downto 0);
        CLK     : in  std_logic;
        RST     : in  std_logic;
        K       : in  std_logic_vector (2 downto 0)

    );

end component;

constant N : integer := 32; 

constant CLK_PERIOD : time := 20 ns;

    signal X     : std_logic_vector (N-1 downto 0);
    signal Y_OUT : std_logic_vector (N-1 downto 0);
    signal CLK   : std_logic;
    signal RST   : std_logic;
    signal K     : std_logic_vector (2 downto 0);

begin

    DUT: SECOND_ORDER_EXPONENTIAL_FILTER 
        
        port map (
            X     => X, 
            Y_OUT => Y_OUT, 
            CLK   => CLK, 
            RST   => RST, 
            K     => K
        );

    CLK_GEN: process

    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;

        CLK <= '1';
        wait for CLK_PERIOD/2;

    end process;

    GEN: process

    begin
       RST <= '1';
        K   <= "001";
        X   <= "00000000000000000000000000000000"; 

        wait until falling_edge(CLK);

        RST <= '0';
---------------------POS and NEG-----------------------------------------------------------------
        X   <= "00000000000000000000010000000000"; --1024
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';

        X   <= "11111111111111111111110000000000";  -- -1024 
        wait for 10*CLK_PERIOD;

        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';
        
---------------------MAX and MIN-----------------------------------------------------------------------------------
        X   <= "01111111111111111111111111111111"; --maximum value 
        wait for 30*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';
        

        X   <= "10000000000000000000000000000000"; --minimum value 
        wait for 20*CLK_PERIOD;

-----------------STEP SIGNAL-------------------------------------
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';
        
        X   <= "11111111111111111111110000000000";   -- -1024
        wait for 10*CLK_PERIOD;
        
        X   <= "00000000000000000000010000000000";   -- 1024
        wait for 20*CLK_PERIOD;
        
        X   <= "11111111111111111111110000000000";   -- -1024
        wait for 10*CLK_PERIOD;
----------CASE K=0--------------------------------------------
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';
        
        K<="000";
        
        X   <= "00000000000000000000000001000000"; --64
        wait for 10*CLK_PERIOD;
        
------------------DIFFERENT K VALUES------------------------
        
        K<="010"; --K=2
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0';      
        
        
        K<="011"; --K=3
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait until falling_edge(CLK);
        RST <= '0'; 
        
        K<="100"; --K=4
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait for 5*CLK_PERIOD;
        RST <= '0'; 
        
        K<="101"; --K=5
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait for 5*CLK_PERIOD;
        RST <= '0'; 
        
        K<="110"; --K=6
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait for 5*CLK_PERIOD;
        RST <= '0'; 
        
        K<="111"; --K=7
        
        X   <= "00000000000000000000010000000000";
        wait for 10*CLK_PERIOD;
        
        wait until falling_edge(CLK);
        RST <= '1';
        wait for 5*CLK_PERIOD;
        RST <= '0'; 
        
        
        
        wait;
        
        end process;
    end BEH;