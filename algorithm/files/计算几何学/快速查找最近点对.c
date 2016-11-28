//2013年4月17日16:04:21
//在N个点中快速查找最近点对,使得他的运行时间可以达到O(N*lnN)的数量级
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #include<time.h>

  #define   INF_TE    1e8
//
  typedef  struct  _Point
 {
       int        x;
       int        y;
  }Point;
static  float  cmp_points(Point  **ypoint,int  size);
//一般的求平面最近点对的算法
  int  generic_point_pair(Point  *point,int size)
 {
       int       i,k;
       int       x,y;
       float     dist,e;

       dist=(float)INF_TE;
       for(i=1;i<size;++i)
      {
               for(k=i+1;k<=size;++k)
              {
                       x=point[k].x-point[i].x;
                       y=point[k].y-point[i].y;
                       e=(float)sqrt(x*x+y*y);
                       if(e<dist)
                             dist=e;
               }
       }
       return  (int)dist;
  }
//对 点按 x坐标的值进行排序
  static  void  xadjust(Point *point,int parent,int size)
 {
       int     child=parent<<1;
       Point   key=point[parent];
      
       for(     ;child<=size; child<<=1  )
      {
               if(child<size && point[child].x<point[child+1].x)
                        ++child;
               if(key.x<point[child].x)
                       point[parent]=point[child];
               else
                       break;
               parent=child;
       }
       point[parent]=key;
  }
//排序的过程
  static  void  xheap_sort(Point *point,int size)
 {
       int      i;
       Point    key;

       for(i=size>>1;i>0 ;--i)
               xadjust(point,i,size);
//调整最大堆
       for(i=size;i>1;    )
      {
               key=point[1];
               point[1]=point[i];
               point[i]=key;

               xadjust(point,1,--i);
       }
  }
//对坐标按照y坐标进行排序
  static  void  yadjust(Point  **point,int  parent,int  size)
 {
       int    child;
       Point  *key=point[parent];
 
       for(child=parent<<1;child<=size;     )
      {
              if(child<size && point[child]->y<point[child+1]->y)
                       ++child;
              if(key->y<point[child]->y)
                      point[parent]=point[child];
              else
                      break;
              parent=child;
              child<<=1;
       }
       point[parent]=key;
  }
//
  static  void  yheap_sort(Point  **point,int  size)
 {
       int    i;
       Point  *key;
 
       for(i=size>>1; i>0 ;--i)
               yadjust(point,i,size);
//交换
       for(i=size;i>1;    )
      {
               key=point[1];
               point[1]=point[i];
               point[i]=key;

               yadjust(point,1,--i);
       }
  }
