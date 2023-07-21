LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.utils.all;

ENTITY mux2x1comp1bit1 IS
PORT(
	I0, I1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	sel1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	S1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END;
ARCHITECTURE main OF mux2x1comp1bit1 IS

BEGIN
	with sel1 select 
		S1<= I0 when "0",
			 I1 when "1";

END ARCHITECTURE main;