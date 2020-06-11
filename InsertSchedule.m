function [ REST,REFT,schedule,scheduletable,scheduletemp ] = InsertSchedule( taskDAG,nodeCount,ProcessorComPower,serverCount,transRate,transData,computeCost,candidateNode,candidateServer,schedule,scheduletable,scheduletemp,schedulelength,computeStartup,searchStart,timeslot)
%InsertSchedule 此处显示有关此函数的摘要
%   此处显示详细说明
   
    [ REST,REFT ] = InsertTimeCompute( taskDAG, nodeCount,ProcessorComPower,serverCount,transRate,transData,computeCost, candidateNode,candidateServer,scheduletable,schedule,scheduletemp,schedulelength,computeStartup,searchStart,timeslot);
    schedule(1,candidateNode+searchStart,candidateServer) = REST;
    schedule(2,candidateNode+searchStart,candidateServer) = REFT;
    scheduletable(candidateNode,candidateServer) = 1;
    
    % 插入candidateNode后，要对原有调度队列的REST和REFT进行更新，只用更新candidateNode后的节点（最迟开始且REFT还没计算）
    if scheduletemp(1,schedulelength) == -1
        scheduletemp(1,schedulelength) = REST;
        scheduletemp(2,schedulelength) = REFT;
    else
        % 寻找最迟开始且REFT还没计算的节点下标
        start_index = 1; end_index = schedulelength;
        k = floor((start_index+end_index)/2);
        while start_index ~= end_index
            if scheduletemp(2,k) == -1
                start_index = k + 1;
            else
                end_index = k;
            end
            k = floor((start_index+end_index)/2);
        end % while
        % 对candidatenode插入后影响的后继节点（k及k之后的点）进行更新REFT和REST
        for t = k : schedulelength
            % 如果该点t的原结束时间 > REFT（候选节点）,则将候选节点插入t-1之后
            if scheduletemp(2,t) > REFT
                scheduletemp(2,t-1) = REFT;
                scheduletemp(1,t-1) = REST;
                t = schedulelength - 1;
                break;
            else
            % 如果t的结束时间 <= REFT,则候选节点插入t-1之前
                scheduletemp(1,t-1) = scheduletemp(1,t);
                scheduletemp(2,t-1) = scheduletemp(2,t);
            end
        end % for t
        if t == schedulelength
            scheduletemp(1,t) = REST;
            scheduletemp(2,t) = REFT;
        end
    end % if scheduletemp(1,nodeCount) == -1
    
end %function

