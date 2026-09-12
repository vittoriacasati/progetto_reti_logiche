library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_SECOND_ORDER_EXPONENTIAL_FILTER is
end TB_SECOND_ORDER_EXPONENTIAL_FILTER;

architecture BEH of TB_SECOND_ORDER_EXPONENTIAL_FILTER is

    component SECOND_ORDER_EXPONENTIAL_FILTER is
        generic ( N : integer := 32 );
        Port (
            X       : in  std_logic_vector(N-1 downto 0);
            Y_OUT   : out std_logic_vector(N-1 downto 0);
            CLK     : in  std_logic;
            RST     : in  std_logic;
            K       : in  std_logic_vector(2 downto 0)
        );
    end component;

    constant N          : integer := 32;
    constant CLK_PERIOD : time := 10 ns;

    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal x_tb   : std_logic_vector(N-1 downto 0) := (others => '0');
    signal k_tb   : std_logic_vector(2 downto 0)   := (others => '0');
    signal y_tb   : std_logic_vector(N-1 downto 0);

    -- costanti in Q16.16: 1.0 = 0x00010000
    constant ONE_Q16_16   : std_logic_vector(31 downto 0) := X"00010000";
    constant ZERO_Q16_16  : std_logic_vector(31 downto 0) := (others => '0');
    constant MINUS_ONE    : std_logic_vector(31 downto 0) := X"FFFF0000"; -- -1.0
    constant TWO_POINT_5  : std_logic_vector(31 downto 0) := X"00028000"; -- 2.5

    signal test_label : string(1 to 20) := "waiting...          "; -- solo per leggibilità in waveform, ignorabile

begin

    UUT: SECOND_ORDER_EXPONENTIAL_FILTER
        generic map ( N => N )
        port map (
            X     => x_tb,
            Y_OUT => y_tb,
            CLK   => clk_tb,
            RST   => rst_tb,
            K     => k_tb
        );

    clk_process: process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus: process
    begin
        report "=== RESET iniziale ===";
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;
      

        ---------------------------------------------------------------
        report "=== TEST 1: gradino costante, k=3 ===";
        ---------------------------------------------------------------
        k_tb <= "011";
        x_tb <= ONE_Q16_16;
        for i in 1 to 15 loop
            wait for CLK_PERIOD;
        end loop;

        ---------------------------------------------------------------
        report "=== TEST 2: impulso, k=2 ===";
        ---------------------------------------------------------------
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        k_tb <= "010";
        x_tb <= ONE_Q16_16;
        wait for CLK_PERIOD;
        x_tb <= ZERO_Q16_16;
        for i in 1 to 10 loop
            wait for CLK_PERIOD;
          
        end loop;

        ---------------------------------------------------------------
        report "=== TEST 3: caso limite k=0 (atteso Y=X) ===";
        ---------------------------------------------------------------
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        k_tb <= "000";
        x_tb <= TWO_POINT_5;
        for i in 1 to 5 loop
            wait for CLK_PERIOD;
          
        end loop;

        ---------------------------------------------------------------
        report "=== TEST 4: valore negativo, k=1 ===";
        ---------------------------------------------------------------
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        k_tb <= "001";
        x_tb <= MINUS_ONE;
        for i in 1 to 10 loop
            wait for CLK_PERIOD;
             
        end loop;

        ---------------------------------------------------------------
        report "=== TEST 5: k massimo (k=7), gradino ===";
        ---------------------------------------------------------------
        rst_tb <= '1';
        wait for CLK_PERIOD*2;
        rst_tb <= '0';
        wait for CLK_PERIOD;

        k_tb <= "111";
        x_tb <= ONE_Q16_16;
        for i in 1 to 15 loop
            wait for CLK_PERIOD;
                end loop;

        report "=== SIMULAZIONE COMPLETATA ===";
        wait;
    end process;

end BEH;