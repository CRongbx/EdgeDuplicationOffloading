function [actual_finish_time,actual_start_time] = GetAFT(taskDAG,nodeCount,serverCount,transRate, processorlist, candidateNode, s1,actual_finish_time,actual_start_time,temp_schedule)
%GetAFT 计算任务中所有子任务的AFT(actual finish time)和AST(actual start time)
%输入 s1:计算candidatenode的处理器
%    temp_schedule:调度策略(node,server)1表示被调度，反之为0
%输出：actual_finish_time (1,nodeCount);
%     actual_start_time (nodeCount,serverCount+1)   
%   
    compute_time = zeros(nodeCount,serverCount+1); % 计算时延
    for i = 1 : nodeCount
        for s = 1 : serverCount+1
            compute_time(i,s) = taskDAG(i,i)/processorlist(1,s);
        end 
    end
    
    communicate_time = zeros(nodeCount,nodeCount,serverCount+1); % 子任务通信时延    
    
 
    max_delay = -1;
    temp_delay = -1;
    min_delay = inf; 
    temp_delay_withoutd = inf; temp_delay_withd = inf;  
    for l = 1 : nodeCount
        if taskDAG(candidateNode,l) < 0 % 遍历所有candidatenode的前驱节点，寻找最大值
            % 计算communicate_time（candidateNode,l,s1）
            if temp_schedule(candidateNode,s1) == temp_schedule(l,s1)
                communicate_time(candidateNode,l,s1) = 0;
            else
                communicate_time(candidateNode,l,s1) = taskDAG(l,candidateNode)/transRate(serverCount+1,s1);
            end
            % 判断l是否存在duplication
            [isduplication,dserver] = IsDuplication(serverCount,temp_schedule,l,s1);
            if isduplication == 0 % 不存在Duplication
                temp_delay =  actual_finish_time(1,l) + communicate_time(candidateNode,l,s1);
            else % 存在dulication
                temp_delay_withoutd = actual_finish_time(1,l) + communicate_time(candidateNode,l,s1);
                % 计算temp_delay_withd = actual_finish_time(1,
                % 计算
            end % if isduplication == 0
            if temp_delay > max_delay
                max_delay = temp_delay;
            end 
        end % if taskDAG(candidateNode,l) < 0
    end % for l
    wait_data_ready_time = max_delay;  % 等待前驱节点输出数据准备好的时延
    
    
    [lastest_finish_time,~] = GetProcessorAvailableTime(taskDAG,nodeCount,serverCount,transRate, autual_finish_time,s1,candidateNode,temp_schedule);
%     processor_available_time = max(timeslot,lastest_finish_time);   % 处理器s1，空闲可用的时间。Max{timeslot, 该处理器中最后一个执行的前驱任务完成时间}
    processor_available_time = lastest_finish_time;
    
    
    actual_start_time(candidateNode,s1) = max(processor_available_time,wait_data_ready_time);
    
    
    min_finish_time = inf;  temp_min_finish_time = inf;
    for k = 1 : serverCount+1
        temp_min_finish_time = actual_start_time(candidateNode,k) + compute_time(candidateNode,k);
        if min_finish_time > temp_min_finish_time
            min_finish_time = temp_min_finish_time;
        end
    end % for k
    actual_finish_time(1,candidateNode) = min_finish_time;
    
    
    
    
    function [isduplication,dserver] = IsDuplication(serverCount,schedule,node,s1)
        % 根据调度表，判断node是否存在除服务器s1之外的重复子任务，若存在isduplication为1，反之为0
        % dserver为重复子任务的执行server（不包括s1）,若不存在为-1
        for dserver = 1 : serverCount+1
            if dserver ~= s1 && schedule(node,dserver) == 1
                isduplication = 1;
                return;
            end 
        end % for dsserver
        isduplication = 0;
        dserver = -1;
    end % function IsDuplication
    
end % function GetAFT
