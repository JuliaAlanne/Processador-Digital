library verilog;
use verilog.vl_types.all;
entity altProcessor is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        exampleOut      : out    vl_logic_vector(15 downto 0);
        ex_RF_W_addr    : out    vl_logic_vector(3 downto 0);
        I_data          : out    vl_logic_vector(15 downto 0);
        I_addr          : out    vl_logic_vector(15 downto 0);
        I_rd            : out    vl_logic
    );
end altProcessor;
