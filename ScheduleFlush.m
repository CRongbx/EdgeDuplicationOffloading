function [ schedule,scheduletable ] = ScheduleFlush( taskDAG,nodeCount,localComPower, serverComList,serverCount,transRate,transData,computeCost,computeEnergy,transEnergy, schedule,scheduletable,schedulelength,computeStartup,searchStart,rankList,timeslot)
%ScheduleFlush 根据能耗限制、同一子任务上传过多处理器带来的不必要开销，进行调度策略的修改调整
%   Algorithm2 的关键部分
% 能耗与时延的平衡模块——LatencyEnergyTrandoff():根据time和energy消耗及能耗限制来削减卸载决策
    
    % 卸载策略中,找到完成最后一个模块的任务的处理器。makespan为整个任务（nodeCount）的结束时间
    for s = 1 : (serverCount + 1)
        if scheduletable(nodeCount,s) == 1
           makespan = schedule(2,searchStart+nodeCount,s);
           break;
        end
    end % for s
    
    % 除最后一个子任务外，按照rank（优先级从高到低）检查每个子任务是否可以删除
    for i = 1 : (nodeCount-1) % 最后一个任务一定不能删除
        checkTask = rankList(1,i);
        for j = 1 : (serverCount+1)
            schedule_backup = schedule;
            scheduletable_backup = scheduletable;
            if GetDuplicationCount(checkTask,scheduletable,serverCount) ~= 1 && scheduletable_backup(checkTask,j) == 1
                % 当一个子任务同时在多个不同的处理器上设置Duplication时是没有必要的，尝试删除
                    % 尝试删除
                schedule_backup(1,searchStart+checkTask,j) = -1;
                schedule_backup(2,searchStart+checkTask,j) = -1;
                scheduletable_backup(checkTask,j) = 0;
                
                    % 删除完checkTask后需要把它"后面"(ranklist)的节点也要重新计算（前驱节点没完成，后面的节点不能开始）
                for p = (i+1):nodeCount
                    t1 = rankList(1,p);
                    for s1 = 1 : (serverCount+1)
                        % 如果后继节点调度了，需要重新计算REFT和REST
                        if scheduletable_backup(t1,s1) == 1
                            schedule_backup(1,searchStart+t1,s1) = -1;
                            schedule_backup(2,searchStart+t1,s1) = -1;
                            % schedule_backup(t1,s1) = 0;
                            schedule_temp = schedule_backup(:,1:schedulelength,s1);
                            schedule_temp = (sortrows(schedule_temp',1))';
                            [REST,REFT] = InsertTimeCompute(taskDAG,nodeCount,[serverComList,localComPower],serverCount,transRate,transData,computeCost,t1,s1,scheduletable_backup,schedule_backup,schedule_temp,schedulelength,computeStartup,searchStart,timeslot);
                            schedule_backup(1,searchStart+t1,s1) = REST;
                            schedule_backup(2,searchStart+t1,s1) = REFT;                            
                        end % if scheduletable_backup(t1,s1) == 1                        
                    end % for s1
                end % for p
                % 上述循环执行完，REST为最后一个节点的值，也是整个任务的Finish time
                % 若删除checkTask后的Finish Time <=
                % 原本的时间（makespan），删除checktask可以采取，修改调度策略
                if REFT <= makespan
                    % 删除策略有效减少时延，可采用
                    schedule = schedule_backup;
                    scheduletable = scheduletable_backup;
                else
                    % 删除策略会增加时延。若以一定时延换取能耗优化，可采用；否则，不可采用，恢复原策略
%                     if LatencyEnergyTradeoff(taskDAG,computeEnergy,transEnergy,schedule_backup,scheduletable_backup,searchStart,) == 1
                        %（本版本程序先默认关闭该选择），该函数的返回值始终是0
                      if 0 > 1
                        schedule = schedule_backup;
                        scheduletable = scheduletable_backup;
                      end                                        
                end % if REFT <= makespan
            end % if 
        end % for j
    end % for i
    
    % 上述步骤后，makespan会改变，需要重新计算
    for s = 1 : (serverCount + 1)
        if scheduletable(nodeCount,s) == 1
           makespan = schedule(2,searchStart+nodeCount,s);
           lastStart = schedule(1,searchStart+nodeCount,s);
           processor = s;
           break;
        end
    end % for s
    % 根据更新后的makespan和lastStart，再删去一批卸载节点
    for s = 1 : (serverCount+1)
        for t = 1 : (nodeCount-1)
           if scheduletable(t,s) == 1
                % 不同处理器 || 同一处理器
                if schedule(2,searchStart+t,s) < lastStart || (((schedule(2,searchStart+t,s)==lastStart) && ((s==processor) || (lastStart == makespan)) ) )
                    % 保留
                else
                    % 删除
                    schedule(1,searchStart+t,s) = -1;
                    schedule(2,searchStart+t,s) = -1;
                    scheduletable(t,s) = 0;
                end 
           end
        end
    end     
        
end % function

