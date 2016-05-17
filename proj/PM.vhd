library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PM is
  port (
    clk, rst	: in std_logic;   
    address		: in std_logic_vector(31 downto 0);  
		rx				: in std_logic;  
    instr_out	: out std_logic_vector(31 downto 0)
    );
  
end PM;

architecture Behavioral of PM is

type prog_mem is array (0 to 255) of std_logic_vector(31 downto 0);
signal prog_mem_c : prog_mem := (b"000000_00000_00000_00000_00000000000",
																 b"000000_00000_00000_00000_00000000000",
																 b"000000_00000_00000_00000_00000000000",
																 b"010110_00000_01010_00000_00000000100", -- cmp D
																 b"011011_00000_00000_00000_00000001100",	-- beq 12
																 b"000000_00000_00000_00000_00000000000",	-- NOP

														     b"010110_00000_01010_00000_00000000101", -- cmp Q
																 b"011101_00000_00000_00000_00000000000", -- bne 0
																 b"000010_00001_00000_00000_00000000001", -- move 9 r1
																 b"000100_00000_01000_00001_00000000000", -- gstore r1 r8 0
																 b"011001_00000_00000_00000_00000000000", -- jmp 0
																 b"000000_00000_00000_00000_00000000000",	-- NOP

																 -- tillagt
																 b"010110_00000_00011_00000_00000010011", -- cmp 19 i r3
																 b"011101_00000_00000_00000_00000010100", -- bne 20
															   b"000000_00000_00000_00000_00000000000",	-- NOP
																 b"000110_01001_01001_00000_00000000001", -- ++ y
			                           b"000010_00011_00000_00000_00000000000", -- move 0 r3
																 b"000010_01000_00000_00000_00000000000", -- move 0 r8
																 b"000010_01010_00000_00000_00000000000", -- move 0 r10
																 b"011001_00000_00000_00000_00000000000", -- jmp 0
																 b"000000_00000_00000_00000_00000000000",	-- NOP
																 -- tillagt

																 b"000110_01000_01000_00000_00000000001", -- ++
																 b"000110_00011_00011_00000_00000000001", -- ++ r4  ----- tillagt
																 b"000010_01010_00000_00000_00000000000", -- move 0
																 b"011001_00000_00000_00000_00000000000", -- jmp 0
																 others => (others => '0'));


component program_loader
  Port (clk,rst,rx	  		: in  STD_LOGIC;
				we_out						: out std_logic;
        instr_out					: out STD_LOGIC_VECTOR(31 downto 0);	
				PM_count_out			: out std_logic_vector(15 downto 0)	 				
				);          
end component;

signal we					: std_logic;
signal instr_in		: std_logic_vector(31 downto 0); 
signal PL_count   : std_logic_vector(15 downto 0);


begin 

process(clk) begin
  if rising_edge(clk) then    
      if (we = '1') then 
        prog_mem_c(conv_integer(PL_count)) <= instr_in;      
      end if;    
  end if;
end process;

port3 : program_loader port map(clk => clk, rst => rst, we_out => we, instr_out => instr_in, PM_count_out => PL_count, rx => rx);

instr_out <= prog_mem_c(conv_integer(address));


end Behavioral;
