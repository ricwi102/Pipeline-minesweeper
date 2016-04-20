library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_minne is
port (clk : in std_logic;
      -- port 1
      adr : in std_logic_vector(8 downto 0);
      we : in std_logic;
      ce : in std_logic;
      data_in : in std_logic_vector(7 downto 0);     
      data_out : out std_logic_vector(7 downto 0));
end data_minne;

architecture Behavioral of data_minne is

-- Deklaration av ett dubbelportat block-RAM
-- med 2048 adresser av 8 bitars bredd.
type ram_t is array (0 to 512) of
  std_logic_vector(7 downto 0);

-- Nollställ alla bitar på alla adresser
signal ram : ram_t := (others => (others => '0'));

signal Z3, Z4 : std_logic_vector(31 downto 0) := (others => '0');  -- Register

begin

PROCESS(clk)
BEGIN
  if (rising_edge(clk)) then
    z3 <= data_in;
    -- synkron skrivning/läsning port 1
    if (ce = '0') then
      if (we = '1') then
        ram(conv_integer(adr)) <= z3;
      end if;
      z4 <= ram(conv_integer(adr));
    end if;

  end if;
END PROCESS;

end Behavioral;
