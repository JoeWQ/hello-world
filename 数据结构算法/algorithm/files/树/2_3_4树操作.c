//2012/12/1/9:31
//2,3,4树的操作
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  M_INT    0x80000000
/*************************************************************/
//234树的操作和23树的操作很类似，但是相对而言，它比23树的操作要简单一些
  typedef  struct  _Tree234
 {
//结点中的数据域
      int  ldata;
      int  mdata;
      int  rdata;
//指针域
      struct  _Tree234   *lchild;  //左子树
      struct  _Tree234   *lmchild;//左中子树
      struct  _Tree234   *mrchild;//中右子树
      struct  _Tree234   *rchild;//右子树
  }Tree234;
  typedef  struct  _Tree234Info
 {
//指向234树的根结点的指针
      struct  _Tree234   *root;
//记录234树的结点的数目
      int                nlen;
//记录234树的数据域的数目
      int                dlen;
  }Tree234Info;
/***********************************************************/
   #include"234visit.c"
/************************************************************/
//234树的查找操作
  Tree234  *search234(Tree234Info *,int);
/********************************************************/
//和插入操作相关的函数调用
  int  insert234(Tree234Info *,int );
//当结点r(p的父节点)是一个2结点时进行的分裂操作
  static  void  split2(Tree234 *r,Tree234 *p);
//当结点r是一个3结点时进行的范烈操作
  static  void  split3(Tree234 *,Tree234 *);
//当结点p是根结点时进行的分裂操作，此时需要更新info->root的内容
  static  void  split4(Tree234Info *info);
//将数据添加到结点中
  static  void  put_in(Tree234 *,int);
/**************************************************************************/
//和删除相关的函数调用
  static  void   union_root(Tree234 *);
  static  void   union2(Tree234 *,Tree234 *,Tree234 *);
  static  void   union3(Tree234 *,Tree234 *,Tree234 *);
  static  void   union4(Tree234 *,Tree234 *,Tree234 *);
//掌管总的调度策略
  static  void   union234(Tree234 *,Tree234 *,Tree234 *);
//替换策略函数
  static  void   replace234(Tree234Info *,Tree234 *,int);
  int     remove234(Tree234Info *,int);
/***********************************************************************/
//查找成功，则返回1，否则返回0
  Tree234  *search234(Tree234Info  *info,int data)
 {
        Tree234  *node=info->root;
        
        while( node )
       {
             if(node->ldata==data || node->mdata==data || node->rdata==data)
                     break;
             else if(data<node->ldata)
                    node=node->lchild;
             else if(node->mdata==M_INT  || data<node->mdata)
                    node=node->lmchild;
             else if(node->rdata==M_INT  || data<node->rdata)
                    node=node->mrchild;
             else
                    node=node->rchild;
        }
        return  node;
  }
//分裂2结点
  static  void  split2(Tree234 *r,Tree234 *p)
 {
//如果p是r的左子树
        Tree234 *tmp=(Tree234 *)malloc(sizeof(Tree234));
        tmp->rchild=NULL;
        tmp->mrchild=NULL;
        tmp->rdata=M_INT;
        tmp->mdata=M_INT;

        if(p==r->lchild)
       {
              printf("  *21*  ");
              r->mdata=r->ldata;
              r->ldata=p->mdata;
              tmp->ldata=p->rdata;
              p->mdata=M_INT;
              p->rdata=M_INT;

              r->mrchild=r->lmchild;
              r->lmchild=tmp;
              tmp->lchild=p->mrchild;
              tmp->lmchild=p->rchild;
              p->mrchild=NULL;
              p->rchild=NULL;
        }
        else// if(p==r->lmchild)
       {
              printf(" *22* ");
              r->mdata=p->mdata;
              p->mdata=M_INT;
              tmp->ldata=p->rdata;
              p->rdata=M_INT;
         
              tmp->lchild=p->mrchild;
              tmp->lmchild=p->rchild;
              r->mrchild=tmp;
              p->rchild=NULL;
              p->mrchild=NULL;
        }
        printf(" $222$  ");
  }
