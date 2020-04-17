function [ CriticalPath, PathLen ] = FindCriticalPath( AEST, ALST, NodeCount)
%FindCriticalPath 给定任务DAG找到关键路径
%输入：
%   - AEST: the average earliest start time
%   - ALST: the average lastest start time
%   - NodeCount: DAG图中节点数目
%输出：
%   - CriticalPath: 按AEST递增排序的关键路径;  [1,i]:节点i编号; [2,i]:节点i的AEST（关键路径的节点AEST=ALST）
%   - PathLen: 关键路径长度（节点数目）

    PathLen = 0;
    CriticalPath = zeros(NodeCount,2);
    
    for i = 1 : NodeCount
       if AEST(1,i) == ALST(1,i) 
          PathLen = PathLen + 1;
          CriticalPath(1,PathLen) = i;
          CriticalPath(2,PathLen) = AEST(1,i);
       end
    end
    CriticalPath = CriticalPath';   % 矩阵转置
    % sortrows(A,i) 从第i列开始对矩阵A中每一行元素递增排序 (i=1时可省略)（i为负数时表示递减顺序排序）
    CriticalPath = sortrows(CriticalPath, 1);
    CriticalPath = CriticalPath';
end

