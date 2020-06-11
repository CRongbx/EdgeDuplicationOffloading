function [AEST] = GetAEST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate,transData,computeCost)
%GetAEST 计算actual earliest start time 

    % (1,nodeCount)获得用户userNum中每个节点的平均计算延迟：平均「计算量/处理器计算能力（服务器+本地）」
    mean_compute_time = GetMeanComputeTime(nodeCount,computeCost, localComPower,serverComList,serverCount);
    % (nodeCount,nodeCount)获得用户userNum中每个节点的平均通信延迟：平均『节点i与每个处理器的通信量/每个处理器之间的传输速率』
    mean_communicate_time = GetMeanCommunicateTime(taskDAG,nodeCount ,serverCount, transRate,transData);
    
    AEST = zeros(1,nodeCount)-1; % 未处理节点的AEST为-1
    AEST(1,1) = 0;
    
    for j = 2 : nodeCount
        AEST = GetAEST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, AEST, j);
    end % for j




function [AEST] = GetAEST_Node(taskDAG,nodeCount, meanComputeTime, meanCommunicateTime, AEST,node)
% 递归计算AEST，返回节点node的AEST
    if AEST(1,node) > 0
        % 已经计算过，直接返回
        return 
    end
    max_AEST = -1;
    temp = max_AEST;
    for l = 1 : nodeCount 
        % l in predecessor(node)
        if taskDAG(node,l) < 0
            if AEST(1,l) < 0
                AEST = GetAEST_Node(taskDAG,nodeCount, meanComputeTime, meanCommunicateTime, AEST, l);
            end
            temp = AEST(1,l)+meanComputeTime(1,l)+meanCommunicateTime(l,node);
            if temp > max_AEST
                max_AEST = temp;
            end 
        end 
    end % for l
    AEST(1,node) = max_AEST;
end % funcation GetAEST_Node

end % funcation GetAEST
