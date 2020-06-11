function [ transRateini,transRate,channel ] = RegetBandwidth( channel,transRate,userCount,serverCount,user,server )
%RegetBandwidth 将原user的信道分配方案改为server上的分配，然后根据香农公式重新计算传输速率
%   channel(userCount,serverCount)1为选择该信道
    
    transRateini = transRate;
    % 先取消目标用户user当前的信道分配
    for s = 1 : serverCount
        if channel(user,s) == 1
            channel(user,s) = 0;
        end
    end % for s
    % 设置新的信道分配
    if server ~= (serverCount+1)
        channel(user,server)= 1;
    end
    
    % 重新计算传输速率
    for s = 1 : serverCount
        num = 0; % 统计同一服务器s上给多少用户分配了信道资源,传输速率均分
        for  u = 1 : userCount
            if channel(u,s) == 1
                num = num + 1;
            end
        end % for u
        
        num = max(1,num); % 除法分母不为0
        transRate(s,serverCount+1,:) = transRate(s,serverCount+1,:)/num;
        transRate(serverCount+1,s,:) = transRate(s,serverCount+1,:);
    end 
    
end

