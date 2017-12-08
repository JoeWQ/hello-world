//双端堆的相关操作
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  #define  SEED_T     0x8730
  #define  MAX_SIZE   9
  #define  LIMIT_T    24
//向双端堆中插入一个元素
  void  insert(int *,int *n,int);
  void  max_insert(int *,int,int);
  void  min_insert(int *,int,int);
//创建一个双端堆
  void  CreateDeap(int *,int);
//删除双端堆的最小元素值
  int   delete_min(int *,int *);
//删除双端堆的最小元素值
  int   delete_max(int *,int *);
//找出与给定最小堆索引向对应的最大堆索引
  int   find_max(int ,int);
//找出与给定最大堆索引相对应的最小堆索引
  int   find_min(int,int);
//确定给定的索引是处在最大堆中还是在最小堆中
  int   level(int);
//调整堆结构
  void  adjust_max(int *,int,int);
  void  adjust_max(int *,int,int);
//查找与给定索引向对应的索引
  int  find_max(int  nsize,int i)
 {
      int  k=0;
      int  child=i;
      while(child>0)
     {
           child>>=1;
           ++k;
      }
      child=i+(1<<(k-2));
      return (child>nsize)?(child>>1):child;
  }
  int  find_min(int nsize,int i)
 {
      int  k=0;
      int  child=i;
   
      while(child>0)
     {
          ++k;
         child>>=1;
      }   
      return  i-(1<<(k-2));
  }
//判断当前给定的索引节点是坐落在最大堆还是在最小堆中,注意这里没有检查集中特殊的情况
  int  level(int i)
 {
       while(i!=2 && i!=3)
      {
            i>>=1;
       }
       return (i==2)?0:1;
  }
//调整堆结构      
  void  adjust_max(int *deap,int nsize,int i)
 {
       int  parent,child;
       int  partner,tmp;
       
       for(child=i;child>3;child>>=1)
      {
            partner=find_min(nsize,child);
            if(deap[partner]>deap[child])
           {
                tmp=deap[partner];
                deap[partner]=deap[child];
                deap[child]=tmp;
            }
            parent=child>>1;
            if(deap[parent]<deap[child])
            {
                  tmp=deap[parent];
                  deap[parent]=deap[child];
                  deap[child]=tmp;
             }
        }
   }
  void  adjust_min(int *deap,int nsize,int i)
 {
        int  parent,child;
        int  partner,tmp;

        partner=find_max(nsize,i);
        for(child=i;child>2;child>>=1)
       {
             partner=find_max(nsize,child);
             if(deap[partner]<deap[child])
            {
                  tmp=deap[partner];
                  deap[partner]=deap[child];
                  deap[child]=tmp;
             }
             parent=child>>1;
             if(deap[child]<deap[parent])
            {
                  tmp=deap[parent];
                  deap[parent]=deap[child]; 
                  deap[child]=tmp;
             }
        }
  }

  void  CreateDeap(int  *deap,int nsize)
 {
      int  i,len=nsize>>1;

      if(nsize<=2)
         return;
      if(nsize==3)
     {
           if(deap[2]>deap[3])
          {
               i=deap[2];
               deap[2]=deap[3];
               deap[3]=i;
           }
           return;
      }
      for(i=nsize;i>len;--i)
     {
//如果在最大堆中
           if(level(i))
                adjust_max(deap,nsize,i);
           else
                adjust_min(deap,nsize,i);
      }
      for(i=nsize;i>=len;--i)
     {
//如果在最大堆中
           if(level(i))
                adjust_max(deap,nsize,i);
           else
                adjust_min(deap,nsize,i);
      }
  }
//向堆中插入元素
  void  insert(int *deap,int *nsize,int key)
 {
       int  partner;
       int  len=++(*nsize);
//如果要插入的地方是最大堆
       if(len==2)
      {
            deap[2]=key;
            return;
       }
       if(len==3)
      {
            if(key<deap[2])
           {
                partner=deap[2];
                deap[3]=deap[2];
                deap[2]=key;
                return;
            }
            deap[3]=key;
            return;
       }
//如果是坐落在最大堆中
       if(level(len))
      {
           partner=find_min(len,len);
           printf("当前索引%d伙伴的索引是:%d值为%d\n",len,partner,deap[partner]);
           if(deap[partner]>key)
          {
                deap[len]=deap[partner];
                min_insert(deap,partner,key);
           }
           else
                max_insert(deap,len,key);
       }
       else
      {
printf("当前索引%d伙伴的索引是:%d值为%d\n",len,partner,deap[partner]);
           partner=find_max(len,len);
           if(deap[partner]<key)
          {
                deap[len]=deap[partner];
                max_insert(deap,partner,key);
           }
           else
                min_insert(deap,len,key);
       }
  }
//在最大堆中插入元素
  void  max_insert(int *deap,int start,int key)
 {
       int  child,parent;
       
       for(child=start;child>3;)
      {
           parent=child>>1;
           if(deap[parent]<key)
               deap[child]=deap[parent];
           else
               break;
           child=parent;
       }
       deap[child]=key;
  }
//在最小堆中插入元素
  void  min_insert(int *deap,int  start,int key)
 {
       int  child,parent;
       
       for(child=start;child>2;)
      {
           parent=child>>1;
           if(deap[parent]>key)
               deap[child]=deap[parent];
           else
               break;
           child=parent;
       }
       deap[child]=key;
  }
