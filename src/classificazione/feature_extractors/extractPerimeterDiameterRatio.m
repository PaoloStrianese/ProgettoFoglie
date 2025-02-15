function ratioVal = extractPerimeterDiameterRatio(bw)
A = extractArea(bw);
P = extractPerimeter(bw);
if isempty(A) || A == 0
    ratioVal = [];
else
    equivDiameter = 2 * sqrt(A/pi);
    ratioVal = P / equivDiameter;
end
end
