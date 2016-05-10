library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  port (
    clk, rst	: in std_logic;   
    address	: in std_logic_vector(31 downto 0);    
    instr_out	: out std_logic_vector(31 downto 0)
    );
  
end PM;

architecture Behavioral of PM is

type prog_mem is array (0 to 255) of std_logic_vector(31 downto 0);
signal prog_mem_c : prog_mem :=
  ( others => (others => '0') );


component program_loader
  Port (  clk,rst	  		: in  STD_LOGIC;
					we_out				: out std_logic;
          instr_out			: out STD_LOGIC_VECTOR(31 downto 0);
					PM_count_out	: out std_logic_vector(15 downto 0)	 				
					);          
  end component;

signal we					: std_logic;
signal instr_in		: std_logic_vector(31 downto 0); 
signal PL_count   : std_logic_vector(15 downto 0);


begin 

process(clk) begin
  if rising_edge(clk) then
    if (rst = '0') then
      prog_mem_c <= (others => (others => '0'));
    else
      if (we = '1') then 
        prog_mem_c(conv_integer(PL_count)) <= instr_in;      
      end if;
    end if;
  end if;
end process;

port3 : program_loader port map(clk => clk, rst => rst, we_out => we, 
																instr_out => instr_in, PM_count_out => PL_count);

instr_out <= prog_mem_c(conv_integer(address));


end Behavioral;
