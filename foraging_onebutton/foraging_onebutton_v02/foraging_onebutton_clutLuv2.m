

function L = foraging_onebutton_clutLuv2
    
    
    %% calibration values
    Lthres = 8;
    delta = 6/29;
    
    fitparam = [0.6748, 21.8418, 9.1180];
    rx = 0.5273; ry = 0.2997; rz = 0.1729;
    gx = 0.3233; gy = 0.5959; gz = 0.0809;
    bx = 0.1521; by = 0.0694; bz = 0.7786;
    XYZn = [37.3279, 36.9788, 69.0775];

    %% Lab to XYZ
    Yconv = @(Luv,XYZn) ((Luv(:,1)+16)./116).^3;
    u0conv = @(Luv,XYZn) 4.*XYZn(1)./(XYZn(1)+15.*XYZn(2)+3.*XYZn(3));
    v0conv = @(Luv,XYZn) 9.*XYZn(2)./(XYZn(1)+15.*XYZn(2)+3.*XYZn(3));
    aconv = @(Luv,XYZn) (52.*Luv(:,1)./(Luv(:,2)+13.*Luv(:,1).*u0conv(Luv,XYZn))-1)./3;
    bconv = @(Luv,XYZn) -5.*Yconv(Luv,XYZn);
    cconv = @(Luv,XYZn) -1./3;
    dconv = @(Luv,XYZn) Yconv(Luv,XYZn).*(39.*Luv(:,1)./(Luv(:,3)+13.*Luv(:,1).*v0conv(Luv,XYZn))-5);
    Xconv = @(Luv,XYZn) (dconv(Luv,XYZn)-bconv(Luv,XYZn))./(aconv(Luv,XYZn)-cconv(Luv,XYZn));
    Zconv = @(Luv,XYZn) Xconv(Luv,XYZn).*aconv(Luv,XYZn)+bconv(Luv,XYZn);
    XYZconv = @(Luv,XYZn) [Xconv(Luv,XYZn), Yconv(Luv,XYZn), Zconv(Luv,XYZn)];

    
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
    Luvmat = [collum*ones(npoints,1),colsat.*cos(anglist'),colsat.*sin(anglist')];
    XYZmat = XYZn(2)*XYZconv(Luvmat,XYZn);
    RGBmat =  invM2*XYZmat';
    
    L.clutpoints = npoints;
    L.Xrgb = uint8(RGBmat);
    
end