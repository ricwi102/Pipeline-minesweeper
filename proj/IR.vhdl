library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity IR is
  port ( clk            : in std_logic;                         --System clock
         prog_mem       : in std_logic_vector(31 downto 0);     --Program Memory Input
         rst            : in std_logic;                         --Reset
	 IR1_out        : out std_logic_vector(31 downto 0));   --Output
	 IR2_out        : out std_logic_vector(31 downto 0));   --Output
	 IR3_out        : out std_logic_vector(31 downto 0));   --Output
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
  signal PC		: std_logic_vector(31 downto 0);
  signal PC1		: std_logic_vector(31 downto 0);
  signal PC2		: std_logic_vector(31 downto 0);

begin
  
  --Stepping process of IR(1-4).
process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
	IR1_value <= 0;
        IR2_value <= 0;
        IR3_value <= 0;
        IR4_value <= 0;     
      else	
        IR4_value <= IR3_value;
        IR3_value <= IR2_value;
        IR2_value <= IR1_value;
        IR1_value <= prog_mem;
        
      end if;
    end if;
  end process;

  IR1_out <= IR1_value;
  IR2_out <= IR2_value;
  IR3_out <= IR3_value;
  IR4_out <= IR4_value;

process(clk)
  begin
    if rising_edge(clk) then 
      if rst = '1' then
	PC  <= 0;
	PC1 <= 0;
	PC2 <= 0;        
      else	
	if kolla om instruktionen inte är jmp then -- kolla om instruktionen är jump , dock inte bestämt vilken jmp är än
	  PC <= PC+4;
	  mem_pos <= PC; -- uppdatera pos i programminnet
	else
	  ext(24 downto 0) <= IR1(24 downto 0);
	  ext(30 downto 25) <= (others => '0');
	  ext(31) <= IR1(25) ; 
	  PC2 <= ext + PC1; 
	  PC <= ext + PC1; -- Sätt ext innan till valda bitar
	  mem_pos <= PC;
	end if;
        
      end if;
    end if;
  end process;


  
end Behavioral;
