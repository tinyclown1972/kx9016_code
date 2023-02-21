library ieee;
use ieee.std_logic_1164.all;
entity SEG7_LUT is
    port(
        iDIG : in std_logic_vector(3 downto 0);
        oSEG : out std_logic_vector(6 downto 0)
    );
end entity;

architecture behav of SEG7_LUT is
begin
    process(iDIG)
    begin
        case iDIG is
            when "0000" => oSEG<= "1000000";    --0
            when "0001" => oSEG<= "1111001";    --1
            when "0010" => oSEG<= "0100100";    --2
            when "0011" => oSEG<= "0110000";    --3
            when "0100" => oSEG<= "0011001";    --4
            when "0101" => oSEG<= "0010010";
            when "0110" => oSEG<= "0000010";
            when "0111" => oSEG<= "1111000";
            when "1000" => oSEG<= "0000000";
            when "1001" => oSEG<= "0011000";
            when "1010" => oSEG<= "0001000";
            when "1011" => oSEG<= "0000011";
            when "1100" => oSEG<= "1000110";
            when "1101" => oSEG<= "0100001";
            when "1110" => oSEG<= "0000110";
            when "1111" => oSEG<= "0001110";           
            when others => oSEG<= "0001110";                
        
        end case;
    end process;
end behav;
