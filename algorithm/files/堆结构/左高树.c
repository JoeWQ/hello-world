//2012/11/8/19:05
//关于左高树的相关操作
//*左高树多用来进行两个最小或者最大堆的快速合并操作，以及支持单独的优先级队列
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/************************************************/
//定义左高树的相关数据结构,这里操作的树最小左高树
  typedef  struct  _LTree
 {
//数据域
       int  key;
//记录以该结点为根结点的树的倾斜度
       int  shortest;
//链域
       struct  _LTree  *lchild;
       struct  _LTree  *rchild;
  }LTree;
//定义存储左高树的根结点的相关数据结构
  typedef  struct  _LTreeInfo
 {
       struct  _LTree  *root;
       int     length;
  }LTreeInfo;
//左高树的相关操作
  void  insertNode(LTreeInfo *,int );
//删除最小值结点
  int   removeRoot(LTreeInfo *,int *);
//将两个给定的左高树进行合并
  void  union2LTree(LTreeInfo  *,LTreeInfo *);
//创建一个左高树
  void  CreateLTree(int *,int,LTreeInfo *);
/*************************************************************/
  void  CreateLTree(int *input,int len,LTreeInfo *info)
 {
        int        i;
        for(i=0;i<len;++i)
            insertNode(info,*input++);
  }
//删除根结点
  int  removeRoot(LTreeInfo *info,int *min)
 {
       LTree  *tmp=NULL;
       LTreeInfo  binfo;

       if(info->root)
      {
            tmp=info->root;
            printf("%x\n",tmp);
            *min=tmp->key;
            --info->length;
            if(! tmp->lchild)
                info->root=NULL;
            else if(tmp->rchild)
           {
                printf("***\n");
                info->root=tmp->lchild;
                binfo.root=tmp->rchild;
                binfo.length=0;
//                printf("^^a->key:%x,b->key:%x^^\n",tmp->lchild,tmp->rchild);
                union2LTree(info,&binfo);
            }
            else  
                info->root=tmp->lchild;
            free(tmp);
//注意下面的一步，当释放了内存之后，tmp->lchild,/rchild中的值将会被改变，仔细检查程序
//尤其是，被释放的内存不要在引用他
//            printf("###%x,###%x \n",tmp->lchild,tmp->rchild);
            return 1;
       }
      return 0;
  }
//合并两棵最小左高树，将结果写到ainfo的相应指针域中，并且合并后仍然为一棵左高树。
  void  union2LTree(LTreeInfo *ainfo,LTreeInfo *binfo)
 {
      LTree  *a,*b,*tmp;
//      LTree  *p,*q;
//数的深度一般不会超过32,
      LTree  *queue[32];
      int    len=0;
//a始终代表最小子树的根结点，b为较大子树的根结点     
      a=ainfo->root;
      b=binfo->root;
//如果a>b，就交换两个结点
//      printf("^^a->key:%x,b->key:%x^^\n",a,b);
      if(a->key>b->key)
     {
          tmp=a;
          a=b;
          b=tmp;
      }
//一下开始进行信息的统计
     while( a )
    {
          if(a->key>b->key)
         {
              tmp=a;
              a=b;
              b=tmp;
          }
          queue[len++]=a;
          a=a->rchild;
     }
//循环之后，b将代表的是最终的以a的最右端的子树的根结点
//从数组的末端弹出保存的指针

     while(--len>=0)
    {
          a=queue[len];
          if(! a->lchild)
               a->lchild=b;
          else if(a->lchild->shortest<b->shortest)
         {
               a->rchild=a->lchild;
               a->lchild=b;
          }
          else
         {
               a->rchild=b;
               a->shortest=b->shortest+1;
          }
          b=a;
     }
     ainfo->root=a;
     ainfo->length+=binfo->length;
     binfo->root=NULL;
     binfo->length=0;
  }
//向树中插入一个元素
  void  insertNode(LTreeInfo *info,int key)
 {
      LTreeInfo  tmp;
      LTree      *a;

	  a=(LTree *)malloc(sizeof(LTree));
      a->lchild=NULL;
      a->rchild=NULL;
      a->key=key;
      a->shortest=0;

      ++info->length;
      if(! info->root)
          info->root=a;
      else
     {
          tmp.length=0;
          tmp.root=a;
          union2LTree(info,&tmp);
      }
  }
//测试程序代码
  int  main(int argc,char *argv[])
 {
      LTreeInfo  ainfo,binfo;
      int        akey[6]={2,7,13,80,50,11}; 
      int        bkey[8]={20,18,5,9,8,12,10,15};
      int        len1=6,len2=8;
      int        i=0,j=0;
       
//      j=time(NULL);
//      srand(0x137FD);
      printf("akey数组中的值:\n");
      for(i=0;i<len1;++i)
            printf("  %d  ",akey[i]);
      printf("\n");
      printf("数组bkey中的值:\n");
      for(i=0;i<len2;++i)
            printf("  %d  ",bkey[i]);
      printf("\n");

      ainfo.root=NULL;
      binfo.root=NULL;
      ainfo.length=0;
      binfo.length=0;

      printf("开始为akey创建左高树。。。\n");
      CreateLTree(akey,len1,&ainfo);

      printf("开始为bkey创建左高树...\n");
      CreateLTree(bkey,len2,&binfo);

      printf("开始将两个左高树合并...\n");
      union2LTree(&ainfo,&binfo);
      printf("开始逐个地将元素删除...\n");
      i=1;
      while(ainfo.root)
     {
          removeRoot(&ainfo,&j);
          printf("第%d个元素是 %d \n",i++,j);
      }
      return 0;
  }

          