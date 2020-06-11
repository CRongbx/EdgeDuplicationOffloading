
function [ ranklist ] = GetRankList( taskDAG,nodeCount,localComPower,serverComList,serverCount,transRate,transData,computeCost,delta )
%function [ ranklist ] = GetRankList( taskDAG,nodeCount,MaxNodeCount )
%GetRankList 获得DAG中每个子任务的rank，按照优先级从高到低（递增）顺序排序
%   rank依据，借助AOE网络关键路径发，计算AEST（actual earliest start time）和ALST（actual lastest finish time）
%   delta 视AEST和ALST相等的误差范围
    
    ranklist = zeros(1,nodeCount); 

    AEST = GetAEST(taskDAG,nodeCount,localComPower,serverComList,serverCount,transRate,transData,computeCost);
    ALST = GetALST(taskDAG,nodeCount,computeCost,transData,localComPower,serverComList,serverCount,transRate,AEST(1,nodeCount));
%     AEST = [0,2,6,3,10];
%     ALST = [0,3,6,5,10];
    
    
    CP_num = 1;
    for i = 1 : nodeCount
        if abs(AEST(1,i)-ALST(1,i)) < delta
            CP(1,CP_num) = i;
            CP(2,CP_num) = AEST(1,i);
            CP_num = CP_num + 1;
        end
    end 
    CP_num = CP_num - 1;
    CP = CP';
    CP = sortrows(CP,1);
    CP = CP';
    
    stack = zeros(1,nodeCount); 
    stack_pos = 0; % 栈顶元素指针
    isranked = zeros(1,nodeCount); % 是否ranked。1ranked,反之为0
    rank_pos = 1; 
    
    for i = CP_num : -1 : 1
       stack_pos = stack_pos + 1;
       stack(1,stack_pos) = CP(1,i);
       isranked(1,CP(1,i)) = 1;
    end
    
    while stack_pos ~= 0
        % 取栈顶元素处理
        ordernum = stack(1,stack_pos);
        signed = 0;
        for k = 1 : nodeCount
            % 前驱节点入栈
            if taskDAG(k,ordernum) > 0  % k-->ordernum
               if isranked(1,k) == 0
                  isranked(1,k) = 1;
                  % 压栈
                  stack_pos = stack_pos + 1;
                  stack(1,stack_pos) = k;
                  signed = 1;
                  break;
               end
            end
        end % for k
        % 是否有前驱节点入栈
        if signed == 0
            ranklist(1,rank_pos) = ordernum;
            rank_pos = rank_pos + 1;
            stack_pos = stack_pos - 1; % 弹栈
        end
    end % while

end % function GetRankList
