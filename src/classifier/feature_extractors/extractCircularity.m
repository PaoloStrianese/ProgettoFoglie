function circVal = extractCircularity(bw)
A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(P) || P == 0
    circVal = [];
else
    circVal = (4*pi*A) / (P^2);
end
end
