function [bool] = IsIn(x, array, len)
% 判断x是否在长度为len的数组array中
% 返回：1存在 o不存在
bool = 0;
for  j = 1: len
    if x == array(1, j)
        bool = 1;
        break;
    end
end
end 