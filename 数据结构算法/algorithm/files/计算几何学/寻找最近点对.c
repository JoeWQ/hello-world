//2013年4月6日15:07:05
//在N个点之间寻找距离(欧几里得距离)最近的点对
  #include<stdio.h>
  #include<stdlib.h>
  #include<math.h>

  #define   E_INF    0xFFFFFFFF
//点的坐标结构表示
  typedef  struct  _Point
 {
        int      x;
        int      y;
  }Point;
//一些中间数据结构
  typedef  struct  _XYPoint
 {
//复制已经存在的点得X或Y坐标
        int       xy;
//记录该点得索引
        int       index;
  }XPoint;
//对点进行排序按点的某一偏序进行排序
  static  void  adjust(XYPoint   *pxy,int  parent,int  size)
 {
        int         child,tmp;
        XYPoint     key;

        key=pxy[parent];
        tmp=key.xy;
        for(child=parent<<1; child<=size;   )
       {
              if(child<size && pxy[child].xy < pxy[child+1].xy)
                      ++child;
              if(tmp >= pxy[child].xy)
                      break;
              else
                      pxy[parent]=pxy[child];

              parent=child;
              child<<=1;
        }
        pxy[parent]=key;
  }
//堆排序算法
  static  void  heap_sort(XYPoint  *pxy,int  size)
 {
        int         x,y,parent,i;
        XYPoint     tmp;
//对堆做整体的调整
        for(parent=size>>1;parent ;--parent)
                 adjust(pxy,parent,size);
//下面是排序过程
        for(i=size; i ;    )
       {
                tmp=pxy[i];
                pxy[i]=pxy[1];
                pxy[1]=tmp;

                adjust(pxy,1,--i);
        }
  }
//寻找最近点对
  void   least_distance(Point  *point,int  size)
 {
        XYPoint   *xpoint,*ypoint;
//p1,p2记录着分治算法中，两边具有最小距离的点对(在point中的索引)，而pp则记录着最终的最短点对距离
        Point     p1,p2,pp;
        int       len=size+1;
        int       i,j,k,m;
        double    disc,xm;//xm是分界线，min记录着点之间的最小距离
        double    *min;
         

        xpoint=(XYPoint  *)malloc(sizeof(XYPoint)*len);
        ypoint=(XYPoint  *)malloc(sizeof(XYPoint)*len);
        *min=(double *)malloc(sizeof(double)*(1+(size>>1)));
//复制操作
        for(x=0,y=1;x<size;++x,++y)
       {
               xpoint[y].xy=point[x].x;
               ypoint[y].xy=point[x].y;
               xpoint[y].index=ypoint[y].index=point[x].index;
        }
//下面是点的排序操作
        heap_sort(xpoint,size);
        heap_sort(ypoint,size);
//一下是采用分治法，在形式上和归并排序很相似
//因为在i=2时，情况比较特殊，所以要单独抽出来计算
//数组 min 的功能是一个树形记录
        k=0
        for(i=1;i<size;i+=2)
       {
              j=xpoint[i].index;
              m=xpoint[i+1].index;
              disc=point[j].x-point[m].x;
              xm=point[j].y-point[m].y;
              min[k++]=sqrt(disc*disc+xm*xm);
        }
//如果size是奇数
        if(size & 0x 1)
              min[k++]=E_INF;
//下面是一个合并的过程
        for(i
               