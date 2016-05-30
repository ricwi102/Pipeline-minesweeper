library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity ALU is
  port (
    clk 		: in std_logic;													--System clock
    input1 		: in std_logic_vector (31 downto 0);	--
    input2 		: in std_logic_vector (31 downto 0);
    op_ctrl 		: in std_logic_vector (5 downto 0);
    z_flag_out 		: out std_logic;
		n_flag_out		: out std_logic;
    output 		: out std_logic_vector (31 downto 0)  --Output to D3.
    );
end ALU;

architecture Behavioral of ALU is 

signal z_flag : std_logic := '0';
signal n_flag : std_logic := '0';
signal flag_output: std_logic_vector (32 downto 0) := (others => '0'); --ALU-Output and signal to set the flags.

begin 

-- The process that decides what to do with the inputs for each operation.
-- Bitkoden för varje instruktion finns i kommandon.txt
  process(clk) begin
    if rising_edge(clk) then
      case op_ctrl is
				when "000010" => flag_output <= ('0' & input1);											-- MOVE reg, #
        when "000011" => flag_output <= ('0' & input1) + ('0' & input2);		-- LOAD reg1, reg2, #
        when "000100" => flag_output <= ('0' & input1) + ('0' & input2);		-- GSTORE reg1, reg2, #
        when "000101" => flag_output <= ('0' & input1) + ('0' & input2);		-- STORE reg1, reg2, #
        when "000110" => flag_output <= ('0' & input1) + ('0' & input2);		-- ADD reg1, reg2, #
        when "000111" => flag_output <= ('0' & input1) + ('0' & input2);		-- ADD reg1, reg2, reg3
        when "001000" => flag_output <= ('0' & input2) - ('0' & input1);		-- SUB reg1, reg2, #
        when "001001" => flag_output <= ('0' & input1) - ('0' & input2);		-- SUB reg1, #, reg2
        when "001010" => flag_output <= ('0' & input2) - ('0' & input1);		-- SUB reg1, reg2, reg3 
        when "001011" => flag_output <= ('0' & (input1(15 downto 0)) 
																						* (input2(15 downto 0)));				-- MULT reg1, reg2, #
        when "001100" => flag_output <= ('0' & (input1(15 downto 0)) 		
																						* (input2(15 downto 0)));				-- MULT reg1, reg2, reg3
        when "001101" => flag_output <= ('0' & input1) and ('0' & input2);	-- AND reg1, reg2, #		
        when "001110" => flag_output <= ('0' & input1) and ('0' & input2); 	-- AND reg1, reg2, reg3
        when "001111" => flag_output <= ('0' & input1) or ('0' & input2);		-- OR reg1, reg2,  #	
        when "010000" => flag_output <= ('0' & input1) or ('0' & input2);		-- OR reg1, reg2, reg3
        when "010001" => flag_output <= ('0' & input1) xor ('0' & input2);	-- XOR reg1, reg2, #	
        when "010010" => flag_output <= ('0' & input1) xor ('0' & input2);	-- XOR reg1, reg2, reg3
        when "010011" => flag_output <= (others => '0');  --LSL
        when "010100" => flag_output <= (others => '0');  --LSL2
        when "010101" => flag_output <= ('0' & input2) - ('0' & input1);		-- CMP reg1, #
        when "010110" => flag_output <= ('0' & input2) - ('0' & input1);		-- CMP reg1, reg2
        when "010111" => flag_output(32 downto 1) <= (others => '0');				-- BTST reg1, #
                         flag_output(0) <= input2(conv_integer(input1));		
        when "011000" => flag_output(32 downto 1) <= (others => '0');				-- BTST reg1, reg2
                         flag_output(0) <= input2(conv_integer(input1));		
        when others => flag_output <= flag_output;
      end case;
    end if;
  end process;

  output <= flag_output(31 downto 0);


  z_flag <= '1' when (conv_integer(flag_output(31 downto 0)) = 0) else '0';
  n_flag <= '1' when (flag_output(31) = '1') else '0';
	
	z_flag_out <= z_flag;
	n_flag_out <= n_flag; 

end Behavioral;
