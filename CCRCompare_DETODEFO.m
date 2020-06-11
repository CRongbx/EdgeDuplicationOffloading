% DETO DEFO PGOA算法比较：完成时延-服务器数
userCount = 5;
serverCount = 2;
iterationnum = 20;
CCRCount = 15;
avgdelay_DETO = zeros(1,CCRCount);
avgdelay_DEFO = zeros(1,CCRCount);

delta = 0.001;  % 相等允许的误差范围
nodeCountList = zeros(1,userCount)+10;  % 每个用户都有10个子任务
nodeCountMax = max(nodeCountList);
taskDAG = zeros(nodeCountMax,nodeCountMax,userCount);
taskDAG(:,:,1) = [0,-1,-1,-1,-1,-1,0,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,-1,0,0,0;1,0,0,0,0,0,0,-1,-1,0;1,0,0,0,0,0,0,0,-1,0;1,0,0,0,0,0,0,-1,0,0;0,0,1,0,0,0,0,0,0,-1;0,1,0,1,0,1,0,0,0,-1;0,1,0,1,1,0,0,0,0,-1;0,0,0,0,0,0,1,1,1,0]';
for p = 2 : userCount_max
    taskDAG(:,:,p) = taskDAG(:,:,1);
end
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
localComList = rand(1,userCount)+1.2; % 计算主频

computeCost = rand(1,nodeCountMax,userCount) * unitCost; 
 except = zeros(nodeCountMax,serverCount+1,userCount);
for u = 1 : userCount
    except(nodeCountList(1,u),1:serverCount,u) = 1;
end
serverComList = zeros(1,serverCount)+10;
for s = 1 : serverCount % 服务器资源异构化
    serverComList(1,s) = rand()* serverComList(1,s);
end
transRate = zeros(serverCount+1,serverCount+1,userCount)+1;
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

% 下面四个需要重新定义
Ratio = 0;
computeEnergy = 0;
transEnergy = 0;
sthelse = 0;
% CCR = 总Communication Cost / 总Compute Cost
for CCR = 1 : CCRCount
    transData = zeros(nodeCountMax,nodeCountMax,userCount) + unitCost*mean(nodeCountList)*CCR/mean(edgeCount);
       
        allowDuplication = zeros(1,nodeCountMax,userCount) + 1;
        [ avgdelay,schedule,scheduletable,channel,timeslotArray ] = GameDETO( taskDAG,nodeCountList,userCount,serverCount,iterationnum,transData,computeCost,localComList,serverComList,transRate,computeStartup,0,except,allowDuplication,transEnergy,computeEnergy,delta,sthelse );
        avgdelay_DETO(1,CCR) = min (avgdelay(1,iterationnum),avgdelay(1,iterationnum-1));

        allowDuplication = zeros(1,nodeCountMax,userCount) ;
        [ avgdelay,schedule,scheduletable,channel,timeslotArray ] = GameDETO( taskDAG,nodeCountList,userCount,serverCount,iterationnum,transData,computeCost,localComList,serverComList,transRate,computeStartup,0,except,allowDuplication,transEnergy,computeEnergy,delta,sthelse );
        avgdelay_DEFO(1,CCR) = min (avgdelay(1,iterationnum),avgdelay(1,iterationnum-1));

end % for CCR

plot(1:CCRCount,avgdelay_DEFO,'-or','LineWidth',2);
% plot(1:Num,Avgdelaymin-2*Computetotal/Tasktotal,'r','LineWidth',2);
hold on;
plot(1:CCRCount,avgdelay_DETO,'--+b','LineWidth',2);
% plot(1:Num,AvgdelayminNodup-2*Computetotal/Tasktotal,':b','LineWidth',2);
% plot(1:Num,Avgdelayminton,'--','LineWidth',2);
hold on;
% title(' 任务完成时间比较');
xlabel('CCR:通信开销/计算开销');
ylabel('任务完成时间/ms');
legend('DETO算法','DEFO算法');
