function [ duplication_count ] = GetDuplicationCount( candidatenode,scheduletable,serverCount )
%GetDuplicationCount 根据卸载决策表scheduletable来获得子任务candidatenode设置了几个重复子任务（同一任务在多少处理器执行）
    duplication_count = 0;
    for s = 1 : (serverCount+1)
        if scheduletable(candidatenode,s) == 1
            duplication_count = duplication_count + 1;
        end
    end % for s
end

