LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity keyboard_handler_tb is
end keyboard_handler_tb;

architecture behavioral of keyboard_handler_tb is

  component keyboard_handler
    port (
      clk               : in std_logic;
      rst               : in std_logic;
      PS2KeyboardCLK    : in std_logic;
      PS2KeyboardData   : in std_logic;
      KeyPressedOut     : out std_logic_vector(3 downto 0)
      );
  end component;

  signal clk             : std_logic := '0';
  signal rst             : std_logic := '0';
  signal PS2KeyboardCLK  : std_logic := '0';
  signal PS2KeyboardData : std_logic := '0';
  signal KeyPressedOut   : std_logic_vector(3 downto 0);
  signal running         : boolean := true;
  signal keyboard_input : std_logic_vector(0 to 10) := "00001110001";
begin

  uut: keyboard_handler port map(
    clk => clk,
    rst => rst,
    PS2KeyboardCLK => PS2KeyboardCLK,
    PS2KeyboardData => PS2KeyboardData,
    KeyPressedOut => KeyPressedOut);

  
  clk_gen : process
    begin
      while running loop
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
      end loop;
      wait;
    end process;

    kb_clk_gen : process
    begin
      while running loop
        PS2KeyboardCLK <= '0';
        wait for 5 us;
        PS2KeyboardCLK <= '1';
        wait for 5 us;
      end loop; 
      wait;
    end process;

    simuli_generator : process 
     variable i : integer;
     begin
       
       for i in 0 to 10 loop
         PS2KeyboardData <= keyboard_input(i);
         wait for 10 us;
       end loop;  -- i
         

    for i in 0 to 99999999 loop         -- V�nta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    
    running <= false;        
    
       wait; 
     end process; 
end behavioral;