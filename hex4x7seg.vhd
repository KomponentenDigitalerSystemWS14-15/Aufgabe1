
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

	CONSTANT N1: natural := 16384;
	SIGNAL cnt1: integer RANGE 0 TO N1-1;
	SIGNAL clk_mod1: std_logic;

	CONSTANT N2: natural := 4;
	SIGNAL cnt2: integer RANGE 0 TO N2-1;
	SIGNAL clk_mod2: std_logic;

BEGIN

   -- Modulo-2**14-Zaehler als Prozess

	PROCESS (rst, clk) BEGIN
		IF rst = RSTDEF THEN
			cnt1 <= 0;
			clk_mod1 <= '0';
		ELSIF rising_edge(clk) THEN
			clk_mod1 <= '0';
			IF en = '1' THEN
				IF cnt1 = N1-1 THEN
					cnt1 <= 0;
					clk_mod1 <= '1';
				ELSE
					cnt1 <= cnt1 + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;
   
   -- Modulo-4-Zaehler als Prozess

	PROCESS (rst, clk_mod1) BEGIN
		IF rst = RSTDEF THEN
			cnt2 <= 0;
			clk_mod2 <= '0';
		ELSIF rising_edge(clk_mod1) THEN
			clk_mod2 <= '0';
			IF en = '1' THEN
				IF cnt2 = N2-1 THEN
					cnt2 <= 0;
					clk_mod2 <= '1';
				ELSE
					cnt2 <= cnt2 + 1;
				END IF;
			END IF;
		END IF;
	END PROCESS;

   -- 1-aus-4-Dekoder als selektierte Signalzuweisung

	-- with sel select
	-- t <= "0010101" when "1010110",
	--	"0101011" when others;

   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung

   
   -- 7-aus-4-Dekoder als selektierte Signalzuweisung
   
   
   
   -- 1-aus-4-Multiplexer als selektierte Signalzuweisung


END struktur;