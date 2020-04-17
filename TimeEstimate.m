function [ AEST,ALST ] =  TimeEstimate( TaskDAG, ServerList, TransRate, UserList, UserNum, delta)
% TimeEstimate 根据DAG和传输速率估算任务平均最早开始时间AEST和平均最晚开始时间ALST
% 输入：
%   -TaskDAG：用户UserNum的任务DAG图，（i,i）CPU cycles,(i,j)=x (j,i)=-x 边从i到j，通信开销x KB
% 输出：
%   -AEST&ALST (ms)


    % 计算任务i中每个子任务的的平均计算时间和通信消耗时间
        % 任务i中子任务的平均计算开销 ms
    MeanComputeCost = zeros(1, UserList(UserNum).NodeCount);
        % 任务i中每个子任务间的平均通信开销 ms(inf表示子任务之间无通信关系);i->j, (i,j)>0 (j,i)<0
    MeanCommunCost = zeros(UserList(UserNum).NodeCount,UserList(UserNum).NodeCount); 
        % 变量初始化--MeanComputeCost
    for i = 1 : UserList(UserNum).NodeCount
        SumComputeCost = 0;  % 所有子任务总CPU cycles (Mega)
        for j = 1 : UserList(UserNum).NodeCount
            SumComputeCost = SumComputeCost + TaskDAG(j,j); 
        end
        MeanComputeCost(1,i) = SumComputeCost/UserList(UserNum).CPUFreq;  % Megacycles/GHz = ms

    end
        % 变量初始化--MeanCommunCost
            % 计算服务器阵列与用户i的平均通信速率MeanTransRate
    MeanTransRate = 0;
    for s = 1 : ServerList.ServerCount
        MeanTransRate = MeanTransRate + TransRate(UserNum,s);
    end    
    MeanTransRate = MeanTransRate / ServerList.ServerCount;
    for t1 = 1 : UserList(UserNum).NodeCount  % suntask t1
       for t2 = 1  : UserList(UserNum).NodeCount  % suntask t2
          % 先判断子任务t1-t2是否有通信关系。若存在通信关系，求得任务i和每个服务器的传输速率平均值，t1-t2传输数据大小/平均传输速率
          % 得到每个子节点间的平均通信开销
          if TaskDAG(t1,t2) ~= 0    % 两个子任务存在通信关系
              MeanCommunCost(t1,t2) = TaskDAG(t1,t2)/MeanTransRate;
              MeanCommunCost(t2,t1) = -MeanCommunCost(t1,t2);
          else
              MeanCommunCost(t1,t2) = inf;
              MeanCommunCost(t2,t1) = inf;
          end
       end
    end

    % 计算UserNum用户的AEST和ALST
    AEST = zeros(1,UserList(UserNum).NodeCount)-1;
    ALST = AEST;
    AEST = GetAEST(TaskDAG,UserNum,UserList(UserNum).NodeCount,MeanCommunCost,MeanComputeCost);
    ALST(1,UserList(UserNum).NodeCount) = AEST(1,UserList(UserNum).NodeCount);
    ALST = GetALST(TaskDAG,UserNum,UserList(UserNum).NodeCount,MeanCommunCost,MeanComputeCost);
    
end