//分裂3结点
  static  void  split3(Tree234 *r,Tree234 *p)
 {
//如果p是r的左子树
        Tree234 *tmp=(Tree234 *)malloc(sizeof(Tree234));
        tmp->rchild=NULL;
        tmp->mrchild=NULL;
        tmp->rdata=M_INT;
        tmp->mdata=M_INT;
        
        if(p==r->lchild)
       {
             printf("  #31#  ");
             r->rdata=r->mdata;
             r->mdata=r->ldata;
             r->ldata=p->mdata;
             tmp->ldata=p->rdata;
             p->mdata=M_INT;
             p->rdata=M_INT;
             
             r->rchild=r->mrchild;
             r->mrchild=r->lmchild;
             r->lmchild=tmp;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
             p->mrchild=NULL;
             p->rchild=NULL;
        }
        else if(p==r->lmchild)//如果是左中子树
       {
             printf("  #32#  ");
             r->rdata=r->mdata;
             r->mdata=p->mdata;
             p->mdata=M_INT;
             tmp->ldata=p->rdata;
             p->rdata=M_INT;
             
             r->rchild=r->mrchild;
             r->mrchild=tmp;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
             p->mrchild=NULL;
             p->rchild=NULL;
        }
        else //如果是中右子树
       {
             tmp->ldata=p->rdata;
             tmp->lchild=p->mrchild;
             tmp->lmchild=p->rchild;
 
             r->rdata=p->mdata;
             r->rchild=tmp;
             p->rdata=M_INT;
             p->mdata=M_INT;
             p->rchild=NULL;
             p->mrchild=NULL;
        }
        printf("  $333$  ");
//剩下的一种情况，在哦我们的定义的数据结构操作中不会出现，所以省略
  }
//分裂4结点，这种情况只能发生在根结点中
  static  void  split4(Tree234Info *info)
 {
       Tree234  *q=(Tree234 *)malloc(sizeof(Tree234));
       Tree234  *r=(Tree234 *)malloc(sizeof(Tree234));
       Tree234  *p=info->root;
//对新申请的数据域进行部分更新，剩下的部分为要用到的
       r->rdata=M_INT;
       r->mdata=M_INT;
       r->rchild=NULL;
       r->mrchild=NULL;

       q->rdata=M_INT;
       q->mdata=M_INT;
       q->rchild=NULL;
       q->mrchild=NULL;

       r->ldata=p->mdata;
       q->ldata=p->rdata;
       p->mdata=M_INT;
       p->rdata=M_INT;
//更新指针域
       r->lchild=p;
       r->lmchild=q;
       q->lchild=p->mrchild;
       q->lmchild=p->rchild;
       p->mrchild=NULL;
       p->rchild=NULL;
       info->root=r;
       printf(" #444#  ");
  }
       

//插入成功，则返回1，否则返回0
  int  insert234(Tree234Info  *info,int data)
 {
       Tree234  *p,*q,*r;
       int      flag=0;
//先从根节点判断
       if(! info->root)
      {
             p=(Tree234 *)malloc(sizeof(Tree234));
             p->ldata=data;
             p->mdata=M_INT;
             p->rdata=M_INT;
             p->lchild=NULL;
             p->lmchild=NULL;
             p->mrchild=NULL;
             p->rchild=NULL;
             info->root=p;
             info->nlen=1;
             info->dlen=1;
             return 1;
       }
//开始进入循环的前夕
       if(info->root->rdata!=M_INT) //如果根根结点是一个4结点，则直接分裂
      {
             split4(info);
             info->nlen+=2;
       }
//开始进入循环
       r=NULL;
       q=NULL;
       p=info->root;
       while( p )
      {
            if(p->rdata!=M_INT)//如果p是4结点,则进行分裂操作
           {
                 if(r->mdata!=M_INT)//如果是yige 3结点
                      split3(r,p);
                 else
                      split2(r,p);
                 ++info->nlen;
                 if(p!=r->lchild && p!=r->lmchild &&p!=r->mrchild)
                         printf("  @@@  ");
                 p=r;
            }
            r=p;
            q=p;
//沿234树的分支进行查找
            if(p->ldata==data || p->mdata==data || p->rdata==data)
           {
                  flag=1;
                  break;
            }
            else if(data<p->ldata)
                  p=p->lchild;
            else if(p->mdata==M_INT || data<p->mdata)
                  p=p->lmchild;
            else if(p->rdata==M_INT || data<p->rdata)
                  p=p->mrchild;
            else
                  p=p->rchild;
       }
//如果查找失败，则直接将数据域添加进结点q中
      if(! flag )
     {
           ++info->dlen;
           put_in(q,data);
      }
      return !flag;
  }
//添加数据到叶结点中
  static  void  put_in(Tree234 *q,int data)
 {
        if(data<q->ldata)
       {
             q->rdata=q->mdata;
             q->mdata=q->ldata;
             q->ldata=data;
        }
        else if(q->mdata==M_INT || data<q->mdata)
       {
             q->rdata=q->mdata;
             q->mdata=data;
       }
       else
             q->rdata=data;
  }
