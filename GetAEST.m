function [ AEST ] = GetAEST( TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost )
%GetAEST �����û�UserNum������������AEST
%   AEST = max{pred_AEST+���ڵ�MeanComputeCost+���ڵ��ǰ���ڵ�ƽ��ͨ�ſ���} 
    AEST(1,1) = 0;  % ��ʼ�ڵ�����翪ʼʱ��Ϊ0
    for i = 2 : NodeCount
       AEST = GetAESTNode(TaskDAG, UserNum,NodeCount, MeanCommunCost,MeanComputeCost,i); 
    end
end

