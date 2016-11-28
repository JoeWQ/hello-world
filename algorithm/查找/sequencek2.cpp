/*
  *@aim:在一个单调递增的数列中查找第k小数字
  &2016-2-22 09:47:49
  */
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
//数字划分
 int                sequencek(int     *y,const    int    size,const    int   _index)
{
            int         k,m;
            int         _origin,_final;
            int         _value,_temp;
            
            _origin=0,_final=size-1;
//三元划分
            while(_origin<=_final)
           {
                           _value=y[(_origin+_final)>>1];
                           y[(_origin+_final)>>1]=y[_final];
//下面的运算将集合y划分成三段:(<_value,_value,>=_value)
                           for(m=_origin-1,k=_origin;k<_final;++k)
                          {
                                          if(y[k]<_value )
                                         {
                                                       m=m+1;
                                                       if( k  !=  m  )
                                                      {
                                                                    _temp=y[k];
                                                                    y[k]=y[m];
                                                                    y[m]=_temp;
                                                       }
                                          }
                           }
//交换_value,
                           m=m+1;
                           y[_final]=y[m];
                           y[m]=_value;
                           
                           if(_index>m)
                                    _origin=m+1;
                           else if(_index<m )
                                    _final=m-1;
                           else
                                    return      y[_index];
            }
            return     -1;
 }
     int               main(int    argc,char    *argv[])
    {
                 int                       y[32];
                 const     int        size=32;
                 int                       k,i,_key;
                 
                 srand((int)time(NULL));
                 for(k=0;k<size;++k)
                              y[k]=rand()%157;
                 
                 _key=rand()%size;
                 int     _result=sequencek(y,size,_key);
                 for(k=0;k<size;++k)
                             printf("%d------>%d\n",k,y[k]);
//排序之后,验证
                 for(i=0;i<size;++i)
                {
                               int         _index=i;
                              for(k=i+1;k<size;++k)
                             {
                                           if(y[_index] >y[k])
                                                     _index=k;
                              }
                              if(_index !=  i)
                             {
                                           int      _temp=y[_index];
                                           y[_index]=y[i];
                                           y[i]=_temp;
                              }
                 }
                 printf("------------------------------\n");
                 for(k=0;k<size;++k)
                               printf("%d----------->%d\n",k,y[k]);
                 printf("sequence   %d   is   %d \n",_key,_result);
                 printf("real  result  is %d\n",y[_key]);
                 return   0;
     }