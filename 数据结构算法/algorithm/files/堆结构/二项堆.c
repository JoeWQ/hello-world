//2012/11/16/19:55
//二项堆的相关操作:插入，删除、合并操作
//二项堆的最主要用途就是可以将一个操作的代价分摊给另一个操作，比如可以将删除操作
//的代价分摊给插入操作
/***************这里的所有操作都是关于最小二项堆的******************/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
/**********************************************/
  typedef  struct  _Beap
 {
//结点的数据域
       int  data;
//结点的度
       int  degree;
//结点的儿子结点
       struct  _Beap   *child;
//与结点相连的兄弟结点
       struct  _Beap   *left;
       struct  _Beap   *right;
  }Beap;
//为了方便堆而相对的操作而定义的记录二项堆的相关的信息结构
  typedef  struct  _BeapInfo
 {
//记录和根结点相连接的兄弟结点的数目
       int             len;
//记录指向二项堆的最小根结点的指针
       struct  _Beap   *root;
  }BeapInfo;
//为了执行合并操作而专门引入的数据结构
  typedef  struct  _Link
 {
       struct  _Beap  *root;
       struct  _Line  *next;
  };
  typedef  struct  _DegreeInfo
 {
       struct  _Link    *front;
       struct  _Link    *rear;
  }DegreeInfo;
/*********************************************************************/
  void  insert_item(BeapInfo  *,int );
//删除二项堆的根结点，若成功返回1，否则返回0
  int   remove_root(BeapInfo  *,int *);
//合并两个二项堆
  void  union2beap(BeapInfo *,BeapInfo *);
  static  void  UnionBeap(BeapInfo *);
/**********************************************************************/
  void  insert_item(BeapInfo  *info,int data)
 {
       Beap  *tmp;
       Beap  *rear;

       tmp=(Beap *)malloc(sizeof(Beap));
       tmp->data=data;
       tmp->child=NULL;
       tmp->left=NULL;
       tmp->right=NULL;
       tmp->degree=0;
//如果二项堆为空，则直接插入
       ++info->len;
       if(! info->root)
      {
            info->root=tmp;
            tmp->left=tmp;
            tmp->right=tmp;
       }
       else
      {
//比较根结点的关键字的值大小
            if(data<info->root->data)  //如果跟定的数据域小于已存在的二项堆的根结点的值
           {
                  data=info->root->data;
                  info->root->data=tmp->data;
                  tmp->data=data;
            }
//将已经建立好的结点插入到二项堆的最顶层的链中
            rear=info->root->left;
            tmp->right=info->root;
            tmp->left=rear;
            rear->right=tmp;
            info->root->left=tmp;
//剩下的工作是合并已经存在的链
           UnionBeap(info);
      }
  }
//合并两个二项堆
  void  union2beap(BeapInfo  *ainfo,BeapInfo *binfo)
 {
       Beap  *arear,*brear;

       arear=ainfo->root->left;
       brear=binfo->root->left;
       arear->right=brear;
       brear->left=arear;
       ainfo->root->left=binfo->root;
       binfo->root->right=ainfo->root;
//调整二项堆的最小根结点
       ainfo->len+=binfo->len;
       if(ainfo->root->data>binfo->root->data)
            ainfo->root=binfo->root;
       binfo->root=NULL;
       binfo->len=0;
  }
//删除根结点
  int  remove_root(BeapInfo  *info,int  *min)
 {
      Beap  *tmp,*p;
      Beap  *left,*right;
      Beap  *child,*rear;

      if(! info->root)
     {
           printf("删除操作异常！给定的二项堆已经为空\n");
           *min=0xFFFFFFFF;
           return 0;
      }
      *min=info->root->data;
//如果二项堆只有一个根结点
      --info->len;
      if(info->root==info->root->left)
     {
           child=info->root->child;
           free(info->root);
           if(! child)
          {
                info->root=NULL;
                return 1;
           }
           else
          {
//寻找最小结点
                p=child->right;
                tmp=child;
                while(p!=child)
               {
                     if(p->data<tmp->data)
                         tmp=p;
                     p=p->right;
                }
                info->root=tmp;
                return 1;
           }
      }
//如果二项堆的根结点数目大于1,则先将被删除的二项堆的根结点的儿子节点与其他顶层结点串接起来
      else
     {
           child=info->root->child;
           rear=child->left;
           right=info->root->right;
           left=info->root->left;
    
           left->right=child;
           child->left=left;
           rear->right=right;
           right->left=rear;
//开始寻找最小结点
           tmp=left;
           p=left->right;
           while(p!=left)
          {
                if(p->data<tmp->data)
                     tmp=p;
                p=p->right;
           }
           free(info->root);
           info->root=tmp;
     }
//     printf("  &&&  ");
     UnionBeap(info);
     return 1;
  }
