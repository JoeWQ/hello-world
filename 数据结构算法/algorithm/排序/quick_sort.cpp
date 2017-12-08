/*
  *@aim:快速排序
  &2016-2-23 16:37:21
  */
 #include<stdio.h>
 #include<time.h>
 #include<stdlib.h>
    int              partion(int    *y,int       _origin,int    _final)
   {
              int                           _key,_index;
              const      int           _start=_origin;
              
              _key=y[(_origin+_final)>>1];
              y[(_origin+_final)>>1]=y[_origin];
//_index指向小于_key的集合的末尾
              _index=_origin;
              _origin=_origin+1;
              
              while(_origin<=_final )
             {
                            while(_origin<=_final && y[_origin]<_key)
                                           ++_origin,++_index;
                            while(_final>=_origin && y[_final]>_key)
                                           --_final;
                            if( _origin<_final   )
                           {
                                            int       _temp=y[_origin];
                                            y[_origin]=y[_final];
                                            y[_final]=_temp;
//此时将产生一个新的小于_key元素,小于_key的元素集合需要扩张
                                            _index=_origin;
                            }
                            ++_origin;
                            --_final;
              }
              y[_start]=y[_index];
              y[_index]=_key;
              return    _index;
    }
    void               quick_sort(int    *y,int     _origin,int    _final)
   {
                 if(_origin<_final)
                {
                            int        _index=partion(y,_origin,_final);
                            quick_sort(y,_origin,_index-1);
                            quick_sort(y,_index+1,_final);
                 }
    }
    int          main(int    argc,char    *argv[])
   {
                int               y[32];
                const      int               size=32;
                
                int               k;
                srand((int)time(NULL));
                for(k=0;k<size;++k)
                            y[k]=rand()%197;
                quick_sort(y,0,size-1);
                for(k=0;k<size;++k)
                             printf("%d----------------->%d\n",k,y[k]);
                return      0;
    }