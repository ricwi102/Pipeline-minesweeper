library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_mux is
  port (D4      : in std_logic_vector (31 downto 0);
        Z4      : in std_logic_vector (31 downto 0);
        IR4     : in std_logic_vector (31 downto 0);
        we      : out std_logic;
        data    : out std_logic_vector (31 downto 0);
        adr     : out std_logic_vector (4 downto 0)
        );
   
  
end register_mux;

architecture Behavioral of register_mux is
signal D4_help : std_logic_vector (31 downto 0);
signal Z4_help : std_logic_vector (31 downto 0);
signal IR4_help : std_logic_vector (31 downto 0);
alias command : std_logic_vector(5 downto 0) is IR4_help(31 downto 26);
  
begin
  D4_help <= D4;
  Z4_help <= Z4;
  IR4_help <= IR4;

  adr <= IR4_help(25 downto 21);
  data <= Z4 when (command = "000011") else
          D4;
  we <= '0' when ((conv_integer(command) > 20)
                  or (command = "000000")
                  or (command = "000001")
                  or (command = "000100")
                  or (command = "000101")) else
        '1';

end Behavioral;
