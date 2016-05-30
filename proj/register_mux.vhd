library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity register_mux is
  port (D4      : in std_logic_vector (31 downto 0);
        Z4      : in std_logic_vector (31 downto 0);
        IR4     : in std_logic_vector (31 downto 0);
        we      : out std_logic;											--WE for PM
        data    : out std_logic_vector (31 downto 0);	--Z4 or D4
        adr     : out std_logic_vector (4 downto 0)		--Andress pointer for PM
        );
   
end register_mux;

architecture Behavioral of register_mux is

alias command : std_logic_vector(5 downto 0) is IR4(31 downto 26);
  
begin  
  adr <= IR4(25 downto 21);									--Gets the adress for PM
  data <= Z4 when (command = "000011") else	--If the intruction is LOAD
          D4;

	-- we=0 if the operation doesnt need to write to PM
  we <= '0' when ((conv_integer(command) > 20)
                  or (command = "000000")
                  or (command = "000001")
                  or (command = "000100")
                  or (command = "000101")
									or (command = "010101")
									or (command = "010110")) else
        '1';

end Behavioral;
