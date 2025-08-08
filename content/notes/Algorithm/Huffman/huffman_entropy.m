plaintext='A DEAD DAD CEDED A BAD BABE A BEADED ABACA BED'
h_encoding="1000011101001000110010011101100111001001000111110010011111011111100010001111110100111001001011111011101000111111001"
p_len = length(plaintext)
h_len = length(h_encoding)

bits_per_symbol = h_len / p_len

E = entropy_calc(plaintext)

fprintf("Huffman Encoding: [%f] bits/symbol.\n", bits_per_symbol)
fprintf("Entropy of the plain text: [%f] bits.\n", E)
