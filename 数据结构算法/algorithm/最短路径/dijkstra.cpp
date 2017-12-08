/*
  *@aim:Dijkstra最短路径算法实现
  *@date:2014-11-5 19:09:24
  *@author:狄建彬
  */
  #include"CGHeap.h"
  #include"Array.h"
  #include"CGraph.h"
  #include<stdio.h>
  #include<stdlib.h>
  #define    infine    0x3FFFFFFF
/*
  *@function:dijkstra_shortest_path
  *@idea:贪心算法
  *@param:g图的临街表表示
  *@param:s源点
  *@param:d各个点到源点的距离
  *@param:parent各个索引所代表的顶点标示的前驱，如果一个顶点没有前驱，则为-1
  *@request:图中没有负权值，否则会破坏它贪心思想的基础假设
  *@request:size of d and parent >=g->getVertexCount()
  */
   void    dijkstra_shortest_path(CGraph   *g,int    s,int   *d,int   *parent)
  {
             int         size=g->getVertexCount();
             int         x,y;
 //一个堆中底层元素的临时指针
             CGVertex      *p;
//图中临街表后继的指针
             CSequela       *q;
//初始，向堆中填充元素
             for(x=0;x<size;++x)
            {
                        d[x]=infine;
                        parent[x]=-1;
             }
             d[s]=0;
//建立一个二叉堆
             CGHeap        heap(d,size),*h=&heap;
             while(  h->getSize() )
            {
//获取当前堆中的装载最小元素的堆指针
                       p = h->getMin();
                       y = p->vertex;
//注意，在删除之后，下面就不能再使用p了，具体原因请参见CGHeap的内部实现
                       h->removeMin();
//对y的后继结点进行松弛
                       q = g->getSequelaVertex( y );
                       while( q )
                      {
//注意下面两步的代码，根据假设q->weight始终大于0，着可以保证，接下来的任何操作都不会产生比前一步堆中的最小元素
//更小的元素d[q->vertex_tag],在贪心算法中可以解释成，当下的步骤依赖于前面已经解决的问题，
//而不依赖于将来有待解决的问题
                                    x = d[y]+q->weight;
                                    if( d[q->vertex_tag] > x )
                                   {
                                               d[q->vertex_tag]=x;
                                               parent[q->vertex_tag] = y;
//对堆中的相关元素进行调整
                                               p = h->findQuoteByIndex(q->vertex_tag);
//减值操作，这个是堆区别于树的最重要的一个操作
                                               p->key=x;
//调整堆的结构
                                               h->decreaseKey(p);
                                    }
                                    q=q->next;
                       }
             }
  }
    int    main(int    argc,char   *argv[])
  {
           int    adj[5][5]={
                                       {0,1,20,0,3},
                                       {0,0,0,50,0},
                                       {0,0,0,7,0},
                                       {0,0,0,0,0},
                                       {0,0,5,100,0}
                                 };
           int      size=5;
           int      i,j;
           int      d[6];
           int      parent[6];
           Array      garray(size,size),*y=&garray;
           for(i=0;i<size;++i)
                 for(j=0;j<size;++j)
                          y->set(i,j,adj[i][j]);
//设置无效值
          y->setInvalideValue(0);
//建立图的临街表表示
          CGraph     graph(y);
          dijkstra_shortest_path(&graph,0,d,parent);
         
          printf("We have solved the shortest path:\n");
          for( i=0;i<size;++i)
         {
                     printf("0------->%d: %d  ,path is:  ",i,d[i]);
                    j=i;
                    while(j>=0  )
                   {
                              printf("%d ",j);
                              j=parent[j];
                   }
                  putchar('\n');
           }
          return   0;
  }
