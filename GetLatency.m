function [ starttime,finishtime,latency ] = GetLatency( schedule,userCount,serverCount,nodeCountList )
%UNTITLED13 此处显示有关此函数的摘要
%   此处显示详细说明
    
    starttime = zeros(1,userCount)-1;
    finishtime = zeros(1,userCount)-1;
    latency = zeros(1,userCount)-1;
    for i = 1 : userCount
        [starttime(1,i),finishtime(1,i),latency(1,i)] = GetLatency_ForSingleUser(schedule,serverCount,userCount,i,nodeCountList);
    end

end % function getlatency

