function [un, vn, wn] = dgvf_calc(I, niter, miu, dt, dx, dy, dz)
	% Generate the diffusion gradient vector field as in Xu and Prince 1998
	% dgvf_calc is the three dimensional extension of the 2D version described in Equation 12
	% Xu and Prince 1998,"Snakes, Shapes, and Gradient Vector Flow", IEEE Transactions on Image Processing Vol.7(3)
    % Input:
    %			I: three dimensional image (matrix)
    %			miu: the smoothing parameter (more smoothing -- higher miu-- for noisy images)   
	%			niter: number of iterations
	%			dt: time step
	%			dx, dy,dz: pixel spacing, set all to one for isotropic images
	% Output:
	%			un, vn, wn: the gradient vector field
	% Example usage:
	%			[un vn wn] = dgvf_calc(I,sqrt(numel(I)), 0.5, 1, 1, 1, 1)
    %
    % Author:   Dr.Khaled Khairy, Janelia Farm Research Campus, Howard Hughes Medical Institute.
    %			June 2011. Please send corrections or comments to khairyk@janelia.hhmi.org
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
verbose = 0;
[un, vn, wn] = gradient(double(I)); 
E = -sqrt(un.^2 + vn.^2 + wn.^2); 		% Energy as in Xu and Prince 1998 Equation 2
                                        % if the image is a line drawing
                                        % then use: E = I --> Eq. 4
[fx, fy, fz] = gradient(-E); clear E;	
b = fx.^2 + fy.^2 + fz.^2;              % Equation 15
c1 = b.*fx; clear fx
c2 = b.*fy; clear fy
c3 = b.*fz; clear fz
r = miu*dt/dx/dy/dz;                	% Equation 17 (Xu and Prince 1998)
if (dt>(dx*dy*dz/6/miu)), disp('convergence not guaranteed!!!! Resetting dt');dt =(dx*dy*dz/6/miu/2);disp(dt);end; % Equation 18
if verbose, disp('Calculating 3D diffusion gradient vector field');end
%% Start the time stepping (Xu Prince 1998 p.363 using 3D version of Equation 16 (Xu and Prince 1998)
for n = 1:niter,        
    if verbose,disp(['Diffusion gradient calculation iteration : ' num2str(n) '  of  ' num2str(niter)]);end
    
    un = (1-b.*dt).*un+ r.*(  circshift(un,[-1  0  0])...
        + circshift(un,[ 1  0  0])...
        + circshift(un,[ 0 -1  0] )...
        + circshift(un,[ 0  1  0] )...
        + circshift(un,[ 0  0 -1] )...
        + circshift(un,[ 0  0  1])...
        - 6.*un)...
        + c1.*dt;
    
    vn = (1-b.*dt).*vn+ r.*(  circshift(vn,[-1  0  0])...
        + circshift(vn,[ 1  0  0])...
        + circshift(vn,[ 0 -1  0] )...
        + circshift(vn,[ 0  1  0] )...
        + circshift(vn,[ 0  0 -1] )...
        + circshift(vn,[ 0  0  1])...
        - 6.*vn)...
        + c2.*dt;
    wn = (1-b.*dt).*wn+ r.*(  circshift(wn,[-1  0  0])...
        + circshift(wn,[ 1  0  0])...
        + circshift(wn,[ 0 -1  0] )...
        + circshift(wn,[ 0  1  0] )...
        + circshift(wn,[ 0  0 -1] )...
        + circshift(wn,[ 0  0  1])...
        - 6.*wn)...
        + c3.*dt;
end
if sum(isnan([un(:)' vn(:)' wn(:)']));error('diffusion gradient calculation failed');end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
