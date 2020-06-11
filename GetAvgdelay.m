function [ avgdelay ] = GetAvgdelay( schedule,userCount,nodeCountList,serverCount )
%UNTITLED11 compute avg. delay (任务的结束时间==最后一个子任务的结束时间)
%   此处显示详细说明
    avgdelay = 0;
    startsearch = 0;
    for i = 1 : userCount
        processor = serverCount+1;
        for p = 1 : serverCount
           if schedule(2,startsearch+nodeCountList(1,i),p) ~= -1
                processor = p;
                break;
           end
        end 
        
        avgdelay = avgdelay + schedule(2,startsearch+nodeCountList(1,i),processor);
        startsearch = startsearch + nodeCountList(1,i);
    end % for i
    
    avgdelay = avgdelay/userCount;
end

