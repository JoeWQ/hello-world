/*
  *@aim:��Ȩ�������������
  *@date:2015-5-23
  */
#include"CArray2D.h"
#include"CArray.h"
#include<stdio.h>
//��Ȩ�������������
  struct         CTask
 {
//����ʼ��ʱ��
             int              startTime;
//���������ʱ��
             int              finishTime;
//Ȩֵ
             int              weight;
  };
  //@aim:��������Ȩֵ���ݻ����
  //@note:task[0]λһ�����������task[0].startTime=0,task[0].finishTime=0
  //@request:task�Ѿ�����finishTime��������
    int         weight_interval_schedule(CTask        *task,int      size)
   {
//theta��¼������j������������������Ҳ����theta(j)=max{i | task[i].finishTime<=task[j].startTime}
//���û�����������֣��ͼ�Ϊ0
              CArray<int>            theta(size),*p;
//record��¼��ֹ����ǰ����i����õ��ܵ�Ȩֵ�Ĵ�С
              CArray<int>            record(size),*q;
              int                             i,k;
              
              i=1;
              p=&theta;
//�����뵱ǰ�����ݵ����������
              while(i<size)
             {
                             k=i-1;
                             while(k &&task[k].finishTime>task[i].startTime)
                                          --k;
                             p->set(i,k);
                             ++i;
;              }
               i=1;
               q=&record;
//ע������ĵݹ�ʽ��������
               q->set(0,0);
               while(i<size)
              {
//��⣬���������벻�����������ܹ��ɵ���Ȩֵ�Ĵ�С
                               int           back;
                               back=q->get( p->get(i) )+task[i].weight;
                               int           extra=q->get(i-1);
                               q->set(i,    back>extra?back:extra);
                               ++i;
               }
               return    q->get(size-1);
    }
      int        main(int    argc,char    *argv[])
     {
               CTask                 task[6]={{0,0,0},{1,5,4},{3,8,8},{6,13,16},{12,15,9},{14,18,20}};
               int                      size=6;
               int                     weight=0;
               
               weight=weight_interval_schedule(task,size);
               printf("total weight is %d\n",weight);
               return   0;
      }