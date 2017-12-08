//2012/12/6/9:10
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//定义颜色，红色为1，黑色为0
  #define   C_R     1
  #define   C_B     0
/**************************************************/
  typedef  struct  _Tree_r
 {
       int  data;
       int  color;
       struct  _Tree_r   *parent;
       struct  _Tree_r  *lchild;
       struct  _Tree_r   *rchild;
  }Tree_r;
//被封装的红黑树信息结构
  typedef  struct  _Tree_rInfo
 {     
       struct  _Tree_r  *root;
       int              len;
  }Tree_rInfo;
//查找
  Tree_r   *search_r(Tree_rInfo  *,int );
//插入操作
  int    insert_r(Tree_rInfo  *,int );
//插入后的调整操作
  static  void   adjust_r(Tree_rInfo  *,Tree_r *);
//向左旋转
  static  void   rotate_r_l(Tree_rInfo *,Tree_r *);
//向右旋转
  static  void   rotate_r_r(Tree_rInfo *,Tree_r *);
//*******************************和删除操作相关的函数调用
  static  Tree_r  *find_next(Tree_r *);
  int      remove_r(Tree_rInfo *,int data);
  static   void  fixup_r(Tree_rInfo *,Tree_r  *,Tree_r *);
//******************************************************

  Tree_r  *search_r(Tree_rInfo  *info,int data)
 {
        Tree_r   *node=info->root;
/*
        while( node )
       {
             if(data==node->data)
                  break;
             else if(data<node->data)
                  node=node->lchild;
             else
                  node=node->rchild;
        }
*/
//使用内联汇编进行红黑树的查找,运行时间time(NULL)：8,比纯 C代码(11)要稍微快一些
        __asm
       {
               mov  eax,data;
               mov  esi,node
               test  esi,esi
               jz  over
            L0:
                    mov  edx,[esi]
                    cmp  eax,edx
                    jz   over
                    jg  L1
                    mov esi,[esi+12]
                    jmp L2
            L1:
                    mov esi,[esi+16]
            L2:     
                    test  esi,esi
                    jnz  L0
            over:
                mov eax,esi
        }
//        return node;
  }
//插入操作
  int   insert_r(Tree_rInfo  *info,int data)
 {
       Tree_r   *node=info->root,*r=NULL;
       int      flag=0;
       if(! node)
      {
             node=(Tree_r *)malloc(sizeof(Tree_r));
             node->lchild=NULL; 
             node->rchild=NULL;
             node->parent=NULL;
             node->data=data;
             node->color=C_B;
             info->root=node;
             info->len=1;
             return 1;
       }
        while( node )
       {
             r=node;
             if(data==node->data)
            {
                   flag=1;
                   break;
             }
             else if(data<node->data)
                   node=node->lchild;
             else
                   node=node->rchild;
        }
        if( flag )
             return 0;
//创建新的结点,并插入树中
        node=(Tree_r *)malloc(sizeof(Tree_r));
        node->data=data;
        node->color=C_R;
        node->parent=r;
        node->lchild=NULL;
        node->rchild=NULL;
        if(data<r->data)
             r->lchild=node;
        else
             r->rchild=node;
//开始进入调整阶段
        adjust_r(info,node);
        ++info->len;
        return 1;
  }
