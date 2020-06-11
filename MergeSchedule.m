function [ schedule,scheduletable,initialAllocation ] = MergeSchedule( mergeTaskDAG,mergeNodeCount,nodeCountList,mergeUserCount,mergeUserList,userCount,serverCount,candidateServer,localComList,serverComList,transRate,transData,computeCost,comStartup,searchStart,except,allowDuplication,schedulelength,schedule,scheduletable,initialAllocation,ratio,computeEnergy,transEnergy,delta,timeslot)
%MergeSchedule ALgorithm3：Multiuser对用户组合并后的DAG调度
%   此处显示详细说明
    if mergeUserCount < 1
        return;
    end
    
    % 调度表初始化
    schedule_temp = zeros(2,mergeNodeCount+schedulelength,mergeUserCount+1)-1;
    schedule_temp(:,1:schedulelength,1) = schedule(:,1:schedulelength,candidateServer);
    for u = 1 : mergeUserCount
        schedule_temp(:,1:schedulelength,u+1) = schedule(:,1:schedulelength,candidateServer+mergeUserList(1,u));
    end % for u    
    scheduletable_temp = zeros(mergeNodeCount,mergeUserCount+1);
    except_temp = zeros(mergeNodeCount,mergeUserCount+1);
    allowDuplication_temp = zeros(1,mergeNodeCount);
    initialAllocation_temp = zeros(mergeNodeCount,mergeUserCount+1);
    offset = 1;
    for u = 1 : mergeUserCount
        % 先处理出起始和结束节点（合并DAG新引入的节点）之外的其他节点的调度信息
            % edge server
        except_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,u))),1) = except(1:nodeCountList(1,mergeUserList(1,u)),candidateServer,mergeUserList(1,u));
            % local processor
        except_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,u))),1+u) = except(1:nodeCountList(1,mergeUserList(1,u)),serverCount+1,mergeUserList(1,u));
        for m = 2 : (mergeUserCount+1)
            if m ~= (u+1)
                % merge后的用户组之间不能在互相处理任务
               except_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,u))),m) = 1;
            end 
        end % for m
        
        allowDuplication_temp(1,(offset+1):(offset+nodeCountList(1,mergeUserList(1,u)))) = allowDuplication(1,1:nodeCountList(1,mergeUserList(1,u)),mergeUserList(1,u));
        offset = offset + nodeCountList(1,mergeUserList(1,u));
    end % for u
    localComList_temp = localComList(1,mergeUserList(1,1));
     serverComList_temp = zeros(1,mergeUserCount);
     serverComList_temp(1,1) = serverComList(1,candidateServer);
     for u = 2 : mergeUserCount
          serverComList_temp(1,u) = localComList(1,mergeUserList(1,u));
     end
    comStartup_temp = zeros(1,mergeUserCount+1);
    comStartup_temp(1,1) = comStartup(1,candidateServer);
    for u = 1 : mergeUserCount
%         localComList_temp(1,u) = localComList(1,mergeUserList(1,u));
         
%         computePower_temp(1,1+u) = localComList(1,mergeUserList(1,u));
        comStartup_temp(1,1+u) = comStartup(1,serverCount+mergeUserList(1,u));
    end 
    transRate_temp = zeros(mergeUserCount+1,mergeUserCount+1)+inf;
    for t = 1 : mergeUserCount
        transRate_temp(1,t+1) = transRate(candidateServer,serverCount+1,mergeUserList(1,t));
        transRate_temp(t+1,1) = transRate_temp(1,t+1);
    end 
    transdata_temp = zeros(mergeNodeCount,mergeNodeCount);
    computecost_temp = zeros(1,mergeNodeCount);
    offset = 1;
    for u = 1 : mergeUserCount
       transdata_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,u))),(offset+1):(offset+nodeCountList(mergeUserList(1,u)))) = transData(1:nodeCountList(1,mergeUserList(1,u)),1:nodeCountList(1,mergeUserList(1,u)),mergeUserList(1,u)); 
       computecost_temp(1,(offset+1):(offset+nodeCountList(1,mergeUserList(1,u)))) = computeCost(1,1:nodeCountList(1,mergeUserList(1,u)),mergeUserList(1,u));
       offset = offset + nodeCountList(1,mergeUserList(1,u));
    end
    
    % transRate_temp = RecomputeTranRate()
    
    % 对合并后的DAG执行调度算法DEFO
%     [schedule_temp,scheduletable_temp,initialAllocation_temp] = DuplicationOffloadAlg(mergeTaskDAG,mergeNodeCount,localComList_temp,serverComList_temp,mergeUserCount,transRate_temp,transdata_temp,computecost_temp,computeEnergy,transEnergy,except_temp,delta,schedule_temp,scheduletable_temp,mergeNodeCount+schedulelength,allowDuplication_temp,comStartup,searchStart+schedulelength,timeslot);
    [schedule_temp,scheduletable_temp,initialAllocation_temp] = DuplicationOffloadAlg(mergeTaskDAG,mergeNodeCount,localComList_temp,serverComList_temp,mergeUserCount,transRate_temp,transdata_temp,computecost_temp,computeEnergy,transEnergy,except_temp,delta,schedule_temp,scheduletable_temp,mergeNodeCount+schedulelength,allowDuplication_temp,comStartup,searchStart+schedulelength,timeslot,initialAllocation_temp);
    schedule_temp = schedule_temp(:,(schedulelength+1):(schedulelength+mergeNodeCount),:);
    
    % 把调度后的结果输出到调度信息表
    offset = 1;
    search = 1;
    p = 1; % merge user index
    for u = 1 : userCount % all user index
        if u == mergeUserList(1,p)
                % schedule for server
           schedule(:,search:(-1+search+nodeCountList(1,mergeUserList(1,p))),candidateServer) = schedule_temp(:,(offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1);
                % schedule for user local
           schedule(:,search:(-1+search+nodeCountList(1,mergeUserList(1,p))),serverCount+mergeUserList(1,p)) = schedule_temp(:,(offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1+p);
           offset = offset + nodeCountList(1,mergeUserList(1,p));
           p = p + 1;
           if p > mergeUserCount
               break;
           end
        end
        search = search + nodeCountList(1,u);
    end % for u
    offset = 1;
    for p = 1 : mergeUserCount
       scheduletable(1:nodeCountList(1,mergeUserList(1,p)),candidateServer,mergeUserList(1,p)) = scheduletable_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1);
       scheduletable(1:nodeCountList(1,mergeUserList(1,p)),serverCount+1,mergeUserList(1,p)) = scheduletable_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1+p);
       initialAllocation(1:nodeCountList(1,mergeUserList(1,p)),candidateServer,mergeUserList(1,p)) = initialAllocation_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1);
       initialAllocation(1:nodeCountList(1,mergeUserList(1,p)),serverCount+1,mergeUserList(1,p)) = initialAllocation_temp((offset+1):(offset+nodeCountList(1,mergeUserList(1,p))),1+p);      
       offset = offset + nodeCountList(1,mergeUserList(1,p));
    end
        
    
end % function

