function [ SchedulResult ] = DTOA( TaskDAG, ServerList, TransRate, UserList, delta)
%DTOA: Algorithm1: the Duplication-based task offloading Algorithm
%�㷨����: ���û��������������������Դ�칹���������û��ܺ�����
%����: 
%   -TaskDAG���û�i������DAGͼ����i,i��CPU cycles,(i,j)=x (j,i)=-x �ߴ�i��j��ͨ�ſ���x KB
%   -ServerList: ���������� ����Ԫ�أ�CPUFreq,IsIdle(1����),ServerNum(���),ServerCount��������
%   -TransRate: �û�i�ͷ�����j��ͨ�����ʾ���N*M��
%   -UesrList:�û��б� ����Ԫ�أ�CPUFreq, EnergyAware, UserCount�����û�����,NodeCount(����������)
%   -UserNum: ���û��ı��
%   -delta: Rank�׶Σ��ж�AEST��ALST��ȵ���Χ
%�����
%   -ScheduleResult:���Ƚ��(J*(M+1)) JΪ��������Ŀ����1�б�ʾ����ִ�У�Ԫ��ֻ��1��0����


end

