
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
	SIGNAL modCount14 : std_logic_vector(13 DOWNTO 0) := "00000000000000";
	SIGNAL modCount2 : std_logic_vector(1 DOWNTO 0) := "00";
	SIGNAL modEnable : std_logic := '0';
BEGIN
   
	-- Modulo-2**14-Zaehler als Prozess
	PROCESS(clk, rst)
	BEGIN
		-- check for reset
		IF rst = '1' THEN
			modCount14 <= "00000000000000";
		ELSIF rising_edge(clk) THEN
			-- check for overflow
			IF modCount14 = "11111111111111" THEN
				modCount14 <= (others => '0');
				-- on overflow set enable
				modEnable <= '1';
			ELSE
				modCount14 <= modCount14 + 1;
				-- unset enable 
				IF modEnable /= '0' THEN
					modEnable <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;


	-- Modulo-4-Zaehler als Prozess
	PROCESS(modEnable, rst)
	BEGIN
		IF rst = '1' THEN
			modCount2 <= "00";
		ELSIF rising_edge(modEnable) THEN
			IF modCount2 = "11" THEN
				modCount2 <= (OTHERS => '0');
			ELSE
				modCount2 <= modCount2 + 1;
			END IF;
		END IF;
	END PROCESS;

	-- 1-aus-4-Dekoder als selektierte Signalzuweisung


	-- 1-aus-4-Multiplexer als selektierte Signalzuweisung


	-- 7-aus-4-Dekoder als selektierte Signalzuweisung



	-- 1-aus-4-Multiplexer als selektierte Signalzuweisung


END struktur;
