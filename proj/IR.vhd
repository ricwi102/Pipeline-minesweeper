library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


-- entity
entity IR is
  port ( clk, rst       : in std_logic;                         --System clock
       
	 IR1_out        : out std_logic_vector(31 downto 0);   --Output
	 IR2_out        : out std_logic_vector(31 downto 0);   --Output
	 IR3_out        : out std_logic_vector(31 downto 0);   --Output
         IR4_out        : out std_logic_vector(31 downto 0);

	 IR1_in		: in std_logic_vector(31 downto 0); 
	 IR2_in 	: in std_logic_vector(31 downto 0)
         );   --Output
	
end IR;

-- architecture
architecture Behavioral of IR is
  
  --The Value of the IR components.
  signal IR1_value      :std_logic_vector(31 downto 0) := (others => '0');
  signal IR2_value      :std_logic_vector(31 downto 0) := (others => '0');
  signal IR3_value      :std_logic_vector(31 downto 0) := (others => '0');
  signal IR4_value      :std_logic_vector(31 downto 0) := (others => '0');


begin
  
  --Stepping process of IR(1-4).
process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
	IR1_value <= (others => '0');
        IR2_value <= (others => '0');
        IR3_value <= (others => '0');
        IR4_value <= (others => '0');     
      else	
        IR4_value <= IR3_value;
        IR3_value <= IR2_value;
        IR2_value <= IR2_in;
        IR1_value <= IR1_in;
        
      end if;
    end if;
  end process;

  IR1_out <= IR1_value;
  IR2_out <= IR2_value;
  IR3_out <= IR3_value;
  IR4_out <= IR4_value;
  

end Behavioral;
