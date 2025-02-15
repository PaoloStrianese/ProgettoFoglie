function rectVal = extractRectangularity(bw)
A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    rectVal = [];
else
    rectVal = (P^2) / A;
end
end
