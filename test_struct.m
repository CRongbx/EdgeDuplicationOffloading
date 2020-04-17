function [a,c] = test_struct( s )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
s = struct('a',1,'b',2);
a = s.a/s.b;
c = s.b;
end

