library ieee;
USE ieee.std_logic_1164.all ;

ENTITY cinext IS
PORT(
  x, y : in std_logic;
  cin    : out std_logic
);
END cinext;

ARCHITECTURE main of cinext is
BEGIN
	cin <= x AND (NOT y);
END main;