//从双端堆中删除最大和最小元素
  int  delete_min(int *deap,int *nsize)
 {
       int  parent,child;
       int  key,tmp,len,partner;

       if(*nsize<=1) 
      {
           printf("堆中的所有元素都已经被删除完毕!\n");
            return -1;
       }
       if(*nsize==2)
      {
           --(*nsize);
           return deap[2];
       }
       if(*nsize==3)
      {
          tmp=deap[2];
          deap[2]=deap[3];
          --(*nsize);
          return tmp;
       }
       if(*nsize==4)
      {
           tmp=deap[2];
           deap[2]=deap[4];
           --(*nsize);
           return tmp;
       }
       tmp=deap[2];
       key=deap[(*nsize)--];
       len=*nsize;
//       printf(" @@@nsize:%d\n",*nsize); 
       for(child=4;child<=len;)
      {
            if(child<len && deap[child]>deap[child+1])
                 ++child;
            deap[child>>1]=deap[child];
            parent=child;
            child<<=1;
       }
       partner=find_max(len,parent);
       if(key>deap[partner])
      {
            child=deap[partner];
            deap[partner]=key;
            key=child;         
       }
       min_insert(deap,parent,key);
//       printf(" !!!nsize:%d\n",*nsize);
       return tmp;
  }
//注意删除最大节点的操作要比删除最小节点要复杂得多，必须得考虑到所有的情况
  int  delete_max(int *deap,int *nsize)
 {
       int  parent,child,key;
       int  tmp,len,partner;

       len=*nsize;
       if(len<=1)
      {
           printf("堆中的所有元素都已经被删除完毕!\n");
           return -1;
       }
       if(len==2)
      {
           --(*nsize);
           return deap[2];
       }
       if(len==3)
      {
           --(*nsize);
           return deap[3];
       }
       if(len<6)
      {
            if(len==4)
           {
                tmp=deap[3];
                deap[3]=deap[4];
                --(*nsize);
                return tmp;
            }
            else
           {
                child=4;
                --(*nsize);
                if(deap[4]<deap[5])
               {
                     tmp=deap[3];
                     deap[3]=deap[5];
                     return tmp;
                }
                else
               {
                     tmp=deap[3];
                     deap[3]=deap[4];
                     deap[4]=deap[5];
                     return tmp;
                }
            }
       }
       key=deap[len];
       --len;
       --(*nsize);
       tmp=deap[3];
       
       for(parent=3,child=6;child<=len;)
      {
           if(child<len && deap[child]<deap[child+1])
                 ++child;
           deap[child>>1]=deap[child];
           parent=child;
           child<<=1;
       }
       partner=find_min(len,parent);
//注意下面的这一步判断操作，如果没有，会在几种非常难以察觉的情况下出错，比如len=5(上面*nsize>=6,单自减后变成len>=5了)
       if((partner<<1)<=len)
      {
            partner<<=1;
            if(partner<len && deap[partner]<deap[partner+1])
                  ++partner;
       }
       if(key<deap[partner])
      {
           child=key;
           key=deap[partner];
           deap[partner]=child;
       }
       max_insert(deap,parent,key);
       return tmp;
  }
  int  main(int argc,char *argv[])
 {
      int  i=0,tmp,nsize,k;
      int  deap[LIMIT_T];
      int  copy[LIMIT_T];

      printf("初始化数组:\n");
      srand(0x569043);
      nsize=MAX_SIZE+2;
      for(i=2;i<=nsize;++i)
     {
          deap[i]=rand();
          printf("  %d  ",deap[i]);
      }

      printf("\n************************创建双端堆*****************************\n");
      CreateDeap(deap,nsize);
      printf("创建后堆中的元素分别为:\n");
      for(i=2;i<=nsize;++i)
         printf("  %d  ",deap[i]);
      
      printf("\n现在向数组中插入4个元素:\n");
      for(i=0;i<4;++i)
     {
          tmp=rand();
          insert(deap,&nsize,tmp);
          printf("插入第%d个元素 %d后现在的数组内容为:\n  ",i,tmp);
 
          for(k=2;k<=nsize;++k)
               printf("  %d  ",deap[k]);
          putchar('\n');
          
      }
//      printf("\n插入后元素的顺序为:\n");
//      for(i=2;i<=nsize;++i)
 //          printf("  %d  ",deap[i]);
 
      printf("\n删除前nsize的值为:%d\n",nsize);
      for(i=2;i<=nsize;++i)
          copy[i]=deap[i];
      tmp=nsize;
      
      printf("\n现在以删除最小值的方式对双端堆删除其元素!\n");
      for(i=2;i<=tmp;++i)
     {
          printf("  %d  ",delete_min(deap,&nsize));
//          printf("\n删除第%d个元素后，nsize的值为:%d \n",i,nsize);
      }
      printf("\n__________________________________________________\n"); 
    
      printf("先在以删除最大值的方式对双端堆中的元素进行删除!\n");
      nsize=tmp;
      for(i=2;i<nsize;++i)
     {
//          putchar('\n');
//          for(k=2;k<=tmp;++k)
//               printf("  %d  ",deap[k]);
          printf("  %d  \n",delete_max(copy,&tmp));
//          printf("\n____________________________________________________________\n");
      }
      printf("\n现在删除元素完毕!\n");
      return 0;
  }