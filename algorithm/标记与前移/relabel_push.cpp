/*
  *@aim:重标记与前移算法实现
  *@date:2015-6-2
   */
   #include"CGraph.h"
   #include<assert.h>
  //标记顶点，如果有可能的话，返回是否标记了
  //@param:graph图的邻接表表示,height高度函数
  //idx,目标定点
   static       bool        relabel(CGraph   *graph,int    *height,CArray2D<int>  *c,CArray2D<int> *f,
                                                int   idx);
   //@param:content边from--->to的最大容量
   //@param:flow,当前from--->to之间的实际流
   //@param:height高度函数
   //@prgma:remind_flow剩余流量
   static       void        push(CArray2D<int>    *content,CArray2D<int>  *flow,int *remind_flow,int   from,int  to);
   //初始化前直流
 //remind_flow:剩余流
 //height:高度函数
   static        void       init_preflow(CGraph *,CArray2D<int>    *content,CArray2D<int> *flow,int  *height,
             int   *remind_flow,int  from,int  to);
 //排除操作
   static        void       discharge(CGraph *,CArray2D<int> *content,CArray2D<int> *flow,int *remind,
                                                      int *height,int idx);
   //标记与前移过程
   void           relabel_and_push(CGraph    *graph,int   from,int  to);
//重标记过程
   bool           relabel(CGraph    *graph,int    *height,CArray2D<int> *c,CArray2D<int> *f,int    idx)
  {
                      CVertex                 *vertex=graph->getVertex(idx);
                      CAdjoinVertex      *adjoin=vertex->adjoinVertex;
//分别检索各个邻接顶点
                      CAdjoinVertex       *other=adjoin;
                      adjoin=adjoin->next;
                      while( adjoin)
                     {
//具有较小高度并且有剩余流
                                   if( height[adjoin->adjoinVertex]<height[other->adjoinVertex] &&
                                         c->get(idx,adjoin->adjoinVertex)>f->get(idx,adjoinVertex)   ) 
                                                 other=adjoin;
                                   adjoin=adjoin->next;
                      }
                      if(  height[idx]<=height[other->adjoinVertex] )
                    {
                                   height[idx]=height[other->adjoinVertex]+1;
                                   return    true;
                      }
                     return     false;
   }
//压入流,调用条件height[from]=height[to]+1
  void        push(CArray2D<int>    *content,CArray2D<int>  *flow,int  *remind_flow,
                            int   from,int  to)
 {
//比较,或者是具有容量之内的流，或者是剩余流量的值
                  int          value=content->get(from,to)-flow(from,to);
                  value=value>remind_flow[from]?remind_flow[from]:value;
//
                  remind_flow[from]-=value;
                  value+=flow->get(from,to);
                  flow->set(from,to,   value);
                  flow->set(to,from,-value);
  }
//排除顶点
   void       discharge(CGraph *graph,CArray2D<int> *content,CArray2D<int> *flow,int *remind,
                                                      int *height,int idx)
  {
                  CVertex                *vertex=graph->getVertex(idx);
                  CAdjoinVertex     *adjoin=NULL;
                   while(remind[idx]>0)
                  {
                                if(  !adjoin  )
                               {
                                               adjoin=vertex->adjoinVertex;
                                               relabel(graph,height,content,flow,idx);
                                }
                                else if( height[idx]==height[adjoin->adjoinVertex]+1 && 
                                  content->get(idx,adjoin->adjoinVertex)>flow->get(idx,adjoin->adjoinVertex))
                                               push(content,flow,remind,idx,adjoin->adjoinVertex);
                                else
                                               adjoin=adjoin->next;
                   }
   }
  //
   void           relabel_and_push(CGraph    *graph,int    from,int   to)
  {
               int               size=graph->size();
               CArray2D<int>        content(size,size);
               CArray2D<int>        flow(size,size);
               CArray2D<int>        *c=&content,*f=&flow;
//剩余流
               int             *remind_flow=new    int[size];
               int             *height=new    int[size];
//顶点队列               
               int             *queue=new     int[size];
               int               i=0;
//初始化前置流
               init_preflow(c,f,height,from,to);
               assert( graph->topologicSort(queue)  );
//现在queue[0]一定为from,queue[size-1]一定为to,去掉他们
               for(i=0;i<size-2;++i)
                           queue[i]=queue[i+1];
               i=0;
               size-=2;
               while(i<size)
              {
                                   int      idx=queue[i];
                                   int      old_height=height[idx];
                                   discharge(graph,c,f,remind_flow,height,idx);
//如果在以上过程中被重标记了,i一道队列的头部
                                   if(old_height<height[idx])
                                  {
                                                 int    k=i-1;
                                                 while(k>=0)
                                                {
                                                               queue[k+1]=queue[k];
                                                               --k;
                                                 }
                                                 i=0;
                                                 queue[0]=idx;
                                   }
                                   ++i;
               }
               delete      queue;
               delete      height;
               delete      remind_flow;
   }
 //
   void            init_preflow(CGraph  *graph,CArray2D<int>  *content,CArray2D<int>  *flow,int  *height
                                             int  *remind_flow,   int   from,int to)
 {
                content->fillWith(0);
                flow->fillWith(0);
                int           i,j;
                CVertex       *vertex;
                CSequelaVertex     *sequela;
                int                         size=graph->size();
                for(i=0;i<size;++i)
               {
                               vertex=graph->getVertex(i);
                               sequela=vertex->m_sequelaVertex;
                               while(sequela)
                              {
                                               content->set(i,sequela->sequelaVertex,sequela->weight);
                                               sequela=sequela->next;
                               }
                }
//显式的赋值
                for(i=0;i<size;++i)
               {
                         height[i]=0;
                         remind_flow[i]=0;
                }
                height[from]=size;
                height[to]=0;         
//剩余流数据的修改
                vertex=graph->getVertex(from);
                sequela=vertex->m_sequelaVertex;
                while(sequela)
               {
                                remind_flow[from]-=sequela->weight;
                                remind_flow[sequela->sequelaVertex]=sequela->weight;
                                sequela=sequela->next;
                }
  }