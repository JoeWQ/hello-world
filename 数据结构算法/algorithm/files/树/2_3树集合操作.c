//2012/11/28/9:14
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
  #define  M_INT    0x80000000
/**************************************************/
//定义23树结构
  typedef  struct  _Tree23
 {
//左数据域
      int  ldata;
//右数据域
      int  rdata;
//三种指针域
      struct  _Tree23   *lchild;
      struct  _Tree23   *mchild;
      struct  _Tree23   *rchild;
  }Tree23;

  typedef  struct  _Tree23Info
 {
//记录23树的根节点
      struct  _Tree23   *root;
//记录整棵23树的结点数目
      int               len;
  }Tree23Info;
//**********************************************************
  #include"23visit.c"
//**************************************************
//若成功则返回指向该结点的指针,否则返回NULL
  Tree23  *search23(Tree23Info *,int );
//*****************************************************
//与插入操作相关的函数调用
//如果给定的数据已经存在则返回0，否则返回数组的实际长度
//参数的含义树的根结点，存放结点的缓冲区,目标数据,指向存放数组实际长度的指针,如果成功，返回1，否则返回0

  static  int  find_23_node(Tree23Info *,Tree23 **,int);
//拆分结点操作
  static  void  split_23_node(Tree23 *,Tree23 **,int *);
  int     insert23(Tree23Info *,int data);
/*****************************************************************/
//23树的删除操作
  int  remove23(Tree23Info  *,int );
//删除操作所要用到的几个额外操作
//;旋转操作
  static  void  rotate23(Tree23 *,Tree23 *,Tree23 *);
//合并操作
  static  void  union23(Tree23 *,Tree23 *,Tree23 *);
//存放操作
  static  void  put_int(Tree23 *,Tree23 *,int);
  
//*******************************************************************
  Tree23  *search23(Tree23Info  *info,int data)
 {
       Tree23  *node;
       
       node=info->root;
       while(node)
      {
            if(node->ldata==data || data==node->rdata)
                 break;
            else if(data<node->ldata)
                 node=node->lchild;
            else if(node->rdata==M_INT || data<node->rdata)
                 node=node->mchild;
            else
                 node=node->rchild;
       }
       return node;
  }
//插入结点操作
  int  insert23(Tree23Info  *info,int data)
 {
       Tree23  *p,*q,*tmp,*child=NULL;
       Tree23  *vbuf[32];
       int   len=0,i=0;
//如果树为空
       if( !info->root)
      {
            tmp=(Tree23 *)malloc(sizeof(Tree23));
            tmp->ldata=data;
            tmp->rdata=M_INT;
            tmp->lchild=NULL;
            tmp->mchild=NULL;
            tmp->rchild=NULL;
            info->root=tmp;
            info->len=1;
            return 1;
       }
       len=find_23_node(info,vbuf,data); 

//如果函数返回0，则表示目标结点已经存在，插入失败
       if( ! len)
      {
            printf("给定的结点%d已经存在，此次插入操作失败!\n",data);
            return 0;
       }
       q=NULL;
       ++info->len;
       while(--len>=0)
      {
            p=vbuf[len];
//如果是2结点，则直接插入
            if(p->rdata==M_INT)
           {
//结点的存储规则是，ldata<rdata,所以这一步的判断是必须的
                 if(p->ldata>data)
                { 
                      p->rdata=p->ldata;
                      p->rchild=p->mchild;
                      p->mchild=q;
                      p->ldata=data; 
                 }
                 else
                {
                      p->rdata=data;
                      p->rchild=q;
                 }
                 return 1;
            }
//如果是3结点，则先进行拆分操作
            else
           {
                 split_23_node(p,&q,&data);
//如果已经到达了根结点,则进行组装，并直接退出循环
                 if(p==info->root)
                {
                      tmp=(Tree23 *)malloc(sizeof(Tree23));
                      tmp->ldata=data;
                      tmp->rdata=M_INT;
                      tmp->lchild=p;
                      tmp->mchild=q;
                      tmp->rchild=NULL;
                      info->root=tmp;
                      return 1;
                 }
            }
       }
       return 1;
  }
//*************************************************************************
  static int  find_23_node(Tree23Info *info,Tree23 **vbuf,int data)
 {
       int  len=0;
       Tree23 *node=info->root;
       
       while(node)
      {
             vbuf[len++]=node;
             if(data==node->ldata || data==node->rdata)
            {
                  len=0;
                  break;
             }
             else if(data<node->ldata)
                  node=node->lchild;
             else if(node->rdata==M_INT || data<node->rdata)
                  node=node->mchild;
             else
                  node=node->rchild;
       }
       return len;
  }