/*************************删除操作**********************************/
//合并2结点操作，这个操作具有普遍性,现在已经假设p为一个2结点
  static  void  union2(Tree234 *r,Tree234 *p,Tree234 *q)
 {
//这里已经假设q为一个2结点时,则直接按r为4节点的方式合并结点
         if(p==r->lchild)
        {
               p->mdata=r->ldata;
               p->rdata=q->ldata;
               r->ldata=r->mdata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
                     
               p->mrchild=q->lchild;
               p->rchild=q->lmchild;
               r->lmchild=r->mrchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(q);
          }
          else if(p==r->lmchild)//如果p为r的左中子树
         {
               q->mdata=r->ldata;
               q->rdata=p->ldata;
               r->ldata=r->mdata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
                     
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->lmchild=r->mrchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(p);
          }
          else if(p==r->mrchild)//如果p为r的中右子树
         {
               q->mdata=r->mdata;
               q->rdata=p->ldata;
               r->mdata=r->rdata;
               r->rdata=M_INT;
       
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->mrchild=r->rchild;
               r->rchild=NULL;
               free(p);
          }
          else if(p==r->rchild)
         {
               q->mdata=r->rdata;
               q->rdata=p->ldata;
               r->rdata=M_INT;
               q->mrchild=p->lchild;
               q->rchild=p->lmchild;
               r->rchild=NULL;
               free(p);
         }
  }
