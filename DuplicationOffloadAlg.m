function [ schedule,scheduletable,initialAllocation ] = DuplicationOffloadAlg( taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,computeEnergy,transEnergy,except,delta, schedule,scheduletable, schedulelength,allowDuplication,computeStartup,searchStart,timeslot,initialAllocation )
% Duplication based offloading algorithm1
%   serverComList 服务器计算能力列表（GHZ）
%   transRate (用户,服务器)的通信速率矩阵（）
%   except (nodecount,serverCount+1) =1表示有些任务不能上传到该核上（比如涉及输入输出的任务，不可卸载到远端）
%   allowDuplication（1,nodecount）是否允许该子任务设置Duplication （1允许，0不允许）
% 输出：对于单个用户
% 1. 哪个处理器执行scheduletable+是否有重复子任务 行数：子任务数量；列数：处理器M+1，最后一列为本地处理器； 
% 2. 处理器调度顺序schedule  两行，第一行REST，第二行REFT，按照REST排序。(2,MaxNodeCount,serverCount+1)
% 3. 卸载处理器决策 initialallocation (MaxNodeCount, serverCount+1)

    % rank the subtask of DAG into ranklist by increasing order
    % ranklist[1,Nodecount of task UserNum] 越小越优先,从1开始按照优先级递增顺序排序，第二列存储子任务编号
    [rankList] = GetRankList(taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,delta);
    for node = 1 : nodeCount
        candidateNode = rankList(1,node);
        [schedule,scheduletable,initialAllocation] = DuplicationOffloadAlg_OneNode( taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,except, schedule,scheduletable,schedulelength,candidateNode,allowDuplication,computeStartup,searchStart,timeslot,initialAllocation);
    end % for node
    % energy-aware 添加energy限制后尝试删除一些卸载决策ScheduleFlush，h()
    % scheduleFlush();
    [ schedule,scheduletable ] = ScheduleFlush( taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,computeEnergy,transEnergy, schedule,scheduletable,schedulelength,computeStartup,searchStart,rankList,timeslot);
   
    
end % function DuplicationOffloadAlg

