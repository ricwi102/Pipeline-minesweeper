


-- entity
entity IR is
  port ( clk            : in std_logic;                         --system clock
         prog_mem       : in std_logic_vector(31 downto 0);     --Program Memory Input
         rst            : in std_logic;                         --reset
         IR4_out        : out std_logic_vector(31 downto 0));   --Output
end IR;

-- architecture
architecture Behavioral of IR is
  
  --The Value of the IR components.
  signal IR1_value      :std_logic_vector(31 downto 0);
  signal IR2_value      :std_logic_vector(31 downto 0);
  signal IR3_value      :std_logic_vector(31 downto 0);
  signal IR4_value      :std_logic_vector(31 downto 0);

  --Jump fuction wannabe wtf omg
  signal ext		: std_logic_vector(31 downto 0);
  signal PC2		: std_logic_vector(31 downto 0);
  signal PC		: std_logic_vector(31 downto 0);

begin
  
  --Stepping process of IR(1-4).
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	IR1_value = 0;
        IR2_value = 0;
        IR3_value = 0;
        IR4_value = 0;
        
      else
	
        IR4_value = IR3_value;
        IR3_value = IR2_value;
        IR2_value = IR1_value;
        IR1_value = prog_mem;
        
      end if;
    end if;
  end process;
  
end Behavioral;
