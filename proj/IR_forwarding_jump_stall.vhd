library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity IR_and_forwarding_and_stall is
  port (
    clk         : in std_logic;
    rst         : in std_logic;

    IR1_o       : out std_logic_vector(31 downto 0);
    IR2_o       : out std_logic_vector(31 downto 0);
    IR3_o       : out std_logic_vector(31 downto 0);
    IR4_o       : out std_logic_vector(31 downto 0);

    ALU_A_out   : out std_logic_vector(31 downto 0);  
    ALU_B_out   : out std_logic_vector(31 downto 0);

    PM_in 	: in std_logic_vector(31 downto 0);
    A2_in 	: in std_logic_vector(31 downto 0);
    B2_in 	: in std_logic_vector(31 downto 0);
    D3_in 	: in std_logic_vector(31 downto 0);
    D4_Z4_in 	: in std_logic_vector(31 downto 0);

    z_flag	: in std_logic
    );
  
end IR_and_forwarding_and_stall;

architecture Behavioral of IR_and_forwarding_and_stall is

  --Ports from dataforwarding.
  component dataforwarding
    port ( 
         IR2_in_df      : in std_logic_vector(31 downto 0);
         IR3_in_df      : in std_logic_vector(31 downto 0);
         IR4_in_df      : in std_logic_vector(31 downto 0);

         A2_in          : in std_logic_vector(31 downto 0);
         D4_Z4_in       : in std_logic_vector(31 downto 0);
         D3_in          : in std_logic_vector(31 downto 0);
         B2_in          : in std_logic_vector(31 downto 0);
        
         ALU_A_out      : out std_logic_vector(31 downto 0);
         ALU_B_out      : out std_logic_vector(31 downto 0)
         );
  end component;

  --Ports from IR.
  component IR
  port ( clk, rst       : in std_logic;                         --System clock       

	 IR1_out        : out std_logic_vector(31 downto 0);   --Output
	 IR2_out        : out std_logic_vector(31 downto 0);   --Output
	 IR3_out        : out std_logic_vector(31 downto 0);   --Output
         IR4_out        : out std_logic_vector(31 downto 0);

	 IR1_in		: in std_logic_vector(31 downto 0);
	 IR2_in		: in std_logic_vector(31 downto 0)
         );   --Output
  end component;

  --Ports from jump_and_stall
  component jump_stall
  port ( clk,rst        	: in std_logic;

       	 IR1_in_js      	: in std_logic_vector(31 downto 0);
         IR2_in_js         	: in std_logic_vector(31 downto 0);
         IR1_out_js		: out std_logic_vector(31 downto 0);
         IR2_out_js    		: out std_logic_vector(31 downto 0);

         PC_out         	: out std_logic_vector(31 downto 0);
         PM_in          	: in std_logic_vector(31 downto 0);
         z_flag_in      	: in std_logic
        );
  end component;

  -- Interna
  signal IR1_value : std_logic_vector(31 downto 0); 	-- IR till JS
  signal IR2_value : std_logic_vector(31 downto 0); 	-- IR till JS och DF
  signal IR3_value : std_logic_vector(31 downto 0);	-- IR till DF	
  signal IR4_value : std_logic_vector(31 downto 0); 	-- IR till DF

  signal IR1_plus  : std_logic_vector(31 downto 0); 	-- JS till IR 
  signal IR2_plus  : std_logic_vector(31 downto 0);	-- JS till IR  
  
begin  -- Behavioral

  IR1_o <= IR1_value;
  IR2_o <= IR2_value;
  IR3_o <= IR3_value;
  IR4_o <= IR4_value;
 

--IR portarna.
 U0 : IR port map(clk=>clk, rst=>rst,
		  IR1_out => IR1_value, IR2_out => IR2_value, IR3_out => IR3_value, IR4_out => IR4_value,	-- Interna IR_value kopplas
		  IR1_in => IR1_plus, IR2_in => IR2_plus);							-- IR_plus kopplas till IR			

--Dataforwardingportar.
 U1 : dataforwarding port map(ALU_A_out => ALU_A_out, ALU_B_out => ALU_B_out, 					-- IR 						
			      A2_in => A2_in, B2_in => B2_in, D3_in => D3_in, D4_Z4_in => D4_Z4_in,						
			      IR2_in_df => IR2_value, IR3_in_df => IR3_value, IR4_in_df => IR4_value );											

--Jump_stall-portar.
 U2 : jump_stall port map(clk => clk, rst => rst,
			  PM_in => PM_in, IR1_in_js => IR1_value, IR2_in_js => IR2_value, 
			  IR1_out_js => IR1_plus, IR2_out_js => IR2_plus,
			  z_flag_in => z_flag); 			

end Behavioral;
