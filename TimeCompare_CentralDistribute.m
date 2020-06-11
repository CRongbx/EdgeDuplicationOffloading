% DETO算法集中式-分布式，算法比较

userCount = 1;
userCount_max = 7;
iterationnum = 20;
time_central = zeros(1,userCount_max); % running time
time_distribute = zeros(1,userCount_max);
avgdelay_central = zeros(1,userCount_max);  % average delay
avgdelay_distribute = zeros(1,userCount);
serverCount = 2;
delta = 0.001;  % 相等允许的误差范围
nodeCountList = zeros(1,userCount_max)+10;  % 每个用户都有10个子任务
nodeCountMax = max(nodeCountList);

taskDAG = zeros(nodeCountMax,nodeCountMax,userCount_max);
taskDAG(:,:,1) = [0,-1,-1,-1,-1,-1,0,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,-1,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,0,0,-1,0;1,0,0,0,0,0,0,-1,0,0;0,0,1,0,0,0,0,0,0,-1;0,1,0,1,0,1,0,0,0,-1;0,1,0,1,1,0,0,0,0,-1;0,0,0,0,0,0,1,1,1,0]';
for p = 2 : userCount_max
    taskDAG(:,:,p) = taskDAG(:,:,1);
end


CCR = 2.5; % CCR = 总Communication Cost / 总Compute Cost
unitCost = 10; % subtask compute cost 这里可以调整为(1,node,user)的列表
edgeCount = zeros(1,userCount_max); % 每个用户DAG的边数
    % 初始化edgeCount
for u = 1 : userCount_max
    for  n1 = 1 : nodeCountList(1,u)
        for n2 = 1 : nodeCountList(1,u)
            if taskDAG(n1,n2) == 1
                edgeCount(1,u) = edgeCount(1,u)+1;
            end
        end % for n2
    end % for n1
end % for u


schedulelength = sum(nodeCountList); % 需要调度的节点数量
transData = zeros(nodeCountMax,nodeCountMax,userCount_max) + unitCost*mean(nodeCountList)*CCR/mean(edgeCount);
localComList = rand(1,userCount_max)+1.2; % 计算主频
serverComList = zeros(1,serverCount)+10;
for s = 1 : serverCount % 服务器资源异构化
    serverComList(1,s) = rand()* serverComList(1,s);
end
computeCost = rand(1,nodeCountMax,userCount_max) * unitCost; 
transRate = zeros(serverCount+1,serverCount+1,userCount_max)+1;
for p = 1 : userCount_max
    for s1 = 1 : (serverCount+1)
        for s2 = 1 : (serverCount+1)
            if s1 <= s2
                transRate(s2,s1,p) = transRate(s1,s2,p);
            end
        end 
    end 
end
computeStartup = zeros(1,serverCount+userCount_max);    % 每个处理器开始计算的时间

% 下面四个需要重新定义
Ratio = 0;
computeEnergy = 0;
transEnergy = 0;
sthelse = 0;


