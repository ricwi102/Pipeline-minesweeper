--------------------------------------------------------------------------------
-- VGA lab
-- Anders Nilsson
-- 16-dec-2015
-- Version 1.0


-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type
                                        -- and various arithmetic operations

-- entity
entity VGA_lab is
  port (clk	                	: in std_logic;                         -- system clock
	 			rst                   : in std_logic;                         -- reset
				IR3_in								: in std_logic_vector(31 downto 0);
				Z3_in									: in std_logic_vector(31 downto 0);
				D3_in									: in std_logic_vector(31 downto 0);
	 			Hsync	                : out std_logic;                        -- horizontal sync
	 			Vsync	                : out std_logic;                        -- vertical sync
	 			vgaRed	              : out	std_logic_vector(2 downto 0);   -- VGA red
			 	vgaGreen              : out std_logic_vector(2 downto 0);     -- VGA green
			 	vgaBlue	        			: out std_logic_vector(2 downto 1));     -- VGA blue
end VGA_lab;


-- architecture
architecture Behavioral of VGA_lab is

  -- picture memory component
  component PICT_MEM
    port ( clk						: in std_logic;                         -- system clock
	 -- port 1
           IR3_in	        : in std_logic_vector(31 downto 0);                         
           data_in	      : in std_logic_vector(7 downto 0);      -- data in
           addr1	        : in unsigned(10 downto 0);             -- address
	 -- port 2
           data_out	    : out std_logic_vector(7 downto 0);     -- data out
           addr2					: in unsigned(10 downto 0));            -- address
  end component;
	
  -- VGA motor component
  component VGA_MOTOR
    port ( clk			: in std_logic;                         -- system clock
           rst			: in std_logic;                         -- reset
           data			: in std_logic_vector(7 downto 0);      -- data
           addr			: out unsigned(10 downto 0);            -- address
           vgaRed		: out std_logic_vector(2 downto 0);     -- VGA red
           vgaGreen	        : out std_logic_vector(2 downto 0);     -- VGA green
           vgaBlue		: out std_logic_vector(2 downto 1);     -- VGA blue
           Hsync		: out std_logic;                        -- horizontal sync
           Vsync		: out std_logic);                       -- vertical sync
  end component;
	
  -- intermediate signals between PICT_MEM and VGA_MOTOR
  signal	data_out2_s     : std_logic_vector(7 downto 0);         -- data
  signal	addr2_s		: unsigned(10 downto 0);                -- address
	
begin

  -- picture memory component connection
  U1 : PICT_MEM port map(clk=>clk, IR3_in => IR3_in, data_in=>Z3_in(7 downto 0), addr1=>unsigned(D3_in(10 downto 0)), data_out=>data_out2_s, addr2=>addr2_s);
	
  -- VGA motor component connection
  U2 : VGA_MOTOR port map(clk=>clk, rst=>rst, data=>data_out2_s, addr=>addr2_s, vgaRed=>vgaRed, vgaGreen=>vgaGreen, vgaBlue=>vgaBlue, Hsync=>Hsync, Vsync=>Vsync);

end Behavioral;

