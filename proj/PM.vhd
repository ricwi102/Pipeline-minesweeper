library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  port (
    clk, rst	: in std_logic;   
    address		: in std_logic_vector(9 downto 0);  
		rx				: in std_logic;  
    instr_out	: out std_logic_vector(31 downto 0);
		running_out : out std_logic		
    );
  
end PM;

architecture Behavioral of PM is

type prog_mem is array (0 to 1023) of std_logic_vector(31 downto 0);
signal prog_mem_c : prog_mem := (b"000000_00000_00000_00000_00000000000",
																	b"000000_00000_00000_00000_00000000000",
																	b"000000_00000_00000_00000_00000000000",
																	b"101101_00000_00000_00000_00000000000",
																	others => (others => '0'));


component program_loader
  Port (clk,rst,rx	  		: in  STD_LOGIC;
				we_out						: out std_logic;
				running_out				: out std_logic;
        instr_out					: out STD_LOGIC_VECTOR(31 downto 0);	
				PM_count_out			: out std_logic_vector(9 downto 0)	 				
				);          
end component;

signal we					: std_logic;
signal running_pl	: std_logic;
signal instr_in		: std_logic_vector(31 downto 0); 
signal PL_count   : std_logic_vector(9 downto 0);


begin 

process(clk) begin
  if rising_edge(clk) then    
      if (we = '1') then 
        prog_mem_c(conv_integer(PL_count)) <= instr_in;      
      end if;    
  end if;
end process;

port3 : program_loader port map(clk => clk, rst => rst, we_out => we, instr_out => instr_in, PM_count_out => PL_count, rx => rx, running_out => running_pl);

instr_out <= prog_mem_c(3); -- conv_integer(address)
running_out <= running_pl;


end Behavioral;
