/*
  *@aim:ͼ���ٽֱ����ݽṹ��ʵ��
  *@date:2014-11-1 14:44:08
  *@author:�ҽ���
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
//���ڽӾ����е�����ת�����ٽֱ���
//��ʼ��������
         for(i=0;i<this->size;++i)
        {
                  this->vertex[i].post_vertex=NULL;
                  this->vertex[i].post_count=0;
                  this->vertex[i].prev_count=0;
                  this->vertex[i].is_visited=false;
         }
//����
         invalide = adj->getInvalideValue();
         for(i=0;i<this->size;++i)
        {
                  for(j=this->size-1; j>=0 ;--j )
                 {
                            value = adj->get(i,j);
//����������һ����Ч�ı�
                            if( value != invalide )
                           {
                                      p = (CSequela  *)malloc(sizeof(CSequela));
//�޸ĵ�ǰ������ڴ�����
                                      p->vertex_tag = j;
                                      p->prev_vertex=i;
                                      p->weight = value;
                                      p->next=this->vertex[i].post_vertex;
//�ߵ�ʽѹ��ջ��
                                      this->vertex[i].post_vertex=p;
//������ض��������ͳ���
                                      ++this->vertex[j].prev_count;
                                      ++this->vertex[i].post_count;
                            }
                   }
          }
  }
//����
  CGraph::~CGraph()
 {
           int               i,j;
           CSequela     *p,*q;
//�ͷź�̽�����ݽṹ��ռ�õ��ڴ�
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
//���ض������Ŀ
  int       CGraph::getVertexCount(  )
 {
           return    this->size;
  }
//���رߵ���Ŀ
  int       CGraph::getEdgeCount( )
 {
           int     i;
           int     count=0;
           for(i=0;i<this->size;++i )
                  count+=this->vertex[i].post_count;
           return   count;
  }
//������ض�������ݽṹ���ڳ����У�ʹ����һ����Ҫ�������������
   CVertex     *CGraph::getCVertex(int     v)
  {
           CVertex    *p=NULL;
           if(   v>=0 && v<this->size)
                p=this->vertex+v;
           return   p;
  }
//���غ���ض����йص����иö���ĺ�̽ڵ�������׵�ַ��ͬ���ģ�ʹ����һ����Ҫ˽���޸�
//���ݽṹ���������
   CSequela       *CGraph::getSequelaVertex(int    v)
  {
             CSequela    *q=NULL;
             if(   v>=0 && v <=this->size )
                    q= (this->vertex+v)->post_vertex;
             return   q;
  }
//ͼ����������
//@request:size of seq >=this->size+1,and the last index contains value -1
  int       CGraph::topologicSort(int     *seq )
 {
           int            i,index;
           int            stack_size=0;
           int            origin=-1;//��ʼ����
           CSequela        *q;
//
//�����ڴ棬��¼ÿ����������
            int      *prev_edge=(int   *)malloc(sizeof(int)*(this->size<<1));
//��¼ÿһ�����ܳ�Ϊ��һ�����������еĶ���
            int      *other_stack=prev_edge+this->size;
           for( i=this->size-1  ;  i >=0 ;--i  )
          {
//���������һ�����Ϊ0 �Ķ���,ѹ��ջ
                     if( ! this->vertex[i].prev_count   )
                               other_stack[stack_size++]=i;
           }
//�����⵽û�����Ϊ0�Ķ���
           if(   stack_size <=0 )
          {
                    free(prev_edge);
                    return   origin;
          }
           index=0;
            for(i=0;i<this->size;++i)
                    prev_edge[i]=this->vertex[i].prev_count;            
//�������еı�
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
//���Ŀ�궥������Ϊ0���Ϳ��Խ��������seq��
                                if(  !prev_edge[q->vertex_tag] )
                                        other_stack[stack_size++]=q->vertex_tag;
                                q=q->next;
                      }
            }
            free( prev_edge );
            return   index == this->size ?index:-1;
  }
//****************************************CGrapgEdge********************************
     CGraphEdge::CGraphEdge()
    {
     }
     CGraphEdge::~CGraphEdge()
    {

     }
//*****************************************CGraphEdgeSequence*********************
     CGraphEdgeSequence::CGraphEdgeSequence()
    {
             this->edge=NULL;
             this->size=0;
     }
     CGraphEdgeSequence::~CGraphEdgeSequence()
    {
             if( this->edge )
            {
                     free(this->edge);
                     this->size=0;
             }
     }
/*
 *@function:sortGraphEdge
 *@date:2014-11-09 20:53:16
 *@note:this function do not response free seq->edge,it caller's task
 *@aim:�Զ����µ���Ϊ����
 */
   static    void      cgrapa_edge_weight_adjust(CGraphEdge *seq,int  parent,int  size)
  {
              CGraphEdge     graph_edge,*algol=&graph_edge;
		          int            child=parent<<1;
		          algol->weight=seq[parent].weight;
		          algol->from_vertex=seq[parent].from_vertex;
	         	 algol->to_vertex=seq[parent].to_vertex;
//
             for(   ;child<=size;  )
	        	{
		                     if(child<size && seq[child].weight<seq[child+1].weight)
				                            ++child;
			                   if( algol->weight<seq[child].weight)
			                  {
			                              seq[parent].weight=seq[child].weight;
					                        	seq[parent].from_vertex=seq[child].from_vertex;
				                        		seq[parent].to_vertex=seq[child].to_vertex;
	                 			}
                				else
				                           break;
			                 	parent=child;
			                	child<<=1;
		          }
		          seq[parent].weight=algol->weight;
		          seq[parent].from_vertex=algol->from_vertex;
	         	  seq[parent].to_vertex=algol->to_vertex;
   }
   void    CGraph::sortGraphEdge(CGraphEdgeSequence  *seq)
  {
		         CGraphEdge     *edge=NULL;
          	 int            size;
		         int            i;
		         CSequela        *q;
//get count of graph edges
             size=0;
		         for(i=0;i<this->size;++i)
	                    size+=this->vertex[i].post_count;
	           seq->size=size;
		         edge=(CGraphEdge *)malloc(sizeof(CGraphEdge)*size);
		         seq->edge=edge;
//��ȡ���еı�
             size=0;
             for(i=0;i<this->size;++i)
	          {
	                        q=this->vertex[i].post_vertex;
				                  while(q)
			                   {
			                              edge[size].weight=q->weight;
					                          edge[size].from_vertex=q->prev_vertex;
					                          edge[size].to_vertex=q->vertex_tag;
					                          ++size;
					                          q=q->next;
			                    }
	            }
//��������Ա߽�������,ʹ�ö����򷽷�
              --edge;
	          	for(i=size>>1;i>0 ; --i)
		                  cgrapa_edge_weight_adjust(edge,i,size);
//swap  data
              CGraphEdge     graph_edge,*algol=&graph_edge;
	          	for(  ;size>1; )
	           {
	                        algol->weight=edge[1].weight;
				                  algol->from_vertex=edge[1].from_vertex;
			                   	algol->to_vertex=edge[1].to_vertex;
				
				                  edge[1].weight=edge[size].weight;
			                   	edge[1].from_vertex=edge[size].from_vertex;
			                  	edge[1].to_vertex=edge[size].to_vertex;
				
				                  edge[size].weight=algol->weight;
				                  edge[size].from_vertex=algol->from_vertex;
				                  edge[size].to_vertex=algol->to_vertex;
			                  	--size;
				                  cgrapa_edge_weight_adjust(edge,1,size);
	            }
   }
