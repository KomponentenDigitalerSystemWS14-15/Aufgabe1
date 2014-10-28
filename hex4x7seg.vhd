LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF:  std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        en:    IN  std_logic;                       -- enable,          active high
        swrst: IN  std_logic;                       -- software reset,  active RSTDEF
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      positiv logic
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        an:    OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable (anode control) signals,      active low
        dp:    OUT std_logic;                       -- 1 decimal point output,                      active low
        seg:   OUT std_logic_vector( 7 DOWNTO 1));  -- 7 FPGA connections to seven-segment display, active low
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS

    -- hier sind benutzerdefinierte Konstanten und Signale einzutragen

    -- Zaehler 1
    CONSTANT N1: natural := 2**14;
    SIGNAL cnt1: integer RANGE 0 TO N1-1;
    SIGNAL clk_mod: std_logic;

    -- Zaehler 2
    CONSTANT N2: natural := 4;
    SIGNAL enable_an: integer RANGE 0 TO N2-1 := 0;
    
    SIGNAL an_tmp: std_logic_vector(3 DOWNTO 0); -- active low
    SIGNAL seg_tmp: std_logic_vector(7 DOWNTO 1); -- active low
    SIGNAL dp_tmp: std_logic; -- active low
    
    SIGNAL sw_tmp: std_logic_vector(3 DOWNTO 0); -- active high
    
BEGIN

   -- Modulo-2**14-Zaehler als Prozess

    PROCESS (rst, clk) BEGIN
        IF rst = RSTDEF THEN
            cnt1 <= 0;
            clk_mod <= '0';
        ELSIF rising_edge(clk) THEN
            clk_mod <= '0';
            IF en = '1' THEN
                IF cnt1 = N1-1 THEN
                    cnt1 <= 0;
                    clk_mod <= '1';
                ELSE
                    cnt1 <= cnt1 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
   
   -- Modulo-4-Zaehler als Prozess

--  PROCESS (rst, clk_mod) BEGIN
--      IF rst = RSTDEF THEN
--          enable_an <= 0;
--      ELSIF rising_edge(clk_mod) THEN
--          IF enable_an = N2-1 THEN
--              enable_an <= 0;
--          ELSE
--              enable_an <= enable_an + 1;
--          END IF;
--      END IF;
--  END PROCESS;
    
    PROCESS (rst, clk, clk_mod) BEGIN
        IF rst = RSTDEF THEN
            enable_an <= 0;
        ELSIF rising_edge(clk) THEN
            IF clk_mod = '1' THEN
                IF enable_an = N2-1 THEN
                    enable_an <= 0;
                ELSE
                    enable_an <= enable_an + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

   -- 1-aus-4-Dekoder als selektierte Signalzuweisung

    WITH enable_an SELECT
        an_tmp <= "1110" WHEN 0,
                  "1101" WHEN 1,
                  "1011" WHEN 2,
                  "0111" WHEN 3;

    an <= an_tmp WHEN rst /= RSTDEF AND swrst /= RSTDEF ELSE (others => '1');

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung

    WITH enable_an SELECT
        sw_tmp <= data( 3 DOWNTO  0) WHEN 0, -- DISP0
                  data( 7 DOWNTO  4) WHEN 1, -- DISP1
                  data(11 DOWNTO  8) WHEN 2, -- DISP2
                  data(15 DOWNTO 12) WHEN 3; -- DISP3
   
   -- 7-aus-4-Dekoder als selektierte Signalzuweisung
   
    WITH sw_tmp SELECT
        seg_tmp <= "0000001" WHEN "0000",
                   "1001111" WHEN "0001",
                   "0010010" WHEN "0010",
                   "0000110" WHEN "0011",
                   "1001100" WHEN "0100",
                   "0100100" WHEN "0101",
                   "0100000" WHEN "0110",
                   "0001111" WHEN "0111",
                   "0000000" WHEN "1000",
                   "0000100" WHEN "1001",
                   "0001000" WHEN "1010",
                   "1100000" WHEN "1011",
                   "0110001" WHEN "1100",
                   "1000010" WHEN "1101",
                   "0110000" WHEN "1110",
                   "0111000" WHEN "1111",
                   "1111111" WHEN OTHERS;

    seg <= seg_tmp WHEN rst /= RSTDEF AND swrst /= RSTDEF ELSE (others => '1');

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung

    WITH enable_an SELECT
        dp_tmp <= NOT dpin(0) WHEN 0, -- DISP0
                  NOT dpin(1) WHEN 1, -- DISP1
                  NOT dpin(2) WHEN 2, -- DISP2
                  NOT dpin(3) WHEN 3; -- DISP3

    dp <= dp_tmp WHEN rst /= RSTDEF AND swrst /= RSTDEF ELSE '1';
                  
END struktur;