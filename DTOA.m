function [ SchedulResult ] = DTOA( TaskDAG, ServerList, TransRate, UserList, delta)
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
%   -ScheduleResult:调度结果(J*(M+1)) J为子任务数目，第1列表示本地执行，元素只有1和0两类


end

