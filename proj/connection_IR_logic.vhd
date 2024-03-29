library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity connection_IR_logic is
  port (
    clk         : in std_logic;												--System clock
    rst         : in std_logic;												--System reset

    IR1_o       : out std_logic_vector(31 downto 0);
    IR2_o       : out std_logic_vector(31 downto 0);
    IR3_o       : out std_logic_vector(31 downto 0);
    IR4_o       : out std_logic_vector(31 downto 0);

    ALU_A_out   : out std_logic_vector(31 downto 0);  
    ALU_B_out   : out std_logic_vector(31 downto 0);

		segments		: out std_logic_vector(6 downto 0);		-- 8-segment display
		seg_pos			: out std_logic_vector(3 downto 0);
  
    A2_in 			: in std_logic_vector(31 downto 0);
    B2_in 			: in std_logic_vector(31 downto 0);
    D3_in 			: in std_logic_vector(31 downto 0);
    D4_Z4_in 		: in std_logic_vector(31 downto 0);

    z_flag			: in std_logic;
		n_flag      : in std_logic;
	
		rx					: in std_logic
    );
  
end connection_IR_logic;

architecture Behavioral of connection_IR_logic is

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

  --Ports from jump stall logic.
  component jump_stall
  port ( clk,rst        	: in std_logic;

       	 IR1_in_js      	: in std_logic_vector(31 downto 0);
         IR2_in_js         	: in std_logic_vector(31 downto 0);
         IR1_out_js		: out std_logic_vector(31 downto 0);
         IR2_out_js    		: out std_logic_vector(31 downto 0);

         PC_out         	: out std_logic_vector(9 downto 0);
         PM_in          	: in std_logic_vector(31 downto 0);
         z_flag_in      	: in std_logic;
				 n_flag_in      	: in std_logic;
				 running_pl_in		: in std_logic
        );
  end component;

	--ports from Program Memory (PM).
  component PM
  port(	clk, rst	: in std_logic;    	
    	address			: in std_logic_vector(9 downto 0);
			rx					: in std_logic;    	
    	instr_out		: out std_logic_vector(31 downto 0);
			running_out : out std_logic		
	);
  end component;

	--Ports from the timer.
	component timer is
  port (
    clk, rst : in std_logic;          -- 
    segments : out std_logic_vector(6 downto 0);
    pos : out std_logic_vector(3 downto 0);
		IR1_in : in std_logic_vector(31 downto 0)
    );   
	 end component;
  

  -- Intern signals 
  signal IR1_value : std_logic_vector(31 downto 0) := (others => '0'); 	-- IR till JS
  signal IR2_value : std_logic_vector(31 downto 0) := (others => '0'); 	-- IR till JS och DF
  signal IR3_value : std_logic_vector(31 downto 0) := (others => '0');	-- IR till DF	
  signal IR4_value : std_logic_vector(31 downto 0) := (others => '0'); 	-- IR till DF

  signal IR1_plus  : std_logic_vector(31 downto 0) := (others => '0'); 	-- JS till IR 
  signal IR2_plus  : std_logic_vector(31 downto 0) := (others => '0');	-- JS till IR  

  signal PM_internal : std_logic_vector(31 downto 0) := (others => '0');	
  signal PC_internal : std_logic_vector(9 downto 0) := (others => '0');

	signal running_pl : std_logic;

  
begin  -- Behavioral

  IR1_o <= IR1_value;
  IR2_o <= IR2_value;
  IR3_o <= IR3_value;
  IR4_o <= IR4_value;


 

--IR ports.
 port0 : IR port map(clk=>clk, rst=>rst,
										 IR1_out => IR1_value, IR2_out => IR2_value, IR3_out => IR3_value, IR4_out => IR4_value,	-- Interna IR_value kopplas
										 IR1_in => IR1_plus, IR2_in => IR2_plus);							-- IR_plus kopplas till IR			

--Dataforwarding ports.
 port1 : dataforwarding port map(ALU_A_out => ALU_A_out, ALU_B_out => ALU_B_out,		-- IR 						
																 A2_in => A2_in, B2_in => B2_in, D3_in => D3_in, D4_Z4_in => D4_Z4_in,
																 IR2_in_df => IR2_value, IR3_in_df => IR3_value, IR4_in_df => IR4_value );

--Jump_stall ports.
 port2 : jump_stall port map( clk => clk, rst => rst,
															PM_in => PM_internal, IR1_in_js => IR1_value, IR2_in_js => IR2_value, 
															IR1_out_js => IR1_plus, IR2_out_js => IR2_plus,
															PC_out => PC_internal,
															z_flag_in => z_flag, n_flag_in => n_flag, running_pl_in => running_pl); 

-- PM ports
 port3 : PM port map(clk => clk, rst => rst, address => PC_internal, instr_out => PM_internal, rx => rx, running_out => running_pl);

--Timer ports
 port4 : timer port map(clk => clk, rst => rst, segments => segments, pos => seg_pos, IR1_in => IR1_value);



end Behavioral;
