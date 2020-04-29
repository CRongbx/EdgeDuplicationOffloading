function [ ALST ] = GetALST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate, AEST_end)
%GetALST 计算actual lastest start time 
%   此处显示详细说明
    mean_compute_time = GetMeanComputeTime(taskDAG,nodeCount,localComPower,  serverComList,serverCount);
    mean_communicate_time = GetMeanCommunicateTime(taskDAG,nodeCount ,serverCount, transRate);
    
    ALST = zeros(1,nodeCount)-1;  % 未处理节点的ALST为-1
    ALST(1,nodeCount) = AEST_end; 
    
    for node = (nodeCount-1) : -1 : 1
        ALST = GetALST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, ALST, node);
    end % for node


function [ALST] = GetALST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, ALST, node)
% 递归计算ALST，返回节点node的ALST
    if ALST(1,node) > 0
        % 已经计算过，直接返回
        return 
    end
    
    min_ALST = inf;
    temp = min_ALST;
    
    for k = 1 : nodeCount
        % k in successor(node)
        if taskDAG(k,node) < 0
            if ALST(1,k) < 0
                ALST = GetALST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, ALST, k);
            end
            temp = ALST(1,k)-mean_communicate_time(node,k);
            if temp < min_ALST
                min_ALST = temp;
            end
        end % if
    end % for k
    ALST(1,node) = min_ALST-mean_compute_time(1,node);
end % function GetALST_Node

end % function GetALST

