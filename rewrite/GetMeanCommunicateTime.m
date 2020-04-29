function [mean_communicate_time] = GetMeanCommunicateTime(taskDAG,nodeCount ,serverCount, transRate)
%GetMeanCommunicateTime (nodeCount,nodeCount)获得用户userNum中每个节点的平均通信延迟
%   平均通信延迟：平均『节点i与每个处理器的通信量/每个处理器之间的传输速率』
%   transRate:处理器s1与处理器s2之间的通信传输速率。最后一行一列表示本地处理器。不可通信记录为inf
%   (serverCount+1,serverCount+1,userCount)本函数考虑单用户场景，默认传入transRate时usernum以固定(serverCount+1,serverCount+1)
%   taskDAG若两个节点无通信，矩阵值为inf            

    % mean_communicate_time记录节点之间的通信时延，（i,j）为正数表示从i-->j，负数表示从j-->i.只计算存在通信的节点
    mean_communicate_time = zeros(nodeCount,nodeCount); 
    for node1 = 1 : nodeCount
        for node2 = 1 : nodeCount
            % 存在通信node1->node2
            if taskDAG(node1,node2)>0 && node1 ~= node2
                trans_server_num = 0;
                s1 = serverCount+1; % s1为local processor
                for s2 = 1 : serverCount+1
                    if s1 == s2 
                        continue;
                    end
                    if transRate(s1,s2) ~= inf
                        trans_server_num = trans_server_num + 1;
                        mean_communicate_time(node1,node2) = mean_communicate_time(node1,node2) + taskDAG(node1,node2)/transRate(s1,s2);
                    end
                end % for s2
                mean_communicate_time(node2,node1) = -mean_communicate_time(node1,node2);
            end % if taskDAG(node1,node2)>0 && node1 ~= node2
        end % for node2
    end % for node1
    
    % 上述计算求和，最后还要再除以总通信选择节点
    mean_communicate_time = mean_communicate_time/trans_server_num;
end


