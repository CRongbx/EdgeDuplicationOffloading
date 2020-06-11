function [ schedule,scheduletable,initialAllocation ] = LocalSchedule( localUserCount, localUserList, taskDAGList,nodeCountList,userCount,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,searchStart,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,timeslot,initialAllocation )
%LocalSchedule 假设任务只能在本地执行，计算卸载策略（主要是处理器调度顺序schedule）
%   localUserList(1,localusercount)本地执行的用户序号
   if localUserCount <= 0
       return;
   end
   
   nodemax = max(nodeCountList);
   for i = 1 : localUserCount
       except = ones(nodemax,serverCount+1,userCount);
       % 所有子任务都只能在本地执行,不允许设置重复子任务
       except(:,serverCount+1, localUserList(1,i)) = 0;
       allowDuplication = zeros(1,nodemax,userCount);
       [schedule,scheduletable,initialAllocation] = MultiUserSchedule(taskDAGList,nodeCountList,userCount,localUserList(1,i),localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation);
   end 

end

