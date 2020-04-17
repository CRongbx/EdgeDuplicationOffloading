function [ RankList ] = DAGRank( TaskDAG, ServerList, TransRate, UserList, UserNum, delta )
%DAGRank 对任务DAG递增排序
%思路：计算AEST(the average earliest start time)和ALST(the average lastest start
%   time)，基于此计算结果确定关键路径（AOE网关键路径法），从而得到排序结果
[AEST, ALST] = TimeEstimate( TaskDAG, ServerList, TransRate, UserList, UserNum, delta);
[CriticalPath, PathLen] = FindCriticalPath(AEST,ALST,UserList(UserNum).NodeCount);
PrioritySort;

end

