//2013/1/10/14:36
//最小 斐波那契堆的相关操作，和二项堆相比，斐波那契堆的操作无疑使复杂的，因为它的结构比较松散
//另外它的所有操作建立在平摊分析上，而不是摸一个操作的时间开销的数量级上
  #include<stdio.h>
  #include<stdlib.h>
/*********************************************/
  typedef  struct  _FibBeap
 {
        int         key;
//记录这个结点在成为其它结点的子结点以来，是否失去了孩子结点
        int         mark;
//记录结点的度
        int         degree;
//指向父结点的指针
        struct     _FibBeap   *parent;
//指向孩子结点的指针
        struct     _FibBeap   *child;
//left,right维护了一个双向循环链表
        struct     _FibBeap   *left;
        struct     _FibBeap   *right;
  }FibBeap;
//定义斐波那契堆的头结构
  typedef  struct  _FibBeapHeader
 {
//记录斐波那契堆的根结点，亦即最小根结点，这里是与二项堆的区别
        struct  _FibBeap     *minrt;
        int                  count;
  }FibBeapHeader;

/************************************************/
//合并两个具有相同度的结点,使b成为a的一个子结点
  static  void  union_2_fib_beap(FibBeap *a,FibBeap *b);
//分裂最小根结点,但是分裂之后仍然合并到一个堆中
  static  void  split_fib_beap(FibBeapHeader  *);
//处理孩子结点
  static  void  process_child(FibBeap  *,FibBeapHeader *);
//剪枝操作
  static  void  cut_fib_beap(FibBeapHeader *,FibBeap *);
//测试结点的融合情况
  static  void  print_node(FibBeapHeader *);
//计算给定的正数的对数(向下取整)
  static  int    lg2(int  lg)
 {
       int  i=0;
       while( lg>>=1 )
            ++i;
       return i;
  }
//合并两个斐波那契堆,这里假设两个给定的斐波那契堆均不为空
  void  union_fib_beap(FibBeapHeader  *hfa,FibBeapHeader  *hfb)
 {
        FibBeap  *a,*b,*ar,*bt;
//注意合并两个链表时，一定要分清楚要解开那个链，要修改那个链，否则很容易出错
        a=hfa->minrt;
        b=hfb->minrt;

        ar=a->left;
        bt=b->left;

        ar->right=b;
        b->left=ar;

        a->left=bt;
        bt->right=a;

        hfa->count+=hfb->count;
        hfb->count=0;
        hfb->minrt=NULL;
//修改最小根结点
        if(a->key>b->key)
             hfa->minrt=b;
  }
//向一个斐波那契堆中插入一个结点
  FibBeap  *insert_fib_beap(FibBeapHeader  *hf,int  key)
 {
        FibBeap   *f=(FibBeap  *)malloc(sizeof(FibBeap));
        FibBeap   *a,*r;
        f->key=key;
        f->mark=0;
        f->degree=0;
        f->parent=NULL;
        f->child=NULL;
//修改指针
        a=hf->minrt;
        if(!  a )
       {
               hf->minrt=f;
               f->left=f;
               f->right=f;
        }
        else
       {
               r=a->right;
               a->right=f;
               f->left=a;
         
               f->right=r;
               r->left=f;
//修改最小根结点
              if(key<a->key)
                   hf->minrt=f;
        }
        ++hf->count;
        return f;
  }
//删除最小结点/这个操作比较复杂，因为它承担了所有其它操作应该完成但是没有完成的工作
//统计具有相同度的根结点,vbuf针指针组的容量要大，否则会出现越界行为
  static  void  record_fib_beap(FibBeapHeader  *hf,FibBeap  **vbuf)
 {
        int      i=0;
        FibBeap   *a,*y,*t;
//注意，我们之所以选择这种方法，是因为它关联到了下面的函数中，最小根结点的选择问题
        a=hf->minrt;
        t=a->right;
        a->right=NULL;
        y=t;
        while( y )
       {
              i=y->degree;
              y->left=NULL;
              t=y->right;
//注意，下面的一步，我们使用节点中的right域连接 各个根结点
              y->right=vbuf[i];
              vbuf[i]=y;
              y=t;
       }
  }
