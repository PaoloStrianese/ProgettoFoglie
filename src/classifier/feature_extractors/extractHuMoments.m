function out = extractHuMoments(image)
eta = SI_Moment(image);
out = Hu_Moments(eta);
end