while userCount <= userCount_max
    % 对不同用户数的环境，进行算法调度
    avgdelay_min = inf;
        % 调度用户时，需要跳过在它之前执行的子任务（其他用户）
    schedulelength = sum (nodeCountList(1,1:userCount));
    userList = zeros(1,userCount);
    for i = 1 : userCount
        userList(1,i) = i;
    end
    
    except = zeros(nodeCountMax,serverCount+1,userCount);
        % 起始和终结节点必须要在本地执行
    except(1,1:serverCount,:) = 1; % 起始节点。1表示不可卸载到该处理器执行
    for i = 1 : userCount
       except(nodeCountList(1,i),1:serverCount,i) = 1; % 终结节点
    end
    
    allowDuplication = zeros(1,nodeCountMax,userCount) + 1; % 1表示允许设置重复子任务
    % clock 返回一个六元素的日期向量，其中包含小数形式的当前日期和时间 [year month day hour minute seconds]    
    t1 = clock;  % 任务起始时间
    timeslot = 0;
    for i = 0 : userCount % 上传到第一个服务器的用户数目
        for j = 0 : userCount %上传到第二个服务器的用户数目
            if i+j > userCount
                break;
            end
            
            % i的选择组合
            combinei = nchoosek(userList,i); % 从userList中一次取i个用户的所有组合（矩阵）
            
            % 遍历i的所有排列组合
            for q = 1 : nchoosek(userCount,i)
                schedule = zeros(2,schedulelength,serverCount+userCount)-1;
                scheduletable = zeros(nodeCountMax,serverCount+1,userCount);
                initialAllocation = zeros(nodeCountMax,serverCount+1,userCount);
                
                user_temp = userList;
                tempi = combinei(q,:);
                tempi = sort(tempi); % 对选中组合的用户，按照编号由小到大排序
                
                for y = 1 : i
                    channeltemp(tempi(1,y),1) = 1;
                end % for y
                
                if i~=0
                    % 有用户上传到服务器1
                        % 合并用户组DAG
                    [mergeTaskDAG,mergeNodeCounti] = MergeSomeGraph(taskDAG,nodeCountList,tempi,i); 
                        % 对用户组一起调度
                    [schedule,scheduletable,initialAllocation] = MergeSchedule(mergeTaskDAG,mergeNodeCounti,nodeCountList(1,1:userCount),i,tempi,userCount,serverCount,1,localComList,serverComList,transRate,transData,computeCost,computeStartup,0,except,allowDuplication,schedulelength,schedule,scheduletable,initialAllocation,Ratio,computeEnergy,transEnergy,delta,0);
                end
                    
                schedule_backup = schedule;
                scheduletable_backup = scheduletable;
                initialAllocation_back = initialAllocation;
                
                
                % 计算没有上传处理器1的用户列表
                for z = 1 : i
                    user_temp(1,tempi(1,z)) = -1;    % merged user group              
                end % for z
                user_temp2 = zeros(1,userCount-i); % 在处理器2执行的用户列表
                offset = 1;
                for z = 1 : userCount
                    if user_temp(1,z) ~= -1
                        user_temp2(1,offset) = user_temp(1,z);
                        offset = offset + 1;
                    end 
                end % for z
                
                
                
                % 对user组合i没有涉及的user组成的user_temp2中，组合选择上传到处理器2的用户任务
                combinej = nchoosek(user_temp2,j);
                
                for x = 1 : nchoosek(userCount-i,j)
                    schedule = schedule_backup;
                    scheduletable = scheduletable_backup;
                    initialAllocation  =initialAllocation_back;
                    tempj = combinej(x,:);
                    tempj = sort(tempj);
                    
                for y = 1 : j
                    channeltemp(tempj(1,y),2) = 1;
                end 
                                    
                    templocal = zeros(1,userCount-i-j); % 在本地执行的用户列表
                    templocalnum = 1;
                    for t = 1 : userCount
                       if IsIn(t,tempi,i) == 0 && IsIn(t,tempj,j) == 0                           
                           templocal(1,templocalnum) = t;
                           templocalnum = templocalnum + 1;
                       end
                    end
                    templocal = sort(templocal);
                    templocalnum = templocalnum - 1; %
                    
                    if j ~= 0 
                      [mergeTaskDAGj,mergeNodeCountj] = MergeSomeGraph(taskDAG,nodeCountList,tempj,j); 
                      [schedule,scheduletable,initialAllocation] = MergeSchedule(mergeTaskDAGj,mergeNodeCountj,nodeCountList(1,1:userCount),j,tempj,userCount,serverCount,2,localComList,serverComList,transRate,transData,computeCost,computeStartup,0,except,allowDuplication,schedulelength,schedule,scheduletable,initialAllocation,Ratio,computeEnergy,transEnergy,delta,0);                  
                    end
                    if templocalnum ~= 0                  
                        [schedule,scheduletable,initialAllocation] = LocalSchedule(templocalnum, templocal, taskDAG,nodeCountList(1,1:userCount),userCount,localComList, serverComList,serverCount,transRate,transData,computeCost,computeStartup,0,delta,computeEnergy,transEnergy,schedule,scheduletable,schedulelength,0,initialAllocation);                       
                    end
                    
                    [avgdelay] = GetAvgdelay(schedule,userCount,nodeCountList,serverCount);
                    if avgdelay < avgdelay_min
                        avgdelay_min = avgdelay;
                        schedule_min = schedule;
                        scheduletable_min = scheduletable;
                        initialAllocation_min = initialAllocation;
                    end
                end % for x
            end % for q            
        end % for j
    end %for i
    
    t2 = clock; % 任务结束时间
    time_central(1,userCount) = etime(t2,t1); % 计算两个时间的时间差
    avgdelay_central(1,userCount) = avgdelay_min;
    % 上述集中式调度算法测试结束
    
    % 下面进行分布式调度算法测试
    t1 = clock;
    [ avgdelay,schedule,scheduletable,channel,timeslotArray ] = GameDETO( taskDAG,nodeCountList(1,1:userCount),userCount,serverCount,iterationnum,transData,computeCost,localComList,serverComList,transRate,computeStartup,0,except,allowDuplication,transEnergy,computeEnergy,delta,sthelse);
    t2 = clock;
    time_distribute(1,userCount) = etime(t2,t1);
    avgdelay_distribute(1,userCount) = min([avgdelay(1,iterationnum),avgdelay(1,iterationnum-1)]);
    
    
    userCount = userCount + 1;
    
end % while

    
plot(1:userCount_max,time_central,'--','LineWidth',2);
hold on; % 保持原图不刷新
plot(1:userCount_max,time_distribute,'-','LineWidth',2);
hold on;
xlabel('用户数');
ylabel('算法平均运行时间/ms');
legend('集中式 DETO','分布式 DETO');

% bar(1:userCount_max,avgdelay_central);
% hold on; % 保持原图不刷新
% b = [avgdelay_central;avgdelay_distribute]';
% bar(1:userCount_max,b,0.9);
% hold on;
% title('集中式-分布式DETO 任务完成时间比较');
% xlabel('用户数');
% ylabel('任务完成时间/ms');
% legend('集中式 DETO','分布式 DETO');