//调整红黑树的结构
  static  void  adjust_r(Tree_rInfo *info,Tree_r *r)
 {
       Tree_r   *p=r->parent;
//gp为r的祖父结点，y为p的兄弟节点
       Tree_r   *gp=NULL,*y=NULL;
//循环条件，当出现两个连续的红色指针,注意，这里面从红黑树的定义出发
//已经假定某些条件已经得到满足,而且，它已经得到满足
       while(p && p->color)
      {
             gp=p->parent;
             if(p==gp->lchild)
            {
                   y=gp->rchild;
//如果y的颜色为红黑，则只需改变指针的颜色，而无需改变指针的值
                   if(y && y->color)
                  {
                        gp->color=C_R;
                        p->color=C_B;
                        y->color=C_B;
                        r=gp;
                        p=r->parent;
                   }
//在y->color为红色的条件不满足时，依据r为p的左或者是右子树，而进行左或右旋转操作
                   else  if(r==p->rchild)
                  {
//此时先执行向左旋转，使r成为其父结点的左子树，然后再执行向右旋转
                        gp->color=C_R;
                        r->color=C_B;
                        rotate_r_l(info,p);
                        rotate_r_r(info,gp);
                        break;
                   }
                   else
                  {
                        gp->color=C_R;
                        p->color=C_B;
                        rotate_r_r(info,gp);
                        break;
                  }
             }
             else//下面的程序设计思路和上面的是对称的
            {
                   y=gp->lchild;
                   if(y && y->color)
                  {
                        gp->color=C_R;
                        y->color=C_B;
                        p->color=C_B;
                        r=gp;
                        p=r->parent;
                  }
                  else if(r==p->rchild)
                 {
                        p->color=C_B;
                        gp->color=C_R;
                        rotate_r_l(info,gp);
                        break;
                  }
                  else
                 {
                       r->color=C_B;
                       gp->color=C_R;
                       rotate_r_r(info,p);
                       rotate_r_l(info,gp);
                       break;
                  }
            }
      }
      info->root->color=C_B;
  }
//旋转操作,左旋转
  static  void  rotate_r_l(Tree_rInfo  *info,Tree_r  *p)
 {
       Tree_r  *r=p->rchild,*gp=p->parent;
      
       p->rchild=r->lchild;
       if(r->lchild)
            r->lchild->parent=p;
       r->lchild=p; 
       p->parent=r;
       r->parent=NULL;
       if(p==info->root)
             info->root=r;
       else
      {
             if(gp->lchild==p)
                 gp->lchild=r;
             else
                 gp->rchild=r;
             r->parent=gp;
       }
  }
//右旋转
  static  void  rotate_r_r(Tree_rInfo  *info,Tree_r *p)
 {
       Tree_r  *r=p->lchild,*gp=p->parent;
  
       p->lchild=r->rchild; 
       if(r->rchild)
             r->rchild->parent=p;
       r->rchild=p;
       p->parent=r;
       r->parent=NULL;
       if(p==info->root)
              info->root=r;
       else
      {
              if(gp->lchild==p)
                    gp->lchild=r;
              else
                    gp->rchild=r;
              r->parent=gp;
       }
  }
//查找给定结点的后继结点
  static  Tree_r  *find_next(Tree_r  *r)
 {
       Tree_r  *p;
       
       if(r->rchild)
      {
            p=r->rchild;
            while( p )
           {
                 r=p;
                 p=p->lchild;
            } 
            return  r;
       }
       p=r->parent;
       while( p && r==p->rchild)
      {
            r=p;
            p=p->parent;
       }
       return p;
  }
//删除操作,成功则返回1，否则返回0
  int  remove_r(Tree_rInfo  *info,int  data)
 {
        Tree_r   *r,*p,*y,*x,*gp;
        int      color;
//先进行查找操作
        r=search_r(info,data);
        if(!  r)
//       {
//              printf("删除错误，您给定的数据 %d 不存在!\n",data); 
              return 0;
//        }
//注意，下面的删除判断逻辑可能会比较难以理解
        y=NULL,x=NULL;
        --info->len;
        if(!r->lchild || !r->rchild)
             y=r;
        else
             y=find_next(r);
//寻找y的子结点
        if(y->lchild)
             x=y->lchild;
        else
             x=y->rchild;
//开始修改指针
        p=y->parent;
        if( x )
            x->parent=p;
//判断r是否为根结点
        if(! p)
            info->root=x;
        else
       {
             if(y==p->lchild)
                  p->lchild=x;
             else
                  p->rchild=x;
        }
//移动指针以及数据,,p记录的是y的父结点的颜色，这一点，要到红黑树的调整时才会显示出它的用处
//之所以这样设计，乃是因为这个程序原本就是为了大规模数据处理而设计的，所以，我们采用的是移动指针，而非移动数据
        if(y!=r)
       {
//注意下面这一句非常重要，它的作用就相当于当多线程程序中的数据同步
             if(y->parent==r)
                   p=y;
             color=y->color;
             y->color=r->color;
             y->lchild=r->lchild;
             y->rchild=r->rchild;
             if(r->lchild)
                  r->lchild->parent=y;
             if(r->rchild)
                  r->rchild->parent=y;
             gp=r->parent;
             r->color=color;
             y->parent=NULL;
//********************************************
            if(! gp )
                 info->root=y;
            else
           {
                 if(gp->lchild==r)
                     gp->lchild=y;
                 else
                     gp->rchild=y;
                 y->parent=gp;
            }
//判断指针的颜色，以决定是否要对红黑树进行调整
           y=r;
        }
        if(!y->color)//如果刚刚被删除的是黑子树,则需要调整
              fixup_r(info,p,x);
        free(r);
        return 1;
  }
