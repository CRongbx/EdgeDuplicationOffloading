function [mergeTaskDAG,mergeNodeCount] = MergeSomeGraph(taskDAGList,nodeCountList,userList,mergeUserCount)
% 合并用户组DAG
% 输出：mergeTaskDAG 合并后的DAG；mergeNodeCount 合并的节点数量

    % 对合并的用户、DAG等信息初始化
    nodeCount_max = max(nodeCountList);
    mergeTaskDAGArray = zeros(nodeCount_max,nodeCount_max,mergeUserCount); % 合并前的DAG数组
    mergeNodeCountArray = zeros(1,mergeUserCount);
    
    for i = 1 : mergeUserCount
        user = userList(1,i);
        mergeTaskDAGArray(:,:,i) = taskDAGList(:,:,user);
        mergeNodeCountArray(1,i) = nodeCountList(1,user);
    end % for i
    
    %[mergeTaskDAG,mergeNodeCount] = TaskDAGMerged(mergeTaskDAGArray,mergeUserCount,mergeNodeCountArray);
    
    
    % 开始合并DAG
    mergeNodeCount = 0; % 合并DAG中包含的节点数量
    for u = 1 : mergeUserCount
        mergeNodeCount = mergeNodeCount + mergeNodeCountArray(1,u);
    end
    mergeTaskDAG = zeros(mergeNodeCount,mergeNodeCount); % 合并后的DAG
    offset = 0;
    for t = 1 : mergeUserCount
        % 初始化mergeTaskDAG为Array中所有DAG的加和
       mergeTaskDAG((offset+1):(offset+mergeNodeCountArray(1,t)), (offset+1):(offset+mergeNodeCountArray(1,t))) = mergeTaskDAGArray(1:mergeNodeCountArray(1,t),1:mergeNodeCountArray(1,t),t); 
       offset = offset + mergeNodeCountArray(1,t);
    end
    
    mergeTaskDAG_backup = mergeTaskDAG;
        % 合并后需要添加开始节点和结束节点
    mergeTaskDAG = zeros(mergeNodeCount+2,mergeNodeCount+2);
    offset = 1;
    for u = 1 : mergeUserCount
       % 添加边：新起始节点-原起始节点；新结束节点-原结束节点
            % 起始节点
       mergeTaskDAG(1,offset+1) = 1;
       mergeTaskDAG(offset+1,1) = -1;
            % 结束节点
       mergeTaskDAG(offset+mergeNodeCountArray(1,u),mergeNodeCount+2) = 1;
       mergeTaskDAG(mergeNodeCount+2,offset+mergeNodeCountArray(1,u)) = -1;
       offset = offset + mergeNodeCountArray(1,u);
    end
    mergeTaskDAG(2:(mergeNodeCount+1), 2:(mergeNodeCount+1)) = mergeTaskDAG_backup;
    mergeNodeCount = mergeNodeCount + 2;
    
    
end % function MergeSomeGraph