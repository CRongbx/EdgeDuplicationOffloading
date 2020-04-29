
function [ ranklist ] = GetRankList( taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate, delta )
%function [ ranklist ] = GetRankList( taskDAG,nodeCount,MaxNodeCount )
%GetRankList 获得DAG中每个子任务的rank，按照优先级从高到低（递增）顺序排序
%   rank依据，借助AOE网络关键路径发，计算AEST（actual earliest start time）和ALST（actual lastest finish time）
%   delta 视AEST和ALST相等的误差范围
    
    ranklist = zeros(1,nodeCount);
    
    AEST = GetAEST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate);
    ALST = GetALST(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate,AEST(1,nodeCount));
%     AEST = [0,2,6,3,10];
%     ALST = [0,3,6,5,10];
    
    stack = zeros(1,nodeCount); 
    stack_pos = 0; % 栈顶元素指针
    rank = 0;
    isranked = zeros(1,nodeCount); % 是否ranked。1ranked,反之为0
    
    for node = 1 : nodeCount
        if abs(AEST(1,node)-ALST(1,node)) < delta
           % 属于关键路径，压栈
           stack_pos = stack_pos + 1;
           stack(1,stack_pos) = node;
           parent = 1;
           while  parent < node
               if taskDAG(node,parent)<0 && isranked(parent)==0
                     % node是否有未rank的父节点
                    % 父节点压栈
                    stack_pos = stack_pos + 1;
                    stack(1,stack_pos) = parent;
               end
               parent = parent + 1;
           end % while
           % 弹栈，设置rank，直到栈空
           while stack_pos > 0
               rank = rank + 1;
               ranklist(1,rank) = stack(1,stack_pos);
               isranked(1,stack(1,stack_pos)) = 1;
               stack_pos = stack_pos - 1;
           end % while
        end % if
    end % for node

end % function GetRankList
