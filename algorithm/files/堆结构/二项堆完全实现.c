//20113/1/7/14:17
//最小二项堆操作，在一个二项堆中，我们将它的所有根链按照它的度的大小严格地的进行排序
  #include<stdio.h>
  #include<stdlib.h>
  #define  INF_T   0x7FFFFFFF
//定义二项堆的数据结构
  typedef  struct  _Beap
 {
//数据域
        int               key;
//记录结点的度
        int               degree;
//指向父结点的指针
        struct  _Beap    *parent;
//指向右兄弟结点的指针
        struct  _Beap    *rsib;     
//指向后代结点的指针
        struct  _Beap    *child;  
  }Beap;
//定义二项堆的头结点的结构
  typedef  struct  _BeapHeader
 {
//二项堆的根
        struct  _Beap    *root;
//记录这个二项堆的结点数目
        int              count;
  }BeapHeader;
//合并两个结点
  static  void  union_2_node(Beap  *,Beap  *b);
//翻转链表,并且使这些链表的父指针为空
  static  void  reverse_p_null_node(BeapHeader *);
//合并两个二项堆,并按照度的大小进行严格升序排序,注意，这里面只是进行根的排序，但并不进行根的合并
//而且这里面不进行参数的合法性检查,它所做的前提假设是 ha,hb所包含的二项堆均不为空
  void  beap_merge(BeapHeader  *ha,BeapHeader  *hb)
 {
//t记录的是整个二项堆的根结点
        Beap  *a,*b;
        Beap  *vbuf[32];
        int   k=0,i=0;
        a=ha->root;
        b=hb->root;
        while( a && b )
       {
//如果此时 a的度小于等于b结点的度,就将a放在前面
              if(a->degree<=b->degree)
             {
                     vbuf[k++]=a;
                     a=a->rsib;
              }
              else
             {
                     vbuf[k++]=b;
                     b=b->rsib;
              }
        }
        i=1;
        while(i<k)
       {
              vbuf[i-1]->rsib=vbuf[i];
              ++i;
        }
//注意下面的代码
        vbuf[i-1]->rsib=a?a:b;
        ha->root=vbuf[0];
        ha->count+=hb->count;
        hb->root=NULL;
        hb->count=0;
   }
//合并二项堆中具有相同度的根结点,这里依然没有对参数进行检查
  void  beap_union(BeapHeader  *h)
 {
//a为当前结点,b为a的后继结点,prev为a的前驱，若a没有前驱，则prev为空
        Beap  *a,*b,*prev;
        prev=NULL;
        a=h->root;
        b=a->rsib;
//循环进行的条件，a的后继不为空
        while( b )
       {
                if(a->degree!=b->degree || (b->rsib && b->rsib->degree==b->degree))
               {
                      prev=a;
                      a=b;
                      b=b->rsib;
                }
                else if(a->key<=b->key)
               {
                      a->rsib=b->rsib;
                      union_2_node(a,b);
                      b=a->rsib;
                }
                else
               {
                      if(!  prev)
                           h->root=b;
                      else
                           prev->rsib=b;
                      union_2_node(b,a);
                      a=b;
                      b=b->rsib;
                }
         }
  }
//合并两个根结点,将b合并到a中
  static void  union_2_node(Beap  *a,Beap  *b)
 {
//首先将a的度增加一
       b->rsib=NULL;
       ++a->degree;
       b->parent=a;
       b->rsib=a->child;
       a->child=b;
  }
//查找最小结点和最小结点的前驱，若没有前驱则在prev中写入NULL,若prev为NULL，则不写入.所需的时间O(ln(n))
  Beap  *find_min(BeapHeader  *h,Beap  **prev)
 {
//p记录着a前驱,b记录着最小根结点,r记录着最小根结点的前驱
       Beap  *a,*p,*b,*r;
//初始化数据
       a=h->root;
       b=a;
       p=NULL;
       r=NULL;
       while( a )
      {
            if(a->key<=b->key)
           {
                 r=p;
                 b=a;
            }
            p=a;
            a=a->rsib;
       }
       if( prev )
            *prev=r;
       return b;
  }
//向一个二项堆中插入一个结点
  Beap  *insert_beap(BeapHeader  *h,int key)
 {
      Beap  *p=(Beap  *)malloc(sizeof(Beap));
      p->key=key;
      p->parent=NULL;
      p->child=NULL;
      p->rsib=NULL;
      p->degree=0;

      p->rsib=h->root;
      h->root=p;
      ++h->count;
      beap_union(h);
      return p;
  }
