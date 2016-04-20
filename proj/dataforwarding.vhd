-- LIBRARY HERE ?

entity dataforward is
  port ( clk            : in std_logic;
         IR2_in         : in std_logic_vector(31 downto 0);
         IR3_in         : in std_logic_vector(31 downto 0);
         IR4_in         : in std_logic_vector(31 downto 0);
         A2_in          : in std_logic_vector(31 downto 0);
         D4_Z4_in       : in std_logic_vector(31 downto 0);
         D3_in          : in std_logic_vector(31 downto 0);
         B2_in          : in std_logic_vector(31 downto 0);
         IR3_op         : in std_logic_vector(31 downto 0);
         Ir4_op         : in std_logic_vector(31 downto 0);
         ALU_A_out      : out std_logic_vector(31 downto 0);
         ALU_B_out      : out std_logic_vector(31 downto 0)
         );
end dataforward;

architecture Behavioral of dataforward is

  signal WB_ROM : std_logic_vector(30 downto 0) := "000000111111111111111111111000";
  
begin  

  process(clk)
  begin
    if rising_edge(clk) then

      WB(conv_integer(IR3_op))          -- WBs signal (1/0) utifrån inputen
      
      
    end if;
  end process;

  

end Behavioral;
