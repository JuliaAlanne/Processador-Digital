library verilog;
use verilog.vl_types.all;
entity altProcessor_vlg_check_tst is
    port(
        ex_RF_W_addr    : in     vl_logic_vector(3 downto 0);
        exampleOut      : in     vl_logic_vector(15 downto 0);
        I_addr          : in     vl_logic_vector(15 downto 0);
        I_data          : in     vl_logic_vector(15 downto 0);
        I_rd            : in     vl_logic;
        sampler_rx      : in     vl_logic
    );
end altProcessor_vlg_check_tst;
