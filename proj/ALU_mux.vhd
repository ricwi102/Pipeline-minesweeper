library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_mux is
  port (
    clk,rst    : in std_logic;											-- Clock and reset ports.
    reg        : in std_logic_vector(31 downto 0);	-- Registers
    IR1        : in std_logic_vector(31 downto 0);
    IR2        : in std_logic_vector(31 downto 0);
    output     : out std_logic_vector(31 downto 0)
    );
end ALU_mux;



architecture Behavioral of ALU_mux is
signal r_internal : std_logic_vector(31 downto 0) := (others => '0');
signal IM2    : std_logic_vector(31 downto 0) := (others => '0');  -- Constants to the mux.
alias command : std_logic_vector(5 downto 0) is IR2(31 downto 26);

begin
  r_internal <= reg;

--The process that fetches the constant form IR1.
  process(clk)
    begin
      if(rising_edge(clk)) then
        if(rst = '1') then
          IM2 <= (others => '0');
        else    
          IM2(9 downto 0) <= IR1(9 downto 0);
          IM2(31 downto 10) <= (others => IR1(10));
        end if;
      end if;
    end process;
  
--Checks if the command that is used needs the constant.
--If it does, then the output is set to IM2.
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
														 command = "010001" or
                             command = "010100" or
                             command = "010101" or
                             command = "010111") else
            r_internal;
  


end Behavioral;
