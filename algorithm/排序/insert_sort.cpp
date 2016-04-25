/*
  *@aim:插入排序
  &2016-2-19 09:38:22
  */
 #include<stdio.h>
 #include<stdlib.h>
 #include<time.h>
//升序排序
    void        insert_sort(int      *y,int    size)
   {
                 int           i,k;
                 int           _key;
                 for(i=1;i<size;++i)
                { 
                              _key=y[i];
                              k=i-1;
                              while(k>=0 && y[k]>_key)
                             {
                                           y[k+1]=y[k];
                                           --k;
                              }
                              if(k+1 != i )
                                           y[k+1]=_key;
                 }
    }
//shell 排序
    void           shell_sort(int     *y,const  int     size)
   {
//步长
                 const     int       step[5]={121,40,13,4,1};
                 int                      k,_step,_key;
                 int                      i;
                 for(k=0;k<5;++k)
                {
                                _step=step[k];
//i为起始索引
                                for(i=0;i<size;i+=_step)
                               {
                                               const  int    j=i+_step>size?i+_step:size;
                                               for(int   a=i+1;a<j;++a)
                                              {
                                                               int      b=a-1;
                                                               _key=y[a];
                                                               while(b>=i && y[b]>_key)
                                                              {
                                                                              y[b+1]=y[b];
                                                                              --b;
                                                               }
                                                               if(b+1 != a)
                                                                         y[b+1]=_key;
                                               }
                                }
                 }
    }
    int      main(int    argc,char   *argv[])
   {
//使用大的数据量来测试两种算法的运行时间
                int               *a1=(int *)malloc(sizeof(int)*1024*128);
                int               *a2=(int *)malloc(sizeof(int)*1024*128);
                int               i;
                int          size=1024*128;
                srand(0xf56789);
                for(i=0;i<size;++i)
               {
                              a1[i]=rand();
                              a2[i]=rand();
                }
                time_t        _start,_end;
                _start=clock();
                insert_sort(a1,size);
                _end=clock();
                printf("time :%f\n",difftime(_end,_start));
                
                _start=clock();
                shell_sort(a2,size);
               _end=clock();
               printf("time :%f\n",difftime(_end,_start));
//实验证明,对于大数据量,shell排序的速度要远远快于插入排序,尽管它看上去代码不够美观
//15055:31
#ifdef   __TEST__
                for(i=0;i<size;++i)
               {
                               printf(" %d ",a1[i]);
                               if(i % 8==0)
                                         printf("\n");
                }
                printf("\n-----------------------------------\n");
                for(i=0;i<size;++i)
               {
                               printf(" %d ",a2[i]);
                               if(i % 8==0)
                                         printf("\n");
                }
#endif
                return  0;
    }