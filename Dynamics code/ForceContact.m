function [g] = ForceContact(g,t)

global NFPlate FPlate Body

%%%%%%TO BE FINISHED - PLEASE DO NOT CHANGE%%%%%%%%

%for each ground force
for k=1:NFPlate

    %Evaluate the splines of Forces and COP at time t
    Fxy =   ppval(FPlate(k).Fxy_spline, t);
    Fz =    ppval(FPlate(k).Fz_spline, t);
    CoPxy = ppval(FPlate(k).COPxy_spline, t);
    
    %Simplifying variable use
    i=FPlate(k).i;
    j=FPlate(k).j;
    spi=FPlate(k).spi;
    spj=FPlate(k).spj;
    
    %Deciding in which body to apply the force
    force=[Fxy; Fz];
    Boundary_Point = Body(i).r + Body(i).A * spi;
    
    if CoPxy < Boundary_Point
        %apply force to body i
        [g] = ApplyForce(i,g,force,spi)
    else
        %apply force to body j
        [g] = ApplyForce(j,g,force,spj)
        
    end
    
        
    
    
    
    [force,sPpi] = groundreaction(k,t);
    spi = Body(i).A*sPpi;
    
    %Applys to the right body the force and corresponding Moment
    [g] = ApplyForce(i,g,force,n,sp);
end

end
