function [ avgdelay,schedule,scheduletable,channel,timeslotArray ] = GameDETO( taskDAGList,nodeCount,userCount,serverCount,iterationnum,transData,computeCost,localComList,serverComList,transRate,computeStartup,searchStart,except,allowDuplication,transEnergy,computeEnergy,delta,sthelse )
%GameDETO Alg4 分布式调度算法DETO 博弈论
%   此处显示详细说明
    
    % 变量初始化
    avgdelay = zeros(1,iterationnum);
    schedule = zeros(2,sum(nodeCount),serverCount+userCount,iterationnum)-1;
    nodeCount_max = max(nodeCount);
    scheduletable = zeros(nodeCount_max,serverCount+1,userCount,iterationnum);
    initialAllocation = zeros(nodeCount_max,serverCount+1,userCount,iterationnum);
    timeslot = 0;
    timeslotArray = zeros(1,iterationnum);
    channel = zeros(userCount,serverCount,iterationnum);
    transRateini = transRate;
    localuserlist = zeros(1,userCount);
    for t = 1 : userCount
        localuserlist(1,t) = t;
    end
    
    % initialize: timeslot(1),a(0) = {0,0,0,...,0} all the users execute locally
    [ schedule(:,:,:,1),scheduletable(:,:,:,1),initialAllocation(:,:,:,1) ] = LocalSchedule( userCount, localuserlist, taskDAGList,nodeCount,userCount,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,0,delta,computeEnergy,transEnergy,schedule(:,1:sum(nodeCount),:,1),scheduletable(:,:,:,1),sum(nodeCount), timeslot,initialAllocation(:,:,:,1));
    [start_current,finish_current,latency_current] = GetLatency(schedule(:,:,:,1),userCount,serverCount,nodeCount);
    latency_last = latency_current;
    finish_last = finish_current;
    avgdelay(1,1) = mean(latency_current);
    timeslot_last = timeslot;
    timeslot = max(finish_current);
    timeslotArray(1,1) = timeslot;
    
    % 每个时隙执行一次迭代
    for i = 2 : iterationnum
        maxImproveRatio = -1; % latencylast/latencycurrent
        for u = 1 : userCount
            minLatencyOverServer = inf;
            % 遍历所有处理器，找到当前时隙执行u任务时延最小的调度方案
            for s = 1 : (serverCount+1)
                scheduletemp = zeros(2,sum(nodeCount),serverCount+userCount)-1;
                [ ~,transRate,~ ] = RegetBandwidth( channel(:,:,(i-1)),transRateini,userCount,serverCount,u,s );
                [scheduletemp(:,:,1:serverCount),channeltemp] = DuplicationLastSchedule(userCount,schedule(:,:,1:serverCount,i-1),channel(:,:,i-1),nodeCount,serverCount,u,s,transData,transRateini,transRate,timeslot,timeslot_last );
                if s == (serverCount+1) || channel(u,s,(i-1)) ~= 1
                    % 对前一时刻没有调度远端的可能，执行一次算法，看看当前时刻能否产生更优效果
                    excepttemp = except;
                    for m = 1 : serverCount
                        if m == s
                            continue;
                        end
                        excepttemp(:,m,u) = 1; % 没有分配channel，即不可将user的任务放在m处理器上执行
                    end % for m
                    % 在多用户中，对u单独调度DETO
                    [scheduletemp,~,~] = MultiUserSchedule(taskDAGList,nodeCount,userCount,u,localComList,serverComList,serverCount,transRate,transData,computeCost,computeStartup,excepttemp,allowDuplication,delta,computeEnergy,transEnergy,scheduletemp,scheduletable(:,:,:,i),sum(nodeCount),0,timeslot,initialAllocation(:,:,:,i));                    
                end % if
                % starttime,finishtime
                [~,~,latency] = GetLatency_ForSingleUser(scheduletemp,serverCount,userCount,u, nodeCount);
                if latency < minLatencyOverServer
                    minLatencyOverServer = latency;
                    channelbackup = channeltemp;
                    transRatebackup = transRate;
                end 
            end % for s
            
            % 当前时隙下新调度方案的提升效果大于设定maxImproveRatio时才可以采纳，否则延续用前一时隙方案            
            if latency_last(1,u)/minLatencyOverServer > maxImproveRatio
               maxImproveRatio = latency_last(1,u)/minLatencyOverServer;
               candidataUser = u;
               transRatemin = transRatebackup;
               channelmin = channelbackup;
            end                                    
        end % for u
        
        if maxImproveRatio <= 1
            % 若前一时隙的latency < 当前时隙latency
            % 则当前到后续时隙后沿用前一时隙的方案
           for j = i : iterationnum
               scheduletable(:,:,:,j) = scheduletable(:,:,:,i-1);
               initialAllocation(:,:,:,j) = initialAllocation(:,:,:,i-1);
               avgdelay(1,j) = avgdelay(1,i-1);
               % 记录REFT和REST的schedule需要加上每次时隙的时间
               schedule(:,:,:,j) = LastToCurrent(schedule(:,:,:,j-1),serverCount,nodeCount,userCount,timeslot,timeslot_last);
               % 更新时隙
               timeslot_last = timeslot;
               timeslot = timeslot + max(latency_last);
               timeslotArray(1,j) = timeslot;
           end 
           break; % break for i (itertationnum)
        end
        
        channel(:,:,i) = channelmin;
        [ schedule(:,:,:,i),scheduletable(:,:,:,i),initialAllocation(:,:,:,i) ] = OffloadingScheme( taskDAGList,nodeCount,userCount,candidataUser,localComList, serverComList,serverCount,channelmin,transRatemin,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule(:,:,:,i),scheduletable(:,:,:,i),sum(nodeCount),0,timeslot,initialAllocation(:,:,:,i) );
        [ start_current,finish_current,latency_current ] = GetLatency( schedule(:,:,:,i),userCount,serverCount,nodeCount );
        
        latency_last = latency_current;
        avgdelay(1,i) = mean(latency_current);
        timeslot_last = timeslot;
        timeslot = max(finish_current);
        timeslotArray(1,i) = timeslot;
        if  i ~= 2 && avgdelay(1,i) == avgdelay(1,i-1) && avgdelay(1,i) == avgdelay(1,i-2)
           % 和前两次迭代相比，本次迭代的avgdelay也没变
           for j = (i+1) : iterationnum
              scheduletable(:,:,:,j) = scheduletable(:,:,:,i);
              initialAllocation(:,:,:,j) = initialAllocation(:,:,:,i);
              avgdelay(1,j) = avgdelay(1,i);
              schedule(:,:,:,j) = LastToCurrent(schedule(:,:,:,j-1),serverCount,nodeCount,userCount,timeslot,timeslot_last);
              timeslot_last = timeslot;
              timeslot = max(latency_last);
              timeslotArray(1,j) = timeslot;
           end
           break; % for i iterationnum
        end
        
    end % for i (itertationnum)
    
    
end

