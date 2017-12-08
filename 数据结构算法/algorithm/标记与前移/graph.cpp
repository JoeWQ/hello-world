/*
  *@aim:标记与前移算法中图数据结构的实现
  *@date:2015-6-2
  */
 #include"graph.h"
 #include<assert.h>
 CGraph::CGraph(CArray2D<int>     *graph)
{
             int          row=graph->rowCount();
             this->m_size=row;
             this->m_vertex=new     CVertex[row];
             int          invalide=graph->getInvalideValue();

             int          i,j;
             CSequelaVertex           *sequela;
             CAdjoinVertex             *adjoin;
//初始，所有的数据清零         
             for(i=0;i<this->m_size;++i)
            {
                           m_vertex[i].m_sequelaVertex=NULL;
                           m_vertex[i].m_adjoinVertex=NULL;
                           m_vertex[i].m_vertex=0;
                           m_vertex[i].m_sequelaCount=0;
             }
             for(i=0;i<row;++i)
            {
                           for(j=0;j<row;++j)
                          {
                                          int         value=graph->get(i,j);
                                          if(value != invalide)
                                         {
//创建后继顶点
                                                         sequela=new   CSequelaVertex();
                                                         sequela->sequelaVertex=j;
                                                         sequela->actualVertex=i;
                                                         sequela->weight=value;
                                                         sequela->next=m_vertex[i].m_sequelaVertex;
                                                         m_vertex[i].m_sequelaVertex=sequela;
                                                         ++m_vertex[i].m_sequelaCount;//同级该顶点的后继顶点的数量
//创建邻接顶点,注意以下是两个相反的方向
//i--->j
                                                         adjoin=new    CAdjoinVertex();
                                                         adjoin->adjoinVertex=j;
                                                         adjoin->next=m_vertex[i].m_adjoinVertex;
                                                         m_vertex[i].m_adjoinVertex=adjoin;
//j--->i                                                         
                                                         adjoin=new    CAdjoinVertex();
                                                         adjoin->adjoinVertex=i;
                                                         adjoin->next=m_vertex[j].m_adjoinVertex;
                                                         m_vertex[j].m_adjoinVertex=adjoin;
                                          }
 }
 //destroy
  CGraph::~CGraph()
 {
                 int           i;
                 CSequelaVertex          *sequela,*p;
                 CAdjoinVertex            *adjoin,*q;
                 for(i=0;i<m_size;++i)
                {
                                sequela=m_vertex[i].m_sequelaVertex;
                                while(sequela)
                               {
                                              p=sequela;
                                              sequela=sequela->next;
                                              delete   p;
                                }
                                adjoin=m_vertex[i].m_adjoinVertex;
                                while(adjoin)
                               { 
                                              q=adjoin;
                                              adjoin=adjoin->next;
                                              delete   q;
                                }
                 } 
                 delete    m_vertex;
                 m_vertex=NULL;
                 m_size=0;
  }
  //
    CVertex            *CGraph::getVertex(int     idx)
   {
                 assert(idx>=0 && idx<m_size);
                 return       m_vertex+idx;
    }
    //
     int                  CGraph::size()
    {
                 return      this->m_size;
     }
//图的拓扑排序,输出到set里面，如果排序成功了
    int                    topologicSort(int          *set)
   {
//记录排序定点的堆栈
                int            *stack=new     int[this->m_size<<1];
//记录各个顶点的入度
                int            *count=stack+this->m_size;
                int            size=0,i,top=-1;
                for(i=0;i<m_size;++i)
               {
                              count[i]=m_vertex[i].m_sequelaCount;
                              if(count[i]==0)
                             {
                                       stack[size++]=i;
                                       top=i;
                              }
                }
//如果没有找到入度为0 的边，排序失败
                if(top==-1)
               {
                         delete    stack;
                        return   0;
                }
                i=0;
                CSequelaVertex       *sequela;
                while(  size>0  )
               {
                              top=stack[--size];
                              set[i++]=top;
                              sequela=m_vertex[top].m_sequelaVertex;
//顺序地删除边
                              while(sequela)
                             {
                                             --count[sequela->sequelaVertex];
                                             if( !count[sequela->sequelaVertex])
                                                             stack[size++]=sequela->sequelaVertex;
                                             sequela=sequela->next;
                              }
                }
                delete     stack;
//检测是否有环
                return   i==m_size;
    }