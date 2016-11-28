//根据中序和后续遍历的情况建立与之相对应的二叉树
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
//***************************************
  typedef struct  _Tree
 {
     int  data;
//记录对该节点而言，左子树可用的字符数,不包含dada数据
     short  le;
//记录对该节点而言，有字数可用的字符数
     short  re;
//记录对该根节点而言，可用的字符数
     int  len;
//记录所访问的节点中的字符数据在字符串中所对应的位置
     int  start;
     int  end;
     struct  _Tree  *parent;
     struct  _Tree  *lchild;
     struct  _Tree  *rchild;
  }Tree;
  Tree  *CreateTree(char *,char *);
  #ifndef  TREE_CONTAINED
    #include "m_tree.c"
  #endif
//任意节点的初始化
  void  init(Tree  *node)
 {
      node->data=0;
      node->le=0;
	  node->re=0;
      node->len=0; 
//start,end记录的是一个访问序列中根节点的索引
      node->start=0;
      node->end=0;
      node->parent=NULL;
      node->lchild=NULL;
      node->rchild=NULL;
   }
//
//根据中序和后续的遍历情况创建与之相对应的二叉树,注意下面的函数没有进行严格的参数检查,但是
//只要是正确的参数输入，都能产生与之相应的正确输出
  Tree  *CreateTree(char *preorder,char  *inorder)
 {
//两个字符串的长度
      int  inlen,prelen;
      int  data,i,k,count;
      Tree  *root=NULL,*tmp,*parent;

      inlen=strlen(inorder);
      prelen=strlen(preorder);
      if(!inlen || !prelen || inlen!=prelen)
     {
          printf("输入参数错误，请仔细验证!\n");
          return  NULL;
      }
      root=(Tree  *)malloc(sizeof(Tree));
      init(root);
      data=preorder[0];
      root->data=data;
      for(i=0;i<inlen;++i)
     {
         if(inorder[i]==data)
            break;
      }
      root->start=0;
      root->end=i;
      root->le=i;
      root->re=inlen-i-1;
//开始创建根节点的子树
      parent=root;
//      printf("&&&&\n");
      printf("root:start:%d,end:%d,le:%d,re:%d,data:%c,end:%d\n",root->start,root->end,root->le,root->re,root->data,root->end);
      for(i=1;i<inlen;++i)
     {
          
          if(!parent->lchild && parent->le)
         {
              printf("111\n");
              tmp=(Tree *)malloc(sizeof(Tree));
              init(tmp);
              data=preorder[i];
              tmp->data=data;
              tmp->parent=parent;
              parent->lchild=tmp;
              tmp->start=i;
              for(count=parent->le,k=parent->end-parent->le;count;++k,--count)
                  if(inorder[k]==data)
                       break;
              tmp->end=k;
              tmp->le=parent->le-count;
              tmp->re=count-1;

printf("lchild:%x, rchild:%x,le:%d,re:%d ,data:%c,end:%d\n",tmp->lchild,tmp->lchild,tmp->le,tmp->re,tmp->data,tmp->end);
              if(tmp->le || tmp->re )
                 parent=tmp;
           }
           else if(!parent->rchild && parent->re)
          {
              printf("222\n");
              tmp=(Tree *)malloc(sizeof(Tree));
              init(tmp);
              tmp->parent=parent;
              parent->rchild=tmp;
              tmp->start=i;
              data=preorder[i];     
              tmp->data=data;
    //          tmp->end=parent->end;
              for(count=parent->re,k=parent->end+1;count;++k,--count)
                   if(preorder[k]==data)
                        break;
              tmp->end=k;
              tmp->le=parent->re-count;
              tmp->re=count-1;

printf("lchild:%x, rchild:%x,le:%d,re:%d ,data:%c,end:%d\n",tmp->lchild,tmp->lchild,tmp->le,tmp->re,tmp->data,tmp->end);
              if(tmp->le || tmp->re)
                 parent=tmp;
            }
            else
           {
              printf("&&&&\n");
               --i;
               parent=parent->parent;
            }
       }
    return  root;
  }
//释放节点
  void  free_node(Tree *node)
 {
      free(node);
  }
//打印输出
  void  print_node(Tree  *node)
 {
      printf("data:%4c , lchild:%8x ,rchild:%8x ,parent:%8x,addr:%8x\n",node->data,node->lchild,node->rchild,node->parent,node);
  }

  int main(int argc,char *argv[])
 {
      Tree  *root;
      char  *preorder="ABCDEFG";
      char  *inorder="CBEDAFG";
      callback=print_node;

	    printf("开始创建二叉树!\n");
      root=CreateTree(preorder,inorder);
      printf("前序遍历结果如下:\n");
      Preorder(root);
      printf("二叉树的中序遍历结果如下所示:\n");
      VisitTree(root);

      printf("释放节点:\n");
      callback=free_node;
      VisitTree(root);
      return 0;
  }             