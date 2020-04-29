function [ userNum,offloadDecision,duplicationInid,scheduleTable ] = DuplicationOffloadAlg( taskDAG,userNum,nodeCount,MaxNodeCount,localComPower,  serverComList,serverCount, transRate,delta)
% Duplication based offloading algorithm1
%   serverComList 服务器计算能力列表（GHZ）
%   transRate (用户,服务器)的通信速率矩阵（）
% 输出：对于用户i 1. 哪个处理器执行offloadDecision_forOne  行数：子任务数量；列数：处理器M+1，最后一列为本地处理器；
% 2.是否有重复子任务duplicationInid_forOne 行数1；列数：子任务数量（最大节点个数）  若该子任务存在重复子任务为1，否则为0
% 3.处理器调度顺序scheduleTable_forOne  (1，子任务编号（最大节点个数）)
% 每个处理器的对于同一任务中所有子任务的调度优先级一致

    % rank the subtask of DAG into ranklist by increasing order
    % ranklist[1,Nodecount of task UserNum] 越小越优先,从1开始按照优先级递增顺序排序，第二列存储子任务编号
    ranklist = GetRankList(taskDAG,nodeCount,localComPower,  serverComList,serverCount,transRate, delta);
    
    % isscheduled[1, Nodecount] 1处理过，0未处理. schedulelen 已处理的子任务个数
    isscheduled = zeros(1,nodeCount);
    schedulelen = 0;
     
    % predecessorlist处理器列表，最后一列为local processor,第一行表示CPU主频（GHZ）,第二行表示处理器是否空闲，0表示空闲，1相反
    processorlist = [serverComList,localComPower;zeros(1,serverCount+1)];  % ,横向拼接 ;纵向拼接
    offloadDecision = zeros(MaxNodeCount,serverCount+1);
    duplicationInid = zeros(1,MaxNodeCount);
    scheduleTable = zeros(1,MaxNodeCount);
    scheduleRank = 1;   % 记录存放scheduleTable的调度优先级，1最高
    
    while schedulelen <= nodeCount  % 当ranklist中还存在未调度节点时
        
        % 从ranklist中选择优先级最高（最小==队首）且未处理的子任务作为candidateNode
        for i = 1 : nodeCount
            if isscheduled(1,ranklist(1,i)) == 0
                candidateNode = ranklist(1,i);
                break;
            end
        end % for i
        
        earliest_finish_time = inf;
        actual_finish_time = zeros(1,nodeCount) -1;   
        actual_start_time = zeros(nodeCount,serverCount+1) -1; 
        temp_schedule = zeros(nodeCount,serverCount+1); % 1表示节点i卸载到处理器j上，反正为0
        
        % for each processor s1 in s (including local prdcessor)
        for s1 = 1 : serverCount+1
            % compute the actual finish time(AFT) of subtask[candidateNode] on processor s1 
            % without duplication
            temp_schedule = offloadDecision;
            temp_schedule(candidateNode,s1) = 1;
            [actual_finish_time,actual_start_time] = GetAFT(taskDAG,nodeCount,serverCount,transRate, processorlist, candidateNode, s1,actual_finish_time,actual_start_time,temp_schedule);
            
            if actual_finish_time(1,candidateNode) < earliest_finish_time
                earliest_finish_time = actual_finish_time(1,candidateNode);
                processorlist(2,s1) = 1; % 处理器S1标注忙碌
                % save schedule result
                offloadDecision(candidateNode,s1) = 1;
                duplicationInid(1,candidateNode) = 0;
                scheduleTable(1,candidateNode) = scheduleRank;
            end % if
            
            % 找到子任务cnadidateNode的关键前驱子任务critical predecessor，其开始时间依赖这个关键前驱任务的计算结果到达时间。
            %-定义在子任务的所有前驱子任务中，到达时间最晚的节点就是critical predecessor
            % ##############3GetCriticalPredecessor 参数需要补充！！！！！！！！！！！！！！！！！
            critical_predecessor = GetCriticalPredecessor(taskDAG,nodeCount,candidateNode); % 返回节点编号
            
            for s2 = 1 : serverCount+1
                % compute the actual finish time(AFT) of subtask[candidateNode] on processor s1 
                % with critical_predecessor has duplication on s2
           
            % 计算caritical_predecessor在本地或s1处理器上有Duplication时的结束时间
            [AFT_s,~] = GetAFT_Duplication(taskDAG,userNum,nodeCount,serverCount,transRate, processorlist, candidateNode, s1,s1,actual_finish_time,actual_start_time);
            [AFT_l,~] = GetAFT_Duplication(taskDAG,userNum,nodeCount,serverCount,transRate, processorlist, candidateNode, s1,serverCount+1,actual_finish_time,actual_start_time);
           
            if AFT_l < earliest_finish_time || AFT_s < earliest_finish_time
                if AFT_l < AFT_s
                    earliest_finish_time = AFT_l;
                % save schedule result
                offloadDecision(candidateNode,s1) = 1;
                duplicationInid(1,candidateNode) = 1;
                scheduleTable(1,candidateNode) = scheduleRank;
                % 更新后，关键前驱子任务的到达时间改变，所以candidate的关键前驱子任务可能不再是之前的那个
                temp_critical_predecessor = GetCriticalPredecessor(taskDAG,nodeCount,candidateNode); % 返回节点编号
                if temp_critical_predecessor == critical_predecessor 
                    % 没有改变关键前驱子任务，本次循环结束，继续寻找下一个s2
                    isgoto = 0;
                    continue;
                else
                   % goto line 12(Algorihtm 1)
                   isgoto = 1;
                end
             end % if

            end % for s2
        end % for s1
        scheduleRank = scheduleRank+1;
        isscheduled(1,candidateNode) = 1; % mark candidatenode as scheduled
    end % while
    
end % function DuplicationOffloadAlg