//将具有相同度的根结点链接起来，并形成一个单独的根链
  static  void  consolate_fib_beap(FibBeapHeader  *hf,FibBeap  **vbuf,int len)
 {
       FibBeap  *y,*t,*r;
       FibBeap  *rt=hf->minrt;  //记录最小根结点
       int   i;

       t=NULL,r=NULL;
       for(i=0;i<=len;++i)
      {
//合并操作
            y=vbuf[i];
            vbuf[i]=NULL;
            while( y )
           {
                  t=y->right;
                  if(! t )
                 {
                     vbuf[i]=y;
                     break;
                  }
                  r=t->right;
//注意下面的一步操作
                  y->right=NULL;
                  t->right=NULL;
//可以考虑一下，如果有两个根结点的值同是最小的，这里是否会出现需要修改hf->minrt的值 的情形
                  if(y->key<=t->key)
                 {
                      union_2_fib_beap(y,t);
//注意，这里并不会产生数组的越界行为，因为斐波那契堆的性质已经保证了这种情况不会发生
                      y->right=vbuf[i+1];
                      vbuf[i+1]=y;
//记录根结点,这一步必须加上去，应为它涉及到重复的最小根结点的选择
                      if(y->key==rt->key)
                            rt=y;
                  }
                  else
                 {
                      union_2_fib_beap(t,y);
                      t->right=vbuf[i+1];
                      vbuf[i+1]=t;
                  }
                  y=r;
            }
       }
       hf->minrt=rt;
  }
  FibBeap   *remove_fib_beap_min(FibBeapHeader  *hf)
 {
       FibBeap   *a,*y,*r,*tmp;
//下面的数据域是为了合并操作的需要而出现
       FibBeap   **vbuf;
       int       i,len;
       a=hf->minrt;
       if(!  a )
      {
             printf("删除错误，斐波那契堆中已经为空!\n");
             return NULL;
       }
//tmp记录着最小根结点,它作为返回值，应该被额外保存
       tmp=a;
       --hf->count;
//如果是只剩最后一个结点，则无需进行合并操作，可以直接返回
       if(! hf->count)
          return tmp;
//将最小根结点的所有孩子结点分裂出来，并在此合并到根链中
       split_fib_beap(hf);
//注意下面的代码，我们采取了用空间换时间的策略
       len=lg2(hf->count)+1;

       vbuf=(FibBeap **)malloc(sizeof(FibBeap *)*(len+1));
//初始清零操作
       for(i=0;i<=len;++i)
           vbuf[i]=NULL;
//建立统计信息
       record_fib_beap(hf,vbuf);
//第三步，合并具有相同度的根结点
       consolate_fib_beap(hf,vbuf,len);
//第四步，将已经分散的根结点合并成一个双向循环链表
//r记录着循环链表的最前端的结点
//y记录着当前结点的前驱
       r=NULL;  
       y=NULL;  
//a记录着当前的结点
       for(i=0;i<=len;++i)
      {
              a=vbuf[i];
              if(  a  )
             {
                   if(! r )
                        r=a;
                   else
                  {
                        y->right=a;
                        a->left=y;
                   }
                   y=a;
              }
        }
        r->left=y;
        y->right=r;
        free(vbuf);
        return tmp;
   }
//合并两个结点,将b合并到a中
  static  void  union_2_fib_beap(FibBeap  *a,FibBeap *b)
 {
        FibBeap  *y=a->child;
        FibBeap  *x;
        ++a->degree;
//清除标记
        b->mark=0;
//将b合并到a的孩子结点中
        b->parent=a;
        if(! y)
       {
              a->child=b;
              b->right=b;
              b->left=b;
        }
        else
       {
              x=y->left;
              b->right=y;
              y->left=b;
              b->left=x;
              x->right=b;
        }
  }
//分裂最小根结点,这个函数被调用的前提假设是:最小根结点已经被保存了
  static  void  split_fib_beap(FibBeapHeader  *fa)
 {
        FibBeap        *a,*r,*t;
        FibBeapHeader  hfc,*fb=&hfc;
//先分裂
        a=fa->minrt;
        r=a->right;
//如果只剩一个根结点
        if(a==r)
             process_child(r->child,fa);
        else
       {
             fb->minrt=NULL;
             fb->count=0;
//去掉结点 a
             t=a->left;
             t->right=r;
             r->left=t;
             process_child(t,fa);
             process_child(a->child,fb);
//如果满足条件，就执行合并链表操作 
             if(fa->minrt && fb->minrt)
                  union_fib_beap(fa,fb);
        }
//为了数据的隐私起见，将曾经的最小根结点的儿子节点设为NULL
       a->child=NULL;
  }
  static  void  process_child(FibBeap  *child,FibBeapHeader  *ha)
 {
       FibBeap  *r,*t,*p;
       
       if(! child)
             ha->minrt=NULL;
       else
      {
             t=child->right;
             child->right=NULL;
//查找最小根结点，且将孩子节点的相应数据域做修改
             p=t;
             r=t;
             while( r )
            {
                  r->parent=NULL;
                  r->mark=0;
                  if(p->key>r->key)
                      p=r;
                  r=r->right;
             }
             ha->minrt=p;
             child->right=t;
       }
   }
