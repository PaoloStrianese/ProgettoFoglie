function compVal = extractCompactness(bw)
A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    compVal = [];
else
    compVal = P / (2 * sqrt(pi*A));
end
end
