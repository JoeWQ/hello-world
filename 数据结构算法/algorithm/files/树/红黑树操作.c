//2012/12/3/15:50
//这是一个不成功的程序
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/******************************************************/
//定义颜色的掩码值，在我们的数据结构定义中，我们使用一个整形的值来定义颜色值(红与黑)
  #define  C_R    0x1  //用1代表红色，0代表黑色
  #define  C_B    0x0

  typedef  struct  _Treerb
 {
//定义颜色数据域，这种定义，将决定我们将采用自顶向下的插入操作
//data
        int         data;
//左结点的颜色
        short       lc;
//右结点的颜色
        short       rc;
//指针域
        struct  _Treerb    *lchild;
        struct  _Treerb    *rchild;
  }Treerb;
//被封装的信息结构
  typedef  struct  _TreerbInfo
 {
//定义红黑树的根结点
        struct  _Treerb  *root;
//记录红结点的层数
        int              rlayer;
//记录黑结点的层数
        int              blayer;
//记录红黑树的结点数目
        int              nodes;
  }TreerbInfo;
  //********************************************************
    static  void  rotate_ll(Treerb *,Treerb *,Treerb *);
	static  void  rotate_lr(Treerb *,Treerb *,Treerb *);
	static  void  rotate_rl(Treerb *,Treerb *,Treerb *);
	static  void  rotate_rr(Treerb *,Treerb *,Treerb *);
/*********************************************************/
//删除操作
/**********************************************************/
	static  find_next(Treerb *,Treerb **);
	int     removerb(TreerbInfo *,int);
/*******************************************************/
//查找操作
  Treerb  *searchrb(TreerbInfo  *info,int data)
 {
        Treerb   *node=info->root;
        
        while( node )
       {
               if(data==node->data)
                    break;
               else if(data<node->data)
                    node=node->lchild;
               else
                    node=node->rchild;
        }
        return node;
  }
/************************************************************************/
  static  int  modify_colors(Treerb *p,Treerb *r)
 {
          int   flag=0;
//如果r为根结点
          if(! p) 
              flag=1;
//p为2结点,这里会有一种不确定性，但是由这个函数的删除操作理论，可以
//排除这种不确定性
          else if( !p->lc &&  !p->rc)
         {
                flag=1;
                if(p->lchild==r)
                      p->lc=C_R;
                else
                      p->rc=C_R;
          }
//如果有3结点的黑色指针指向它
          else if(r==p->lchild && p->rc)
         {
                flag=1;
                p->lc=C_R;
          }
          else if(r==p->rchild && p->lc)
         {
                flag=1;
                p->rc=C_R;
          }
          return flag;
  }
//红黑树的插入操作(自顶向下的插入),这个操作要涉及很多的额外函数调用
  int  insertrb(TreerbInfo  *info,int data)
 {
       Treerb   *gp,*p,*r,*q;
       int      flag=0,modify=0;

       if(! info->root)
      {
             p=(Treerb *)malloc(sizeof(Treerb));
             p->data=data;
             p->lchild=NULL; 
             p->rchild=NULL;
//子结点一律染成黑色
             p->lc=C_B;
             p->rc=C_B;
             info->root=p;
             return 1;
       }
//p为r的父结点，gp为r的祖父结点
       gp=NULL,p=NULL,q=NULL;;
       r=info->root;
       
       while( r )
      {
             if(r->lchild && r->rchild && r->lc && r->rc)//如果是一个4结点，则依据情况进行拆分操作
            {
//如果被拆分的结点是根结点，或者是一个2结点的儿子结点，或者被一个3结点指向，则只需要修改颜色即可
                   r->lc=C_B;
                   r->rc=C_B;
                   modify=modify_colors(p,r);
////如果产生冲突，则进行旋转操作
                   if(!modify && p && gp)
                  {
                        if(gp->lchild==p)
                       {
                              if(p->lchild==r) 
                                   rotate_ll(gp,p,r);
                              else
                             {
                                   rotate_lr(gp,p,r);
                                   p=r;
                              }
                        }
                        else
                       {
                              if(p->lchild==r)
                             {
                                   rotate_rl(gp,p,r);
                                   p=r;
                              }
                              else
                                   rotate_rr(gp,p,r);
                        }
                        if(gp==info->root)
                              info->root=p;
                        else
                       {
                             if(q->lchild==gp)
                                   q->lchild=p;
                             else
                                   q->rchild=p;
                        }
                        gp=p;
                        p=r;
                   }
                   else
                  {
                       q=gp;
                       gp=p; 
                       p=r;
                   }
              }
              else
             {
                   q=gp;
                   gp=p;
                   p=r;
              }
              if(data==r->data)
             {
                   flag=1;
                   break;
              }
              else  if(data<r->data)
                   r=r->lchild;
              else
                   r=r->rchild;
       }
       if(! flag)
      {
              r=(Treerb *)malloc(sizeof(Treerb));
              r->data=data;
              r->lchild=NULL;
              r->rchild=NULL;
              r->lc=C_B;
              r->rc=C_B;
              if(data<p->data)
             {
                    p->lchild=r;
                    p->lc=C_R;
              }
              else
             {
                    p->rchild=r;
                    p->rc=C_R;
              }
              ++info->nodes;
        }
       return !flag;
  }
//旋转操作
  static  void  rotate_ll(Treerb *gp,Treerb *p,Treerb *r)//LL旋转
 {
        gp->lchild=p->rchild;
        p->rchild=gp;

        p->lc=C_R;
        p->rc=C_R;
        gp->lc=C_B;
  }
