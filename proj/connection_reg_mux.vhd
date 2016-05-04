library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity connection_reg_mux is
   port( clk, rst	: in std_logic;				--System clock and system reset.
	 IR1_in		: in std_logic_vector(31 downto 0);	--External IR1 input.
	 IR2_in		: in std_logic_vector(31 downto 0);	--External IR2 input.
	 IR3_in		: in std_logic_vector(31 downto 0);	--External IR3 input.
	 IR4_in		: in std_logic_vector(31 downto 0);	--External IR4 input.

	 B2_mux		: in std_logic_vector(31 downto 0);	--
	 A2_mux		: in std_logic_vector(31 downto 0);	--	
	 A2, B2		: out std_logic_vector(31 downto 0);	--A2 and B2 registers.
	 D3		: out std_logic_vector(31 downto 0);
	 D4_Z4_data	: out std_logic_vector(31 downto 0);	--Either D4 or Z4, the mux chooses.

	 z_flag 	: out std_logic

	);
end connection_reg_mux;



architecture Behavioral of connection_reg_mux is

component Regs is
  port (
    clk, rst 			 : in std_logic;
    w_enable 			 : in std_logic; 
    out1, out2 			 : out std_logic_vector (31 downto 0);
    write_in 			 : in std_logic_vector (31 downto 0);      
    read_address1, read_address2 : in std_logic_vector (4 downto 0);
    write_address 		 : in std_logic_vector (4 downto 0)
    );
end component;


component ALU_mux is
  port (
    clk,rst    : in std_logic;
    reg        : in std_logic_vector(31 downto 0);
    IR1        : in std_logic_vector(31 downto 0);
    IR2        : in std_logic_vector(31 downto 0);
    output     : out std_logic_vector(31 downto 0)
    );
end component;


component register_mux is
  port (D4      : in std_logic_vector (31 downto 0);
        Z4      : in std_logic_vector (31 downto 0);
        IR4     : in std_logic_vector (31 downto 0);
        we      : out std_logic;
        data    : out std_logic_vector (31 downto 0);
        adr     : out std_logic_vector (4 downto 0)
        );
end component;

component ALU is
  port (clk 	: in std_logic;
    	input1 	: in std_logic_vector (31 downto 0);
    	input2 	: in std_logic_vector (31 downto 0);
    	op_ctrl : in std_logic_vector (5 downto 0);
	z_flag_out 		: out std_logic;
    	output 	: out std_logic_vector (31 downto 0)  	        -- Gives D3 its value.
	);
end component;

component data_minne is
  port (clk 	: in std_logic;
       	adr 	: in std_logic_vector(8 downto 0); 	    	--Uses the D3 value for adresing.
	IR3_in	: in std_logic_vector(31 downto 0);
        data_in : in std_logic_vector(31 downto 0);     	--Takes its value from "Z3" (B2 MUX)
        data_out : out std_logic_vector(31 downto 0)		--Gives Z4 its value.
	);
end component;

signal write_data 	: std_logic_vector (31 downto 0) := (others => '0');
signal we_internal	: std_logic := '0';
signal ALU_mux_out	: std_logic_vector (31 downto 0) := (others => '0');
signal D3_int,D4_int	: std_logic_vector (31 downto 0) := (others => '0');
signal Z4_int		: std_logic_vector (31 downto 0) := (others => '0');
signal adr_internal 	: std_logic_vector (4 downto 0) := (others => '0');
signal DM_adr 		: std_logic_vector (8 downto 0) := (others => '0');

alias read_adr_int1	: std_logic_vector (4 downto 0) is IR1_in(20 downto 16);
alias read_adr_int2	: std_logic_vector (4 downto 0) is IR1_in(15 downto 11);
alias command		: std_logic_vector (5 downto 0) is IR2_in(31 downto 26);

begin

DM_adr <= D3_int(8 downto 0);

D4_Z4_data <= write_data;
D3 <= D3_int;

process(clk)
  begin 
    if(rising_edge(clk)) then
	D4_int <= D3_int;
    end if; 
end process;


---- PORT MAPS ----


U0 : Regs port map(clk => clk, rst => rst, w_enable => we_internal, 
		   out1 => A2 , out2 => B2 , write_in => write_data ,
		   read_address1 => read_adr_int1, read_address2 => read_adr_int2, write_address => adr_internal ); 

U1 : ALU_mux port map(clk => clk, rst => rst,
		      reg => B2_mux, IR1 => IR1_in , IR2 => IR2_in, output => ALU_mux_out);	



U2 : register_mux port map(D4 => D4_int, Z4 => Z4_int, IR4 => IR4_in,
			   we => we_internal, data => write_data , adr => adr_internal);

U3 : ALU port map(clk => clk, input1 => ALU_mux_out, input2 => A2_mux, op_ctrl => command, z_flag_out => z_flag , output => D3_int); 

U4 : data_minne port map(clk => clk, adr => DM_adr , data_in => B2_mux, data_out => Z4_int, IR3_in => IR3_in);


end Behavioral;
	

