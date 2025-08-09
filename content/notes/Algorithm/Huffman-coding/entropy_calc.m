function H = entropy_calc(sequence)
    symbols = unique(sequence);
    counts = histc(sequence, symbols);
    p = counts / length(sequence);
    p_nonzero = p(p > 0);
    H = -sum(p_nonzero .* log2(p_nonzero));
    disp(['Entropy: ', num2str(H), ' bits']);
end
