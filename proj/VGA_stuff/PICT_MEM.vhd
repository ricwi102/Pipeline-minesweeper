--------------------------------------------------------------------------------
-- PICT MEM
-- Anders Nilsson
-- 16-feb-2016
-- Version 1.1


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type



-- entity
entity PICT_MEM is
  port ( clk				: in std_logic;
         -- port 1
         IR3_in			: in std_logic_vector(31 downto 0);
         data_in		: in std_logic_vector(7 downto 0);         
         addr1			: in unsigned(10 downto 0);
         -- port 2         
         data_out		: out std_logic_vector(7 downto 0);
         addr2			: in unsigned(10 downto 0));
end PICT_MEM;

	
-- architecture
architecture Behavioral of PICT_MEM is

  -- picture memory type
  type ram_t is array (0 to 2047) of std_logic_vector(7 downto 0);
  -- initiate picture memory to one cursor ("1F") followed by spaces ("00")
  signal pictMem : ram_t := (others => x"0c");



	signal we			:	std_logic;

begin


	we <= '1' when (IR3_in(31 downto 26) = "000100") else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if (we = '1') then
        pictMem(to_integer(addr1)) <= data_in;
      end if;     
      
      data_out <= pictMem(to_integer(addr2));
    end if;
  end process;


end Behavioral;

