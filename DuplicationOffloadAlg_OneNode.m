function [ schedule,scheduletable,initialAllocation ] = DuplicationOffloadAlg_OneNode( taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,except, schedule,scheduletable,schedulelength,candidateNode,allowDuplication,computeStartup,searchStart,timeslot,initialAllocation)
        % 对单个子任务CandidateNode执行DOA算法()
        ftime = inf;    % earliest finish time
        flag = 0; % 标志是否有duplication
        processor = -1;
        % 1 REST; 2 REFT。其中REST的递增排序体现了每个子任务在处理器的调度顺序
        schedulerank = zeros(2,schedulelength,serverCount+1)-1; 
        for p = 1 : serverCount+1
            temp = schedule(:,1:schedulelength,p); % schedule(:,MaxNodeCount,:)
            temp = sortrows(temp',1);
            schedulerank(:,:,p) = temp';
        end 
        
        processorComPower = [serverComList,localComPower];
        for s1 = 1 : (serverCount+1)
            if except(candidateNode,s1) == 1
                % 若候选子任务不能卸载到处理器s1
                continue;
            end
            
            % scheduletemp为特定某处理器上的schedulerank
            scheduletemp = schedulerank(:,:,s1);
            
            % 在没有Duplication的情况下尝试将candidateNode调度到S1上，计算REFT，将这种调度产生的结果存到schedule_backup
            [~,REFT,schedule_backup,~,~] = InsertSchedule(taskDAG,nodeCount,processorComPower,serverCount,transRate,transData,computeCost,candidateNode,s1,schedule,scheduletable,scheduletemp,schedulelength,computeStartup,searchStart,timeslot);
            if REFT < ftime
                ftime = REFT;
                % save scheduling result
                flag = 0;
                processor = s1;
                    % 最后一次调度产生的结果
                schedule_last = schedule_backup;
                scheduletable_last = scheduletable;
                scheduletable_last(candidateNode,s1) = 1;
            end 
            
            % get "Critical Predecessor"(CP)
            [~,critical_task] = GetLastestPredecessorTime(taskDAG,nodeCount,serverCount, transRate,transData,s1,candidateNode,scheduletable,schedule,computeStartup,searchStart);
            critical_task_backup = critical_task;   % 备份一下，因为duplication的引入可能会改变critical predecessor
            
            if  critical_task ~= -1
                % 存在critical predecessor
                for s2 = 1 : serverCount+1
                    critical_task = critical_task_backup;
                    if except(critical_task,s2) == 1 || allowDuplication(1,critical_task) == 0
                        % CP不允许迁移到s2，或者不允许有Duplication
                        continue;
                    end
                    
                    % recompute candidatennode's REFT with CP duplication on s2; 
                    % if CP flush, then recompute,unil no new CP (goto语句的实现)
                    scheduletemp = schedulerank(:,:,s2);
                    scheduletable_backup = scheduletable;
                    schedule_backup = schedule;
                    
                    while 0 < 1
                        if critical_task == -1
                            break;
                        end
                        if except(critical_task,s2) == 1 || allowDuplication(1,critical_task) == 0
                            break;
%                             continue;
                        end
                        if scheduletable_backup(critical_task,s2) ~= 1
                            % 处理器s2上没有CP的重复子任务时才需要设置，否则不需要
                            % 如何实现duplcation?
                            %   -保持原调度不变，先将CP插入S2（line 86）；再按上一步产生的调度表计算candidateNode插入s1(line 90)
                            [~,~,schedule_backup,scheduletable_backup,scheduletemp] = InsertSchedule(taskDAG,nodeCount,processorComPower,serverCount,transRate,transData,computeCost,critical_task,s2,schedule,scheduletable,scheduletemp,schedulelength,computeStartup,searchStart,timeslot); 
                        else
                            break;
                        end
                        [~,REFT] = InsertTimeCompute(taskDAG, nodeCount,processorComPower,serverCount,transRate,transData,computeCost,candidateNode,s1,scheduletable_backup,schedule_backup,scheduletemp,schedulelength,computeStartup,searchStart,timeslot);
                        
                        if ftime > REFT
                           ftime = REFT;
                           % save scheduling result
                           schedule_last = schedule_backup;
                           scheduletable_last = scheduletable_backup;
                           if s1 == s2
                               scheduletemp_last = scheduletemp;
                           else
                               scheduletemp_last = schedulerank(:,:,s1);
                           end
                           flag = 1;
                           processor = s1;
                        else
                            break;
                        end
                        % recompute critical task 
                        [~,critical_task] = GetLastestPredecessorTime(taskDAG,nodeCount,serverCount, transRate,transData, s1,candidateNode,scheduletable_backup,schedule_backup,computeStartup,searchStart);
                    end % while 0 < 1
                end % for s2
            end % if  critical_task ~= -1
        end % for s1
        
        schedule = schedule_last;
        scheduletable = scheduletable_last;
        if flag == 1
            % 存在duplication，candidatenode需要重新计算下其在processor执行且前驱节点存在重复子任务时的调度
            [~,~,schedule,scheduletable,~] = InsertSchedule(taskDAG,nodeCount,processorComPower,serverCount,transRate,transData,computeCost,candidateNode,processor,schedule_last,scheduletable_last,scheduletemp_last,schedulelength,computeStartup,searchStart,timeslot);
        end 
        initialAllocation(candidateNode,processor) = 1;
    end % function DuplicationOffloadAlg_OneNode

