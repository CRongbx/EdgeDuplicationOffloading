function [ schedulecurrent ] = LastToCurrent( schedulelast,serverCount,nodeCount,userCount,timeslot,timeslotlast )
%LastToCurrent 为上一时隙timeslotlast的调度时间信息，移到当前时隙timeslot，更新调度信息
%   此处显示详细说明
    
    schedulecurrent = zeros(2,sum(nodeCount),serverCount+userCount)-1;
    for n = 1 : sum(nodeCount)
       for p = 1 : (serverCount+userCount)
          if schedulelast(1,p) ~= -1
             schedulecurrent(1,n,p) = schedulelast(1,n,p)+timeslot-timeslotlast;
             schedulecurrent(2,n,p) = schedulelast(2,n,p)+timeslot-timeslotlast;
          end
       end
    end

end

