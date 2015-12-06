function [inliers, H] = myAffineT(f1, f2, matches)

% tuning parameters
threshvalue=2;
inl_frac_thresh=0.1;
max_itr = 10000;

x1 = double(f2(1:2, matches(2,:))) ;
x2 = double(f1(1:2, matches(1,:))) ;

n = size(x1,2);

for itr=1:max_itr,
    % step 1
    p = randperm(n);
    q = x1(:,p(1:4));
    r = x2(:,p(1:4));
    
    % step 2
    A =    [q(1,1) q(2,1) 0 0 1 0; 0 0 q(1,1) q(2,1) 0 1];
    A = [A; q(1,2) q(2,2) 0 0 1 0; 0 0 q(1,2) q(2,2) 0 1];
    A = [A; q(1,3) q(2,3) 0 0 1 0; 0 0 q(1,3) q(2,3) 0 1];
    A = [A; q(1,4) q(2,4) 0 0 1 0; 0 0 q(1,4) q(2,4) 0 1];
    
    b = [r(1,1); r(2,1); r(1,2); r(2,2); r(1,3); r(2,3); r(1,4); r(2,4)];
    
    x = A\b;
    
    % step 3
    % compute transformed points
    x1t = [x1(1,:)*x(1) + x1(2,:)*x(2) + x(5);
        x1(1,:)*x(3) + x1(2,:)*x(4) + x(6)];
    
    % Step 4
    dists = sqrt((x1t(1,:) - x2(1,:)).^2 + (x1t(2,:) - x2(2,:)).^2);
    inl = dists<=threshvalue;
    inl_frac = sum(inl)/n;
    if inl_frac_thresh<=inl_frac,
        H = [x(1) x(2) x(5); x(3) x(4) x(6); 0 0 1];
        inliers = find(inl);
        return;
    end
end
disp(itr);

end