//*****************************************************************************
  static  void  split_23_node(Tree23 *p,Tree23 **q,int *data)
 {
       Tree23  *tmp,*child=NULL,*a=NULL;
       int     mid=0,max=0;
//考虑到二级指针的低效，我们直接使用一级指针
//将最小值写入结点p中，且选出中间值
       if(p->ldata>*data)
      {
           mid=p->ldata;
           p->ldata=*data;
           max=p->rdata;
       }
       else
      {
           if(p->rdata<*data)
          {
               mid=p->rdata;
               max=*data;
           }
           else
          {
               mid=*data;
               max=p->rdata;
           }
       }
       p->rdata=M_INT;
       tmp=(Tree23 *)malloc(sizeof(Tree23));
       tmp->ldata=max;
       tmp->rdata=M_INT;
       tmp->mchild=NULL;
       tmp->rchild=NULL;
       tmp->lchild=NULL;
       *data=mid;

//       printf("大%d,中%d,小%d",max,mid,p->ldata);
       if(! *q)
            *q=tmp;
       else
      {
//注意，下一步操作非常重要，如果缺少了它，在info->len的数值非常大的时候，就会出现非常难以察觉的错唔
           if(p->mchild->ldata>(*q)->ldata)//如果满足了这个条件，则交换数据
          {
                 a=p->mchild;
                 p->mchild=*q;
                 *q=a;
           }
           child=p->rchild;
           p->rchild=NULL;
           if(max<(*q)->ldata)
          {
                tmp->lchild=child;
                tmp->mchild=*q;
//                printf(" 1:左%d:中%d:右%d",child->ldata,max,(*q)->ldata);
           }
           else
          {
                tmp->lchild=*q;
                tmp->mchild=child;
//                printf(" 2:左%d:中%d:右:%d",(*q)->ldata,max,child->ldata);
           }
           *q=tmp;
       }
  }
//返回0，则表示查找失败，否则查找成功，并将在路径上遇到的所有结点写入vbuf中
//index中返回的是被查找的目标在vbuf中所在的下下标索引
  static  int  modified_search23(Tree23Info *info,int data,Tree23 **vbuf,int *index)
 {
       Tree23  *node;
       int     len=0;
       int     flag=0;

       node=info->root;
       while(node)
      {
             vbuf[len++]=node;
//在没有查找到目标数据时采用一种策略，在查找到后再采用另一种策略
             if(data==node->ldata || data==node->rdata)
            {
                  *index=len-1;//注意这一步操作
                  flag=1;
                  if(data==node->ldata)//选取左子树中的最大值
                       node=node->lchild;
                  else
                       node=node->mchild;//选取中子树的最大值
                  while( node )
                 {
                       vbuf[len++]=node;
                       if(node->rdata==M_INT)
                             node=node->mchild;
                       else
                             node=node->rchild;
                  }
                  goto label;
              }
              else if(data<node->ldata)
                  node=node->lchild;
              else if(node->rdata==M_INT || data<node->rdata)
                  node=node->mchild;
              else
                  node=node->rchild;
       }
//如果查找没有成功，直接返回0，否则返回数组的实际长度
     label:
       return flag? len:0;
  }
//将结点p中的数据移动到r中
  static  void  put_in(Tree23 *r,Tree23 *p,int data)
 {
       if(r==p)//如果目标结点已经是叶结点
      {
             if(r->rdata==data)
                  r->rdata=M_INT;
             else
            {
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
             }
       }
       else
      {
             if(r->ldata==data)
            {
                  if(p->rdata!=M_INT)//判断结点p的数据域情况
                 {
                        r->ldata=p->rdata;
                        p->rdata=M_INT;
                  }
                  else
                 {
                        r->ldata=p->ldata;
                        p->ldata=M_INT;
                 }
            }
            else
           {
                  if(p->rdata!=M_INT)
                 {
                       r->rdata=p->rdata;
                       p->rdata=M_INT;
                  }
                  else
                 {
                      r->rdata=p->ldata;
                      p->ldata=M_INT;
                 }
           }
      }
  }
//删除操作
  int  remove23(Tree23Info  *info,int data)
 {
       Tree23   *p,*q,*r;
       Tree23   *vbuf[32];
       int      len,index=0;

       if(! info->root)
      {
             printf("删除错误，2_3树已经为空!\n");
             return 0;
       }
       len=modified_search23(info,data,vbuf,&index);
//查找失败返回0
       if(! len)
      {
             printf("很遗憾，您给定的数据%d不存在!\n",data);
             return 0;
       }
//寻找一个叶结点，并以它的一个数据域替换掉结点p中的目标数据域
       r=vbuf[index];
       p=vbuf[--len];
//删除结点r中的数据域
       put_in(r,p,data);
//进入循环处理
       q=NULL;
       while(p->ldata==M_INT && p->rdata==M_INT && p!=info->root)
      {
              if(! len)//如果已经到达根节点，则直接退出
                   break;
              r=vbuf[--len];//p的父结点
              if(p==r->lchild)
                   q=r->mchild;
              else if(p==r->mchild)
                   q=r->lchild;
              else
                   q=r->mchild;
//如果结点q是一个三结点，则进行旋转操作，否则进行合并操作
              if(q->rdata!=M_INT)
                   rotate23(r,p,q); 
              else
                   union23(r,p,q);
              p=r;
       }
//如果p满足这个条件，则p一定是根节点
       if(p->rdata==M_INT && p->ldata==M_INT)
      {
             info->root=p->lchild;
             free(p);
       }
    return 1;
  }
