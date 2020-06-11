function [ REST,REFT ] = InsertTimeCompute( taskDAG, nodeCount,ProcessorComPower,serverCount,transRate,transData,computeCost, candidateNode,candidateServer,scheduletable,schedule,scheduletemp,schedulelength,computeStartup,searchStart,timeslot)
%InsertTimeCompute "处理器中的任务调度--插入子任务(包括重复子任务)"
% 将candidateNode卸载到candidateServer执行时，在已有candidateServer任务里插入该候选任务，并计算该任务的开始时间REST和结束时间REFT
%   ProcessorComPower(1,serverCount+1)
%   schedule(:,:,server) 按照第一行的REST排序。(1,x)表示REST第x大的节点的REST，(2,x)表示REST第x大的节点的REFT，未计算前为-1
%   scheduletemp(:,:) candidateserver固定的schedule
%   scheduletable(node,server) 表示node是否卸载到Server上，卸载为1，否则为0
%   REFT = min 每个处理器{REST + 本节点计算时间}
%   REST = max {REFT,TEST}  本代码中的Starttime
    start_time = 0;
    % 最晚结束的前驱子任务，其输出到达candidateServer的时间 
    [lastest_predecessor_finish_time,~] = GetLastestPredecessorTime( taskDAG,nodeCount,serverCount, transRate, transData,candidateServer,candidateNode,scheduletable,schedule,computeStartup,searchStart);
    %  候选节点的前驱节点输出都到达处理器的等待时间(论文里的t^D)
    TEST = max(lastest_predecessor_finish_time,timeslot);
    
    % 后续需要计算等待candidateServer空闲花费的时间，这个时间和处理器内对各个子任务的调度顺序有关.
    % 由于插入任务时，在处理器已有任务中，结束时间在TEST之后，则没有影响，所以我们只插在REFT在TEST之前，下面的代码确定REFT在TEST之前的节点位置
    start_index = 1; 
    end_index = schedulelength;
    k = ceil((start_index+end_index)/2);
    while start_index ~= end_index
        if scheduletemp(2,k) > TEST
            end_index = k - 1;
        else
            start_index = k;
        end
        k = ceil((start_index+end_index)/2);
    end % while
    
    % 所有节点的REST都未计算（第一个节点）||第一个节点的REFT在TEST后，需要将候选节点插在后面
    if scheduletemp(1,k) == -1 || scheduletemp(2,1) > TEST
        k = -1;
    end
    
    
    if k == -1
        % k==-1代表众多节点中存在节点的REFT没有计算，我们需要找到可能是最后一个完成的节点。可以倒着找，先看最后REST一个节点的REFT是否计算了。
        % REST最晚的节点，其REFT没有计算，那么它就是最后一个完成的前驱节点
        if scheduletemp(2,schedulelength) == -1
            start_time = max(TEST,scheduletemp(2,schedulelength));
        else
        % 如果最后一个开始的前驱节点，却已经计算了REFT。
        % 寻找最晚开始（REST最大）却没计算结束时间的节点。（非candidatenode前驱节点）
            start_index = 1; 
            end_index = schedulelength;
            q = floor((start_index+end_index)/2);
            while start_index ~= end_index
                if scheduletemp(2,q) == -1
                    start_index = q + 1;
                else
                    end_index = q;
                end
                q = floor((start_index+end_index)/2);
            end % while
            % 若最晚开始且还没计算REFT的后继节点的开始时间REST >=
            % 候选节点计算完毕的时间。那么候选节点的REST为TEST;否则REST需要考虑在处理器最晚结束节点的REFT（k=1）
            if scheduletemp(1,q) >= TEST + computeCost(1,candidateNode)/ProcessorComPower(1,candidateServer)
                start_time = TEST;
            else
                k = 1;
            end
        end  % if scheduletemp(2,nodeCount) == -1
    end % if k == -1
    
    if k ~= -1
        % k~=-1表示处理器在candidatenode需要的数据准备好时，仍处于忙碌状态，此时需要计算下等待处理器空闲需要的时间
        start_time = TEST;
        for q = (k+1) : (schedulelength+1) % q从REFT大于TEST的最小值开始，依次递增。REFT小于等于TEST的任务不影响candidateNode的插入
            if q == schedulelength+1
                start_time = max(TEST,scheduletemp(2,schedulelength));
                break;
            end
            % 对于REST大于TEST的第一个节点，”可能“需要将候选任务插在它前面(q-1).
            % 若将候选节点插在（q-1）后q前，候选点计算完成的时间依旧小于等于下一个任务q开始的时间，那么这个候选点选择这个位置插入是对的。（反正q也要等，候选节点的插入利用了这段等待时间）
            % 接上句，若候选节点计算完成的时间大于下一个任务的开始时间，即这个插入方式会延后下个任务q，则放弃这个插入方案
            if scheduletemp(1,q) > TEST && scheduletemp(1,q) >= max(scheduletemp(2,q-1),TEST)+computeCost(1,candidateNode)/ProcessorComPower(1,candidateServer)
               start_time = max(TEST,scheduletemp(2,q-1));
               break;
            end
        end % for q
    end % if k ~= -1
    
    
    REST = start_time;
    REFT = REST + computeCost(1,candidateNode)/ProcessorComPower(1,candidateServer);
end

