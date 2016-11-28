/*
  *@1:最大不相邻金钱组合问题
  *2:最少硬币和问题
  *3:最大硬币收集问题
  &2016-4-20 09:36:28
  */
 #include<stdio.h>
 #define      __MONEY_TYPE_COUNT__     32
//假设_count<=__MONEY_TYPE_COUNT__ 
    int              money_max_combine(int     *_money,int   _count)
  {
                int       _max_money=0;
                int       *p=new     int[__MONEY_TYPE_COUNT__+1];
                
                p[0]=0,p[1]=_money[0];
                _max_money=_money[0];
                for(int  i=1;i<_count;++i)
               {
                            int         _index=i+1;//逻辑上的真正索引
                            _max_money=_money[i]+p[_index-2];//为了更好的表示其含义,这里选择了使用数据的冗余表示
                            if(_max_money<p[_index-1])
                                         _max_money=p[_index-1];
                            p[_index]=_max_money;                             
                }
                delete     p;
                return    _max_money;
   }
 //假设_coin是已经按照硬币的面值升序排序的
   int             coin_min_combine(int  *_coin,int   _coin_count,int    _money)
  {
//假设的最少硬币组合数目
                int             _combine_count=0;
//从子问题开始自底向上构建待求解问题的解
                int             *p=new      int[__MONEY_TYPE_COUNT__];
//如果输入是0,自然最后解也是0
                p[0]=0;
                for(int    n=1;n<=_money;++n)
               {
                             int        k=0;
                             int        _temp=0x3FFFFFFF;
                             while(n>=_coin[k] && k<_coin_count)
                            {
                                           if(_temp>p[n-_coin[k]])
                                                       _temp=p[n-_coin[k] ];
                                           ++k;
                             }
                             p[n]=_temp+1;
                }
                _combine_count=p[_money];
                delete    p;
                return    _combine_count;
   }
//最大硬币收集问题
   int              meney_max_collect(int    (*_money)[__MONEY_TYPE_COUNT__],int   _row,int   _column)
  {
               int         _record[__MONEY_TYPE_COUNT__][__MONEY_TYPE_COUNT__];
               int         i,k;
               
//初始化第0行,0列
               _record[0][0]=_money[0][0];
               for(i=1;i<_column;++i)
                            _record[0][i]=_record[0][i-1]+_money[0][i];
               for(i=1;i<_row;++i)
                            _record[i][0]=_record[i-1][0]+_money[i][0];
//递推关系
               for(i=1;i<_row;++i)
              {
                            for(k=1;k<_column;++k)
                           {
                                          int       _value;
                                          if(_record[i][k-1]>_record[i-1][k])
                                                      _value=_record[i][k-1];
                                          else
                                                      _value=_record[i-1][k];
                                          _record[i][k]=_value+_money[i][k];
                            }
               }
               return   _record[_row-1][_column-1];
   }
   int      main(int   argc,char   *argv[])
  {          
               int            money1[8]={7,5,8,2,13,9,4,20};
               int            size1=8;
               
               printf("money_max_combine is %d\n",money_max_combine(money1,size1));
               
               int            coin[5]={1,2,3,5,10};
               int            size2=4;
               int           money2=13;
               printf("coin_min_combine is %d\n",coin_min_combine(coin,size2,money2));
               
               int            money3[7][__MONEY_TYPE_COUNT__]={
                                         {0,1,0,1,0,0,1},{1,0,1,0,0,1,0},
                                         {1,0,1,0,1,0,1},{1,1,0,1,1,1,0},
                                         {0,1,0,1,0,1,1},{0,0,1,1,1,1,0},{1,1,0,0,0,1,1}
                                         };
               int           row3=7,column3=7;
               printf("meney_max_collect is %d\n",meney_max_collect(money3,row3,column3));
               return     0;
   }