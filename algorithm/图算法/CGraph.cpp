/*
  *@aim:图的临街表数据结构的实现
  *@date:2014-11-1 14:44:08
  *@author:狄建彬
  */
  #include"CGraph.h"
  #include<stdlib.h>
//@request   adj->getColumn>0
  CGraph::CGraph(Array    *adj)
 {
         CSequela    *p;
         int             i,j,value,invalide;
         this->size = adj->getColumn();
         this->vertex=(CVertex   *)malloc(sizeof(CVertex)*this->size);
//将邻接矩阵中的数据转换到临街表中
//初始数据清零
         for(i=0;i<this->size;++i)
        {
                  this->vertex[i].post_vertex=NULL;
                  this->vertex[i].post_count=0;
                  this->vertex[i].prev_count=0;
                  this->vertex[i].is_visited=false;
         }
//增长
         invalide = adj->getInvalideValue();
         for(i=0;i<this->size;++i)
        {
                  for(j=this->size-1; j>=0 ;--j )
                 {
                            value = adj->get(i,j);
//如果这个不是一个无效的边
                            if( value != invalide )
                           {
                                      p = (CSequela  *)malloc(sizeof(CSequela));
//修改当前申请的内存数据
                                      p->vertex_tag = j;
                                      p->prev_vertex=i;
                                      p->weight = value;
                                      p->next=this->vertex[i].post_vertex;
//颠倒式压入栈中
                                      this->vertex[i].post_vertex=p;
//更新相关顶点的入读和出度
                                      ++this->vertex[j].prev_count;
                                      ++this->vertex[i].post_count;
                            }
                   }
          }
  }
//清理
  CGraph::~CGraph()
 {
           int               i,j;
           CSequela     *p,*q;
//释放后继结点数据结构所占用的内存
           for(i=0;i<this->size;++i)
          {
                     p=this->vertex[i].post_vertex;
                     while(  p  )
                    { 
                               q=p->next;
                               free( p );
                               p=q;
                     }
           }
//
           free(this->vertex);
           this->vertex=NULL;
           this->size=0;
  }
//返回顶点的数目
  int       CGraph::getVertexCount(  )
 {
           return    this->size;
  }
//返回边的数目
  int       CGraph::getEdgeCount( )
 {
           int     i;
           int     count=0;
           for(i=0;i<this->size;++i )
                  count+=this->vertex[i].post_count;
           return   count;
  }
//返回相关顶点的数据结构，在程序中，使用者一定不要更改里面的数据
   CVertex     *CGraph::getCVertex(int     v)
  {
           CVertex    *p=NULL;
           if(   v>=0 && v<this->size)
                p=this->vertex+v;
           return   p;
  }
//返回和相关顶点有关的所有该顶点的后继节点的链表首地址，同样的，使用者一定不要私自修改
//数据结构里面的数据
   CSequela       *CGraph::getSequelaVertex(int    v)
  {
             CSequela    *q=NULL;
             if(   v>=0 && v <=this->size )
                    q= (this->vertex+v)->post_vertex;
             return   q;
  }
//图的拓扑排序
//@request:size of seq >=this->size+1,and the last index contains value -1
  int       CGraph::topologicSort(int     *seq )
 {
           int            i,index;
           int            stack_size=0;
           int            origin=-1;//初始顶点
           CSequela        *q;
//
//申请内存，记录每个顶点的入度
            int      *prev_edge=(int   *)malloc(sizeof(int)*(this->size<<1));
//记录每一个可能成为下一个被排入序列的顶点
            int      *other_stack=prev_edge+this->size;
           for( i=this->size-1  ;  i >=0 ;--i  )
          {
//如果遇到了一个入度为0 的顶点,压入栈
                     if( ! this->vertex[i].prev_count   )
                               other_stack[stack_size++]=i;
           }
//如果检测到没有入度为0的顶点
           if(   stack_size <=0 )
          {
                    free(prev_edge);
                    return   origin;
          }
           index=0;
            for(i=0;i<this->size;++i)
                    prev_edge[i]=this->vertex[i].prev_count;            
//遍历所有的边
            for( i=0;i<this->size;++i)
           { 
//current aim index is 'origin'
                      if(    stack_size <=0 )
                              break;
                      origin = other_stack[--stack_size];
                      *( seq + index )= origin;
                      ++index;
                      q=this->vertex[ origin].post_vertex;
                      while(   q    )
                     {
                                --prev_edge[q->vertex_tag];
//如果目标顶点的入度为0，就可以将它加入的seq中
                                if(  !prev_edge[q->vertex_tag] )
                                        other_stack[stack_size++]=q->vertex_tag;
                                q=q->next;
                      }
            }
            free( prev_edge );
            return   index == this->size ?index:-1;
  }
