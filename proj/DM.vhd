library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_minne is
port (clk 			: in std_logic;												--System Clock
      adr 			: in std_logic_vector(11 downto 0);		-- Adress pointer (D3)
      IR3_in 		: in std_logic_vector(31 downto 0);		
      Z3_in 		: in std_logic_vector(31 downto 0); 	--Input
      data_out 	: out std_logic_vector(31 downto 0)); --Output
end data_minne;

architecture Behavioral of data_minne is

-- Deklaration av ett dubbelportat block-RAM
-- med 2048 adresser av 8 bitars bredd.
type ram_t is array (0 to 4095) of
  std_logic_vector(7 downto 0);

-- Nollställ alla bitar på alla adresser
signal ram : ram_t := (others => (others => '0'));

signal Z4 		: std_logic_vector(31 downto 0) := (others => '0');  -- Register
signal we     : std_logic := '0';																	 -- Write Enable

begin

we <= '1' when IR3_in(31 downto 26) = "000101" else '0';					 -- Checks if STORE is in IR3 (since that is the only instruction writing to Data Memory)
data_out <= Z4;	

--Writes to DM if write enable and sets the output from DM.
PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then        
      if (we = '1') then
        ram(conv_integer(adr)) <= Z3_in(7 downto 0);
      end if;
      z4(7 downto 0) <= ram(conv_integer(adr));
    end if;

END PROCESS;

end Behavioral;
