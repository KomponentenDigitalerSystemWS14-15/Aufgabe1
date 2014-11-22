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

    -- Zaehler 1
    CONSTANT N1 : natural := 14;
    SIGNAL cnt1 : std_logic_vector(N1-1 DOWNTO 0) := (others => '0');
    SIGNAL cnt_tmp : std_logic_vector(N1 DOWNTO 0) := (others => '0');
    SIGNAL cnt1_en : std_logic;
    
    -- Zaehler 2
    CONSTANT N2 : natural := 2;
    SIGNAL cnt2 : std_logic_vector(N2-1 DOWNTO 0) := (others => '0');
    
    SIGNAL sw_tmp : std_logic_vector(3 DOWNTO 0) := (others => '0'); -- active high
    
BEGIN

    -- Modulo 2**14 counter
    
    cnt1_en <= cnt_tmp(N1);
    cnt1 <= cnt_tmp(N1-1 DOWNTO 0);
    
    PROCESS (rst, clk)
    BEGIN
        IF rst = RSTDEF THEN
            cnt_tmp <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF swrst = RSTDEF THEN
                cnt_tmp <= (OTHERS => '0');
            ELSIF en = '1' THEN
                cnt_tmp <= '0' & cnt1 + 1;
            END IF;
        END IF;
    END PROCESS;
  
    -- Modulo 2**2 counter
    
    PROCESS (rst, clk) BEGIN
        IF rst = RSTDEF THEN
            cnt2 <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF swrst = RSTDEF THEN
                cnt2 <= (OTHERS => '0');
            ELSE
                IF cnt1_en = '1' THEN
                    cnt2 <= cnt2 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

   -- 1-aus-4-Dekoder als selektierte Signalzuweisung
   
    an <= to_stdlogicvector("1110" rol CONV_INTEGER(cnt2)) WHEN rst /= RSTDEF AND swrst /= RSTDEF ELSE (others => '1');

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung

    WITH cnt2 SELECT
        sw_tmp <= data( 3 DOWNTO  0) WHEN "00", -- DISP0
                  data( 7 DOWNTO  4) WHEN "01", -- DISP1
                  data(11 DOWNTO  8) WHEN "10", -- DISP2
                  data(15 DOWNTO 12) WHEN "11", -- DISP3
                  "1111" WHEN OTHERS;
   
   -- 7-aus-4-Dekoder als selektierte Signalzuweisung
   
    WITH sw_tmp SELECT
        seg <= "0000001" WHEN "0000",
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

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung
      
    dp <= NOT dpin(CONV_INTEGER(cnt2));

END struktur;