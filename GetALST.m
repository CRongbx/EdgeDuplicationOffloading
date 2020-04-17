function [ ALST ] = GetALST(  TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost  )
%GetALST 计算用户UserNum的所有子任务ALST
%   ALST = min{后继节点ALST-与后继节点的平均通信开销}-本节点的平均计算开销
% 一开始知道的是末尾节点，从后往前算
    for i = (NodeCount-1) : -1 : 1
        ALST = GetALSTNode(TaskDAG, UserNum, NodeCount, MeanCommunCost, MeanComputeCost, i);
    end
end

