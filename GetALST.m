function [ ALST ] = GetALST(  TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost  )
%GetALST �����û�UserNum������������ALST
%   ALST = min{��̽ڵ�ALST-���̽ڵ��ƽ��ͨ�ſ���}-���ڵ��ƽ�����㿪��
% һ��ʼ֪������ĩβ�ڵ㣬�Ӻ���ǰ��
    for i = (NodeCount-1) : -1 : 1
        ALST = GetALSTNode(TaskDAG, UserNum, NodeCount, MeanCommunCost, MeanComputeCost, i);
    end
end

