
-- library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;            -- basic IEEE library
use IEEE.NUMERIC_STD.ALL;               -- IEEE library for the unsigned type

-- entity
entity VGA_MOTOR is
  port ( clk							: in std_logic;
				 data							: in std_logic_vector(7 downto 0);
				 rst							: in std_logic;
				 x_pos						: in std_logic_vector(4 downto 0); 
				 y_pos						: in std_logic_vector(3 downto 0);
				 addr							: out unsigned(10 downto 0);
				 vgaRed		        : out std_logic_vector(2 downto 0);
				 vgaGreen	        : out std_logic_vector(2 downto 0);
				 vgaBlue					: out std_logic_vector(2 downto 1);
				 Hsync		        : out std_logic;
				 Vsync		        : out std_logic);
end VGA_MOTOR;


-- architecture
architecture Behavioral of VGA_MOTOR is

  signal	Xpixel	        : unsigned(9 downto 0);         -- Horizontal pixel counter
  signal	Ypixel	        : unsigned(9 downto 0);		-- Vertical pixel counter
  signal	ClkDiv	        : unsigned(1 downto 0);		-- Clock divisor, to generate 25 MHz signal
  signal	Clk25						: std_logic;			-- One pulse width 25 MHz signal
  signal	nextrow					: std_logic;	
		
  signal 	tilePixel       : std_logic_vector(7 downto 0);	-- Tile pixel data
  signal	tileAddr				: unsigned(12 downto 0);	-- Tile address

  signal 	markerPixel			: std_logic_vector(7 downto 0);
  signal 	pixel_out				: std_logic_vector(7 downto 0);

  signal  blank           : std_logic;                    -- blanking signal
	

  -- Tile memory type
  type ram_t is array (0 to 3327) of std_logic_vector(7 downto 0);

-- Tile memory
  signal tileMem : ram_t := 
		( 						x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",    -- pressedtile
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",    -- one
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"30",x"30",x"db",x"db",x"db",x"db",x"db",x"30",x"30",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"30",x"30",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"6d",    -- two
                  x"6d",x"db",x"db",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"30",x"30",x"30",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"30",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"db",x"6d",    -- three
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"db",x"db",x"db",x"6d",    -- four
                  x"6d",x"db",x"db",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"01",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"01",x"01",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"db",x"db",x"6d",    -- five
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"40",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"6d",    -- six
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"1f",x"1f",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"1f",x"1f",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"1f",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

		  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"f4",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"6d",    -- seven
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"f4",x"f4",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"6d",    -- eight
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"e0",x"e0",x"e0",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"e0",x"e0",x"e0",x"e0",x"e0",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"e0",x"e0",x"e0",x"e0",x"e0",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"e0",x"e0",x"e0",x"92",x"92",x"92",x"92",x"6d",x"6d",    -- flag
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"00",x"00",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"00",x"00",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"00",x"00",x"00",x"00",x"00",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"03",x"03",x"03",x"03",x"03",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"03",x"03",x"03",x"03",x"03",x"03",x"03",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"92",x"6d",x"6d",    -- questionmark
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"03",x"03",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
	
		  						x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"00",x"db",x"00",x"00",x"db",x"00",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"00",x"00",x"ff",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"00",x"00",x"ff",x"ff",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"6d",    -- bomb
                  x"6d",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"00",x"00",x"00",x"00",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"00",x"db",x"00",x"00",x"db",x"00",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",

                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",
                  x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"db",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",    -- normaltile
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"db",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"92",x"6d",x"6d",
                  x"db",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",
                  x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d",x"6d");


type  marker_t is array (0 to 255) of std_logic_vector(7 downto 0);
signal marker_rom : marker_t := 
		( x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",     -- Marked!
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"ff",x"e0",
                  x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0",x"e0");

		  
begin

   -- Clock divisor
  -- Divide system clock (100 MHz) by 4
  process(clk)
  begin
    if rising_edge(clk) then
      if rst='1' then
	ClkDiv <= (others => '0');
      else
	ClkDiv <= ClkDiv + 1;
      end if;
    end if;
  end process;
	
  -- 25 MHz clock (one system clock pulse width)
  Clk25 <= '1' when (ClkDiv = 3) else '0';
	
	
  -- Horizontal pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Xpixel <= (others => '0');
      elsif (Clk25 = '1') then      
        if(Xpixel = 799) then
          Xpixel <= (others => '0');
        else            
          Xpixel <= Xpixel + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- Horizontal sync
  Hsync <= '0' when (Xpixel >= 656 and Xpixel <= 752) else '1';

  
  -- Vertical pixel counter
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst = '1') then
        Ypixel <= (others => '0');
      elsif(Clk25 = '1') then
        if(Xpixel = 799) then         
          if(Ypixel = 520) then
            Ypixel <= (others => '0');
          else
            Ypixel <= Ypixel + 1;          
          end if;
        end if;
      end if;
    end if;
  end process; 	

  -- Vertical sync
  Vsync <= '0' when (Ypixel >= 490 and Ypixel <= 492) else '1';
    



  
  -- Video blanking signal

  Blank <= '1' when (Xpixel >= 640 or Ypixel >= 480) else '0';
       
  
  -- Tile memory
  process(clk)
  begin
    if rising_edge(clk) then
      if (blank = '0') then	
          tilePixel <= tileMem(to_integer(tileAddr));	
      else
        tilePixel <= (others => '0');
      end if;
    end if;
  end process;

 process(clk)
 begin
   if rising_edge(clk) then
     if ((Ypixel(8 downto 5) = unsigned(y_pos)) and (Xpixel(9 downto 5) = unsigned(x_pos))) then
	markerPixel <= marker_rom(to_integer(Ypixel(4 downto 1) & Xpixel(4 downto 1) ));
     else
	markerPixel <= (others => '1');
     end if;
   end if;
 end process;

  -- Tile memory address composite
  tileAddr <= unsigned(data(4 downto 0)) & Ypixel(4 downto 1) & Xpixel(4 downto 1);


  -- Picture memory address composite
  addr <= to_unsigned(20, 7) * Ypixel(8 downto 5) + Xpixel(9 downto 5);


  -- VGA generation
 
 
  pixel_out <= tilePixel when (markerPixel = x"ff") else markerPixel;

  vgaRed(2) 	<= pixel_out(7);
  vgaRed(1) 	<= pixel_out(6);
  vgaRed(0) 	<= pixel_out(5);
  vgaGreen(2)   <= pixel_out(4);
  vgaGreen(1)   <= pixel_out(3);
  vgaGreen(0)   <= pixel_out(2);
  vgaBlue(2) 	<= pixel_out(1);
  vgaBlue(1) 	<= pixel_out(0);
  


end Behavioral;

