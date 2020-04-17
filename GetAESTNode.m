function [ AEST ] = GetAESTNode( TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost, lable )
%GetAESTNode ���������lable��AEST
%   AEST = max{pred_AEST+���ڵ�MeanComputeCost+���ڵ��ǰ���ڵ�ƽ��ͨ�ſ���} [�ݹ鴦��]
%   AEST(1,i)��ʼֵΪ-1��(1,1)=0
    if AEST(1,lable) >= 0   % �Ѿ�������������ٵݹ�
     return
    end
    
    Max = -1;
    % ����Ѱ��lable��ǰ���ڵ�i������ǰ���ڵ��AESTҲû������ݹ����
    for i = 1 : NodeCount
        if TaskDAG(lable,i) < 0 % i��lable��ǰ���ڵ�
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

