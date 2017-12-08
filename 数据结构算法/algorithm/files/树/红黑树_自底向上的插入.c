//2012/12/6/9:10
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
//������ɫ����ɫΪ1����ɫΪ0
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
//����װ�ĺ������Ϣ�ṹ
  typedef  struct  _Tree_rInfo
 {     
       struct  _Tree_r  *root;
       int              len;
  }Tree_rInfo;
//����
  Tree_r   *search_r(Tree_rInfo  *,int );
//�������
  int    insert_r(Tree_rInfo  *,int );
//�����ĵ�������
  static  void   adjust_r(Tree_rInfo  *,Tree_r *);
//������ת
  static  void   rotate_r_l(Tree_rInfo *,Tree_r *);
//������ת
  static  void   rotate_r_r(Tree_rInfo *,Tree_r *);
//*******************************��ɾ��������صĺ�������
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
//ʹ�����������к�����Ĳ���,����ʱ��time(NULL)��8,�ȴ� C����(11)Ҫ��΢��һЩ
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
//�������
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
//�����µĽ��,����������
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
//��ʼ��������׶�
        adjust_r(info,node);
        ++info->len;
        return 1;
  }
//����������Ľṹ
  static  void  adjust_r(Tree_rInfo *info,Tree_r *r)
 {
       Tree_r   *p=r->parent;
//gpΪr���游��㣬yΪp���ֵܽڵ�
       Tree_r   *gp=NULL,*y=NULL;
//ѭ�����������������������ĺ�ɫָ��,ע�⣬������Ӻ�����Ķ������
//�Ѿ��ٶ�ĳЩ�����Ѿ��õ�����,���ң����Ѿ��õ�����
       while(p && p->color)
      {
             gp=p->parent;
             if(p==gp->lchild)
            {
                   y=gp->rchild;
//���y����ɫΪ��ڣ���ֻ��ı�ָ�����ɫ��������ı�ָ���ֵ
                   if(y && y->color)
                  {
                        gp->color=C_R;
                        p->color=C_B;
                        y->color=C_B;
                        r=gp;
                        p=r->parent;
                   }
//��y->colorΪ��ɫ������������ʱ������rΪp������������������������������ת����
                   else  if(r==p->rchild)
                  {
//��ʱ��ִ��������ת��ʹr��Ϊ�丸������������Ȼ����ִ��������ת
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
             else//����ĳ������˼·��������ǶԳƵ�
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
//��ת����,����ת
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
//����ת
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
//���Ҹ������ĺ�̽��
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
//ɾ������,�ɹ��򷵻�1�����򷵻�0
  int  remove_r(Tree_rInfo  *info,int  data)
 {
        Tree_r   *r,*p,*y,*x,*gp;
        int      color;
//�Ƚ��в��Ҳ���
        r=search_r(info,data);
        if(!  r)
//       {
//              printf("ɾ������������������ %d ������!\n",data); 
              return 0;
//        }
//ע�⣬�����ɾ���ж��߼����ܻ�Ƚ��������
        y=NULL,x=NULL;
        --info->len;
        if(!r->lchild || !r->rchild)
             y=r;
        else
             y=find_next(r);
//Ѱ��y���ӽ��
        if(y->lchild)
             x=y->lchild;
        else
             x=y->rchild;
//��ʼ�޸�ָ��
        p=y->parent;
        if( x )
            x->parent=p;
//�ж�r�Ƿ�Ϊ�����
        if(! p)
            info->root=x;
        else
       {
             if(y==p->lchild)
                  p->lchild=x;
             else
                  p->rchild=x;
        }
//�ƶ�ָ���Լ�����,,p��¼����y�ĸ�������ɫ����һ�㣬Ҫ��������ĵ���ʱ�Ż���ʾ�������ô�
//֮����������ƣ�������Ϊ�������ԭ������Ϊ�˴��ģ���ݴ������Ƶģ����ԣ����ǲ��õ����ƶ�ָ�룬�����ƶ�����
        if(y!=r)
       {
//ע��������һ��ǳ���Ҫ���������þ��൱�ڵ����̳߳����е�����ͬ��
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
//�ж�ָ�����ɫ���Ծ����Ƿ�Ҫ�Ժ�������е���
           y=r;
        }
        if(!y->color)//����ոձ�ɾ�����Ǻ�����,����Ҫ����
              fixup_r(info,p,x);
        free(r);
        return 1;
  }
//����ɾ������ĺ����,p��x�ĸ����
  void  fixup_r(Tree_rInfo  *info,Tree_r *p,Tree_r *x)
 {
        Tree_r  *y=NULL;
//ѭ��������
        while((x && !x->color) || !x)
       {
              if(x==info->root)
                   break;
              if(x==p->lchild)
             {
                     y=p->rchild;
/**
                     if(! y)//�ϸ����˵����������������
                    {           
                          printf("  --$$$--  ");
                          x=p;
                          break;
                     }
*/
//���x���ֵܽ����һ�����㣬����������Ĵ����ǱȽϼ򵥵�,��������ĳһЩ����л��ø���
                     if(y->color)
                    {
//                          printf("  @@@  ");
                          y->color=C_B;
                          p->color=C_R;
//�����ƶϳ���y������һ���ڶ��ӽ��,���ǹ������Ĳ������ǽ����ı���ɫ������ת��ô�򵥣������Խ��������ת��Ϊ��������
                          rotate_r_l(info,p);
                     }
//���y��������ɫ����(Ҳ����������)
                     else if((!y->lchild || !y->lchild->color) && (!y->rchild || !y->rchild->color))
                    {
                          y->color=C_R;
                          x=p;
                          p=p->parent;
                     }
                     else if(y->lchild && y->lchild->color)//�����������Ϊ��ɫ����������Ϊ��ɫ
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
//����������ں�����������У��ϸ����˵���ǲ�����ֵģ����ֻ��Ϊ�˷�ֹĳЩ�Ƿ��Ĳ���
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
                    else if(y->lchild && y->lchild->color)//���y��������Ϊ��ɫ����ôֻ��ִ��һ����ת����
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
//�������һ�䲻��ȱ��
       if( x )
          x->color=C_B;
  }
//***************ȫ���������ĸ��������Ƿ�õ�����*******************
  static  void  test_r(Tree_rInfo  *info,int data)
 {
        Tree_r  *r=info->root,*p=NULL;
//��¼��·���о����ĺ�ڽ����Ŀ
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
//�����Ҷ�ӽ��
        if(!p->lchild  &&  !p->rchild)
               printf("----------Ҷ��:����:%d,�ڽ��:%d ,--------�ܳ���:%d\n",num_r,num_b,(num_r+num_b));
//        else
//               printf("��Ҷ��:����:%d,�ڽ��:%d ,�ܳ���:%d\n",num_r,num_b,(num_r+num_b));
  }
//������������ȣ����ɵĺ���������ܣ�����֮�ò��Ҳ������Ƚϣ���������Ϊȱ�ٿɱ��ԣ����Բ����Ƚ�
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
//Ϊ���ܸ���һ������������ҵ����ܣ����ǽ�ʹ�����������������洿C���룬�Դ����ȽϺ����������
//�����ǵĲ����У������������ʱ�䣨time(NULL)��������9���������������ʱ����ȻΪ11���ɴˣ����Կ���������Ч��
//ҪԶԶC���룬��Ȼ�����Ҳ����Ҫ���ɵģ���������ִ����������Ż���һ�����δ���ܹ�ʤ�α������ľ��߷���
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
//�����������
        times=time(NULL);
        for(j=0;j<500000;++j)
            for(i=0;i<len;++i)
                 search_array(vbuf,vbuf[i]);
        printf("����������ѵ�ʱ��Ϊ%u\n",(int)time(NULL)-times);

        times=(int)time(NULL);
        for(j=0;j<500000;++j)
            for(i=0;i<len;++i)
                 search_r(info,vbuf[i]);
        printf("��������������ѵ�ʱ��Ϊ:%u\n",(int)time(NULL)-times);
//������Intel Core 2�����ϵó��������ǣ�ʹ��time(NULL)�����������������ʱ��54�����������Ϊ11���ɴˣ������Ͽ���
//������������Ĳ�������ҪԶԶ�������飬������������ݣ��������Ѿ��ź�������ݣ�������������
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
       printf("\n************************���������!***********************\n");
       for(i=0;i<len;++i)
      {
             if(insert_r(&info,vbuf[i]))
                  printf("  %d  ����ɹ�!\n",vbuf[i]);
             else
                  printf("  %d  ����ʧ��!\n",vbuf[i]);
       }
       printf("\n************************��ʼ���в��Ҳ���!*******************\n");
/*
       for(i=0;i<len;++i)
      {
            if(search_r(&info,vbuf[i]))
                  printf("  %d  ���ҳɹ�!\n",vbuf[i]);
            else
                  printf("  %d  ����ʧ��!\n",vbuf[i]);
       }
*/
/*8
       seed=len>>1;
       printf("\n********************ɾ������****************************\n");
       for(i=0;i<seed;++i)
      {
             if(remove_r(&info,vbuf[i]))
                   printf(" %dɾ�������ɹ�!\n",vbuf[i]);
             else
                   printf(" %dɾ��ʧ��!\n",vbuf[i]);
       }
*/
       printf("*********************���Ժ����***************************\n");


       printf("\n*************************���Կ�ʼ*************************\n");
/*
       for(i=seed;i<len;++i)
      {
            test_r(&info,vbuf[i]);
       }
       printf("��������ɫ:%d  \n",info.root->color);
*/
       test_time(&info,vbuf,len);
       return 0;
  }