function [mean_compute_time] = GetMeanComputeTime(nodeCount,computeCost,localComPower, serverComList,serverCount)
% (1,nodeCount)获得用户userNum中每个节点的平均计算延迟：平均「计算量/处理器计算能力（服务器+本地）」
    
    mean_compute_time = zeros(1,nodeCount);
    % 先计算出每个节点在每个处理器上的计算时延，相加，除以处理器个数
    for node = 1 : nodeCount
        for s = 1 : serverCount
            mean_compute_time(1,node) = mean_compute_time(1,node) + computeCost(1,node)/serverComList(1,s);
        end % for s
        % 在加上本地处理器的计算时延
        mean_compute_time(1,node) = mean_compute_time(1,node) + computeCost(1,node)/mean(localComPower);
    end % for node
    mean_compute_time = mean_compute_time/(serverCount+1);
end % function GetMeanComputeTime