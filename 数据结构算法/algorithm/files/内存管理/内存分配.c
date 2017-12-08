//2012/12/19/11:44
//内存分配算法实现
  #include<stdio.h>
//  #include<stdlib.h>
  #define   MAX_SIZE   8192
  typedef  unsigned  short  Word;
  typedef  unsigned  int    Dword;
/**************************************/
//注意，我们分配内存是以8字节为单位的,这个程序只使用了比较简单的内存分配策略
//在后面，我们将会使用更加复杂而高效的内存分配策略
  typedef  struct  _M_Alloc
 {
//记录这段内存的前一段内存的容量
        Word    plink;
//记录这一段内存的容量(size*8),同时最低3位也包含了其它表示:第0位表示使用情况(1表示已经申请,0表示已经释放)
        Word    size;
//记录下一段内存的容量
        Word    nlink;
//下一段内存的标示符,当nlink为0时，ntag域不使用
        Word    tag;
  }M_Header;
//记录整个内存分配情况的内存头信息
  typedef  struct  _M_Header
 {
//记录可供分配的内存的首地址，这个值一旦被初始化，将不会被改变
        char       *top;
//记录整个可供分配的内存的尺寸
        int        size;
//记录已经申请的内存片段数
        int        seg;
//记录最后一个被申请的内存地址.也可以用作边界条件来检测对指针指针是否越界
        char       *last;
  }M_Header;
//合并连续的碎片化了的内存
  static  void  union_m(M_Alloc *,int);
//所有的内存空间加在一起刚好两个页(8192字节)
  static  M_Header   mfirst,*first=NULL;
  static  char      vbuf[MAX_SIZE];
//自定义内存分配 函数
  static  void  init_memory()
 {
        M_Alloc  *mal;
//first的值一旦被初始化，将不会被改变
        first=&mfirst;
        first->top=vbuf;
        first->last=(int *)(top+MAX_SIZE);
        first->seg=0;
        first->size=MAX_SIZE;
//为第一段内存进行初始化
        mal=(M_Alloc *)first->top;
        mal->plink=(Word)0;
// 记录这一块空间的大小，和标记(有效，但没有被使用)
        mal->size=(Word)(MAX_SIZE>>3);
        mal->tag=(Word)(0x0);
        mal->nlink=(Word)0;
  }
  void   *mapply(int  size)
 {
       M_Alloc  *p,*q,*r,*t;
       int      j,k;
       k=size+8;
//首先8字节对齐
       ++first->seg;
       if(k & 0x7)
           k=k( & 0xFFFFFFF8)+8;
       p=first->top;
       for(  ;!p->nlink ;  )
      {
            j=p->size<<3;
            if(!(p->tag & 0x8000) &&(j>=k))//如果p所代表内存空间没有被申请，且空间足够
                 break;
            p=(M_Alloc  *)((char *)p+j);
       }
//如果申请失败
       j=p->size<<3;
//这种判定方法与我们所设定的内尺寸空间分配方式有关
       if((p->tag & 0x8000) || j<k)//如果最后一个内存块已经被分配,或者尺寸不足
      {
             printf("内存空间不足,申请失败!\n");
             return NULl;
       }
//如果申请到的内存是以前被释放掉的内存
       if(p->nlink)
      {
//如果这个内存块与请求的内存的尺寸的差值不大于16，那么就只做上已被申请的标记即可
            if(j-k<16)
                  p->tag|=0x8000;
            else
           {
//如果下一个内存块已经被使用
                 if(p->tag & 0x0080)
                {
 //计算和p紧挨着的内存块
                       q=(M_Alloc *)((char *)p+k);
                       r=(M_Alloc *)((char *)p+j);

                       p->size=k>>3;               //标上尺寸
                       p->tag=(Word)0x8000;        //做上标记
                       q->plink=k;
                       q->size=(j-k)>>3;
                       q->tag=(Word)(0x80);
                       
                       q->nlink=r->size<<3;
                       r->plink=(Word)(j-k);
                       return p;
                 }
                 else//否则执行合并操作
                      union_m(p,k);
             }
        }
        else
       {
            p->size=k;
            p->tag=(Word)0x8000;
            p->nlink=(Word)(j-k);

            q=(M_Alloc *)((char *)p+k);
            q->plink=(Word)k;
            q->size=(Word)((j-k)>>3);
            q->tag=(Word)0x0;
            q->nlink=(Word)0;
        }
     return p;
  }
//这个函数的调用条件是p的下一个内存块是已经被释放的，否则调用将会出错
  static  void  union_m(M_Alloc  *p,int k)
 {
       int       sum=0,j,n;
       M_Alloc   *q,*r,*t=NULL;

       j=p->size<<3;
       q=(M_Alloc *)((char *)p+k);
       r=(M_Alloc *)((char *)p+j);
       
       sum+=(j-k);
       t=r;
       for(  ;!r<first->last && ( r->tag & 0x8000) ; )//判断条件，如果这个内存块是空闲的,且没有到达末尾
      {
               t=r;
               n=r->size<<3;
               sum+=n;
               r=(M_Alloc *)((char *)r+n);
       }
       p->size=(Word)(k>>3);
       p->tag=(Word)0x8000;
       p->nlink=(Word)sum;

       q->size=(Word)(sum>>3);
       q->plink=(Word)k;
       
       if(r>=first->last)
           r=t;
       if(r->nlink)//如果没有到达末尾
      {

             r->plink=(Word)sum;
             q->tag=(Word)0x0080;
             q->nlink=(Word)(r->size<<3);

       }
       else
      {
             q->tag=(Word)0x0000;
             q->nlink=(Word)0;
       }
  }
//释放内存操作
  int  free(void  *t)
 {
       M_Alloc  *q,*r,*p;
       int      j,k;

       p=(M_Alloc *)((char *)t-8);
       if(!(p->tag & 0x8000))
      {
          printf("这个内存段已经被释放过了!\n");
          return 0;
       }
//标示这段内存已经被释放
       p->tag&=0xFF;
       j=p->size<<3;
       q=(M_Alloc *)((char *)p+j);
       if(q<first->last)
      {
            
     