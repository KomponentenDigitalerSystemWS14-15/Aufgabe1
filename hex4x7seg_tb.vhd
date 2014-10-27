LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY hex4x7seg_test IS
   -- empty
END hex4x7seg_test;

ARCHITECTURE test OF hex4x7seg_test IS
    CONSTANT RSTDEF: std_ulogic := '1';
    CONSTANT tpd: time := 20 ns; -- 1/50 MHz

    COMPONENT hex4x7seg IS
        GENERIC(RSTDEF:  std_logic);
        PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
             clk:   IN  std_logic;                       -- clock,           rising edge
             en:    IN  std_logic;                       -- enable,          active high
             swrst: IN  std_logic;                       -- software reset,  active RSTDEF
             data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
             dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
             an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
             dp:    OUT std_logic;                       -- decimal point output,                        active low
             seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
    END COMPONENT;

    SIGNAL rst: std_logic := RSTDEF;

    SIGNAL clk: std_logic := '0';
    SIGNAL hlt: std_logic := '0';

    SIGNAL data: std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dpin: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    
    SIGNAL an: std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL dp: std_logic := '0';
    SIGNAL seg: std_logic_vector(7 DOWNTO 1) := (OTHERS => '0');
   
BEGIN
   
    rst <= RSTDEF, NOT RSTDEF AFTER 5*tpd;
    clk <= clk WHEN hlt='1' ELSE '1' AFTER tpd/2 WHEN clk='0' ELSE '0' AFTER tpd/2;

    dpin <= "0011"; -- DP fuer DISP1 und DISP0
    data <= "10000001" & "10000001"; -- 8 fuer DISP3 und DISP1, 1 fuer DISP2 und DISP0
    
    u1: hex4x7seg
    GENERIC MAP(RSTDEF => RSTDEF)
    PORT MAP(rst   => rst,
             clk   => clk,
             en    => '1',
             swrst => NOT RSTDEF,
             data  => data,
             dpin  => dpin,
             an    => an,
             dp    => dp,
             seg   => seg);

END test;