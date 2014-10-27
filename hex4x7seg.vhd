
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
	SIGNAL currentData : std_logic_vector(3 DOWNTO 0);
BEGIN
   
	-- Modulo-2**14-counter is a frequence divider
	PROCESS(clk, rst)
	BEGIN
		-- check for reset
		IF rst = '1' THEN
			modCount14 <= "00000000000000";
			modEnable <= '0';
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

	-- modulo-4-counter
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

	-- 4-to-1-decoder selects which digit of hex4x7 should be changed 
	PROCESS(modCount2)
	BEGIN
		-- frequents all 'an' out ports
		an <= "1111"; -- default output value
		CASE modCount2 IS
			WHEN "00" => an(0) <= '0';
			WHEN "01" => an(1) <= '0';
			WHEN "10" => an(2) <= '0';
			WHEN "11" => an(3) <= '0';
			WHEN OTHERS => an <= "1111";
		END CASE;
	END PROCESS;

	-- 4-to-1-mux selects the input data that will be displayed at the
	-- current digit
    -- data content is
    -- {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0,
    --  SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0}
	PROCESS(modCount2, data)
	BEGIN
		CASE modCount2 IS
			WHEN "00" => currentData <= data(15 DOWNTO 12);
			WHEN "01" => currentData <= data(11 DOWNTO 8);
			WHEN "10" => currentData <= data(7 DOWNTO 4);
			WHEN OTHERS => currentData <= data(3 DOWNTO 0);
		END CASE;
	END PROCESS;

	-- 4-to-7-decoder calculates signals for segments from binary number
    -- segement content is
    -- {G, F, E, D, C, B, A}
    PROCESS(currentData)
    BEGIN
        CASE currentData IS
            WHEN "0000" => seg <= "1000000"; -- '0'
            WHEN "0001" => seg <= "1111001"; -- '1'
            WHEN "0010" => seg <= "0100100"; -- '2'
            WHEN "0011" => seg <= "0110000"; -- '3'
            WHEN "0100" => seg <= "0011001"; -- '4'
            WHEN "0101" => seg <= "0010010"; -- '5'
            WHEN "0110" => seg <= "0000010"; -- '6'
            WHEN "0111" => seg <= "1111000"; -- '7'
            WHEN "1000" => seg <= "0000000"; -- '8'
            WHEN "1001" => seg <= "0010000"; -- '9'
            --nothing is displayed when a number more than 9 is given as input.
            WHEN OTHERS => seg <="1111111";
        END CASE;
    END PROCESS;

	-- 1-aus-4-Multiplexer als selektierte Signalzuweisung


END struktur;
