function hout=pov_coneplot(varargin)
%CONEPLOT  3D cone plot.
%   CONEPLOT(X,Y,Z,U,V,W,Cx,Cy,Cz) plots velocity vectors as cones
%   at the points (Cx,Cy,Cz) in vector field defined by U,V,W.  The
%   arrays X,Y,Z define the coordinates for U,V,W and must be
%   monotonic and 3D plaid (as if produced by MESHGRID). CONEPLOT
%   automatically scales the cones to fit. 
%   
%   CONEPLOT(U,V,W,Cx,Cy,Cz) assumes [X Y Z] = meshgrid(1:N, 1:M, 1:P)
%   where [M,N,P]=SIZE(U). 
%   
%   CONEPLOT(...,S) automatically scales the cones to fit and then
%   stretches them by S.  Use S=0 to plot the cones without the automatic
%   scaling.
%
%   CONEPLOT(...,COLOR) colors the cones using the array
%   COLOR. COLOR must be a 3D array and be the same size as U. This
%   option only works with cones and not quiver arrows.
%   
%   CONEPLOT(...,'quiver') draws arrows instead of cones (see QUIVER3).
%
%   CONEPLOT(...,'method') specifies the interpolation method to use.
%   'method' can be 'linear', 'cubic', or 'nearest'.  'linear' is the
%   default (see INTERP3).
%   
%   CONEPLOT(X,Y,Z,U,V,W, 'nointerp') does not interpolate the
%   positions of the cones into a volume. The cones are drawn at
%   positions defined by X,Y,Z and are oriented according to
%   U,V,W. Arrays  X,Y,Z,U,V,W must all be the same size.
%
%   CONEPLOT(AX,...) plots into AX instead of GCA.
%
%   H = CONEPLOT(...) returns a PATCH handle in H.
%   
%   Example:
%      load wind
%      vel = sqrt(u.*u + v.*v + w.*w);
%      p = patch(isosurface(x,y,z,vel, 40));
%      isonormals(x,y,z,vel, p)
%      p.FaceColor = 'red';
%      p.EdgeColor = 'none';
%
%      [f verts] = reducepatch(isosurface(x,y,z,vel, 30), .2); 
%      h=coneplot(x,y,z,u,v,w,verts(:,1),verts(:,2),verts(:,3),2);
%      h.FaceColor = 'blue';
%      h.EdgeColor = 'none';
%      [cx cy cz] = meshgrid(linspace(71,134,10),linspace(18,59,10),3:4:15);
%      h2=coneplot(x,y,z,u,v,w,cx,cy,cz,v,2); %color by North/South velocity
%      h2.EdgeColor = 'none';
%
%      axis tight; box on
%      camproj p; camva(24); campos([185 2 102])
%      camlight left; lighting phong
%
%   See also STREAMLINE, STREAM3, STREAM2, ISOSURFACE, SMOOTH3, SUBVOLUME,
%            REDUCEVOLUME.

%   Copyright 1984-2019 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

[fh, x, y, z, u, v, w, cx, cy, cz, s, color, quiv, method, nointerp] = parseargs(nargs,args);

if isempty(s)
  s = 1;
elseif length(s)>1
  error(message('MATLAB:coneplot:ScalarSizeFactor'));
end

if ~isempty(color)
  if ~isequal(size(color), size(u))
    error(message('MATLAB:coneplot:InvalidColorSize'));
  end
end
  

% Take this out when other data types are handled
u = matlab.graphics.chart.internal.datachk(u);
v = matlab.graphics.chart.internal.datachk(v);
w = matlab.graphics.chart.internal.datachk(w);

if isempty(method)
  method = 'linear';
end

if nointerp==1
  x = u;
  y = v;
  z = w;
  u = cx;
  v = cy;
  w = cz;
  % Take this out when other data types are handled
  x = matlab.graphics.chart.internal.datachk(x);
  y = matlab.graphics.chart.internal.datachk(y);
  z = matlab.graphics.chart.internal.datachk(z);
  
  sz = size(x(:));
  if ~isequal(size(y(:)), sz) || ~isequal(size(z(:)), sz) || ...
     ~isequal(size(u(:)), sz) || ~isequal(size(v(:)), sz) || ...
     ~isequal(size(w(:)), sz)  
    error(message('MATLAB:coneplot:InputSizesMustMatch'));
  end
  
  [m,n,p]=size(u); 
  dx = max(x(:)) - min(x(:));
  dy = max(y(:)) - min(y(:));
  dz = max(z(:)) - min(z(:));
  cx = x(:);
  cy = y(:);
  cz = z(:);
  ui = u(:);
  vi = v(:);
  wi = w(:);

