entity IR_and_forwarding_and_stall
  port (
    clk         : in std_logic;
    rst         : in std_logic;
    IR1_o       : out std_logic_vector(31 downto 0);
    IR2_o       : out std_logic_vector(31 downto 0);
    IR3_o       : out std_logic_vector(31 downto 0);
    IR4_o       : out std_logic_vector(31 downto 0)
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
         clk            : in std_logic;                         --System clock
         prog_mem       : in std_logic_vector(31 downto 0);     --Program Memory Input
         rst            : in std_logic;                         --Reset
	 IR1_out        : out std_logic_vector(31 downto 0);   --Output
	 IR2_out        : out std_logic_vector(31 downto 0);   --Output
	 IR3_out        : out std_logic_vector(31 downto 0);   --Output
         IR4_out        : out std_logic_vector(31 downto 0)
         );   --Output
  end component;

  --Ports from jump_and_stall
  component jump_and_stall
    port (
         clk            : in std_logic;
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

  signal IR1 : std_logic_vector(31 downto 0);
  signal IR2 : std_logic_vector(31 downto 0);
  signal IR3 : std_logic_vector(31 downto 0);
  signal IR4 : std_logic_vector(31 downto 0);
  
begin  -- Behavioral

 U0 : IR port map(clk=>clk, rst=>rst, IR1_out => IR1_o, IR2_out => IR2_o, IR3_out => IR3_o, IR4_out => IR4_o, IR1_out => IR1, IR2_out => IR2, IR3_out => IR3, IR4_out => IR4);

 U1 : dataforwarding port map(clk=>clk, IR2_in=>IR2, IR3_in => IR3, IR4_in => IR4);

 U2 : jump_and_stall port map(clk=>clk, IR1_in => IR1, IR2_in => IR2); 

end Behavioral;
