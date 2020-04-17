function [ ALST ] = GetALSTNode( TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost,lable )
%GetALSTNode ���������lable��ALST
    if ALST(1,i) >= 0 
        return 
    end
    
    Min = inf;
    for i = 1 : NodeCount
       if TaskDAG(i,lable) < 0 % i��lable�ĺ�̽ڵ�
           if ALST(1,i) < 0
               ALST = GetALSTNode(TaskDAG,UserNum,NodeCount,MeanCommunCost,MeanComputeCost,i);
           end
           temp = ALST(1,i)-MeanCommunCost(lable,i);
           if temp < Min
               Min = temp;
           end
       end
    end
    ALST(i,lable) = Min - MeanComputeCost(1,lable);
end

