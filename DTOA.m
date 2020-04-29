function [ Schedule, ScheduleTable, InitialAllocate ] = DTOA( TaskDAG, ServerList, TransRate, UserList, UserNum, delta)
%DTOA: Algorithm1: the Duplication-based task offloading Algorithm
%算法限制: 单用户，多服务器，服务器资源异构，不考虑用户能耗限制
%输入: 
%   -TaskDAG：用户i的任务DAG图，（i,i）CPU cycles,(i,j)=x (j,i)=-x 边从i到j，通信开销x KB
%   -ServerList: 服务器阵列 三个元素：CPUFreq,IsIdle(1空闲),ServerNum(编号),ServerCount（总数）
%   -TransRate: 用户i和服务器j的通信速率矩阵（N*M）
%   -UesrList:用户列表 三个元素：CPUFreq, EnergyAware, UserCount（总用户数）,NodeCount(子任务数量)
%   -UserNum: 该用户的编号
%   -delta: Rank阶段，判断AEST和ALST相等的误差范围
%输出：
%   -ScheduleTable 即调度表 行数是Nodenum 列数是Servernum+1 最后一列代表本地 1代表某个任务被分配到该核执行（由于复制有可能分配到多个核）=0代表未分配到该核

    RankList = DAGRank(TaskDAG, ServerList, TransRate, UserList, UserNum, delta);
    % 系统中所有的predecessor,最后一列代表本地，第一行表示CPU freq，第二行表示是否
    PredecessorList = zeros(2,(ServerList.ServerCount)+1)-1;
  
    % 对RankList中的每一个子任务进行调度
    for i = 1 : UserList(UserNum).NodeCount
       CandidateTask = RankList(1,i);   % 待处理子任务的编号
       [Schedule,Scheduletable,InitialAllocate] = 
    end  % for i

end   % function DTOA


function [Schedule, ScheduleTable, InitialAllocate] = DuplicationSchedule
    (TaskDAG, UserCount, CandidateTask,ServerCount, Schedule, ScheduleTable, InitialAllocate, ScheduleLength, ComputeCost, Transdata, ComputePower, TransRate, )
% DuplicationSchedule 对子任务CandateTask(编号)运行DTOA alg1，进行卸载调度
% 输出：
    

end  % function DuplicationSchedule