//翻转根链,且使这些结点的父指针为空
  static  void  reverse_p_null_node(BeapHeader *ha)
 {
      Beap  *a,*b,*p;
      a=ha->root;
      b=NULL;
      p=NULL;
      
      while( a )
     {
           a->parent=NULL;
           p=b;
           b=a;
           a=a->rsib;
           b->rsib=p;
      }
      ha->root=b;
  }
//从最小二项堆中删除最小值结点
  Beap  *remove_min(BeapHeader *ha)
 {
      Beap  *a,*b,*prev=NULL,*tmp;
      BeapHeader  hbc,*hb=&hbc;
       
      a=ha->root;
      if(! a)
            return NULL;
      --ha->count;
      hb->count=0;
      hb->root=NULL;
//b为查找到的最小结点,和最小结点的前驱
      b=find_min(ha,&prev);
      tmp=b;
//检查查找的结点是否是第一个结点
      if(! prev)//此时a==b
     {
           ha->root=b->rsib;
           hb->root=b->child;
           b->rsib=NULL;
      }
      else
     {
           prev->rsib=b->rsib;
           b->rsib=NULL;
           hb->root=b->child;
      }
//处理hb中的二项堆的根结点,翻转链表，且使这些结点的父指针为空
      reverse_p_null_node(hb);
//判断两个二项堆是否为空
      if(!ha->root)
     {
           ha->root=hb->root;
           hb->root=NULL;
      }
      else if(hb->root)
     {
          beap_merge(ha,hb);
          beap_union(ha);
      }
      return tmp;
  }
//关键字减值操作,将关键字减到给定的值
  int  decrease_key(Beap *a,int key)
 {
      Beap  *p;
      
      if(a->key<key)
     {
            printf("给定的值不能大于结点本身所拥有的关键字值\n");
            return 0;
      }
      a->key=key;
      p=a->parent;
//实际上，下面这个循环可以将数据交换在一次之内就可以完成
      while( p && p->key>a->key )
     {
//交换数据
            key=p->key;
            p->key=a->key;
            a->key=key;
//一直冒泡上升，直到循环条件不能成立
            a=p;
            p=p->parent;
      }
      return 1;
  }
//删除任意一个结点
  int  remove_node(BeapHeader  *h,Beap  *y)
 {
      Beap  *x;
      if( !h->root)
           return 0;
//***************************************************
//注意下面的代码
      x=find_min(h,NULL);
      decrease_key(y,x->key-1);
      x=remove_min(h);
      free(x);
      return 1;
  }
//******************************************************************
  int  main(int  argc,char *argv[])
 {
       BeapHeader    hdc,*ha=&hdc;
       Beap          *p;
       Beap          *insert_b[256];
       int           vbuf[256];
       int           size1=256,i,len=64;

       printf("初始化数组1......\n");
       srand(0x7C8F9B); 
       for(i=0;i<size1;++i)
      {
             vbuf[i]=rand();
             printf(" %d  ",vbuf[i]);
             if(!(i & 0x3))
                 printf("\n");
       }
//...
       printf("创建二项堆.......\n");
       ha->root=NULL;
       ha->count=0;
       for(i=0;i<size1;++i)
           insert_b[i]=insert_beap(ha,vbuf[i]);
       printf("\n创建完毕.....\n");
       printf("\n开始执行删除最小元素....\n");
       for(i=0;i<len;++i)
      {
            p=remove_min(ha);
            printf(" %d:  %d \n",i,p->key);
            free(p);
       }
       printf("\n*********************执行减值操作*********************************\n");
       for(i=len,len=128;i<len;++i)
      {
              vbuf[i]=rand()%997;
              decrease_key(insert_b[i],vbuf[i]);
       }
       printf("\n*********************再次执行删除操作******************************\n");
       for(i=len>>1;i<len;++i)
      {
              p=remove_min(ha);
              printf("%d : %d \n",i,p->key);
              free(p);
       }
       printf("\n*********************2次删除操作**************************************\n");
       for(i=len;i<size1;++i)
      {
              p=remove_min(ha);
              printf(" %d  :  %d  \n",i,p->key);
              free(p);
       }
       printf("\n*********************删除操作完毕*************************************\n");
       return 0;
  }