//2013年4月2日17:04:58
//在N个点中，计算它们的最小凸包多边形
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>
  #include"栈和点的排序.c"

//计算向量的点积
  #define   POINT_MUT(p1,p2)     ((p2->x-p1->x)*(p2->y-p1->y)) 
//计算极坐标,q相对p的弧度(但是 不是确切的角度)
//注意，因为屏幕上的坐标与日常使用的指教坐标系有着很大的区别
  static  float   arc_local(Point  *p,Point  *q)
 {
       float   arc=0.0;
       float   x=0.0,y=0.0;
//如果q在p的西北方向，此时q的极角应该大于PI/2
       if(q->x<p->x)
      {
              x=(float)(p->x-q->x);
              y=(float)(p->y-q->y);
              arc=(float)(x/sqrt(x*x+y*y)+1);
       }
       else
      {
              x=(float)(q->x-p->x);
              y=(float)(p->y-q->y);
              arc=(float)(y/sqrt(x*x+y*y));
       }
       return arc;
  }
//计算最小凸包多边形(Graham 算法实现)
  void   GrahamScan(Point   *point,int  size,StackHeader  *h)
 {
       float   *arc;
       int     i,k,j=0;
       Point   *p,*q,*t,tpp;
//对要使用到的数据进行初始化    
       h->point=(int  *)malloc(sizeof(int)*size);
       h->size=size;
       h->index=0;
       arc=(float *)malloc(sizeof(float)*size);
//寻找最下面的点坐标
       k=0;
       q=point;
       for(i=1;i<size;++i)
      {
             if(point[i].y>q->y)
            {
                   k=i;
                   q=&point[i];
             }
             else if(point[i].y==q->y && point[i].x<q->x)
            {
                   k=i;
                   q=&point[i];
             }
       }
//下面是将最下面的点摘除掉
       tpp=point[k];
       --size;
       for(i=k;i<size;++i)
            point[i]=point[i+1];
       point[size]=tpp;
       p=&tpp;
//根据点得极角对点的坐标进行排序
       for(i=0;i<size;++i)
            arc[i]=arc_local(p,point+i);
       SortPoint(point-1,arc-1,size);
/*
       printf("排序后，点的坐标顺序为:\n");
       for(i=0;i<size;++i)
      {
              printf("%d-->x:%d,y:%d \n",i,point[i].x,point[i].y);
       }
*/

//下面是进入循环的初始阶段
       push(h,size);
       push(h,0);
       push(h,1);

       for(i=2;i<size;++i)
      {
             t=point+i;
//             printf("当前元素点 i:%d  x:%d,y:%d\n",i,t->x,t->y);
             GetTop(h,&k);
//             printf("站定元素为:%d : x:%d,y:%d \n",k,point[k].x,point[k].y);
             do
            {
                  NextTop(h,&k);
                  p=&point[k];
                  GetTop(h,&j);
                  q=&point[j];
                  printf("p: %d  ,q:  %d   \n",k,j);
//注意下面的叉乘操作,在计算机显示器坐标系中，它和实际的笛卡尔坐标系刚好相反
                  if(((q->x-p->x)*(t->y-q->y)-(t->x-q->x)*(q->y-p->y))>=0)
                           pop(h,&k);
                  else
                           break;
              }while(h->index);
              push(h,i);
       }
  }
//
  int  main(int argc,char  *argv[])
 {
       Point   point[10]={{5,20},{10,18},{8,10},{24,16},{18,14},{11,0},{7,5}};
       int     i,k=0,len=7;
       StackHeader   hStack,*h=&hStack;

       printf("排序后，点的顺序为:\n");
       GrahamScan(point,len,h);

       printf("在剩余的点中，作为凸多边形的顶点有:\n");
//注意下面取出栈中的元素的方式
       for(i=0;i<h->index;++i)
      {
              k=h->point[i];
              printf("顶点%d:  x:%d,y:%d  \n",k,point[k].x,point[k].y);
       }
       return 0;
  }