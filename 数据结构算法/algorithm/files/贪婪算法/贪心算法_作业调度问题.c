//2013��5��5��21:10:31
//��ҵ�������⡢̰���㷨
  #include<stdio.h>
  #include<stdlib.h>
/*********************************************/
  typedef  struct  _Task
 {
//��ҵ��ٵ����ʱ��
         int     delay;
//������ҵ��û�����ʱ�ĳͷ�
         int     weight;
  }Task;
/********************************************/
//�������������ǰ�������Ѿ�����task�����Ѿ�����weight�����ź�����
//task[0]Ϊһ�����������䲢���������ڣ�ֻ��Ϊ�˼򻯳�����ƶ�����
  int  task_schedule(Task  *task,int  size,int *buf)
 {
        int   i,j,k;
        int   max,t,ct;

        k=0;
        buf[k++]=0;
        max=0;
        t=0;
        for(i=1;i<=size;++i)
       {
              if(task[i].delay<=t && t==max)
                       continue;
              else
             {
//���뵽��ҵ�����еĺ���λ��
                      ++t;
                      if(max<task[i].delay)
                            max=task[i].delay;
                      for(j=k;j>0;--j)
                     {
                              ct=buf[j-1];
                              if(task[i].delay<task[ct].delay)
                                      buf[j]=ct;
                              else
                                      break;
                      }
                      buf[j]=i;
                      ++k;
               }
         }
         return k;
  }
//
  int  main(int argc,char *argv[])
 {
       Task   task[8]={ {0,0}, {4,70},{2,60},{4,50},{3,40},{1,30},{4,20},{6,10} };
       int    size=7;
       int    buf[8],len,i;

       for(i=0;i<=size;++i)
             buf[i]=0;
       len=task_schedule(task,size,buf);
       printf("####\n");
       for(i=1;i<len;++i)
            printf(" %d ",buf[i]);
       printf("\n#######\n");
       return 0;
  }