function [ RankList ] = PrioritySort( TaskDAG, NodeCount, CriticalPath, PathLen )
%PrioritySort 对DAG中每个节点排序（rank越小越优先）
%排序标准：关键路径起点rank=1，沿着关键路径走，如果该关键节点存在其他前驱节点，则给该前驱节点更高的优先级（更小的rank）
%输出：
%   - RankList:（1,x）每一列存储节点编号

    stack = zeros(1, NodeCount);    % 栈：存放CriticalPath，保证从关键路径的起点开始处理
    s_pos = 0;  % 栈顶元素指针
    is_stacked = zeros(1, NodeCount);  % 指示节点是否已经压过栈 1压过 0未压过栈
    RankList = zeros(1, NodeCount);
    r_pos = 1;  % ranklist pos
    
    % 关键路径节点反向入栈
    for i = PathLen : -1 : 1
        s_pos = s_pos + 1;
        stack(1,s_pos) = CriticalPath(1,i);
        is_stacked(1,CriticalPath(1,i)) = 1;
    end
    
    % 沿着关键路径走，如果该关键节点存在其他前驱节点，则给该前驱节点更高的优先级（更小的rank）
    while s_pos > 0
        top_item = stack(1,s_pos);  % 栈顶元素
        flag = 0;  % 指示此次循环栈中元素是否有添加 0未改变 1改变
        for i = 1 : NodeCount
            if TaskDAG(i,top_item) > 0  % i是top_item的前驱节点:若为入栈，入栈并标记 
                if is_stacked(1,i) == 0
                    s_pos = s_pos +1;
                    stack(1,s_pos) = i;
                    is_stacked(1,i) = 1;
                    flag = 1;
                end
            end
        end 
        if flag == 0
           RankList(1,r_pos) = top_item;
           r_pos = r_pos + 1;
           s_pos = s_pos - 1;
        end
    end
    
end

