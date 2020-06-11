function [schedulecurrent,channellast] = DuplicationLastSchedule(userCount,schedulelast,channellast,nodeCount,serverCount,user,server,transdata,transRateini,transRate,timeslot,timeslotlast )

    schedulecurrent = zeros(2,sum(nodeCount),serverCount)-1;
    if server ~= (serverCount+1)
       offset = 1/transRate(serverCount+1,server) - 1/transRateini(serverCount+1,server);
    else
        offset = 0;        
    end

    search = 0;
    for t = 1 : userCount
        for p = 1 : nodeCount(1,t)
            for s = 1 : serverCount
                if schedulecurrent(1,search+p,s) ~= -1
                   schedulecurrent(1,search+p,s) = schedulelast(1,search+p,s)+timeslot-timeslotlast+offset*mean(mean(transdata(:,:,t)));
                   schedulecurrent(2,search+p,s) = schedulelast(2,search+p,s)+timeslot-timeslotlast+offset*mean(mean(transdata(:,:,t)));                   
                end
            end 
        end % for p
        search = search + nodeCount(1,t);
    end % for t
    
    offset2 = 0;
    for p = 1 : userCount
        if p ~= user
            offset2 = offset2 + nodeCount(1,p);
        else
            break;
        end
    end 
    
    for s = 1 : serverCount
        % 取消其他分配到user的s(除了server)
        if s~= server && channellast(user,s) == 1
           for t = 1 : nodeCount(1,user)
              schedulecurrent(1,offset2+t,s) = -1;
              schedulecurrent(2,offset2+t,s) = -1;              
           end
           channellast(user,s) = 0;
        end
    end
    
    if server ~= (serverCount+1)
        channellast(user,server) = 1;
    end 
    
    
end 