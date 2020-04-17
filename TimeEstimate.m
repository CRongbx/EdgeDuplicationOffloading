function [ AEST,ALST ] =  TimeEstimate( TaskDAG, ServerList, TransRate, UserList, UserNum, delta)
% TimeEstimate ����DAG�ʹ������ʹ�������ƽ�����翪ʼʱ��AEST��ƽ��������ʼʱ��ALST
% ���룺
%   -TaskDAG���û�UserNum������DAGͼ����i,i��CPU cycles,(i,j)=x (j,i)=-x �ߴ�i��j��ͨ�ſ���x KB
% �����
%   -AEST&ALST (ms)


    % ��������i��ÿ��������ĵ�ƽ������ʱ���ͨ������ʱ��
        % ����i���������ƽ�����㿪�� ms
    MeanComputeCost = zeros(1, UserList(UserNum).NodeCount);
        % ����i��ÿ����������ƽ��ͨ�ſ��� ms(inf��ʾ������֮����ͨ�Ź�ϵ);i->j, (i,j)>0 (j,i)<0
    MeanCommunCost = zeros(UserList(UserNum).NodeCount,UserList(UserNum).NodeCount); 
        % ������ʼ��--MeanComputeCost
    for i = 1 : UserList(UserNum).NodeCount
        SumComputeCost = 0;  % ������������CPU cycles (Mega)
        for j = 1 : UserList(UserNum).NodeCount
            SumComputeCost = SumComputeCost + TaskDAG(j,j); 
        end
        MeanComputeCost(1,i) = SumComputeCost/UserList(UserNum).CPUFreq;  % Megacycles/GHz = ms

    end
        % ������ʼ��--MeanCommunCost
            % ����������������û�i��ƽ��ͨ������MeanTransRate
    MeanTransRate = 0;
    for s = 1 : ServerList.ServerCount
        MeanTransRate = MeanTransRate + TransRate(UserNum,s);
    end    
    MeanTransRate = MeanTransRate / ServerList.ServerCount;
    for t1 = 1 : UserList(UserNum).NodeCount  % suntask t1
       for t2 = 1  : UserList(UserNum).NodeCount  % suntask t2
          % ���ж�������t1-t2�Ƿ���ͨ�Ź�ϵ��������ͨ�Ź�ϵ���������i��ÿ���������Ĵ�������ƽ��ֵ��t1-t2�������ݴ�С/ƽ����������
          % �õ�ÿ���ӽڵ���ƽ��ͨ�ſ���
          if TaskDAG(t1,t2) ~= 0    % �������������ͨ�Ź�ϵ
              MeanCommunCost(t1,t2) = TaskDAG(t1,t2)/MeanTransRate;
              MeanCommunCost(t2,t1) = -MeanCommunCost(t1,t2);
          else
              MeanCommunCost(t1,t2) = inf;
              MeanCommunCost(t2,t1) = inf;
          end
       end
    end

    % ����UserNum�û���AEST��ALST
    AEST = zeros(1,UserList(UserNum).NodeCount)-1;
    ALST = AEST;
    AEST = GetAEST(TaskDAG,UserNum,UserList(UserNum).NodeCount,MeanCommunCost,MeanComputeCost);
    ALST(1,UserList(UserNum).NodeCount) = AEST(1,UserList(UserNum).NodeCount);
    ALST = GetALST(TaskDAG,UserNum,UserList(UserNum).NodeCount,MeanCommunCost,MeanComputeCost);
    
end