function eccVal = extractEccentricity(bw)
% extractEccentricity: Computes the eccentricity of the object.
%
% Input:
%   bw - binary image containing a single region.
% Output:
%   eccVal - scalar value in [0,1]

stats = regionprops(bw, 'Eccentricity');
if isempty(stats)
    eccVal = [];
else
    eccVal = stats.Eccentricity;
end
end