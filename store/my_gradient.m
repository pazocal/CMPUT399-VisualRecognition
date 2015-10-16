function [Gx,Gy] = my_gradient(G)

[h,w] = size(G);
Gx = zeros(h,w);
Gy = zeros(h,w);

Gx(:,2:w-1) = (G(:,3:w) - G(:,1:w-2))/2;
Gy(2:h-1,:) = (G(3:h,:) - G(1:h-2,:))/2;

end

