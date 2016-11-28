/*
  *@aim:最小堆的实现  
  *@note:注意里面的一点，root的索引0处将不会被使用,并且，对象之间的赋值不使用Copy构造函数
  *@note:能够修改vertex_index内容的，只有adjust函数，并且这个函数将不会检查参数的有效性，
  *@note:当前的实现在实际的应用中是不安全的，因为当操作一个元素的引用的同时，我们可能会访问已经释放掉的内存
   *@note:在下一个版本中，我们将解决掉这个问题
  *@date:2014-10-30 20:19:48
  *@author:狄建彬
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
//输入已经填充好了的值的节点，
//@request:v!=NULL
//@param:d表示各个顶点离原点的距离,定点的标示从索引0开始计算
  CGHeap::CGHeap(int    *d,int    size)
 {
            this->root=(CGVertex *)malloc(sizeof(CGVertex )*(size+4));
            this->vertex_index=(int  *)malloc(sizeof(int)*(size+4));
            this->size=size+1;
            this->total_size=size+4;
            int     child;
//数据复制
           for(child=0; child<size;++child)
          {
                     this->root[child+1].key=d[child];
                     this->root[child+1].vertex=child;
//记录下顶点与它在堆的内存位置之间的映射关系
                     this->vertex_index[child]=child+1;
           }
//调整堆的结构
            child=size>>1;
            for(     ;   child>0 ;  --child      )
                        this->adjust_top_bottom(child );
  } 
//销毁
  CGHeap::~CGHeap()
 {
           free(this->root);
           free(this->vertex_index);
  }
//向堆中插入数据
  void    CGHeap::insert(CGVertex    *v)
 {
//如果检测到当前的堆底层空间已经不足了，则扩张规模
            if( this->size >= this->total_size  )
                     this->expand(   );
            CGVertex    *r = &this->root[this->size];
            r->key = v->key;
            r->vertex=v->vertex;
//将对应的映射位置并入
            this->vertex_index[v->vertex]=this->size;
            ++this->size;
//自底向上调整数据的位置
            this->adjust_bottom_top( this->size -1 );
  }
//获取堆中元素的实际数目
  int         CGHeap::getSize(  )
 {
            return   this->size-1;
  }
//获取堆中最小元素
  CGVertex     *CGHeap::getMin(  )
 {
           CGVertex      *v=NULL;
           if(  this->size >1 )
                  v=this->root+1;
           return   v;
  }
//删除根元素，如果还有数据的话
  void     CGHeap::removeMin(   )
 {
           if(  this->size >1 )
          {
//如果达到了可以缩减的临界值，就缩减底层的内存
                       if(  this->size >DEFAULT_CGHEAP_SIZE && this->size<= (this->total_size>>2) )
                                   this->shrink(   );
                       CGVertex     *final = this->root+(this->size-1);
                       CGVertex     *origin=this->root+1;
                       origin->key = final->key;
                       origin->vertex = final->vertex;
//
                       this->vertex_index[final->vertex]=1;
                       --this->size;
//自顶向下调整堆结构
                       this->adjust_top_bottom( 1 );
           }
  }
//关键字减值操作，这个操作是堆的一项重要内容，它也是与平衡树之间的重大区分
//@request:参数v必须是有效的，它必须是堆中底层的有效的内存位置
//@request:v->key的值必须打打鱼它原来的值
   void    CGHeap::decreaseKey(CGVertex     *v)
  {
//            int      index=v-this->root;
            this->adjust_bottom_top(   v-this->root );
   }
//查找给定的图顶点所对应的堆中元素索引
//@request:vertex必须是有效的
   CGVertex      *CGHeap::findQuoteByIndex(int    vertex )
  {
            return    this->root+this->vertex_index[vertex];
   }
//以下的函数都是堆的底层函数，他们负责堆的调整，内存的扩张与缩减
//@request:parent<this->size
//@note:该函数的行为是自顶向下的，insert方法不能调用这个函数,只有在集中式中才能使用
   void       CGHeap::adjust_top_bottom( int    parent    )
  {
            int                child;
            CGVertex       v,*p=this->root+parent;
//初始
            child = parent<<1;
            v.key=p->key;
            v.vertex = p->vertex;
            p=&v;
//进入循环迭代
            for(     ; child < this->size;  child<<=1   )
           {
//如果有可能，则选择具有更小权值的后继节点
                      if(  child<this->size-1 && this->root[child].key > this->root[child+1].key)
                                 ++child;
//将已经选出的后继节点与当前节点的权值进行比较
//如果当前堆的结构违背了最小堆的原则，则交换数据,另外根据最小堆的递归定义，如果有可能
//后继的数据将一直向上滑动，知道下列的假设不再成立
                      if(   p->key > this->root[child].key )
                     {
                                this->root[parent].key=this->root[child].key;
                                this->root[parent].vertex=this->root[child].vertex;
//记录新成立的映射关系
                                this->vertex_index[this->root[child].vertex] = parent;
                      }
                      else
                                break;
                      parent=child;
            }
//收尾
            this->root[parent].key=p->key;
            this->root[parent].vertex=p->vertex;
            this->vertex_index[p->vertex]=parent;
   }
//自底向上的插入调整
   void     CGHeap::adjust_bottom_top(int   child)
  {
            int               parent;
            CGVertex     v,*p=this->root+child;
            v.key=p->key;
            v.vertex=p->vertex;
            p=&v;
//自底向上重构
            parent = child>>1;
            for(    ; parent>0 ;   parent>>=1    )
           {
//如果当前的子堆不满足最小堆的性质，交换数据
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
//数据结构的扩张
   void    CGHeap::expand(  )
 {
//扩张的规模为原来的2倍
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
//数据结构的缩减
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
