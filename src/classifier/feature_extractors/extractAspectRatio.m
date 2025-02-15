function aspectVal = extractAspectRatio(bw)
L = extractPhysiologicalLength(bw);
W = extractPhysiologicalWidth(bw);
if isempty(W) || W == 0
    aspectVal = [];
else
    aspectVal = L / W;
end
end
