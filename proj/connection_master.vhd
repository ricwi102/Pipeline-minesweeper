library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity connection_master is
  port( clk, rst	: std_logic


	);
end connection_master;



architecture Behavioral of connection_master is

component connection_IR_logic 
  port (
    clk         : in std_logic;
    rst         : in std_logic;

    IR1_o       : out std_logic_vector(31 downto 0);
    IR2_o       : out std_logic_vector(31 downto 0);
    IR3_o       : out std_logic_vector(31 downto 0);
    IR4_o       : out std_logic_vector(31 downto 0);

    ALU_A_out   : out std_logic_vector(31 downto 0);  
    ALU_B_out   : out std_logic_vector(31 downto 0);

    
    A2_in 	: in std_logic_vector(31 downto 0);
    B2_in 	: in std_logic_vector(31 downto 0);
    D3_in 	: in std_logic_vector(31 downto 0);
    D4_Z4_in 	: in std_logic_vector(31 downto 0);

    z_flag	: in std_logic
    );  
end component;



component connection_reg_mux
   port( clk, rst	: in std_logic;

	 IR1_in		: in std_logic_vector(31 downto 0);
	 IR2_in		: in std_logic_vector(31 downto 0);
	 IR3_in		: in std_logic_vector(31 downto 0);
	 IR4_in		: in std_logic_vector(31 downto 0);

	 B2_mux		: in std_logic_vector(31 downto 0);
	 A2_mux		: in std_logic_vector(31 downto 0);
	 A2, B2		: out std_logic_vector(31 downto 0);
	 D4_Z4_data	: out std_logic_vector(31 downto 0)

	);
end component



signal IR1_internal : std_logic_vector(31 downto 0);
signal IR2_internal : std_logic_vector(31 downto 0);
signal IR3_internal : std_logic_vector(31 downto 0);
signal IR4_internal : std_logic_vector(31 downto 0);

signal ALU_A, ALU_B : std_logic_vector(31 downto 0);


signal A2, B2, D3, D4_Z4 : std_logic_vector(31 downto 0); 




begin



U0 : connection_IR_logic port map(clk => clk, rst => rst,
		  		  IR1_o => IR1_internal, IR2_o => IR2_internal,
				  IR3_o => IR3_internal, IR4_o => IR4_internal,
				  ALU_A_out => ALU_A, ALU_B_out => ALU_B,				  
				  A2_in => A2, B2_in => B2, D3_in => D3, D4_Z4_in => D4_Z4,
				  z_flag => );	


U1 : connection_IR_logic port map(clk => clk, rst => rst,
		  		  IR1_in => IR1_internal, IR2_in => IR2_internal,
				  IR3_in => IR3_internal, IR4_in => IR4_internal,
				  A2_mux => ALU_A, B2_mux => ALU_B, A2 => A2, B2 => B2,				  
				  D4_Z4_data => D4_Z4,
				  z_flag => );	

	




end Behavorial;