//调整删除结点后的红黑树,p是x的父结点
  void  fixup_r(Tree_rInfo  *info,Tree_r *p,Tree_r *x)
 {
        Tree_r  *y=NULL;
//循环的条件
        while((x && !x->color) || !x)
       {
              if(x==info->root)
                   break;
              if(x==p->lchild)
             {
                     y=p->rchild;
/**
                     if(! y)//严格地来说，这种情况不会出现
                    {           
                          printf("  --$$$--  ");
                          x=p;
                          break;
                     }
*/
//如果x的兄弟结点是一个红结点，对这种情况的处理是比较简单的,但是它在某一些情况中会变得复杂
                     if(y->color)
                    {
//                          printf("  @@@  ");
                          y->color=C_B;
                          p->color=C_R;
//可以推断出，y至少有一个黑儿子结点,但是关于它的操作不是仅仅改变颜色，和旋转那么简单，但可以将这种情况转化为下面的情况
                          rotate_r_l(info,p);
                     }
//如果y有两个黑色子树(也包括空子树)
                     else if((!y->lchild || !y->lchild->color) && (!y->rchild || !y->rchild->color))
                    {
                          y->color=C_R;
                          x=p;
                          p=p->parent;
                     }
                     else if(y->lchild && y->lchild->color)//如果其左子树为红色，而右子树为黑色
                    {
                          y->lchild->color=p->color;
                          p->color=C_B;
                          rotate_r_r(info,y);
                          rotate_r_l(info,p);
                          break;
                     }
                     else
                    {
                          y->color=p->color;
                          p->color=C_B;
                          y->rchild->color=C_B;
                          rotate_r_l(info,p);
                          break;
                    }
              }
              else
             {
                    y=p->lchild;
//这种情况，在红黑树的理论中，严格地来说，是不会出现的，这里，只是为了防止某些非法的操作
/*
                    if(! y)
                   {
                         printf("  ++$$$+++  ");
                         x=p;
                         break;
                    }
*/
                    if(y->color)
                   {
//                         printf("  ###   ");
                         p->color=C_R;
                         y->color=C_B;
                         rotate_r_r(info,p);
                    }
                    else if( (!y->lchild || !y->lchild->color) &&  (!y->rchild || !y->rchild->color))
                   {
                         y->color=C_R;
                         x=p;
                         p=p->parent;
                    }
                    else if(y->lchild && y->lchild->color)//如果y的左子树为红色，那么只需执行一次旋转操作
                   {
                         y->color=p->color;
                         p->color=C_B;
                         y->lchild->color=C_B;
                         rotate_r_r(info,p);
                         break;
                   }
                   else
                  {
                         y->rchild->color=p->color;
                         p->color=C_B;
                         rotate_r_l(info,y);
                         rotate_r_r(info,p);
                         break;
                   }
              }
       }
//下面的这一句不可缺少
       if( x )
          x->color=C_B;
  }
//***************全面检测红黑树的各种条件是否得到满足*******************
  static  void  test_r(Tree_rInfo  *info,int data)
 {
        Tree_r  *r=info->root,*p=NULL;
//记录在路径中经过的红黑结点数目
        int    num_r=0,num_b=0;
        
        while( r )
       {
              p=r;
              if(r->color)
                    ++num_r;
              else
                    ++num_b;

              if(data==r->data)
                  r=NULL;
              else if(data<r->data)
                  r=r->lchild;
              else
                  r=r->rchild;

        }
//如果是叶子结点
        if(!p->lchild  &&  !p->rchild)
               printf("----------叶子:红结点:%d,黑结点:%d ,--------总长度:%d\n",num_r,num_b,(num_r+num_b));
//        else
//               printf("非叶子:红结点:%d,黑结点:%d ,总长度:%d\n",num_r,num_b,(num_r+num_b));
  }