//减值操作,这里面的减值 和二项堆中的减值操作相仿，但是又有很多地方不一致
//其中的最重要的一点，就是引入了标记 修改
  int  decrease_key(FibBeapHeader  *hf,FibBeap  *x,int key)
 {
        FibBeap    *p,*y;
        if(x->key<=key)
       {
              printf("给定的值 %d 不能大于结点的关键字值%d\n",key,x->key);
              return 0;
        }
        x->key=key;
        p=x->parent;
//下面是满足条件后的级联剪枝操作
        y=x;
       if(p && x->key<p->key)
      {
              cut_fib_beap(hf,x);
//注意下面的逻辑
              x=p;
              p=p->parent;
              while( p )
             {
                    if(! x->mark)
                   {
                          x->mark=1;
                          break;
                    }
                    else
                   {
                          cut_fib_beap(hf,x);
                          x=p;
                          p=p->parent;
                    }
              }
        }
      if(y->key<hf->minrt->key)
            hf->minrt=y;
       return 1;
  }
//剪枝操作
  static  void  cut_fib_beap(FibBeapHeader  *hf,FibBeap *x)
 {
        FibBeap  *p,*r,*t;
        FibBeap  *child;

//第一步，解除x与它的父结点的关系
        p=x->parent;
        --p->degree;
        x->mark=0;
        x->parent=NULL;
        child=p->child;
//如果只有一个孩子结点，必定是x
        if(child->right==child)
               p->child=NULL;
        else
       {
               r=x->right;
               t=x->left;
               r->left=t;
               t->right=r;
//注意，下面的一步不可少
               if(child==x)
                     p->child=r;
        }
//第二步解开根的循环链,然后再合并
        r=hf->minrt;
        t=r->right;

        r->right=x;
        x->left=r;
 
        x->right=t;
        t->left=x;
  }
//删除任意一个结点,删除操作的形式很类似于二项堆，但是又有所区别
  int  remove_fib_beap(FibBeapHeader *hf,FibBeap  *x)
 {
        FibBeap  *r;
      
        if(r=hf->minrt)
       {
             decrease_key(hf,x,r->key-1);
             r=remove_fib_beap_min(hf);
             free(r);
             return 1;
        }
        return 0;
  }
//打印根链的数据
  void  print_node(FibBeapHeader  *hf)
 {
        FibBeap  *r,*t,*p;
        int  i=0;
        r=hf->minrt;
        if(!  r)
           return;
        t=r->right;
        r->right=NULL;

        printf("____________________开始______________________\n");
        p=t;
        while(  p )
       {
                 printf("%d------->%d  \n",i++,p->key);
                 p=p->right;
        }
        printf("++++++++++++++++++++结束++++++++++++++++++++++++\n");
        r->right=t;
  }
//测试数据
  int  main(int  argc,char *argv[])
 {
       int  vbuf[256];
       int  size=128,i=0,len=64,j=32;
       
       FibBeap  *buf[245];
       FibBeap  *p;
       FibBeapHeader  hdc,*hf=&hdc;
       
       srand(0x7c8B);
       printf("初始化数组.....\n");
       for(i=0;i<size;++i)
      {
             vbuf[i]=rand();
             printf("  %d  ",vbuf[i]);
             if(!(i & 0x3))
                 printf("\n");
       }
/**********************插入操作******************************/
       printf("现在开始执行插入操作............\n");
       hf->minrt=NULL;
       hf->count=0;
       for(i=0;i<size;++i)
             buf[i]=insert_fib_beap(hf,vbuf[i]);
       printf("********插入操作结束***********\n");

       printf("**************现在以删除最小元素的方式删除堆中的所有所有元素*******\n");
/*
       for(i=0;i<len;++i)
      {
            p=remove_fib_beap_min(hf);
            printf("  %d--->  %d   \n",i,p->key);
            free(p);
       }
*/
       printf("\n**************************现在开始进行减值操作*****************************\n");
       for(i=len,len<<=1;i<len ;++i)
            decrease_key(hf,buf[i],j++);
       printf("**********************现在测试减值操作的结果*********************\n");
       for(i=0,len>>=1;i<size;++i)
      {
            p=remove_fib_beap_min(hf);
            printf(" %d ----->%d  \n",i,p->key);
       }
       return 0;
  }