else  
  
  [msg, x, y, z] = xyzuvwcheck(x,y,z,u,v,w);  error(msg);
  
  if ~isequal(size(cx), size(cy), size(cz)) 
    error(message('MATLAB:coneplot:SizeMismatch'));
  end

  [m,n,p]=size(u); 
  if isempty(x)
    dx = n-1;
    dy = m-1;
    dz = p-1;
  else 
    dx = max(x(:)) - min(x(:));
    dy = max(y(:)) - min(y(:));
    dz = max(z(:)) - min(z(:));
  end
  
  if isempty(x)
    ui = interp3(u,cx,cy,cz,method);
    vi = interp3(v,cx,cy,cz,method);
    wi = interp3(w,cx,cy,cz,method);
    if ~isempty(color)
      ci = interp3(color,cx,cy,cz,method);
    end
  else
    ui = interp3(x,y,z,u,cx,cy,cz,method);
    vi = interp3(x,y,z,v,cx,cy,cz,method);
    wi = interp3(x,y,z,w,cx,cy,cz,method);
    if ~isempty(color)
      ci = interp3(x,y,z,color,cx,cy,cz,method);
    end
  end
end

% Get the axes if necessary
if isempty(cax)
    cax = gca;
end
fig = ancestor(cax,'figure');

if quiv
  gcfNP = get(fig, 'nextplot');
  set(fig,'NextPlot','add');
  if isprop(cax,'NextPlot')
    gcaNP = get(cax, 'nextplot');
    set(cax,'NextPlot', 'add');
  end
  
  h=quiver3(cax,cx,cy,cz,ui,vi,wi,s);
  
  set(fig, 'nextplot', gcfNP);
  set(cax, 'nextplot', gcaNP);

else
  if s  % based on code from quiver3.m
    % Base autoscale value on average spacing in the x and y and z
    % directions.
    
    delx = dx/n;
    dely = dy/m;
    delz = dz/p;
    del = sqrt(delx.^2 + dely.^2 + delz.^2);
    if del~=0
      len = sqrt((u/del).^2 + (v/del).^2 + (w/del).^2);
      mx = max(len(:));
      if mx==0
	s = 0;
      else
	s = s/mx;
      end
    end
    ui = ui*s; vi = vi*s; wi = wi*s;
  end
  
  conesegments = 14;
  conewidth = 0.333;
  
  [faces, verts] = conegeom(conesegments);
  numcones = size(cx,1);
  flen = size(faces,1);
  vlen = size(verts,1);
  faces = repmat(faces, numcones,1);
  verts = repmat(verts, numcones,1);
  offset = floor((0:flen*numcones-1)/flen)';
  faces = faces+repmat(vlen*offset,1,3);
  
  count_x = 0.1;  

  for i = 1:size(cx,1)
    index = (i-1)*vlen+1:i*vlen;
    len = norm([ui(i),vi(i),wi(i)]);
    verts(index,3) = verts(index,3) * len;
    verts(index,1:2) = verts(index,1:2) * len*conewidth;
    
    verts(index,:) = coneorient(verts(index,:),  [ui(i),vi(i),wi(i)]);
    
    verts(index,1) = verts(index,1) + cx(i);
    verts(index,2) = verts(index,2) + cy(i);
    verts(index,3) = verts(index,3) + cz(i);

    % TODO: Write actual geometry
    fprintf(fh, ['cone {<%0.2f, %0.2f, %0.2f>, %0.2f, <%0.2f, %0.2f, %0.2f>, %0.2f\n'...
                   '        texture { %s }}\n'],...
                   count_x,    2, 0, 0.5,...
                   count_x,    2, 1, 0,...
                   'tex_default');
    count_x = count_x + 1.1;
  end
  
  h = patch('faces', faces, 'vertices', verts, 'parent', cax);
  
  if ~isempty(color)
    fvc = repmat(ci(:)',[vlen 1]);
    set(h, 'facecolor', 'flat', 'facevertexcdata', fvc(:))
  end
end

if nargout==1 
    hout = h;
end

% Register handles with MATLAB code generator
if ~isempty(h)
    if ~isdeployed
        makemcode('RegisterHandle',h,'IgnoreHandle',h,'FunctionName','coneplot');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fh, x, y, z, u, v, w, cx, cy, cz, s, color, quiv, method, nointerp] =...
    parseargs(nin, vargin)

fh = 0;
x = [];
y = [];
z = [];
s = [];
color = [];
method = [];
quiv = 0;
nointerp = 0;

for j=1:3
  if nin>0
    lastarg = vargin{nin};
    if ischar(lastarg) % coneplot(...,'method'),  coneplot(...,'quiver')
      if ~isempty(lastarg)
	lastarg = lower(lastarg);
	if lastarg(1)=='q'
	  quiv = 1;
	elseif lastarg(1)=='n' && length(lastarg)>=2 && lastarg(2)== 'o'
	  nointerp = 1;
	else
	  method = lastarg;
	end
      end
      nin = nin - 1;
    end
  end
end


if nointerp==1 && ~(nin==6 || nin==7)
  error(message('MATLAB:coneplot:WrongNumberOfInputs')); 
end

if nin==7         % coneplot(fh,u,v,w,cx,cy,cz)
  fh = vargin{1};
  u = vargin{2};
  v = vargin{3};
  w = vargin{4};
  cx = vargin{5};
  cy = vargin{6};
  cz = vargin{7};
