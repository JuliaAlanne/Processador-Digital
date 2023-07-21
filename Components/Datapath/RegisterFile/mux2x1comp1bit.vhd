LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY mux2x1comp1bit IS
PORT(
	I20,I21 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	sel2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	S2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END;
ARCHITECTURE main OF mux2x1comp1bit IS

BEGIN
	with sel2 select 
		S2<= I20 when "0",
			  I21 when "1";

END ARCHITECTURE main;