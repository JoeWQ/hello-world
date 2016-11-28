/*
  *@aim:������ȣ�����̰��ѡ�����ʵĵ��ȷ������ö�̬�滮ʵ��
  *@date:2014-10-13
  *@author:�ҽ���
  */
  #include<stdio.h>
  #include<string.h>
  #include"array.h"
   struct      Task
  {
 //����ʼʱ��
           int          start_time;
 //�������ʱ��
           int          finish_time;
   };
  #define     infine      0x37777777
/*
  *@function:task_schedule
  *@aim:���ö�̬�滮����������ɼ��ݵ����������Ŀ
  *@param:y[i][j]��ʾ ����(task[i].finish_time<=task[k].start_time<=task[k].finish_time<=task[j].start_time)������
  *@param:--�������Ŀ,����   i<k<j
  *@param:r��¼��ѡȡ����ǰ�����������,tΪ��������������
  *@param:size�����Ŀ��ע���һ�������һ��������
  *@request:size>=3
  */

   void       task_schedule(Array   *y,Array    *r,Task     *task,int    size)
  {
            int     i,j,d;
            int     e,m,trace;
            int     empty;
//��ʼ����
            for(i=0;i<size-1;++i)  
                    y->set(i,i+1,0); 
//�Ե��������,dΪ���
            for(  d = 2;d<size;++d )
           {
                      for(i = 0;i<size-d;++i)
                     {
//     j>=i && j<i+d
                                e=-1;
//�ж�S(i,i+d)�����Ƿ�Ϊ�գ�ֻ��Ϊ�ǿյ�����£�����ȡ�����ֵ
                                empty=1;
//ע������Ĵ���ʵ����Ӧ�÷���������ɣ�����ֻ��Ϊ�˼�������д���������ʽ
                                for( j=i+1;j<i+d;++j)
                               {
//������ж����ıȽ϶���ֻ��һ�����ɣ�ԭ�������ǲ��õ��Ե����ϵ����Ϸ�ʽ���Ա�֤����Զ������������
                                      if(   task[j].start_time>=task[i].finish_time && task[j].finish_time<=task[i+d].start_time )
                                     {
                                                 empty=0;
//�Ƚ���������ж�����֮���Ƿ����
                                                m = y->get(i,j) + y->get(j,i+d)+1;
                                                if( e < m )
                                                {
                                                        e=m;
                                                        trace = j;
                                                }
                                       }
                                }
                               if(  ! empty  )
                              {
                                       y->set(i,i+d,e);
                                       r->set(i,i+d,trace);
                               }
                               else
                              {
                                       y->set(i,i+d,0);
                                       r->set(i,i+d,0);
                              }
                      }
           }
  }
//
  int    main(int   argc,char   *argv[])
 {
            struct      Task      task[13]={
                                                              {0,0},
                                                              {1,4},{3,5},{0,6},{5,7},
                                                              {3,8},{5,9},{6,10},{8,11},
                                                              {8,12},{2,13},{12,14},
                                                              {infine,infine}
                                                       };
           int               size=13;
//
           Array            schedule_cost(size,size);
           Array            schedule_record(size,size);
 //          Array            prev(size,size);
 //          Array            next(size,size);
           Array            *y=&schedule_cost,*r=&schedule_record;
 //
           task_schedule(y,r,task,size);
//
           int     i,j;
           for(i=0;i<size;++i)
          {
                    for(j=0;j<=i;++j)
                         printf("     "); 
                    for(j=i;j<size;++j)
                         printf("%4d",y->get(i,j));
                    putchar('\n');
           }
           printf("--------------------------------------------------------------------\n");
            for(i=0;i<size;++i)
          {
                    for(j=0;j<=i;++j)
                         printf("     "); 
                    for(j=i;j<size;++j)
                         printf("%4d",r->get(i,j));
                    putchar('\n');
           }
           return   0;
  }
