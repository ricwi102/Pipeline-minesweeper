entity IR_and_forwarding_and_stall
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
    );
  
end IR_and_forwarding_and_stall;

architecture Behavioral of IR_and_forwarding_and_stall is

  --Ports from dataforwarding.
  component dataforwarding
    port ( clk          : in std_logic;
         IR2_in         : in std_logic_vector(31 downto 0);
         IR3_in         : in std_logic_vector(31 downto 0);
         IR4_in         : in std_logic_vector(31 downto 0);
         A2_in          : in std_logic_vector(31 downto 0);
         D4_Z4_in       : in std_logic_vector(31 downto 0);
         D3_in          : in std_logic_vector(31 downto 0);
         B2_in          : in std_logic_vector(31 downto 0);
         IR3_op         : in std_logic_vector(31 downto 0);
         IR4_op         : in std_logic_vector(31 downto 0);
         ALU_A_out      : out std_logic_vector(31 downto 0);
         ALU_B_out      : out std_logic_vector(31 downto 0)
         );
  end component;

  --Ports from IR.
  component IR
    port (
         clk            : in std_logic;                        --System clock
         rst            : in std_logic;                        --Reset
	 PC_in 		: in std_logic_vector(31 downto 0);    --PC intake
	 IR1_in         : in std_logic_vector(31 downto 0);    --Input
	 IR2_in         : in std_logic_vector(31 downto 0);    --Input
	 IR1_out        : out std_logic_vector(31 downto 0);   --Output
	 IR2_out        : out std_logic_vector(31 downto 0);   --Output
	 IR3_out        : out std_logic_vector(31 downto 0);   --Output
         IR4_out        : out std_logic_vector(31 downto 0)
         );   --Output
  end component;

  --Ports from jump_and_stall
  component jump_and_stall
    port (
         IR1_in         : in std_logic_vector(31 downto 0);
         IR2_in         : in std_logic_vector(31 downto 0);
         IR1_out        : out std_logic_vector(31 downto 0);
         IR2_out        : out std_logic_vector(31 downto 0);
         PC_out         : out std_logic_vector(31 downto 0);
         PC_in          : in std_logic_vector(31 downto 0);
         PC2_in         : in std_logic_vector(31 downto 0);
         PM_in          : in std_logic_vector(31 downto 0)
         );
  end component;

  -- Interna
  signal IR1_out : std_logic_vector(31 downto 0); 	-- IR till JS
  signal IR2_out : std_logic_vector(31 downto 0); 	-- IR till JS
  signal IR1_in : std_logic_vector(31 downto 0); 	-- JS till IR 
  signal IR2_in : std_logic_vector(31 downto 0);	-- JS till IR 
  signal IR3_out : std_logic_vector(31 downto 0);	-- IR till DF	
  signal IR4_out : std_logic_vector(31 downto 0); 	-- IR till DF
  signal PC_in  : std_logic_vector(31 downto 0);	-- IR till JS
  signal PC_out : std_logic_vector(31 downto 0);	-- JS till IR
  signal PC2 : std_logic_vector(31 downto 0);		-- IR till DF
  
begin  -- Behavioral

--IR portarna.
 U0 : IR port map(clk=>clk, rst=>rst, IR1_out => IR1_o, IR2_out => IR2_o, IR3_out => IR3_o, IR4_out => IR4_o 					--Externa in/utgångar
, IR1_out => IR1_out, IR2_out => IR2_out, IR3_out => IR3_out, IR4_out => IR4_out, PC_in=>PC_out, PC_out => PC_in, PC2_in => PC2,		--Interna in/utgångar
IR1_in=>IR1_in, IR2_in=>IR2_in);														--Interna in/utgångar

--Dataforwardingportar.
 U1 : dataforwarding port map(ALU_A_out => ALU_A_out, ALU_B_out => ALU_B_out, 									--Externa in/utgångar
A2_in => A2_in, B2_in => B2_in, D3_in => D3_in, D4_Z4_in => D4_Z4_in,						
IR2_in=>IR2_out, IR3_in => IR3_out, IR4_in => IR4_out );											--Interna in/utgångar

--Jump_stall-portar.
 U2 : jump_and_stall port map(PM_in=>PM_in, 													--Externa in/utgångar
IR1_in => IR1_out, IR2_in => IR2_out, PC_out=>PC_out, IR1_out=>IR1_in, IR2_out=>IR2_in, PC2_in => PC2, PC_in => PC_in); 			--Interna in/utgångar

end Behavioral;
