function [ AEST ] = GetAESTNode( TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost, lable )
%GetAESTNode 获得子任务lable的AEST
%   AEST = max{pred_AEST+本节点MeanComputeCost+本节点和前驱节点平均通信开销} [递归处理]
%   AEST(1,i)初始值为-1，(1,1)=0
    if AEST(1,lable) >= 0   % 已经计算过，不用再递归
     return
    end
    
    Max = -1;
    % 遍历寻找lable的前驱节点i，若该前驱节点的AEST也没计算则递归计算
    for i = 1 : NodeCount
        if TaskDAG(lable,i) < 0 % i是lable的前驱节点
            if AEST(1,i) < 0            
                AEST = GetAESTNode(TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost,i);
            end
            temp = AEST(1,i) + MeanComputeCost(1,i) + MeanCommunCost(i,lable);
            if temp > Max
                Max = temp;
            end
        end
    end
    AEST(1,lable) = Max;
end

