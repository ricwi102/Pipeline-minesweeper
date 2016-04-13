library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
  port (
    clk : in std_logic;
    input1 : in std_logic_vector (31 downto 0);
    input2 : in std_logic_vector (31 downto 0);
    op_ctrl : in std_logic_vector (3 downto 0);
    output : out std_logic_vector (31 downto 0)  --kanske inte; 32 för extra bit för flaggor
    );
end ALU;

architecture Behavioral of ALU is 

signal o_flag : std_logic;
signal c_flag : std_logic;
signal f_flag : std_logic;
signal flag_output: std_logic_vector (32 downto 0);

begin 

  process(clk) begin
    if rising_edge(clk) then
      case op_ctrl is
        when "0000" => flag_output <= (others => '0');
	when "0001" => flag_output <= ('0' & input1);	
        when "0010" => flag_output <= ('0' & input1) + ('0' & input2);
        when "0011" => flag_output <= ('0' & input1) - ('0' & input2);
        when "0100" => flag_output <= ('0' & input1) * ('0' & input2);
        when others => flag_output <= (others => '0');
      end case;
    end if;
  end process;

  output <= flag_output(31 downto 0);
  c_flag <= flag_output(32);

end Behavioral;