//合并3结点，所谓的3结点，是指q的结点数目
  static  void  union3(Tree234 *r,Tree234 *p,Tree234 *q)
 {
          if(p==r->lchild)
         {
               p->mdata=r->ldata;
               r->ldata=q->ldata;
               q->ldata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=q->lchild;
               q->lchild=q->lmchild;
               q->lmchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->lmchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->ldata;
               r->ldata=q->mdata;
               q->mdata=M_INT;
//修改指针域               
               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->mrchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->mdata;
               r->mdata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
          else if(p==r->rchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->rdata;
               r->rdata=q->mdata;
               q->mdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->mrchild;
               q->mrchild=NULL;
          }
  }
//合并4结点，4结点即q结点含有3个数据域
  static  void  union4(Tree234 *r,Tree234 *p,Tree234 *q)
 {
          if(p==r->lchild)
         {
//首先数据移动
               p->mdata=r->ldata;
               r->ldata=q->ldata;
               q->ldata=q->mdata;
               q->mdata=q->rdata;
               q->rdata=M_INT;

//指针域移动
               p->mrchild=q->lchild;
               q->lchild=q->lmchild;
               q->lmchild=q->mrchild;
               q->mrchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->lmchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->ldata;
               r->ldata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->mrchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->mdata;
               r->mdata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
          else if(p==r->rchild)
         {
               p->mdata=p->ldata;
               p->ldata=r->rdata;
               r->rdata=q->rdata;
               q->rdata=M_INT;

               p->mrchild=p->lmchild;
               p->lmchild=p->lchild;
               p->lchild=q->rchild;
               q->rchild=NULL;
          }
  }
//总调度函数
  static  void  union234(Tree234 *r,Tree234 *p,Tree234 *q)
 {
//根据q结点的情况调用不同的函数
          if(q->mdata==M_INT)
               union2(r,p,q);
          else if(q->rdata==M_INT)
               union3(r,p,q);
          else
               union4(r,p,q);
  }
//删除结点操作的接口函数
  int  remove234(Tree234Info *info,int data)
 {
        Tree234  *r,*p,*q;
        int      flag=0;

        if(! info->root)
       {
             printf("删除错误,树已经为空!\n");
             return 0;
        }
        p=NULL;
        q=NULL;
//先进行根节点处理
        if(info->root->mdata==M_INT)
              union_root(info->root);
        r=info->root;
//进入循环处理
        while( r )
       {
               if(data==r->ldata || data==r->mdata || data==r->rdata)
              {
                      p=NULL;
                      flag=1;
               }
               else if(data<r->ldata)
              {
                      p=r->lchild;
                      q=r->lmchild;
               }
               else if(r->mdata==M_INT || data<r->mdata)
              {
                      p=r->lmchild;
                      q=r->lchild;
               }
               else if(r->rdata==M_INT || data<r->rdata)
              {
                      p=r->mrchild;
                      q=r->lmchild;
               }
               else
              {       p=r->rchild;
                      q=r->mrchild;
               }
               if(! p)
                   break;
//如果已经查找到目标结点，则改变执行策略
               if( flag)
              {
                      replace234(info,r,data);
                      break;
               }
//根据p是否是一个2结点，依据不同的情况定义r的值
               if(p->mdata!=M_INT)
                      r=p;
               else//在这种情况下，不需要进行下层树结点递进
                      union234(r,p,q);
       }
       return flag;
  }
/********************************************************************/
//替换结点的函数调用
  static  void  replace234(Tree234Info  *info,Tree234 *r,int data)
 {
        Tree234  *p,*q,*tmp=r;
        int      *value=NULL;
//首先处理几种特殊的情况
        if(r==info->root &&  !r->lchild)//如果只有一个结点
       {
              if(data==r->ldata && r->mdata==M_INT)
             {
                   info->root=NULL;
                   free(r);
                   return ;
              }
        }
        if(! r->lchild)//如果r已经为叶结点
       {
              if(data==r->ldata)
             {
                    r->ldata=r->mdata;
                    r->mdata=r->rdata;
              }
              else if(data==r->mdata)
                    r->mdata=r->rdata;
              r->rdata=M_INT;
              return;
        }
//开始进入合并且&查找操作
        q=NULL;
        q=NULL;
        while( r)//循环条件，到达叶结点
       {
              if(r->rdata!=M_INT)
             {
                    p=r->rchild;
                    q=r->mrchild;
              }
              else if(r->mdata!=M_INT)
             {
                    p=r->mrchild;
                    q=r->lmchild;
              }
              else
             {
                    p=r->lmchild;
                    q=r->lchild;
              }
              if(! p)
                   break;
//合并结点操作
              if(p->mdata!=M_INT)
                    r=p;
              else
                    union234(r,p,q);
         }
         p=r;
         r=tmp;
//替换数据域
         if(data==r->ldata)
               value=&r->ldata;
         else if(data==r->mdata)
               value=&r->mdata;
         else
               value=&r->rdata;
         if(p->rdata!=M_INT)
        {
               *value=p->rdata;
               p->rdata=M_INT;
         }
         else if(p->mdata!=M_INT)
        {
               *value=p->mdata;
               p->mdata=M_INT;
         }
//没有下一种情况
  }
//合并根根结点,这个函数式专门为根节点设计的，它不改变r的 值，所以不用传递Tree234Info类型的指针
  static  void  union_root(Tree234 *r)
 {
         Tree234 *p,*q;
         
         if(! r->lchild || r->mdata!=M_INT)//如果只有一个结点或者根节点已经是3或4结点，则直接退出
              return;
         p=r->lchild;
         q=r->lmchild;

         if(p->mdata!=M_INT || q->mdata!=M_INT)
                return ;
//合并操作的实现
         r->mdata=r->ldata;
         r->rdata=q->ldata;
         r->ldata=p->ldata;
         r->lchild=p->lchild;
         r->lmchild=p->lmchild;
         r->mrchild=q->lchild;
         r->rchild=q->lmchild;

         free(p);
         free(q);
  }
         
/***********************************************************/
  int  main(int argc,char *argv[])
 {
       int  vbuf[128];
       int  len=128;
       int  i,seed;
       Tree234Info  info;

       seed=(int)time(NULL);
       srand(seed);
       info.nlen=0;
       info.dlen=0;
       info.root=NULL;
       
       printf("数组的内容如下:\n");
       for(i=0;i<len;++i)
      {
            vbuf[i]=rand();
            printf("  %d  ",vbuf[i]);
            if(!(i & 0x7))
                 printf("\n");
       }
       printf("现在开始执行插入操作:\n");
       for(i=0;i<len;++i)
      {
            if(insert234(&info,vbuf[i]))
                 printf("%d插入操作成功!\n",vbuf[i]);
            else
                 printf("%d插入操作失败!\n",vbuf[i]);
//            dvisit234(&info);
//            printf("********************************************\n");
       }

       printf("******************************************************\n");
/*
       printf("现在开始执行查找操作:\n");
       for(i=0;i<len;++i)
      {
            if(search234(&info,vbuf[i]))
                 printf("%d查找成功!\n",vbuf[i]);
            else
                 printf("%d查找失败!\n",vbuf[i]);
      }
*/
      printf("现在开始执行删除操作:\n");
      for(i=0;i<len;++i)
     {
            if(remove234(&info,vbuf[i]))
                 printf("%d删除成功!\n",vbuf[i]);
            else
                 printf("%d删除失败!\n",vbuf[i]);
      }
      return 0;
  }