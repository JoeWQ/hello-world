/*
  *@aim:��ˮ�ߵ���,��̬�滮
  *@author:�ҽ���
  */
/*
  *@struct:��ˮ�ߵĴ���
  */
    struct      FlowLineCost
   {
//ÿ����ˮ�߲۵Ĵ���,cost��һ�����Ȳ���������
         int     *cost;
//�������ƶ�����һ����ˮ����Ӧ��λ������Ҫ�Ļ���,move_cost[i]��ʾ����� ��ǰ��ˮ��λ��i-1�ƶ���i����Ҫ�Ļ���
         int       *move_cost;
//�������ƶ�����һ����ˮ�ߵ���Ӧλ������Ҫ�Ļ���,����ʾ�Ĵ��º���ͬ��
         int       *move_other_cost;
//��ˮ�ߵĳ���
         int       size;
//��ʼ�Ĵ���:���������͵���ˮ�ߵĴ���
          int      origin_cost;
//����ʱ�������������ˮ������Ҫ�Ĵ���
          int      leave_cost;
    };
/*
  *@func:flow_line_schedule,��ˮ�ߵ��ȣ�������С��ˮ�߻��ѵ�����
  *@param:line��һ������ָ�룬�洢����������׵�ַ
  *@condition:prev->size = next->size
  */
   int       flow_line_schedule(struct  FlowLineCost    *prev,struct   FlowLineCost    *next,int    **line)
  {
//e,w��Ϊһ����ʱ����
            int     i,e,min,w;
            int     *p;
//
            int      *w1,*w2;
            w1=(int   *)malloc(sizeof(int)*prev->size);
            w2=(int   *)malloc(sizeof(int)*prev->size);
            *w1=prev->origin_cost+ *prev->cost;
            *w2=next->origin_cost+ *next->cost;
//
            for(i=1;i<prev->size;++i)
           {
//�� ������ˮ��1�ĵ�i����,����С����
                     e =  w1[i-1] + prev->move_cost[i]+prev->cost[i];
                     w = w2[i-1]+  next->move_other_cost[i]+prev->cost[i];
//
                    p=line[0];
                     if(   e  <   w )
                    {
                             w1[i]=e;
                             p[i]= 0;
                     }
                    else
                   {
                             w1[i]=w; 
                             p[i]=1;
                    }
//�󾭹���ˮ��2�ĵ�i���۵���С����
                   e = w2[i-1]+next->move_cost[i]+next->cost[i];
                   w= w1[i-1]+prev->move_other_cost[i]+next->cost[i];
 //
                   p = line[1];
                   if( e <  w )
                  {
                             w2[i]=e;
                             p[i] = 1;
                   }
                   else
                  {
                             w2[i] = w;
                             p[i ] = 0;
                   }  
            }
//------------------------------------------------------------------------------------------
            i= prev->size-1;
            if(   w1[i] + prev->leave_cost < w2[i] +next->leave_cost )
                     min = 0;
            else
                     min = 1;
            free(w1);
            free(w2);
            return    min;
   }
/*
  *@test:
  *
   */
  int      main(int    argc,char    *argv[])
 {
          struct    FlowLineCost     a,b;
          struct    FlowLineCost     *p=&a,*q=&b;
//
          int            acost[5]={10,21,15,17,16};
          int            bcost[5]={6,9,21,23,4};
          int            amove_cost[5]={0,3,2,4,5};
          int            bmove_cost[5]={0,4,4,1,3};
          int            amove_other_cost[5]={0,1,1,6,1};
          int            bmove_other_cost[5]={0,10,2,4,0};
          int            line[2][5];
          int            *trace[2];
          int            index,*r,i;
//
         p->cost=acost;
         p->size=5;
         p->move_cost=amove_cost;
         p->move_other_cost=amove_other_cost;
         p->origin_cost=2;
         p->leave_cost=7;
//---------------------
         q->cost=bcost;
         q->size=5;
         q->move_cost=bmove_cost;
         q->move_other_cost=bmove_other_cost;
         q->origin_cost=1;
         q->leave_cost=3;
//
         trace[0]=(int  *)line;
         trace[1]=(int  *)line[1];
//������ˮ�ߵ��Ⱥ���
        index= flow_line_schedule(p,q,trace);
//
        printf("%d    ",index);
        for(i=p->size-1;i>0;--i)
       {
                 r=trace[index];
                 printf(" %d   ",r[i]);
        }
        putchar('\n');
         return    0;
  }
