library ieee;
USE ieee.std_logic_1164.all ;

ENTITY abext IS
PORT(
  a, b, x, y : in std_logic;
  sa, sb    : out std_logic
);
END abext;

ARCHITECTURE main of abext is
BEGIN
	sa <= a AND (x NAND y);
	sb <= (NOT y) AND ( x XOR b);
END main;