//将已经散乱的二项堆重新合并
//这里已经确定的是给定的二项堆的根结点是最小结点，这个将用作程序的循环中的条件
  static void  UnionBeap(BeapInfo  *info)
 {
      int   j,len;
      Beap  *p,*q,*tmp;
      Link  *link;
      DegreeInfo   degree[36];
//计算节点的度
      j=info->len;
      len=0;
      while(j)
     {
           ++len;
           j>>=1;
      }
      ++len;
//开始建立与二项堆info所有相关的信息
      for(j=0;j<=len;++j)  //清零操作
     {
           degree[j].front=NULL;
           degree[j].rear=NULL;
      }
      p=info->root;
      do
     {
           j=p->degree;
           link=(Link *)malloc(sizeof(Link));
           link->root=p;

           if(! degree[j].front)
               degree[j].front=link;
           else
               degree[j].rear->next=link;
           degree[j].rear=link;
           p=p->right;
      }while(p!=info->root);
//下一步，开始对具有相同度的根结点进行合并
//度从小到大进行合并，这样也避免了二次遍历数组的操作
      for(j=0;j<=len;++j)
     {
           if(degree[j].front)
              union_degree(degree,j);
      }
//重新将所剩下的根结点重新链接起来(每个数组元素中所包含的结点之多为1个
      p=NULL;
      q=NULL;
      for(j=0;j<=len;++j)
     {
           if(degree[i].front)
          {
                tmp=degree[i].front->root;
                if(! p)
               {
                    p=tmp
                    q=p;
                }
                else
               {
                    p->right=tmp;
                    tmp->left=p;
                    p=tmp;
                }
                free(degree[i].front);
          }
      }
      p->right=q;
      q->left=p;
  }
//合并具有相同度的根结点
  static  void  union_degree(DegreeInfo  *degree,int j)
 {
      Link  *link,*stf,*stc,*front;
      Beap  *p,*q,*child;
      
      front=degree[j].front;
      link=front->next;
      while(front && link)
     {
            p=front->root;
            q=link->root;
            if(p->data>q->data)
           {
                  child=p;
                  p=q;
                  q=child;
            }
            child=p->child;
            if(! child)
           {
                  q->right=q;
                  q->left=q;
                  p->child=q;
            }
            else
           {
                  q->right=child;
                  q->left=child->left;
                  child->left->right=q;
                  child->left=q;
            }
//将新合并的结点加入到另一个数组元素所在指向的链中
            stf=(Link *)malloc(sizeof(Link));
            stf->next=NULL;
            stf->root=p;
            if(! degree[j+1].front)
                 degree[j+1].front=stf;
            else
                 degree[j+1].rear->next=stf;
            degree[j+1].rear=stf;
            stf=link;
            stc=front;
            front=link->next;
            link=NULL;
            if(front)
                link=front->next;
            free(stf);
            free(stc);
       }
       if(front)
      {
            degree[j].front=front;
            degree[j].rear=front;
       }
       else
      {
            degree[j].front=NULL;
            degree[j].rear=NULL;
       }
  }
/***********************************************************/
  int  main(int argc,char *argv[])
 {
       BeapInfo  ainfo,binfo;
	   Beap  *p;
       int   i,j,seed;
       int   test[14]={8,10,3,5,4,6,15,30,7,9,16,12,20,7};
       
       seed=time(NULL);
       ainfo.len=0;
       ainfo.root=NULL;
       ainfo.rear=NULL;
       binfo.len=0;
       binfo.root=NULL;
       binfo.rear=NULL;
       
       printf("由插入式创建一个新的二项堆...\n");
       for(i=0;i<10;++i)
      {
           printf(" ^^^ \n");
           insert_item(&ainfo,test[i]);
       }
       printf("再次向创建的堆中插入新的元素(以大半个堆得形式)...\n");
       for(i=10;i<14;++i)
      {
            binfo.len=1;
            p=(Beap *)malloc(sizeof(Beap));
            p->data=test[i];
            p->child=NULL;
            p->left=NULL;
            p->right=NULL;
            p->degree=0;
            binfo.root=p;
            binfo.rear=p;
            union2beap(&ainfo,&binfo);
       }
//
      printf("开始执行删除操作...\n");
      for(i=0;i<14;++i)
     {
            remove_root(&ainfo,&seed);
            printf("第%d个元素是:%d \n",i,seed);
      }
      return 0;
  }