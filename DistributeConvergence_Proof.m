clear;  % 清除上次执行工作区痕迹

userCount = 30;
serverCount = 10;
iterationnum = 20;
delta = 0.001;  % 相等允许的误差范围
nodeCountList = zeros(1,userCount)+10;  % 每个用户都有10个子任务
nodeCountMax = max(nodeCountList);

taskDAG = zeros(nodeCountMax,nodeCountMax,userCount);
taskDAG(:,:,1) = [0,-1,-1,-1,-1,-1,0,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,-1,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,0,0,-1,0;1,0,0,0,0,0,0,-1,0,0;0,0,1,0,0,0,0,0,0,-1;0,1,0,1,0,1,0,0,0,-1;0,1,0,1,1,0,0,0,0,-1;0,0,0,0,0,0,1,1,1,0]';
for p = 2 : userCount
    taskDAG(:,:,p) = taskDAG(:,:,1);
end
 taskDAG(:,:,1) = [0,1,0,0,1,1,0,0,0,0;-1,0,1,0,1,0,0,0,0,0;0,-1,0,0,-1,0,0,1,0,1;0,0,0,0,0,0,0,-1,0,1;-1,-1,1,0,0,0,0,0,0,1;-1,0,0,0,0,0,1,0,0,0;0,0,0,0,0,-1,0,1,0,0;0,0,-1,1,0,0,-1,0,1,0;0,0,0,0,0,0,0,-1,0,1;0,0,-1,-1,-1,0,0,0,-1,0];
%  taskDAG(:,:,3) = taskDAG(:,:,1);
 
CCR = 5; % CCR = 总Communication Cost / 总Compute Cost
unitCost = 10; % subtask compute cost 这里可以调整为(1,node,user)的列表
edgeCount = zeros(1,userCount); % 每个用户DAG的边数
    % 初始化edgeCount
for u = 1 : userCount
    for  n1 = 1 : nodeCountList(1,u)
        for n2 = 1 : nodeCountList(1,u)
            if taskDAG(n1,n2) == 1
                edgeCount(1,u) = edgeCount(1,u)+1;
            end
        end % for n2
    end % for n1
end % for u

schedulelength = sum(nodeCountList); % 需要调度的节点数量
transData = rand(nodeCountMax,nodeCountMax,userCount) * unitCost*mean(nodeCountList)*CCR/mean(edgeCount);
localComList = zeros(1,userCount)+1.2; % 计算主频
serverComList = zeros(1,serverCount)+10;
for s = 1 : serverCount % 服务器资源异构化
    serverComList(1,s) = rand()* serverComList(1,s);
end
computeCost = rand(1,nodeCountMax,userCount) * unitCost; %这里可以再改进
transRate = rand(serverCount+1,serverCount+1,userCount)*5;
for p = 1 : userCount
    for s1 = 1 : (serverCount+1)
        for s2 = 1 : (serverCount+1)
            if s1 <= s2
                transRate(s2,s1,p) = transRate(s1,s2,p);
            end
        end 
    end 
end
computeStartup = zeros(1,serverCount+userCount);    % 每个处理器开始计算的时间
schedule = zeros(2,schedulelength,serverCount+userCount)-1; 
scheduletable = zeros(nodeCountMax,serverCount+1,userCount);
initialAllocation = zeros(nodeCountMax,serverCount+1,userCount);
userList = zeros(1,userCount); % 用户列表，存放用户index
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
% channel = zeros(userCount,serverCount); % 信道分配方案,1 表示将用户i分配到服务器s

% 下面四个需要重新定义
Ratio = 0;
computeEnergy = 0;
transEnergy = 0;
sthelse = 0;

% GameDETO会自动创造timeslotArray 
[ avgdelay,schedule,scheduletable,channel,timeslotArray ] = GameDETO( taskDAG,nodeCountList,userCount,serverCount,iterationnum,transData,computeCost,localComList,serverComList,transRate,computeStartup,0,except,allowDuplication,transEnergy,computeEnergy,delta,sthelse );
plot(1:iterationnum,avgdelay,'-ob');
% set(h,'Visible','off');
hold on;