//测试与数组相比，生成的红黑树的性能，这里之久查找操作作比较，其它的因为缺少可比性，所以不做比较
  int   search_array(int *vbuf,int data)
 {
        int i=0;
/*
        for(i=0;i<256;++i)
       {
             if(data==vbuf[i])
                 return 1;
        }
*/
//为了能更近一步测试数组查找的性能，我们将使用内联汇编代码来代替纯C代码，以此来比较红黑树的性能
//在我们的测试中，汇编代码的运行时间（time(NULL)函数）是9，而红黑树的运行时间依然为11，由此，可以看出，汇编的效率
//要远远C代码，当然，这个也是需要技巧的，否则，面对现代编译器的优化，一般的人未必能够胜任编译器的决策分析
       __asm
      {
                mov  ecx,256
                mov  edi,vbuf
                mov  eax,data
                cld
                rep  scasd
                jnz  label
                   xor  eax,eax
                   inc  eax
                   mov i,eax
             label:
       }
        return i;
 }
  void   test_time(Tree_rInfo  *info,int *vbuf,int len)
 {
        int  times=0;
        int  i,j;
//测试数组查找
        times=time(NULL);
        for(j=0;j<500000;++j)
            for(i=0;i<len;++i)
                 search_array(vbuf,vbuf[i]);
        printf("数组查找所费的时间为%u\n",(int)time(NULL)-times);

        times=(int)time(NULL);
        for(j=0;j<500000;++j)
            for(i=0;i<len;++i)
                 search_r(info,vbuf[i]);
        printf("红黑树查找所花费的时间为:%u\n",(int)time(NULL)-times);
//我们在Intel Core 2机器上得出的数据是：使用time(NULL)函数，数组查找所用时间54，红黑树查找为11，由此，大致上可以
//看出，红黑树的查找性能要远远优于数组，无论用随机数据，还是用已经排好序的数据，这个结果都成立
  }
//*********************************************************
  int main(int argc,char *argv[])
 {
       int  vbuf[256];
       int  seed,i,len;
       Tree_rInfo  info;
   
       info.len=0;
       info.root=NULL;
       len=256;
       seed=time(NULL);
 
       srand(0x7C8F);
       for(i=0;i<len;++i)
      {
            vbuf[i]=i;//rand();
            printf(" %d  ",vbuf[i]);
            if(!(i & 0x7))
                printf("\n");
       }
       printf("\n************************创建红黑树!***********************\n");
       for(i=0;i<len;++i)
      {
             if(insert_r(&info,vbuf[i]))
                  printf("  %d  插入成功!\n",vbuf[i]);
             else
                  printf("  %d  插入失败!\n",vbuf[i]);
       }
       printf("\n************************开始进行查找操作!*******************\n");
/*
       for(i=0;i<len;++i)
      {
            if(search_r(&info,vbuf[i]))
                  printf("  %d  查找成功!\n",vbuf[i]);
            else
                  printf("  %d  查找失败!\n",vbuf[i]);
       }
*/
/*8
       seed=len>>1;
       printf("\n********************删除操作****************************\n");
       for(i=0;i<seed;++i)
      {
             if(remove_r(&info,vbuf[i]))
                   printf(" %d删除操作成功!\n",vbuf[i]);
             else
                   printf(" %d删除失败!\n",vbuf[i]);
       }
*/
       printf("*********************测试红黑树***************************\n");


       printf("\n*************************测试开始*************************\n");
/*
       for(i=seed;i<len;++i)
      {
            test_r(&info,vbuf[i]);
       }
       printf("根结点的颜色:%d  \n",info.root->color);
*/
       test_time(&info,vbuf,len);
       return 0;
  }