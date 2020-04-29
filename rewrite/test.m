% 测试单用户场景 算法1DuplicationOffloadAlg.m及其子模块的正确性
% task DAG结构：论文Fig2的例子

% taskDAG = [1,1,5,2,0;-1,2,1,0,3;-5,-1,2,0,2;-2,0,0,4,1;0,-3,-2,-1,1];
taskDAG = [2,2,10,4,0;-2,4,2,0,6;-10,-2,4,0,4;-4,0,0,8,2;0,-6,-4,-2,2];
nodeCount = 5;
localComPower = 1;
serverComList = [3,3,3];
serverCount = 3;
transRate = [0,0,0,2;0,0,0,2;0,0,0,2;2,2,2,0];

% [mean_compute_time] = GetMeanComputeTime(taskDAG,nodeCount,localComPower,  serverComList,serverCount);
% [mean_communicate_time] = GetMeanCommunicateTime(taskDAG,nodeCount ,serverCount, transRate);
% [AEST] = GetAEST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate);
% [ALST] = GetALST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate,AEST(1,nodeCount));

delta = 0.001;
[ ranklist ] = GetRankList( taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate, delta );