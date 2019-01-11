

visRel = 0.05;
audRel = 0.06;
fusStd = 0.04;

bimRel = sqrt( ((visRel.^2)*(audRel.^2)) ./ ((visRel.^2)+(audRel.^2)) ); 

sigVal = linspace(-0.2,+0.2,100);

fuseProb = normpdf(sigVal,0,fusStd)./normpdf(0,0,fusStd);

visResp = normcdf(sigVal,0,visRel);
audResp = normcdf(sigVal,0,audRel);
congResp = normcdf(sigVal,0,bimRel);
confRespAud = normcdf( (visRel*sigVal-audRel*sigVal)./(visRel+audRel) ,0,bimRel);
confRespVis = normcdf( (audRel*sigVal-visRel*sigVal)./(visRel+audRel) ,0,bimRel);

confTotVis = fuseProb.*confRespVis + (1-fuseProb).*visResp;
confTotAud = fuseProb.*confRespAud + (1-fuseProb).*audResp;

figure(1)
subplot(1,2,1)
plot(sigVal,visResp, sigVal,audResp, sigVal,congResp, sigVal,confRespVis, sigVal,fuseProb, sigVal,confTotVis)
legend({'Visual','Auditory','Congruent','Conflict','Fusion'})
axis([-0.2,+0.2,0,1])

subplot(1,2,2)
plot(sigVal,visResp, sigVal,audResp, sigVal,congResp, sigVal,confRespAud, sigVal,fuseProb, sigVal,confTotAud)
legend({'Visual','Auditory','Congruent','Conflict','Fusion'})
axis([-0.2,+0.2,0,1])