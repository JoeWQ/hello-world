/*
  *@0-1��������
  & 2016-4-20 19:37:38
  */
 #include<stdio.h>
 #define       __PACK_WEIGHT__     16
 struct        Pack
{
            int          weight;
            int          value;
 };
 //��0��������һ�������
 int            package_max_combine(Pack     *_pack,int   _count,const  int    _max_weight)
{
           int           weight[__PACK_WEIGHT__][__PACK_WEIGHT__];
           int           i,k;
           
           for(i=0;i<=_max_weight;++i)
                       weight[0][i]=0;
           for(i=0;i<=_count;++i)
                       weight[i][0]=0;
           for(k=1;k<=_max_weight;++k)
          {
                      for(i=1;i<=_count;++i)
                     {
                                   int           value;
                                   if(k>=_pack[i].weight)
                                  {
                                                   value=_pack[i].value+weight[i-1][k-_pack[i].weight];
                                                   if(value<weight[i-1][k])
                                                                value=weight[i-1][k];
                                   }
                                   else//��ʱװ�ز���
                                                  value=weight[i-1][k];
                                   weight[i][k]=value;
                      }
           }
           return      weight[_count][_max_weight];
 }
  int           main(int   argc,char   *argv[])
 {
             Pack              _pack[5]={
                                           {0,0},
                                          {5,20},
                                          {4,20},
                                          {7,35},
                                          {2,10},
                                   };
             printf("package_max_combine is %d\n",package_max_combine(_pack,4,10));
             return  0;
  }