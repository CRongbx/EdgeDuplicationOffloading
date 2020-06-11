function [ ALST ] = GetALST(taskDAG,nodeCount,computeCost,transData,localComPower,serverComList,serverCount,transRate, AEST_end)
%GetALST 计算actual lastest start time 
%   此处显示详细说明
    mean_compute_time = GetMeanComputeTime(nodeCount,computeCost, localComPower,serverComList,serverCount);
    mean_communicate_time = GetMeanCommunicateTime(taskDAG,nodeCount ,serverCount, transRate,transData);
    
    ALST = zeros(1,nodeCount)-1;  % 未处理节点的ALST为-1
    ALST(1,nodeCount) = AEST_end; 
    
    % 默认最后一个节点为结束节点
    for node = (nodeCount-1) : -1 : 1
        ALST = GetALST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, ALST, node);
    end % for node


function [ALST] = GetALST_Node(taskDAG,nodeCount,mean_compute_time,mean_communicate_time, ALST, node)
% 递归计算ALST，返回节点node的ALST
    if ALST(1,node) < 0
        
        min_ALST = inf;   
        for k = 1 : nodeCount
            % k in successor(node)
            if taskDAG(node,k) > 0
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
    
    else
        % 已经计算过，直接返回
        return 
    end
end % function GetALST_Node

end % function GetALST

