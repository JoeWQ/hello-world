/*
  *@aim:��С�ѵ�ʵ��  
  *@note:ע�������һ�㣬root������0�������ᱻʹ��,���ң�����֮��ĸ�ֵ��ʹ��Copy���캯��
  *@note:�ܹ��޸�vertex_index���ݵģ�ֻ��adjust��������������������������������Ч�ԣ�
  *@note:��ǰ��ʵ����ʵ�ʵ�Ӧ�����ǲ���ȫ�ģ���Ϊ������һ��Ԫ�ص����õ�ͬʱ�����ǿ��ܻ�����Ѿ��ͷŵ����ڴ�
   *@note:����һ���汾�У����ǽ�������������
  *@date:2014-10-30 20:19:48
  *@author:�ҽ���
  */
  #include"CGHeap.h"
  #include<stdlib.h>
  #define      DEFAULT_CGHEAP_SIZE      8
  CGHeap::CGHeap()
 {
            this->root=(CGVertex   *)malloc(sizeof(CGVertex)*(DEFAULT_CGHEAP_SIZE));
            this->vertex_index=(int   *)malloc(sizeof(int)*(DEFAULT_CGHEAP_SIZE));
            this->size=1;
            this->total_size=DEFAULT_CGHEAP_SIZE;
  }
//�����Ѿ������˵�ֵ�Ľڵ㣬
//@request:v!=NULL
//@param:d��ʾ����������ԭ��ľ���,����ı�ʾ������0��ʼ����
  CGHeap::CGHeap(int    *d,int    size)
 {
            this->root=(CGVertex *)malloc(sizeof(CGVertex )*(size+4));
            this->vertex_index=(int  *)malloc(sizeof(int)*(size+4));
            this->size=size+1;
            this->total_size=size+4;
            int     child;
//���ݸ���
           for(child=0; child<size;++child)
          {
                     this->root[child+1].key=d[child];
                     this->root[child+1].vertex=child;
//��¼�¶��������ڶѵ��ڴ�λ��֮���ӳ���ϵ
                     this->vertex_index[child]=child+1;
           }
//�����ѵĽṹ
            child=size>>1;
            for(     ;   child>0 ;  --child      )
                        this->adjust_top_bottom(child );
  } 
//����
  CGHeap::~CGHeap()
 {
           free(this->root);
           free(this->vertex_index);
  }
//����в�������
  void    CGHeap::insert(CGVertex    *v)
 {
//�����⵽��ǰ�Ķѵײ�ռ��Ѿ������ˣ������Ź�ģ
            if( this->size >= this->total_size  )
                     this->expand(   );
            CGVertex    *r = &this->root[this->size];
            r->key = v->key;
            r->vertex=v->vertex;
//����Ӧ��ӳ��λ�ò���
            this->vertex_index[v->vertex]=this->size;
            ++this->size;
//�Ե����ϵ������ݵ�λ��
            this->adjust_bottom_top( this->size -1 );
  }
//��ȡ����Ԫ�ص�ʵ����Ŀ
  int         CGHeap::getSize(  )
 {
            return   this->size-1;
  }
//��ȡ������СԪ��
  CGVertex     *CGHeap::getMin(  )
 {
           CGVertex      *v=NULL;
           if(  this->size >1 )
                  v=this->root+1;
           return   v;
  }
//ɾ����Ԫ�أ�����������ݵĻ�
  void     CGHeap::removeMin(   )
 {
           if(  this->size >1 )
          {
//����ﵽ�˿����������ٽ�ֵ���������ײ���ڴ�
                       if(  this->size >DEFAULT_CGHEAP_SIZE && this->size<= (this->total_size>>2) )
                                   this->shrink(   );
                       CGVertex     *final = this->root+(this->size-1);
                       CGVertex     *origin=this->root+1;
                       origin->key = final->key;
                       origin->vertex = final->vertex;
//
                       this->vertex_index[final->vertex]=1;
                       --this->size;
//�Զ����µ����ѽṹ
                       this->adjust_top_bottom( 1 );
           }
  }
//�ؼ��ּ�ֵ��������������Ƕѵ�һ����Ҫ���ݣ���Ҳ����ƽ����֮����ش�����
//@request:����v��������Ч�ģ��������Ƕ��еײ����Ч���ڴ�λ��
//@request:v->key��ֵ����������ԭ����ֵ
   void    CGHeap::decreaseKey(CGVertex     *v)
  {
//            int      index=v-this->root;
            this->adjust_bottom_top(   v-this->root );
   }
