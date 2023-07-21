LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.utils.all;
--needed the proprietary quartus ii emulation software for emulation
ENTITY DataPath IS
GENERIC(
	M_addrSIZE : INTEGER := SSIZE;
	regSIZE : INTEGER := BSIZE;
	UNSIGNopt : BOOLEAN := false
);
PORT(
	--Rd_data is the read data from the D memory;
	--'Wen' stands for write enable, 'Ren' for Read enable;
	--W_data is the write output to the D memory;
	--keep in mind that RF_gt only makes sense for JGT
	RF_Wdata, Rd_data : IN STD_LOGIC_VECTOR(regSIZE-1 DOWNTO 0);
	RF_Sel, ALU_Sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	D_sel:IN STD_LOGIC;
	RF_Waddr, RF_RPaddr, RF_RQaddr : IN STD_LOGIC_VECTOR (M_addrSIZE-1 DOWNTO 0);
	D_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	RF_Wen, RF_RenP, RF_RenQ: IN STD_LOGIC;
	clk, wr, rd :IN STD_LOGIC;
	W_data : OUT STD_LOGIC_VECTOR (regSIZE-1 DOWNTO 0);
	RF_RP_zero, RF_gt : OUT STD_LOGIC
	);
END;

ARCHITECTURE main OF DataPath IS
COMPONENT regNbit IS
	GENERIC(
		SIZE : INTEGER := 4
	);
	PORT(
		I : IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
		clk, ld, clear : IN STD_LOGIC;
		S : OUT STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT muxKx1comp1bit IS
	GENERIC(
		SSIZE : INTEGER := 2
	);
	PORT(
		I : vecArray((2**SSIZE)-1 DOWNTO 0);
		sel : IN STD_LOGIC_VECTOR(SSIZE-1 DOWNTO 0);
		S : OUT STD_LOGIC_VECTOR(BSIZE-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x1comp1bit IS
	PORT(
		I20,I21 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		sel2 : IN STD_LOGIC;
		S2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2x1comp1bit1 IS
	PORT(
	I0,I1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	sel1 : IN STD_LOGIC;
	S1: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

COMPONENT RegisterFile IS
GENERIC(
	M_addrSIZE : INTEGER := SSIZE;
	regSIZE : INTEGER := BSIZE
);
PORT(
	Wdata : IN STD_LOGIC_VECTOR(regSIZE-1 DOWNTO 0);
	Waddr, RPaddr, RQaddr : IN STD_LOGIC_VECTOR (M_addrSIZE-1 DOWNTO 0);
	Wen, RenP, RenQ, clk : IN STD_LOGIC;
	RPdata, RQdata : OUT STD_LOGIC_VECTOR(regSIZE-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT compNbit IS
GENERIC(
	SIZE : INTEGER := 4;
	UNSIGNopt : BOOLEAN := false
);
PORT(
  A, B : in std_logic_vector(SIZE-1 DOWNTO 0);
  --in_lt, in_eq, in_gt : in std_logic; in case you ever want to use it for some reason
  s_lt, s_eq, s_gt    : out std_logic
);
END COMPONENT;

COMPONENT ALU IS
GENERIC(
	SIZE : INTEGER := 8;
	UNSIGNopt : BOOLEAN := false
);
PORT(
	A, B : in std_logic_vector(SIZE-1 DOWNTO 0);
	x, y : in std_logic;
   S : out std_logic_vector(SIZE-1 DOWNTO 0);
	gt, eq : out std_logic
);
END COMPONENT;
COMPONENT RAM IS
GENERIC(
        N : natural := 8; -- Número  bits para endereçamento
        M : natural := 16 -- Número de bits para dados
    );
PORT (
    CLK     : in  std_logic;
    ADDR    : in  std_logic_vector(N-1 downto 0);
    RD      : in  std_logic;
    WR      : in  std_logic;
    W_DATA  : in  std_logic_vector(M-1 downto 0);
    R_DATA  : out std_logic_vector(M-1 downto 0)
    );
END COMPONENT;

SIGNAL RF_inputs : vecArray(3 DOWNTO 0);
SIGNAL D1_inputs : vecArray(7 DOWNTO 0);
SIGNAL D2_inputs : vecArray(15 DOWNTO 0);

SIGNAL regLoad : STD_LOGIC_VECTOR((2**M_addrSIZE)-1 DOWNTO 0);
SIGNAL muxOut,muxOut1, ALU_out, RF_Pout, RF_Qout, r_data : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL RF_Pout07,muxOut8B: STD_LOGIC_VECTOR(regSIZE-9 DOWNTO 0);
BEGIN
	RF_inputs(0) <= ALU_out;
	RF_inputs(1) <= Rd_data;
	RF_inputs(2) <= RF_Wdata;
	RF_inputs(3) <= (others => '0');
	rf_mux : muxKx1comp1bit PORT MAP (I => RF_inputs, sel => RF_Sel, S => muxOut);
	D_mux2 : mux2x1comp1bit PORT MAP (I20 =>RF_Pout,I21=> RF_Qout, sel2 => D_Sel, S2 => muxOut1);
	D_mux1 : mux2x1comp1bit1 PORT MAP (I0 => D_addr,I1=> RF_Pout07, sel1 =>D_Sel, S1 => muxOut8B);
	DRAM : RAM PORT MAP (CLK=> clk ,ADDR=> muxOut8B,RD=>rd, WR=>wr , W_DATA=> muxOut1, R_DATA=>r_data);
	RF : RegisterFile PORT MAP (Wdata => muxOut, Waddr => RF_Waddr, RPaddr => RF_RPaddr, RQaddr => RF_RQaddr, Wen => RF_Wen,
		RenP => RF_RenP, RenQ => RF_RenQ, clk => clk, RPdata => RF_Pout, RQdata => RF_Qout);
	ALUport : ALU GENERIC MAP (SIZE => regSIZE) PORT MAP (A => RF_Pout, B => RF_Qout, x => ALU_Sel(1), y => ALU_Sel(0),
		S => ALU_out, gt => RF_gt);
	W_data <= RF_Pout;
	
	--overkill but there's a comparator already anyway
	compz : compNbit GENERIC MAP (SIZE => regSIZE) PORT MAP (A => RF_Pout, B => (others => '0'), s_eq => RF_RP_zero);
		
END;