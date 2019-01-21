/*
  *@aim:��λ�����⣬��ȡ��ǰ�����е�iС(��)��ֵ
  *@idea:��������
  *@date:2014-11-13 10:08:29
  *@author:�ҽ���
  */
 /*
   *@function:middle_sequence
   *@aim:ѡ�������е�iС������
   *@request:aim>=0 and aim<size
   */
   #include<stdio.h>
   #include<stdlib.h>
   #include<time.h>
   int    middle_sequence(int   *d,int  size,int  aim)
  {
//�ݹ�����ʱ��Ҫ��ָ��
 //           int      *p;
//��¼���˵ı߽�ֵ
            int      origin,bottom;
//�м�ֵ
            int      middle_index,middle_value;
            int      left,right;
            int      a,b;
//
            left=0,right=size-1;
            while(   true )
          {
                        origin=left;
                        bottom=right;
                        middle_index=(left+right)>>1;
//��ѡȡ��middle_value������һ���м�ֵ���Ա��⼫�˵����г���
                        middle_value=d[middle_index];
                        a=d[origin];
                        b=d[bottom];
//����a=max(a,b), b=min(a,b)
                        if(    a<b )
                       {
                                a=d[bottom];
                                b=d[origin];
                       }
                       if(    middle_value<b )
                      {
                                size=b;
                                b=middle_value;
                                middle_value=size;
                       }
//��middle_value�������м�ֵ
                       if(  middle_value > a )
                      {
                                size=middle_value;
                                middle_value=a;
                                a=size;
                       }
//ֵ������,������зǳ���Ҫ�����Ǿ����Ƿ�����ȷ���������Ŀ��ֵ�Ĺؼ�����
                       d[origin]=b;
                       d[bottom]=middle_value;
                       d[middle_index]=a;
//��7
//����ʽ�ϣ�������ķ������ڿ���������ӳ���
                        for (    ;origin <bottom ; )
                       { 
                                  while( origin<bottom && d[origin]<=middle_value)
                                               ++origin;
                                  while( bottom>origin && d[bottom] >=middle_value)
                                              --bottom;
                                  if(  origin < bottom )
                                 {
                                            a=d[origin];
                                            d[origin]=d[bottom];
                                            d[bottom]=a;
                                            ++origin;
                                             --bottom;
                                  }
                        }
                        a=d[right];
                        d[right]=d[origin];
                        d[origin]=a;
 //                       printf("origin=%d, bottom=%d\n",origin,bottom);
//��origin,bottom��aim���Ƚ�,���Կ϶����ǣ���ʱorigin=bottom,���� origin=bottom+1
                        if(    aim<origin )
                                 right=origin-1;
                        else if( aim>origin )
                                 left=origin+1;
                        else
                                  return   middle_value;
           }
           return   -1;
   }
//��λ������һ��ʵ�֣�������ӽ��գ������������������
//@request:same as above
   int       other_middle_sequence(int   *d,int   size,int  aim)
  {
            int      left,right;
            int      middle,e;
            int      origin,bottom;
//
           left=0,right=size-1;
           while( true )
          {
//����d[left],d[right],d[(left+right)/2]����ֵ
                    middle=(left+right)>>1;
//3��middle,right��ѡ�����Сֵ,ʹ�õķ�������������
                    size=right;
                    if(   d[middle] <= d[right] )
                             size=middle;   
                    if( d[left] > d[size] )
                   {
                            e=d[left];
                            d[left]=d[size];
                            d[size]=e;
                   }
//eΪd[left],d[middle],d[right]���м�ֵ
                   e=d[right];   //�ٶ�eΪ�м�ֵ����d[right]=e
                   if(  d[middle]< d[right] ) //�������d[right]Ϊ���ֵ,�ͽ�����d[middle]��������
                  {
                            e=d[middle];
                            d[middle]=d[right];
                            d[right]=e;
                   }
                   origin=left-1;
//ע�⣬����Ĵ������ĸ������Ͻ��в���
                   for(bottom=left;bottom<right-1;++bottom)
                  {
                            if(  d[bottom] <=e )
                           {
                                      ++origin;
                                      if(  origin != bottom )
                                     {
                                               middle=d[bottom];
                                               d[bottom]=d[origin];
                                               d[origin]=middle;
                                     }
                            }
                   }
//�ƺ�
                   ++origin;
                   d[right]=d[origin];
                   d[origin]=e;
//��Ϊ�޶�left,right�ľ���
                   if(  aim<origin )
                         right=origin-1;
                   else  if( aim>origin )
                         left=origin+1;
                   else
                         return   e;
           }
           return   -1;
   }
    int    main(int    argc,char   *argv[])
  {
           int    d[16];
           int    size=6;
           int    i;
//ȥ�������
           srand((int) time(NULL));
//
          for(i=0;i<size;++i)
               d[i]=rand()%153;
          for(i=0;i<size;++i)
               printf("%d\n",d[i]);
          printf("------------------------middle_sequence----------------------------\n");
          for(i=0;i<size;++i)
         {
             printf("%d----------------->%d \n",i,middle_sequence(d,size,i));
 //            printf("%d----------------->%d \n",i,other_middle_sequence(d,size,i));
         }
//��ǰ����������
          for(i=0;i<size;++i)
               printf("%d\n",d[i]);
         return  0;
  }
