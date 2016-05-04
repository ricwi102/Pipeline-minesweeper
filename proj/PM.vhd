library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  port (
    clk, rst	: in std_logic;
    address	: in std_logic_vector(31 downto 0);
    instruction	: out std_logic_vector(31 downto 0)
    );
  
end PM;

architecture Behavioral of PM is

type prog_mem is array (0 to 255) of std_logic_vector(31 downto 0);
constant prog_mem_c : prog_mem :=
  (b"000010_00001_00000_00000_00000000100",
   b"000101_00000_00000_00001_00000000001",
   b"000011_00010_00000_00000_00000000001",
   b"000110_00011_00010_00000_00001000000",
   b"011001_00000_00000_00000_00000000000",
   others => (others => '0'));


signal PC_internal : std_logic_vector(31 downto 0) := (others => '0');


begin 
instruction <= prog_mem_c(conv_integer(PC_internal));

PC_internal <= address;
  

end Behavioral;
