library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU_mux is
  port (
    const, reg : in std_logic_vector(31 downto 0);
    IR2        : in std_logic_vector(31 downto 0);
    output     : out std_logic_vector(31 downto 0)
    );
end ALU_mux;



architecture Behavioral of ALU_mux is
signal c_internal, r_internal : std_logic_vector(31 downto 0);
alias command : std_logic_vector(5 downto 0) is IR2(31 downto 26);

begin
  c_internal <= const;
  r_internal <= reg;

  output <= c_internal when (command = "000010" or
                             command = "000011" or
                             command = "000101" or
                             command = "000110" or
                             command = "001000" or
                             command = "001001" or
                             command = "001011" or
                             command = "001101" or
                             command = "001111" or
                             command = "010010" or
                             command = "010100" or
                             command = "010110" or
                             command = "011000") else
            r_internal;
  


end Behavioral;
