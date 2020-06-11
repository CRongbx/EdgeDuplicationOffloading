function [lastest_finish_time,critical_task] = GetLastestPredecessorTime(taskDAG,nodeCount,serverCount, transRate, transData,candidateServer,candidateNode,scheduletable,schedule,computeStartup,searchStart)
%GetLastestPredecessorTime 计算处理器candidateServer在处理candidateTask前，最后一个执行完的前驱子任务的下标及其完成时间
%   若当前该处理器内没有正在执行的任务，不需要等待，则lastest_finish_time=0，critical_task=-1
%   先在每个处理器中寻找最快能够解决任务的处理时间（每个前驱子任务的完成时间），再在这些前驱子任务的完成时间里寻找最大值（最晚完成的前驱子任务时间）
    
    lastest_finish_time = -1; 
    critical_task = -1;

    for node = 1 : nodeCount
        min_processor_finish_time = inf; 
        if taskDAG(candidateNode,node) < 0
            for k = 1 : serverCount+1
                if scheduletable(node,k) == 1 % 前驱节点被分配到k处理器执行
                    if k ==  candidateServer % 前驱节点和目标节点在同一个处理器执行
                        temp_processor_finish_time = schedule(2,searchStart+node,k);
                    else % 前驱节点和目标节点在不同处理器执行
                        temp_processor_finish_time = schedule(2,searchStart+node,k)+computeStartup(1,k)+transData(node,candidateNode)/transRate(k,candidateServer);
                    end % if k ==  candidataServer 
                    if temp_processor_finish_time < min_processor_finish_time
                        min_processor_finish_time = temp_processor_finish_time;
                    end
                end %if schedule(node,k) == 1
            end % for k
            % 该前驱节点node的完成时间为所有处理器中完成时间最短的那个，我们目标最晚前驱子任务完成时间需要比较每个node的完成时间选择最大的那个。
            if min_processor_finish_time > lastest_finish_time
                lastest_finish_time = min_processor_finish_time;
                critical_task = node;
            end
        end % if taskDAG(candidateNode,node) < 0
    end % for node
    
    % 没有找到前驱节点，则不需要等待。lastest_finish_time=0，critical_task=-1
    if critical_task == -1
        lastest_finish_time = 0;
    end
    
    end % function GetLastestPredecessorTime

