 function [starttime,finishtime,latency] = GetLatency_ForSingleUser(schedule,serverCount,userCount,user, nodeCountList)
        % 为单用户，在所有执行它的处理器中，寻找最早开始和最早结束的时间点，计算延迟
        
        starttime_min = inf;
        finishtime_min = inf;
        n = nodeCountList(1,user);
        offset = 0;
        for t = 1 : userCount
            if t ~= user
                offset = offset + nodeCountList(1,t);
            else
                break;
            end
        end % for t
        
        % on edge server
        for s = 1 : serverCount
            if (schedule(1,offset+1,s) ~= -1) && schedule(1,offset+1,s) < starttime_min
                starttime_min = schedule(1,offset+1,s);
            end
            if (schedule(2,offset+n,s)~=-1) && schedule(2,offset+n,s) < finishtime_min
                finishtime_min = schedule(2,offset+n,s);
            end
        end % for s
        
        % on local user
        if schedule(1,offset+1,serverCount+user) ~= -1 && schedule(1,offset+1,serverCount+user) < starttime_min
            starttime_min =  schedule(1,offset+1,serverCount+user);
        end
        if  schedule(2,offset+n,serverCount+user) ~= -1 && schedule(2,offset+n,serverCount+user) < finishtime_min
            finishtime_min = schedule(2,offset+n,serverCount+user);
        end
        
        starttime = starttime_min;
        finishtime = finishtime_min;
        latency = finishtime-starttime;
        
    end % function GetLatency_ForSingleUser