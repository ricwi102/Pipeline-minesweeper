library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_mux is
  port (
    clk,rst    : in std_logic;
    reg        : in std_logic_vector(31 downto 0);
    IR1        : in std_logic_vector(31 downto 0);
    IR2        : in std_logic_vector(31 downto 0);
    output     : out std_logic_vector(31 downto 0)
    );
end ALU_mux;



architecture Behavioral of ALU_mux is
signal r_internal : std_logic_vector(31 downto 0) := (others => '0');
signal IM2    : std_logic_vector(31 downto 0) := (others => '0');
alias command : std_logic_vector(5 downto 0) is IR2(31 downto 26);

begin
  r_internal <= reg;

  process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst = '1') then
          IM2 <= (others => '0');
        else    
          IM2(10 downto 0) <= IR1(10 downto 0);
          IM2(31 downto 11) <= (others => '0');
        end if;
      end if;
    end process;
  
  output <= IM2        when (command = "000010" or
                             command = "000011" or
														 command = "000100" or
                             command = "000101" or
                             command = "000110" or
                             command = "001000" or
                             command = "001001" or
                             command = "001011" or
                             command = "001101" or
                             command = "001111" or
                             command = "010010" or
                             command = "010100" or
                             command = "010101" or
                             command = "010111") else
            r_internal;
  


end Behavioral;
