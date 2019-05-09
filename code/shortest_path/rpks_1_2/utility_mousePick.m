function [ pick_id ] = utility_mousePick( X, N )
    figure;
    scatter(X(:,1),X(:,2),'ro');
    title('Select boundary conditions (i.e. two points)')
    pick = zeros(N,2);
    [pick(:,1),pick(:,2)] = ginput(N);
    close;
    
    dst_mtx = utility_dstMtx(X(:,[1,2]),pick);
    [~,pick_id]=min(dst_mtx,[],1);
end

