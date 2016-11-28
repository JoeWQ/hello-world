/*
  *@aim:树的遍历
  */
  import    java.util.LinkedList;
  class     Tree
 {
                        public       int          data;
//指向父节点左子树右子树的指针
                        public       Tree       parent;
                        public       Tree       lchild;
                        public       Tree       rchild;
  }
  public    class     TreeVisit
 {
//中序遍历
              public         static      void     visit_by_middle_order(Tree     root)
             {
                             LinkedList<Tree>        r=new   LinkedList<Tree>();
                             r.addFirst(root);
                             Tree        y=root.lchild;
                             while( y !=null )
                           {
                                         r.addFirst(y);
                                         y=y.lchild;
                            }
                            while(r.size()!=0)
                           {
                                         y=r.removeFirst();
                                         System.out.print((char)y.data);
                                         y=y.rchild;
                                         while( y!=null )
                                        {
                                                     r.addFirst(y);
                                                     y=y.lchild;
                                         }
                            }
              }
//先序遍历
              public     static     void     visit_by_preorder(Tree   root)
             {
                            Tree      y=root;
                            LinkedList<Tree>      r=new   LinkedList<Tree>();
                            r.addFirst(y);
                            while(r.size()!=0)
                           {
                                         y=r.removeFirst();
                                         System.out.print((char)y.data);
                                         if( y.rchild!=null )
                                                  r.addFirst(y.rchild);
                                         if(y.lchild!=null)
                                                  r.addFirst(y.lchild);
                            }
              }
//后序遍历
              public    static    void    visit_by_postorder(Tree   root)
             {
                            Tree      y=root;
                            LinkedList<Tree>     r=new     LinkedList<Tree>();
                            LinkedList<Tree>     a=new     LinkedList<Tree>();
                            
                            r.addFirst(y);
                            while(r.size()!=0)
                           {
                                       y=r.removeFirst();
                                       a.addFirst(y);
                                       if(y.lchild!=null)
                                                   r.addFirst(y.lchild);
                                       if(y.rchild!=null)
                                                   r.addFirst(y.rchild);
                            }
//访问a
                            while(a.size()!=0)
                           {
                                       y=a.removeFirst();
                                       System.out.print((char)y.data);
                            }
              }
//求树的深度
              public        static      int          tree_depth(Tree    root)
             {
                            int               depth=0;
                            Tree      y=root;
                            LinkedList<Tree>      r=new   LinkedList<Tree>();
                            r.addFirst(y);
                            while(r.size()!=0)
                           {
                                         y=r.removeFirst();
                                  //       System.out.print((char)y.data);
                                         if( y.rchild!=null )
                                                  r.addFirst(y.rchild);
                                         if(y.lchild!=null)
                                                  r.addFirst(y.lchild);
                                         if(  y.lchild==null && y.rchild ==null )
                                        {
                                                       int       d=0;
                                                       while(y!=null)
                                                      { 
                                                                   ++d;
                                                                   y=y.parent;
                                                       }
                                                       if(d>depth)
                                                                depth=d;
                                         }
                            }
                         return    depth;
              }
//节点之间建立联系
      public    static   void      fix_tree_node(Tree    root,boolean  has_left,int   count,int   ldata,int  rdata)
     {
                       Tree       y;
                       if(count==1)
                      {
                                   y=new   Tree();
                                   y.parent=root;
                                   if(has_left)
                                  {
                                           root.lchild=y;
                                           y.data=ldata;
                                   }
                                   else
                                  {
                                           root.rchild=y;
                                           y.data=rdata;
                                   }
                       }
                       else if(count>0)
                      {
                                    y=new    Tree();
                                    y.parent=root;
                                    y.data=ldata;
                                    root.lchild=y;
                                    
                                    y=new   Tree();
                                    y.parent=root;
                                    y.data=rdata;
                                    root.rchild=y;
                       }
      }
      public    static   void   main(String   argv[])
     {
                     Tree   root=new   Tree();
                     root.data='A';
                     Tree     y=root;
                      
                     TreeVisit.fix_tree_node(y,false,2,'B','E');
                     y=y.lchild;
                     TreeVisit.fix_tree_node(y,false,2,'F','K');
                     y=y.rchild;
                     TreeVisit.fix_tree_node(y,true,1,'Q',0);
                     y=y.lchild;
                     TreeVisit.fix_tree_node(y,false,1,0,'R');
                     
                     y=root.rchild;
                     TreeVisit.fix_tree_node(y,false,2,'L','C');
                     y=y.rchild;
                     TreeVisit.fix_tree_node(y,true,1,'X',0);
                     
                     
                     TreeVisit.visit_by_middle_order(root);
                     System.out.println();
                     TreeVisit.visit_by_preorder(root);
                     System.out.println();
                     TreeVisit.visit_by_postorder(root);
                     System.out.println("\n");
                     
                     System.out.println(TreeVisit.tree_depth(root));
      }
  }