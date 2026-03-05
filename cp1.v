module CP1(
    input x1, x2, x3, x4, 
    output sum, carry
);
    assign carry = (x4 | x3) & (x2 | x1)
                 | (x4 & x3)
                 | (x2 & x1);

    assign sum = x4 ^ x3 ^ x2 ^ x1
               | (x4 & x3 & x2 & x1);
endmodule

