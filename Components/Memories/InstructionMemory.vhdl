library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionMemory is
    generic (
        N : natural := 16; -- Número de bits para endereçamento
        M : natural := 16 -- Número de bits para dados
    );
    port (
        CLK  : in  std_logic;
        RD   : in  std_logic;
        ADDR : in  std_logic_vector(N-1 downto 0);
        DATA : out std_logic_vector(M-1 downto 0)
    );
end entity InstructionMemory;

architecture Behavioral of InstructionMemory is
    type MemoryArray is array ((2**N)-1 DOWNTO 0) of std_logic_vector(M-1 downto 0);
    constant Instructions : MemoryArray := (
		  0 => "0011000000000001",-- instrução 0 carragar A na posição 0000
		  1 => "0011000100000010",-- instrução 1 carregar B na posição 0000
		  2 => "0110000000010000", -- armazenamento indireto 
		  
        -- Adicione mais instruções conforme necessário.
        -- Aqui devemos fazer hard coded pra simular o código em assembly.
        others => (others => '0') -- Instruções restantes preenchidas com zeros
    );
    signal data_reg : std_logic_vector(M-1 downto 0);
begin
    process (CLK)
    begin
        if rising_edge(CLK) then
            if RD = '1' then
                data_reg <= Instructions(to_integer(unsigned(ADDR)));
            end if;
        end if;
    end process;

    DATA <= data_reg;
end architecture Behavioral;