//下面是快速求最小点对之间距离的过程
  int   fast_point_pair(Point  *point,int  size)
 {
//m将记录着计算点对距离的跨度
       int        i,k,m,n,j;
       int        x,y,mid;
       Point      **ypoint;
       float      *dist,theta=INF_TE,e,ret=INF_TE;
//dist记录着每一步计算出的点对之间的最小距离、不过对它的引用可能要复杂一些
       dist=(float *)malloc(sizeof(float)*((size>>1)+1));
       ypoint=(Point **)malloc(sizeof(Point *)*(size+1));
//对点按x坐标进行排序
       xheap_sort(point,size);
//          printf("打印出点的坐标:\n");
//          for(i=0;i<=size;++i)
//                  printf("%d  :x:%d ,  %d  \n",i,point[i].x,point[i].y);

//第一步，计算每两个相邻的点之间的距离，但是每个点只参与一次运算
       for(i=1;i<size;i+=2)
      {
            x=point[i+1].x-point[i].x;
            y=point[i+1].y-point[i].y;
            dist[i>>1]=(float)(sqrt(x*x+y*y));
       }
//如果size是奇数
       if( size & 0x1 )
               dist[i>>1]=INF_TE;
//一下的过程的核心思想是合并或者成为归并
//m代表着所要计算的最近点对所在的 区间的跨度
       ypoint[0]=NULL;
       for(k=1,m=2;m<size;m<<=1,++k)
      {
              for(i=1;i<=size;i+=(m<<1))
             {
//将索引mid 归于后者
                    mid=i+m;
//如果剩余的局部 点不够 一步长(跨度为m)，则就把以前计算出的点的距离 前移，然后跳出当前的内部的 循环
                    if(mid>size)
                   {
                           dist[i>>(k+1)]=dist[i>>k];
                           break;
                    }
                    x=i>>k;
                    theta=dist[x]<dist[x+1]?dist[x]:dist[x+1];
//筛选各个点，将各个在(point[mid].x-theta,theta+point[mid].x)范围的点选取出来
                    x=(point[mid].x+point[mid-1].x)>>1;
                    y=x+1+(int)theta;
                    x-=(int)theta;
                    n=0;
                    for(j=mid-1; j>=i ;--j)
                   {
                            if(point[j].x>=x)
                                  ypoint[++n]=point+j;
                            else 
                                  break;
                    }
//将 mid右边的点也过滤到ypoint数组中
                    j=mid;
                    mid+=m-1;
                    mid=(mid<=size)?mid:size;
                    for(    ; j<=mid ;   ++j)
                   {
                            if(point[j].x<=y)
                                  ypoint[++n]=point+j;
                            else
                                   break;
                    }
//                    printf("size:%d ,最大边界:为  %d  \n",size,mid);
//下面是比较的过程
                    yheap_sort(ypoint,n);
                    e=cmp_points(ypoint,n);
                    if(e<theta)
                         theta=e;
//注意下面的一句代码
                    dist[i>>(k+1)]=theta;
                    if(ret>theta)
                         ret=theta;
                }
       }
       free(ypoint);
       free(dist);
       return  (int)ret;
   }
//计算size个点对的最近距离/ypoint必须是已经按照y坐标排好序的
   static  float  cmp_points(Point  **ypoint,int  size)
  {
          int      k,i,j;
          int      x,y;
          double    dist,e;

          dist=INF_TE;
//7个点，在有大量的密集的点存在时，这个是最小上界，如果小于它，将会出现几率性错误
//         printf("size--n---->%d\n",size);
         for(i=1;i<size;++i)
        {
                 k=i+5<=size?(i+5):size;
                 for(j=i+1;j<=k;++j)
                {
                       x=ypoint[i]->x-ypoint[j]->x;
                       y=ypoint[i]->y-ypoint[j]->y;

                       if(!x && !y)
                      {
                            printf("i:%d,j:%d \n",i,j);
                            printf("i坐标 x:%d y:%d   ,j坐标x:%d ,y: %d \n",ypoint[i]->x,ypoint[i]->y,ypoint[j]->x,ypoint[j]->y);
                            e=sqrt(x*x+y*y);
                            if(e<dist)
                                 dist=e;
                            printf("e--> %lf ,dist--->%lf\n",e,dist);
                       }
                       e=sqrt(x*x+y*y);
                       if(  e<dist  )
                             dist=e;
                 }
          }
//         printf("cmp_points--->%lf\n",dist);
         return (float)dist;
  }
//测试
  int  main(int  argc,char *argv[])
 {
          Point    point[129];
          int      size=124,i;
          int      dist;
          
          srand(time(NULL));
          point[0].x=0;
          point[0].y=0;
          for(i=1;i<=size;++i)
         {
                  point[i].x=rand();
                  point[i].y=rand();
          }
          printf("使用一般的计算方法计算出的最近点的距离为:\n");
          dist=generic_point_pair(point,size);
          printf("%d\n",dist);

          printf("\n使用快速点对方法计算出的距离为:\n");
          dist=fast_point_pair(point,size);
          printf("%d\n",dist);

//          printf("打印出点的坐标:\n");
//          for(i=0;i<=size;++i)
//                  printf("%d  :x:%d ,  %d  \n",i,point[i].x,point[i].y);

          return 0;
  }