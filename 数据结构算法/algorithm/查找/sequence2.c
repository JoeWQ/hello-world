/*
  *@aim:��λ������
  *@date:2015-4-30 12:06:51
  */
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define   _OPTIMAL_  1
  //���ص�targetС������������y��
  //@request:target>=0 && target<size
  int          sequence(int     *y,int      size,const  int    target)
  {
            int               value,x,idx,left,right,tmp;
            left=0,right=size-1;
            while(  1 )
           {
//���ڼٶ����������һ�����־�����ѡȡ�ıȽ϶����Ժ����ǻ����һ�����õĽ������
//���ʹ�����ŵĽ������
                         #ifdef    _OPTIMAL_
//�����������򷽷�������µĽ����y[left]<y[right]<y[idx]
                                    tmp=idx=(left+right)>>1;
                                    if( y[right]<y[idx] )
                                              tmp=right;
                                    if( y[tmp]<y[left])
                                    {
                                                 value=y[tmp];
                                                 y[tmp]=y[left];
                                                 y[left]=value;
                                    }
                                    if( y[right] >y[idx])
                                   {
                                                 value=y[right];
                                                 y[right]=y[idx];
                                                 y[idx]=value;
                                    }
                         #endif
                         value=y[right];
//���һ�����ֲ�����Ƚϣ��������ǵļ��裬���ǽ�����ָ�Ϊ���󲿷ֵıȽ϶���
                         for(x=left-1,idx=left; idx<right;++idx)
                        {
                                      if(  y[idx]<value)
                                      {
                                                    ++x;
                                                    if(  x != idx  )
                                                    {
                                                              tmp=y[idx];
                                                              y[idx]=y[x];
                                                              y[x]=tmp;
                                                    }
                                       }
                         }
//x+1���ض�Ϊ�������Ϊ�����ֵ���λ�� value
                         y[right]=y[++x];
                         y[x]=value;
                         if(  target< x )
                                 right=x-1;
                         else if( target >x)
                                 left=x+1;
                         else
                                 return   y[x];
            }
            return         value;
   }
      int    main(int    argc,char    *argv[])
     {
                  int                  values[64];
                  int                  size=32;
                  int                   i=0;
                  srand((unsigned int)time(NULL));
                  
                  for(i=0;i<size;++i)
                              values[i]=rand()%1001;
                  for(i=0;i<size;++i)
                             printf("%d--------->%d\n",i,sequence(values,size,i));
                  return     0;
       }