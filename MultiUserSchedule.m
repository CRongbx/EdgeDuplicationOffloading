function [schedule,scheduletable,initialAllocation] = MultiUserSchedule(taskDAGList,nodeCountList,userCount,user,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,except,allowDuplication,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,searchStart,timeslot,initialAllocation)
% MultiUserSchedule 对userlist中用户user调度执行Alg1:DuplicationOffloadAlg()


  
  % 初始化时注意只对usernum的用户local进行改变，其他照旧  
  schedulel_temp = zeros(2,schedulelength,serverCount+1);
  schedulel_temp(:,:,1:serverCount) = schedule(:,:,1:serverCount);
  schedulel_temp(:,:,serverCount+1) = schedule(:,:,serverCount+user);
  
   
  computeStartup_temp = zeros(1,serverCount+1);
  computeStartup_temp(1,1:serverCount) = computeStartup(1,1:serverCount);
  computeStartup_temp(1,serverCount+1) = computeStartup(1,serverCount+user);
  
  transRate_temp = zeros(serverCount+1,serverCount+1);
  transRate_temp(1:serverCount,1:serverCount) = transRate(1:serverCount,1:serverCount,user);
  transRate_temp(serverCount+1,serverCount+1) = transRate(serverCount+1,serverCount+1,user);
  transRate_temp(1:serverCount,1+serverCount) = transRate(1:serverCount,1+serverCount,user);
  transRate_temp(1+serverCount,1:serverCount) = transRate(1+serverCount,1:serverCount,user);
  
  transData_temp = zeros(nodeCountList(1,user),nodeCountList(1,user));
  transData_temp(:,:) = transData(1:nodeCountList(1,user),1:nodeCountList(1,user),user);
  computeCost_temp = zeros(1,nodeCountList(1,user));
  computeCost_temp(1,1:nodeCountList(1,user)) = computeCost(1,1:nodeCountList(1,user),user);
  
  
  % 由于schedule和scheduletable组织时nodecount那列包含所有用户的node，所以需要确定该用户的node开始下标位置
  search = searchStart;
  for i = 1 : userCount
     if i == user
         break;
     end
     search = search + nodeCountList(1,i);
  end
%    [ schedule,scheduletable,initialAllocation ] =                      DuplicationOffloadAlg( taskDAG,             nodeCount,            localComPower,        serverComList,serverCount,transRate,     transData,     computeCost,     computeEnergy,transEnergy,except,          delta, schedule,      scheduletable,           schedulelength,allowDuplication,          computeStartup,searchStart,timeslot,initialAllocation )
  [schedulel_temp,scheduletable(:,:,user),initialAllocation(:,:,user)] = DuplicationOffloadAlg(taskDAGList(:,:,user),nodeCountList(1,user),localComList(1,user), serverComList,serverCount,transRate_temp,transData_temp,computeCost_temp,computeEnergy,transEnergy,except(:,:,user),delta, schedulel_temp,scheduletable(:,:,user), schedulelength,allowDuplication(:,:,user),computeStartup_temp,search,timeslot,initialAllocation(:,:,user));
  schedule(:,:,1:serverCount) = schedulel_temp(:,:,1:serverCount);
  schedule(:,:,serverCount+user) = schedulel_temp(:,:,serverCount+1);
end % funcation