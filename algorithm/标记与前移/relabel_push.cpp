/*
  *@aim:�ر����ǰ���㷨ʵ��
  *@date:2015-6-2
   */
   #include"CGraph.h"
   #include<assert.h>
  //��Ƕ��㣬����п��ܵĻ��������Ƿ�����
  //@param:graphͼ���ڽӱ��ʾ,height�߶Ⱥ���
  //idx,Ŀ�궨��
   static       bool        relabel(CGraph   *graph,int    *height,CArray2D<int>  *c,CArray2D<int> *f,
                                                int   idx);
   //@param:content��from--->to���������
   //@param:flow,��ǰfrom--->to֮���ʵ����
   //@param:height�߶Ⱥ���
   //@prgma:remind_flowʣ������
   static       void        push(CArray2D<int>    *content,CArray2D<int>  *flow,int *remind_flow,int   from,int  to);
   //��ʼ��ǰֱ��
 //remind_flow:ʣ����
 //height:�߶Ⱥ���
   static        void       init_preflow(CGraph *,CArray2D<int>    *content,CArray2D<int> *flow,int  *height,
             int   *remind_flow,int  from,int  to);
 //�ų�����
   static        void       discharge(CGraph *,CArray2D<int> *content,CArray2D<int> *flow,int *remind,
                                                      int *height,int idx);
   //�����ǰ�ƹ���
   void           relabel_and_push(CGraph    *graph,int   from,int  to);
//�ر�ǹ���
   bool           relabel(CGraph    *graph,int    *height,CArray2D<int> *c,CArray2D<int> *f,int    idx)
  {
                      CVertex                 *vertex=graph->getVertex(idx);
                      CAdjoinVertex      *adjoin=vertex->adjoinVertex;
//�ֱ���������ڽӶ���
                      CAdjoinVertex       *other=adjoin;
                      adjoin=adjoin->next;
                      while( adjoin)
                     {
//���н�С�߶Ȳ�����ʣ����
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
//ѹ����,��������height[from]=height[to]+1
  void        push(CArray2D<int>    *content,CArray2D<int>  *flow,int  *remind_flow,
                            int   from,int  to)
 {
//�Ƚ�,�����Ǿ�������֮�ڵ�����������ʣ��������ֵ
                  int          value=content->get(from,to)-flow(from,to);
                  value=value>remind_flow[from]?remind_flow[from]:value;
//
                  remind_flow[from]-=value;
                  value+=flow->get(from,to);
                  flow->set(from,to,   value);
                  flow->set(to,from,-value);
  }
//�ų�����
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
//ʣ����
               int             *remind_flow=new    int[size];
               int             *height=new    int[size];
//�������               
               int             *queue=new     int[size];
               int               i=0;
//��ʼ��ǰ����
               init_preflow(c,f,height,from,to);
               assert( graph->topologicSort(queue)  );
//����queue[0]һ��Ϊfrom,queue[size-1]һ��Ϊto,ȥ������
               for(i=0;i<size-2;++i)
                           queue[i]=queue[i+1];
               i=0;
               size-=2;
               while(i<size)
              {
                                   int      idx=queue[i];
                                   int      old_height=height[idx];
                                   discharge(graph,c,f,remind_flow,height,idx);
//��������Ϲ����б��ر����,iһ�����е�ͷ��
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
//��ʽ�ĸ�ֵ
                for(i=0;i<size;++i)
               {
                         height[i]=0;
                         remind_flow[i]=0;
                }
                height[from]=size;
                height[to]=0;         
//ʣ�������ݵ��޸�
                vertex=graph->getVertex(from);
                sequela=vertex->m_sequelaVertex;
                while(sequela)
               {
                                remind_flow[from]-=sequela->weight;
                                remind_flow[sequela->sequelaVertex]=sequela->weight;
                                sequela=sequela->next;
                }
  }