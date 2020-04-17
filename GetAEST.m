function [ AEST ] = GetAEST( TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost )
%GetAEST 计算用户UserNum的所有子任务AEST
%   AEST = max{pred_AEST+本节点MeanComputeCost+本节点和前驱节点平均通信开销} 
    AEST(1,1) = 0;  % 起始节点的最早开始时间为0
    for i = 2 : NodeCount
       AEST = GetAESTNode(TaskDAG, UserNum,NodeCount, MeanCommunCost,MeanComputeCost,i); 
    end
end