elseif nin==8     % coneplot(fh,u,v,w,cx,cy,cz,s) or coneplot(u,v,w,cx,cy,cz,color) 
  fh = vargin{1};
  u = vargin{2};
  v = vargin{3};
  w = vargin{4};
  cx = vargin{5};
  cy = vargin{6};
  cz = vargin{7};
  arg7 = vargin{8};
  if length(arg7)==1
    s = arg7;
  else
    color = arg7;
  end
elseif nin==9     % coneplot(fh,u,v,w,cx,cy,cz,s,color) or coneplot(u,v,w,cx,cy,cz,color,s) 
  fh = vargin{1};
  u = vargin{2};
  v = vargin{3};
  w = vargin{4};
  cx = vargin{5};
  cy = vargin{6};
  cz = vargin{7};
  arg7 = vargin{8};
  arg8 = vargin{9};
  if length(arg7)==1
    s = arg7;
    color = arg8;
  else
    color = arg7;
    s = arg8;
  end
elseif nin==10     % coneplot(fh,x,y,z,u,v,w,cx,cy,cz)
  fh = vargin{1};
  x = vargin{2};
  y = vargin{3};
  z = vargin{4};
  u = vargin{5};
  v = vargin{6};
  w = vargin{7};
  cx = vargin{8};
  cy = vargin{9};
  cz = vargin{10};
elseif nin==11    % coneplot(fh,x,y,z,u,v,w,cx,cy,cz,s) or coneplot(x,y,z,u,v,w,cx,cy,cz,color) 
  fh = vargin{1};
  x = vargin{2};
  y = vargin{3};
  z = vargin{4};
  u = vargin{5};
  v = vargin{6};
  w = vargin{7};
  cx = vargin{8};
  cy = vargin{9};
  cz = vargin{10};
  arg10 = vargin{11};
  if length(arg10)==1
    s = arg10;
  else
    color = arg10;
  end
elseif nin==12    % coneplot(fh,x,y,z,u,v,w,cx,cy,cz,s,color) or coneplot(x,y,z,u,v,w,cx,cy,cz,color,s) 
  fh = vargin{1};
  x = vargin{2};
  y = vargin{3};
  z = vargin{4};
  u = vargin{5};
  v = vargin{6};
  w = vargin{7};
  cx = vargin{8};
  cy = vargin{9};
  cz = vargin{10};
  arg10 = vargin{11};
  arg11 = vargin{12};
  if length(arg10)==1
    s = arg10;
    color = arg11;
  else
    color = arg10;
    s = arg11;
  end
else
  error(message('MATLAB:coneplot:WrongNumberOfInputs')); 
end

cx = cx(:); 
cy = cy(:); 
cz = cz(:); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [f, v] = conegeom(coneRes)

cr = coneRes;
[xx, yy, zz]=cylinder([.5 0], cr);
f = zeros(cr*2-2,3);
v = zeros(cr*3,3);
v(1     :cr  ,:) = [xx(2,1:end-1)' yy(2,1:end-1)' zz(2,1:end-1)'];
v(cr+1  :cr*2,:) = [xx(1,1:end-1)' yy(1,1:end-1)' zz(1,1:end-1)'];
v(cr*2+1:cr*3,:) = v(cr+1:cr*2,:);

f(1:cr,1) = (cr+2:2*cr+1)';
f(1:cr,2) = f(1:cr,1)-1;
f(1:cr,3) = (1:cr)';
f(cr,1) = cr+1;
f(cr+1:end,1) = 2*cr+1;
f(cr+1:end,2) = (2*cr+2:3*cr-1)';
f(cr+1:end,3) = f(cr+1:end,2)+1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=coneorient(v, orientation)
cor = [-orientation(2) orientation(1) 0];
if sum(abs(cor(1:2)))==0
  if orientation(3)<0
    vout=rotategeom(v, [1 0 0], 180);
  else
    vout=v;
  end
else
  a = 180/pi*asin(orientation(3)/norm(orientation));
  vout=rotategeom(v, cor, 90-a);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vout=rotategeom(v,azel,alpha)
u = azel(:)/norm(azel);
alph = alpha*pi/180;
cosa = cos(alph);
sina = sin(alph);
vera = 1 - cosa;
x = u(1);
y = u(2);
z = u(3);
rot = [cosa+x^2*vera x*y*vera-z*sina x*z*vera+y*sina; ...
      x*y*vera+z*sina cosa+y^2*vera y*z*vera-x*sina; ...
      x*z*vera-y*sina y*z*vera+x*sina cosa+z^2*vera]';

x = v(:,1);
y = v(:,2);
z = v(:,3);

[m,n] = size(x);
newxyz = [x(:), y(:), z(:)];
newxyz = newxyz*rot;
newx = reshape(newxyz(:,1),m,n);
newy = reshape(newxyz(:,2),m,n);
newz = reshape(newxyz(:,3),m,n);

vout = [newx newy newz];


