function [ RankList ] = DAGRank( TaskDAG, ServerList, TransRate, UserList, UserNum, delta )
%DAGRank ������DAG��������
%˼·������AEST(the average earliest start time)��ALST(the average lastest start
%   time)�����ڴ˼�����ȷ���ؼ�·����AOE���ؼ�·���������Ӷ��õ�������
[AEST, ALST] = TimeEstimate( TaskDAG, ServerList, TransRate, UserList, UserNum, delta);
[CriticalPath, PathLen] = FindCriticalPath(AEST,ALST,UserList(UserNum).NodeCount);
PrioritySort;

end

