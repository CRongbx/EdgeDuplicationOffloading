function [ schedule,scheduletable,initialAllocation ] = OffloadingScheme( taskDAGList,nodeCountList,userCount,user,localComList, serverComList,serverCount,channel,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation )
%OffloadingScheme 此处显示有关此函数的摘要
%   此处显示详细说明
    flag =  zeros(1,userCount); % 记录用户是否经过调度
    for u = 1 : userCount
        % 对除了user以外的其他用户，按照原channel分配进行调度
        if u == user
            continue;
        end
            
        for s = 1 : serverCount
           if  channel(u,s) == 1
              excepttemp = except;
              for r = 1 : serverCount
                  % 除了s，u不能卸载都其他核
                  if r == s
                      continue;
                  end
                  excepttemp(1:nodeCountList(1,u),r,u) = 1;
              end % for r
              % 多用户中对用户u调度(服务器s)
              [schedule,scheduletable,initialAllocation] = MultiUserSchedule(taskDAGList,nodeCountList,userCount,u,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation);
              flag(1,u) = 1;
              break;
           end
        end % for s
    end % for u
    
    for i = 1 : userCount
        if i ~= user && flag(1,i) == 0
            % 非目标用户，且还未经过调度（本地执行）
           excepttemp = except;
           for r = 1 : serverCount
              excepttemp(1:nodeCountList(1,i),r,i) = 1; 
           end
           % 多用户中对用户i调度(本地)
           [schedule,scheduletable,initialAllocation] = MultiUserSchedule(taskDAGList,nodeCountList,userCount,i,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation);
           flag(1,i) = 1;  
        end
    end % for i 
    
    % 对候选用户user按照channel调度
    excepttemp = except;
    for r = 1 : serverCount
        if channel(user,r) ~= 1
            excepttemp(1:nodeCountList(1,user),r,user) = 1;
        end
    end
    [schedule,scheduletable,initialAllocation] = MultiUserSchedule(taskDAGList,nodeCountList,userCount,user,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation);
    
    
end

