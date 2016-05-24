library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
  port (
    clk 		: in std_logic;
    input1 		: in std_logic_vector (31 downto 0);
    input2 		: in std_logic_vector (31 downto 0);
    op_ctrl 		: in std_logic_vector (5 downto 0);
    z_flag_out 		: out std_logic;
		n_flag_out		: out std_logic;
    output 		: out std_logic_vector (31 downto 0)  
    );
end ALU;

architecture Behavioral of ALU is 

--signal o_flag : std_logic := '0';
--signal c_flag : std_logic := '0';
--signal f_flag : std_logic := '0';
signal z_flag : std_logic := '0';
signal n_flag : std_logic := '0';
signal flag_output: std_logic_vector (32 downto 0) := (others => '0');

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
        when "001000" => flag_output <= ('0' & input2) - ('0' & input1);
        when "001001" => flag_output <= ('0' & input1) - ('0' & input2);
        when "001010" => flag_output <= ('0' & input2) - ('0' & input1);
        when "001011" => flag_output <= ('0' & (input1(15 downto 0)) * (input2(15 downto 0)));
        when "001100" => flag_output <= ('0' & (input1(15 downto 0)) * (input2(15 downto 0)));
        when "001101" => flag_output <= ('0' & input1) and ('0' & input2);
        when "001110" => flag_output <= ('0' & input1) and ('0' & input2);
        when "001111" => flag_output <= ('0' & input1) or ('0' & input2);
        when "010000" => flag_output <= ('0' & input1) or ('0' & input2);
        when "010001" => flag_output <= ('0' & input1) xor ('0' & input2);
        when "010010" => flag_output <= ('0' & input1) xor ('0' & input2);
        when "010011" => flag_output <= (others => '0');  --LSL
        when "010100" => flag_output <= (others => '0');  --LSL2
        when "010101" => flag_output <= ('0' & input2) - ('0' & input1);
        when "010110" => flag_output <= ('0' & input2) - ('0' & input1);
        when "010111" => flag_output(32 downto 1) <= (others => '0');
                         flag_output(0) <= input2(conv_integer(input1));
        when "011000" => flag_output(32 downto 1) <= (others => '0');
                         flag_output(0) <= input2(conv_integer(input1));
        when others => flag_output <= flag_output;
      end case;
    end if;
  end process;

  output <= flag_output(31 downto 0);
  --c_flag <= flag_output(32);
  z_flag <= '1' when (conv_integer(flag_output(31 downto 0)) = 0) else '0';
  n_flag <= '1' when (flag_output(31) = '1') else '0';
	
	z_flag_out <= z_flag;
	n_flag_out <= n_flag; 

end Behavioral;
