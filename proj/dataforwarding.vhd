library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dataforwarding is
    port ( 
         IR2_in_df      : in std_logic_vector(31 downto 0);
         IR3_in_df      : in std_logic_vector(31 downto 0);
         IR4_in_df      : in std_logic_vector(31 downto 0);

         A2_in          : in std_logic_vector(31 downto 0);
         D4_Z4_in       : in std_logic_vector(31 downto 0);
         D3_in          : in std_logic_vector(31 downto 0);
         B2_in          : in std_logic_vector(31 downto 0);
        
         ALU_A_out      : out std_logic_vector(31 downto 0);
         ALU_B_out      : out std_logic_vector(31 downto 0)
         );
end dataforwarding;

architecture Behavioral of dataforwarding is

  signal WB_ROM : std_logic_vector(30 downto 0) := "0000001111111111111111111111000";
  signal IR3_IR2_first : std_logic := '0';
  signal IR4_IR2_first : std_logic := '0';
  signal IR3_IR2_second : std_logic := '0';
  signal IR4_IR2_second : std_logic := '0';
  signal ALU_A_in : std_logic_vector(1 downto 0) := "00";
  signal ALU_B_in : std_logic_vector(1 downto 0) := "00";

  alias IR3_command : std_logic_vector(5 downto 0) is IR3_in_df(31 downto 26);
  alias IR4_command : std_logic_vector(5 downto 0) is IR4_in_df(31 downto 26);
  
begin  


  IR3_IR2_first  <= '1' when (IR3_in_df(25 downto 21) = IR2_in_df(20 downto 16)) else '0';
  IR4_IR2_first  <= '1' when (IR2_in_df(20 downto 16) = IR4_in_df(25 downto 21)) else '0';
  IR3_IR2_second <= '1' when (IR3_in_df(25 downto 21) = IR2_in_df(15 downto 11)) else '0';
  IR4_IR2_second <= '1' when (IR4_in_df(25 downto 21) = IR2_in_df(15 downto 11)) else '0';
  -----------------------------------------------------------------------------
  -- -------------------------------
  -----------------------------------------------------------------------------
   


  -- AND -> MUX

  ALU_A_in(1)   <= '1' when ((WB_ROM(conv_integer(IR3_command))='1') and (IR3_IR2_first='1')) else '0';
  ALU_A_in(0)   <= '1' when ((WB_ROM(conv_integer(IR4_command))='1') and (IR4_IR2_first='1')) else '0';

  ALU_B_in(1)   <= '1' when ((WB_ROM(conv_integer(IR3_command))='1') and (IR3_IR2_second='1')) else '0';
  ALU_B_in(0)   <= '1' when ((WB_ROM(conv_integer(IR4_command))='1') and (IR4_IR2_second='1')) else '0';
  
  --

  -- Muxarna
  
      with ALU_A_in select
        ALU_A_out <= A2_in 	when "00",
                     D4_Z4_in 	when "01",
                     D3_in 	when others;

      with ALU_B_in select
        ALU_B_out <= B2_in 	when "00",
                     D4_Z4_in 	when "01",
                     D3_in 	when others;

  --

end Behavioral;