//旋转操作,r为p,q的父节点，而p,q为兄弟节点
  static  void  rotate23(Tree23  *r,Tree23 *p,Tree23 *q)
 {
//如果p为r的左子树,那么q一定为r的中子树
       if(p==r->lchild)
      {
             p->ldata=r->ldata;
             r->ldata=q->ldata;
             q->ldata=q->rdata;
             q->rdata=M_INT;

             p->mchild=q->lchild;
             q->lchild=q->mchild;
             q->mchild=q->rchild;
             q->rchild=NULL;
       }
//如果p为r的中子树，那么q为r的左子树
       else if(p==r->mchild)
      {
             p->ldata=r->ldata;
             r->ldata=q->rdata;
             q->rdata=M_INT;
      
             p->mchild=p->lchild;
             p->lchild=q->rchild;
             q->rchild=NULL;
       }
       else if(p==r->rchild)
      {
             p->ldata=r->rdata;
             r->rdata=q->rdata;
             q->rdata=M_INT;
             
             p->mchild=p->lchild;
             p->lchild=q->rchild;
             q->rchild=NULL;
       }
  }
//合并操作，这个操作的复杂性药比较高，因为它要区分的情况比较多
  static  void  union23(Tree23 *r,Tree23 *p,Tree23 *q)
 {
       if(p==r->lchild)
      {
             if(r->rdata==M_INT)
            {
                  p->ldata=r->ldata;
                  p->rdata=q->ldata;
                  r->ldata=M_INT;
                  r->mchild=NULL;
                  p->mchild=q->lchild;
                  p->rchild=q->mchild;
             }
             else
            {
                  p->ldata=r->ldata;
                  p->rdata=q->ldata;
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
                  p->mchild=q->lchild;
                  p->rchild=q->mchild;
                  r->mchild=r->rchild;
                  r->rchild=NULL;
             }
             free(q);
       }
       else if(p==r->mchild)
      {
             if(r->rdata==M_INT)
            {
                  q->rdata=r->ldata;
                  q->rchild=p->lchild;
                  r->ldata=M_INT;
                  r->mchild=NULL;
             }
             else
            {
                  q->rdata=r->ldata;
                  q->rchild=p->lchild;
                  r->ldata=r->rdata;
                  r->rdata=M_INT;
                  r->mchild=r->rchild;
                  r->rchild=NULL;
             }
             free(p);
       }
       else if(p==r->rchild)
      {
             q->rdata=r->rdata;
             r->rdata=M_INT;
             r->rchild=NULL;
             q->rchild=p->lchild;
             free(p);
       }
  }
/***********************************************************/
  int  main(int argc,char *argv[])
 {
      int  vbuf[64];//={40,20,10,80,70,30,60};
      int  len,seed,j=0,i;
      Tree23Info  info;

      seed=(int)time(NULL);
      srand(seed);
      info.len=0;
      info.root=NULL;
 
      len=64;
      seed=0;
      printf("数组的内容为:\n");
      for(i=0;i<len;++i)
     {
          vbuf[i]=rand(); 
          printf(" %d  ",vbuf[i]);
          if(insert23(&info,vbuf[i]))
               printf("\n%d插入成功!\n",vbuf[i]);
          if(! (i & 0xF))
              printf("\n");
          //遍历整棵2,3树
//          dvisit23(&info);
//          printf("\n***********************************************************\n");
      }
/*******************************************************************/
      printf("*******************************开始执行查找操作:********************************\n");
      for(i=0;i<len;++i)
     {
           if(search23(&info,vbuf[i]))
                printf("\n%d查找成功!\n",vbuf[i]);
           else
                printf("\n%d查找失败!\n",vbuf[i]);
      }
//遍历整棵2,3树
//      dvisit23(&info);
      printf("下面开始执行删除操作:\n");
      for(i=len-1;i>=0;--i)
     {
            if(remove23(&info,vbuf[i]))
                 printf("删除结点%d成功!\n",vbuf[i]);
            else
                 printf("删除结点%d失败!\n",vbuf[i]);
      }
      return 0;
  }