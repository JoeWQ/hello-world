/*
  *@aim:��������ʵ��
  *@date:2015-8-31
  *@author:xiaohuaxiong
  */
  #include<stdio.h>
  #include<time.h>
  #include<stdlib.h>
 /*
   *@param:yΪ�����������,
   *@param:sizeΪ����ĳ���
   *@param:cΪ�ź���֮��������
   *@param:wΪ����������ݵ��Ͻ�
   */
  //@request:size>=3
   void      count_sort(int    *y,int   size,int  w,int    *c)
  {
//�Ѽ���Ϣ������
             int                 *info=new      int[w];
             int                  i;
//��ʼ����
             for(i=0;i<w;++i)
                        info[i]=0;
             for(i=0;i<size;++i)
                          ++info[y[i]];
//����С��i���������ֵ�����'
             int                 x=info[0];
             info[0]=0;
//����
             for(i=1;i<w;++i)
            {
                          int           m=info[i];
                          info[i]=info[i-1]+x;
                          x=m;
             }
             for(i=0;i<size;++i)
            {
                           c[info[y[i]] ]=y[i];
                           ++info[y[i]];
             }
             delete    info;
   }
   int      main(int    argc,char   *argv[])
  {
              int             seed,i;
              int             size=17;
              int             y[17];
              int             x[51];
              seed=17;
              
              srand((int)time(NULL));
              for(i=0;i<size;++i)
                        y[i]=rand()%seed;
              for(i=0;i<size;++i)
                        printf("%d\n",y[i]);
              printf("---------------------------------------------------\n");
              count_sort(y,size,seed,x);

              for(i=0;i<size;++i)
                        printf("%d\n",x[i]);
              return   0;
   }