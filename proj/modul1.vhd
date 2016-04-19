library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
  port (
    clk : in std_logic;
    input1 : in std_logic_vector (31 downto 0);
    input2 : in std_logic_vector (31 downto 0);
    op_ctrl : in std_logic_vector (5 downto 0);
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
	when "000010" => flag_output <= ('0' & input1);	
        when "000011" => flag_output <= ('0' & input1) + ('0' & input2);
        when "000100" => flag_output <= ('0' & input1) + ('0' & input2);
        when "000101" => flag_output <= ('0' & input1) + ('0' & input2);
        when "000110" => flag_output <= ('0' & input1) + ('0' & input2);
        when "000111" => flag_output <= ('0' & input1) + ('0' & input2);
        when "001000" => flag_output <= ('0' & input1) - ('0' & input2);
        when "001001" => flag_output <= ('0' & input1) - ('0' & input2);
        when "001010" => flag_output <= ('0' & input1) - ('0' & input2);
        when "001011" => flag_output <= ('0' & input1) * ('0' & input2);
        when "001100" => flag_output <= ('0' & input1) * ('0' & input2);
        when "001101" => flag_output <= ('0' & input1) and ('0' & input2);
        when "001110" => flag_output <= ('0' & input1) and ('0' & input2);
        when "001111" => flag_output <= ('0' & input1) or ('0' & input2);
        when "010000" => flag_output <= ('0' & input1) or ('0' & input2);
        when "010001" => flag_output <= (others => '0');   --LSR
        when "010010" => flag_output <= (others => '0');  --LSR2
        when "010011" => flag_output <= (others => '0');  --LSL
        when "010100" => flag_output <= (others => '0');  --LSL2
        when "010101" => flag_output <= ('0' & input1) - ('0' & input2);
        when "010110" => flag_output <= ('0' & input1) - ('0' & input2);
        when "010111" => flag_output(32 downto 1) <= (others => '0');
                         flag_output(0) <= input1(conv_integer(input2));
        when "011000" => flag_output(32 downto 1) <= (others => '0');
                         flag_output(0) <= input1(conv_integer(input2));
        when others => flag_output <= (others => '0');
      end case;
    end if;
  end process;

  output <= flag_output(31 downto 0);
  c_flag <= flag_output(32);

end Behavioral;
