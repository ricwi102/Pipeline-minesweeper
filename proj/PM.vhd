library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  port (
    clk         : in std_logic;
    PC          : in std_logic_vector (31 downto 0);
    PM_out      : out std_logic_vector (31 downto 0)
    );
  
end PM;

architecture Behavioral of PM is

type prog_mem is array (0 to 256) of unsigned (31 downto 0);
constant prog_mem_c : prog_mem :=
  (x"00000000");

begin 
PM_out <= prog_mem(conv_integer(PC));
  

end PM;
