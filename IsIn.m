function [ flag ] = IsIn( user,userList,len )
%IsIn 查找user是否在userlist中，其中len为userlist长度
%输出：1存在，0不存在
    
    flag = 0;
    for i = 1 : len
       if user == userList(1,i)
           flag = 1;
           break;
       end
       i = i + 1;
    end

end