//���Ҹ�����ͼ��������Ӧ�Ķ���Ԫ������
//@request:vertex��������Ч��
   CGVertex      *CGHeap::findQuoteByIndex(int    vertex )
  {
            return    this->root+this->vertex_index[vertex];
   }
//���µĺ������Ƕѵĵײ㺯�������Ǹ���ѵĵ������ڴ������������
//@request:parent<this->size
//@note:�ú�������Ϊ���Զ����µģ�insert�������ܵ����������,ֻ���ڼ���ʽ�в���ʹ��
   void       CGHeap::adjust_top_bottom( int    parent    )
  {
            int                child;
            CGVertex       v,*p=this->root+parent;
//��ʼ
            child = parent<<1;
            v.key=p->key;
            v.vertex = p->vertex;
            p=&v;
//����ѭ������
            for(     ; child < this->size;  child<<=1   )
           {
//����п��ܣ���ѡ����и�СȨֵ�ĺ�̽ڵ�
                      if(  child<this->size-1 && this->root[child].key > this->root[child+1].key)
                                 ++child;
//���Ѿ�ѡ���ĺ�̽ڵ��뵱ǰ�ڵ��Ȩֵ���бȽ�
//�����ǰ�ѵĽṹΥ������С�ѵ�ԭ���򽻻�����,���������С�ѵĵݹ鶨�壬����п���
//��̵����ݽ�һֱ���ϻ�����֪�����еļ��費�ٳ���
                      if(   p->key > this->root[child].key )
                     {
                                this->root[parent].key=this->root[child].key;
                                this->root[parent].vertex=this->root[child].vertex;
//��¼�³�����ӳ���ϵ
                                this->vertex_index[this->root[child].vertex] = parent;
                      }
                      else
                                break;
                      parent=child;
            }
//��β
            this->root[parent].key=p->key;
            this->root[parent].vertex=p->vertex;
            this->vertex_index[p->vertex]=parent;
   }
//�Ե����ϵĲ������
   void     CGHeap::adjust_bottom_top(int   child)
  {
            int               parent;
            CGVertex     v,*p=this->root+child;
            v.key=p->key;
            v.vertex=p->vertex;
            p=&v;
//�Ե������ع�
            parent = child>>1;
            for(    ; parent>0 ;   parent>>=1    )
           {
//�����ǰ���ӶѲ�������С�ѵ����ʣ���������
                        if(   p->key < this->root[parent].key )
                       {
                                  this->root[child].key=this->root[parent].key;
                                  this->root[child].vertex=this->root[parent].vertex;
                                  this->vertex_index[this->root[parent].vertex]=child;
                        }
                        else
                                  break;
                        child=parent;
            }
//
            this->root[child].key=p->key;
            this->root[child].vertex=p->vertex;
            this->vertex_index[p->vertex]=child;
  }
//���ݽṹ������
   void    CGHeap::expand(  )
 {
//���ŵĹ�ģΪԭ����2��
            this->total_size = this->size<<1;
            CGVertex     *p=(CGVertex *)malloc(sizeof(CGVertex)*this->total_size);
            int               *index=(int *)malloc(sizeof(int)*this->total_size);
            int                i;
            for( i=1   ;i< size ; ++i)
           {
                      p[i].key=this->root[i].key;
                      p[i].vertex=this->root[i].vertex;
                      index[i-1]=this->vertex_index[i-1];
            }
            free(this->root);
            free(this->vertex_index);
            this->root=p;
            this->vertex_index=index;
  }
//���ݽṹ������
   void    CGHeap::shrink(  )
  {
            this->total_size=this->total_size>>1;
            CGVertex    *p=(CGVertex *)malloc(sizeof(CGVertex)*this->total_size);
            int              *index=(int  *)malloc(sizeof(int)*this->total_size);
            int               i;
            for( i=1;i<size;++i)
           {
                    p[i].key = this->root[i].key;
                    p[i].vertex = this->root[i].vertex;
                    index[i-1]=this->vertex_index[i-1];
            }
            free(this->root);
            free(this->vertex_index);
            this->root = p;
            this->vertex_index=index;
   }
