

function L = foraging_onebutton_clutLuv
    
    
    %% calibration values
    Lthres = 8;
    delta = 6/29;
    
    fitparam = [0.6748, 21.8418, 9.1180];
    rx = 0.5273; ry = 0.2997; rz = 0.1729;
    gx = 0.3233; gy = 0.5959; gz = 0.0809;
    bx = 0.1521; by = 0.0694; bz = 0.7786;
    XYZn = [37.3279, 36.9788, 69.0775];

    %% Lab to XYZ
    Yconv = @(L,Yn) (Yn.*((L+16)./116).^3).*(L>Lthres) + (Yn.*L.*(3./29).^3).*(L<=Lthres);
    Xconv = @(L,u,v,Yn) Yconv(L,Yn).*(9.*u)./(4.*v);
    Zconv = @(L,u,v,Yn) Yconv(L,Yn).*(12-3.*u-20.*v)./(4.*v);
    XYZconv = @(L,u,v,Yn) [Xconv(L,u,v,Yn), Yconv(L,Yn), Zconv(L,u,v,Yn)];

    
    %% XYZ to RGB
    
    % RGB XYZ
    rxyz = [rx;ry;rz];
    gxyz = [gx;gy;gz];
    bxyz = [bx;by;bz];

    rXYZ = rxyz./ry;
    gXYZ = gxyz./gy;
    bXYZ = bxyz./by;

    % reference point
    xyzn = XYZn./XYZn(2);
    uprimen = 4*XYZn(1)/(XYZn(1)+15*XYZn(2)+3*XYZn(3));
    vprimen = 9*XYZn(2)/(XYZn(1)+15*XYZn(2)+3*XYZn(3));
    
    % conversion matrix
    M1 = [rXYZ,gXYZ,bXYZ];
    invM1 = inv(M1);

    S = invM1*xyzn';

    M2 = M1*diag(S);
    invM2 = inv(M2);
    
    
    %% equisaturation circle
    npoints = 1000;
    colsat = 50;            	% saturation (ratio max gamut for this monitor)
    collum = 100;               % fraction luminance at 45deg viewing angle
    anglist = linspace(0,2*pi,npoints);
    uprime = colsat.*cos(anglist')./(13*collum) + uprimen;
    vprime = colsat.*sin(anglist')./(13*collum) + vprimen;
    XYZmat = XYZconv(collum*ones(npoints,1), uprime, vprime, XYZn(2)*ones(npoints,1));
    RGBmat =  invM2*XYZmat';
    
    L.clutpoints = npoints;
    L.Xrgb = uint8(RGBmat);
    
end