//LR旋转
  static  void  rotate_lr(Treerb  *gp,Treerb *p,Treerb *r)
 {
        p->rchild=r->lchild;
        gp->lchild=r->rchild;
        r->lchild=p;
        r->rchild=gp;

        r->lc=C_R;
        r->rc=C_R;
        gp->lc=C_B;
        p->rc=C_B;
  }
//RL右左旋转
  static  void  rotate_rl(Treerb *gp,Treerb  *p,Treerb *r)
 {
       gp->rchild=r->lchild;
       p->lchild=r->rchild;
       r->rchild=p;
       r->lchild=gp;
 
       r->lc=C_R;
       r->rc=C_R;
       p->lc=C_B;
       gp->rc=C_B;
  }
//RR旋转
  static  void  rotate_rr(Treerb *gp,Treerb *p,Treerb *r)
 {
       gp->rchild=p->lchild;
       p->lchild=gp;

       gp->rc=C_B;
       p->lc=C_R;
       p->rc=C_R;
  }
//删除操作
  int  removerb(TreerbInfo  *info,int data)
 {
       Treerb  *r,*p,*q,*brt,*t;
       Treerb  *vbuf[32];
       int     len=0,flag=0;

       if(! info->root)
      {
             printf("删除操作错误，红黑树已经为空!\n"); 
             return 0;
       }
//这个函数的调用，需要借助于r的父结点才能完成,因此，必须采用某一种手段记录下r的父结点的内容
       r=info->root;
       p=NULL;
       q=NULL;
       brt=NULL;
       while( r )
      {
              p=r;
              if(data==r->data)
             {
                   flag=1;
                   break;
              }
              else if(data<r->data)
                   r=r->lchild;
              else
                   r=r->rchild;
       }
//如果没有找到这个数据域，则直接返回
       if(! flag)
            return 0;
           printf("  ***  ");
//如果r已经是叶结点，则直接执行删除操作
           printf("  ###  %x",r);
       if(!r->lchild && !r->rchild)
      {
           if(r==info->root)
                 info->root=NULL;
           else
          {
                if(p->lchild==r)
               {
                     p->lchild=NULL;
                     p->lc=C_B;
               }
                else
               {
                     p->rc=C_B;
                     p->rchild=NULL;
                }
           }
           free(r);
           return 1;
        }
        len=find_next(r,vbuf);
        printf("  @@@  ");
//进入常规的处理过程
        if(len>=3)
       {
              printf("   330  ");
              q=vbuf[--len];
              p=vbuf[--len];
              t=vbuf[--len];
              r->data=q->data;
              if( p->lc)//如果为红色指针，则q必定为叶结点,可以直接删除
             {
                   p->lc=C_B;
                   p->lchild=NULL;
              }
              else
             {
                   if( q->rchild)//当q为黑色结点，且其有一个红色右子树
                         p->lchild=q->rchild;
                   else if( p->rchild && p->rc)//如果q只是一个2结点,且其兄弟节点是一个红色结点
                  {
                         brt=p->rchild;
                         p->rchild=brt->lchild;
                         p->lchild=NULL;
                         brt->lchild=p;

                         p->lc=C_B;
                         p->rc=C_B;
                         brt->lc=C_R;
                         if(t->lchild==p)
                             t->lchild=brt;
                         else
                             t->rchild=brt;
                   }
              }
              free(q);
              printf("  331  ");
         }
         else if(len==2)//此时其右分支没有左子树
        {
              printf("  220  ");
              p=vbuf[--len];
              r->rchild=p->rchild;
              r->data=p->data;
              free(p);
              printf("  221  ");
         }
         else//不会有len等于1的可能
        {
              printf("  000  ");
              if(! p)
             {
                 info->root=r->lchild;
              }
              else
             {
                  if(p->rchild==r)
                      p->rchild=r->lchild;
                  else
                      p->lchild=r->lchild;
              }
              free(r);
              printf("  001  ");
         }
     return 1;
  }
//查找后继替换结点,返回值vbuf数组的有效长度
  static int  find_next(Treerb  *r,Treerb **vbuf)
 {
        int  len=0;
    
        if(! r->rchild)
             return 0;
        vbuf[len++]=r;
        r=r->rchild;
        while(r)
       {
             vbuf[len++]=r;
             r=r->lchild;
        }
        return len;
  }
/**********************************************************************/
  int  main(int argc,char *argv[])
 {
        int   vbuf[256];//={50,10,75,92,5,85,90,7,40,9,30,80,60,70};
        int   len=16;
        int   seed,i;
        TreerbInfo   info;
        info.root=NULL;
        info.nodes=0;
        
        seed=time(NULL);
        srand(0x7C8F);
//        srand(seed);
        for(i=0;i<len;++i)
       {
             vbuf[i]=rand(); 
             printf("  %d  ",vbuf[i]);
             if(!(vbuf[i] & 0x7))
                  printf("\n");
        }

        printf("开始创建红黑树:\n");
        for(i=0;i<len;++i)
       {
              if(insertrb(&info,vbuf[i]))
                   printf("%d插入成功!\n",vbuf[i]);
              else
                   printf("%d插入失败!\n",vbuf[i]);
        }
        printf("开始执行查找操作:\n");
        for(i=0;i<len;++i)
       {
             if(searchrb(&info,vbuf[i]))
                  printf("%d查找成功!\n",vbuf[i]);
             else
                  printf("%d查找失败!\n",vbuf[i]);
       }
       printf("\n*******************************************************\n");
       printf("下面开始执行删除操作\n");
       for(i=0;i<len;++i)
      {
             if(removerb(&info,vbuf[i]))
                  printf("  %d  删除成功!\n",vbuf[i]);
             else
                  printf("  %d  删除失败!\n",vbuf[i]);
       }
        return 0;
  }
