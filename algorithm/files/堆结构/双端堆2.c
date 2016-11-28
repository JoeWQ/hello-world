//2012/11/7/18:25
//**关于双端堆的相关操作*/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
 
  #define   DEAP_MAX_SIZE    48
  #define   INIT_DEAP_SIZE   19

  #include"display_dp.c"
//创建双端堆
  void  CreateDeap(int *);
//向堆中插入一个元素
  int   insertItem(int *,int);
//查询最大值
  int   GetMaxOfDeap(int *,int *);
//查询最小值
  int   GetMinOfDeap(int *,int *);
//删除最大值
  int   removeMaxOfDeap(int *,int *);
//删除最小值
  int   removeMinOfDeap(int *,int *);

//给定一个最小堆中的结点的下标索引，求与其相对应的最大堆中项对应的结点的下标索引
  static  int  find_max(int i,int n)
 {
       int  k=0;
       int  j=i;

       while( j )
      {
          ++k;
          j>>=1;
       }

       i+=1<<(k-2);
       i=i>n?(i>>1):i;

       return i;
  }
//查找与给定的最大堆中的结点相对应的最小堆中的结点索引
  static  int  find_min(int i)
 {
       int  k=0;
       int  j=i;

       while( j )
      {
           ++k;
           j>>=1;
       }
       
       i-=1<<(k-2);
       return i;
  }
//判断给定的结点是在最大堆中还是在最小堆中，若在最小堆返回0，否则返回1
  static  int  level(int i)
 {
       while(i!=2 &&  i!=3)
           i>>=1;

       return i&1;
  }
//对堆结构进行调整,将比父结点小的结点逐级向上移动
  static void  adjust_min(int  *deap,int parent)
 {
       int   child,len=*deap;
       int    tmp;

       tmp=deap[parent];
       for(child=parent<<1;child<=len;  )
      {
            if(child<len  && deap[child]>deap[child+1])
                   ++child;
            if(tmp>deap[child])
                deap[parent]=deap[child];
            else
                break;
            parent=child;
            child<<=1;
       }
       deap[parent]=tmp;
  }
//调整最大堆结构，将比父结点大的结点逐级向上移动
  static  void  adjust_max(int  *deap,int  parent)
 {
       int  child,len=*deap;
       int  tmp=deap[parent];

       for(child=parent<<1;child<=len;  )
      {
             if(child<len  &&  deap[child]<deap[child+1])
                     ++child;
             if(tmp<deap[child])
                   deap[parent]=deap[child];
             else
                   break;
             parent=child;
             child<<=1;
       }
       deap[parent]=tmp;
  }
//从下到上对最小堆的堆结构进行调整
  static  void  adjust_min_b(int *deap,int  child)
 {
       int  parent;
       int  tmp=deap[child];

       for(parent=child>>1;parent>=2;  )
      {
             if(deap[parent]>tmp)
                  deap[child]=deap[parent];
             else
                  break;
             child=parent;
             parent>>=1;
       }
       deap[child]=tmp;
  }
//从下到上对最大堆得堆结构进行调整
  static  void  adjust_max_b(int  *deap,int  child)
 {
       int  parent;
       int  tmp=deap[child];
 
       for(parent=child>>1;parent>=3;  )
      {
            if(deap[parent]<tmp)
                 deap[child]=deap[parent];
            else
                 break;
            child=parent;
            parent>>=1;
       }
       deap[child]=tmp;
  }
//创建双端堆(在原数组上直接实现),数组的下标索引0存储的数组的当前长度，1为最大长度
  void   CreateDeap(int *deap)
 {
      int  len=*deap;
      int  i,j,tmp;
//先建立好最大堆和最小堆，然后再对其中不符合要求的结点重新进行调整
      for(i=len>>1;i>=2;--i)
     {
           if(!  level(i))
                adjust_min(deap,i);
           else
                adjust_max(deap,i);
      }
//开始进行重调整,注意，调整之后，有可能会打破最大堆和最小堆的结构，这个时候必须
//进行从下到上进行再次调整
      for(i=len;i>=2;--i)
     {
//若结点位于最小堆中
           if(!  level(i))
          {
                j=find_max(i,len);
                if(deap[j]<deap[i])
               {
                     tmp=deap[j];
                     deap[j]=deap[i];
                     deap[i]=tmp;
                     adjust_min_b(deap,i);
                     adjust_max_b(deap,j);
                }
           }
           else
          {
                j=find_min(i);
                if(deap[j]>deap[i])
               {
                     tmp=deap[j];
                     deap[j]=deap[i];
                     deap[i]=tmp;
                     adjust_max_b(deap,i);
                     adjust_min_b(deap,j);
                }
           }
       }
  }
/****************************************************************/
//向堆中插入元素
  int  insertItem(int  *deap,int  item)
 {
       int   len,j;
       int   parent;

       if(*deap>=deap[1])
      {
            printf("一处错误，堆中的空间已满！\n");
            return 0;
       }
       len=++*deap;
       parent=len>>1;
//如果堆为空，则直接插入
       if(len==2)
      {
            deap[2]=item;
            return 1;
       }
//如果插入的位置是坐落在最小堆中
       if(!  level(len))
      {
            j=find_max(len,len);
            if(item>deap[j])
           {
                 deap[len]=deap[j];
                 deap[j]=item;
                 adjust_max_b(deap,j);
            }
            else
           {
                 deap[len]=item;
                 adjust_min_b(deap,len);
            }
       }
       else
      {
            j=find_min(len);
            if(item<deap[j])
           {
                 deap[len]=deap[j];
                 deap[j]=item;
                 adjust_min_b(deap,j);
            }
            else
           {
                 deap[len]=item;
                 adjust_max_b(deap,len);
            }
       }
       return 1;
  }
//删除最小值
  int  removeMinOfDeap(int *deap,int *min)
 {
       int  parent,child;
       int  tmp,len,j;

       if(*deap<2)
      {
           printf("删除错误，堆中的元素已经为空!\n");
           return 0;
       }
       if(*deap==2)
      {
           *min=deap[2];
           --*deap;
           return 1;
       }
       len=--*deap;
       tmp=deap[len+1];
       *min=deap[2];
       parent=2;
//将最小堆中的较小元素逐级向上移动
       for(child=parent<<1;child<=len;  )
      {
            if(child<len  &&  deap[child]>deap[child+1])
                  ++child;
            deap[parent]=deap[child];
            parent=child;
            child<<=1;
       }
//注意下面的步骤
       j=find_max(parent,len);
	     if(j==1)
	    {
		        deap[2]=tmp;
		        return 1;
	     }
       child=j<<1;
       if(child<=len)
      {
             j=child;
             if(child<len &&  deap[child]>deap[child+1])
                  ++j;
       }
       if(deap[j]<tmp)
      {
             deap[parent]=deap[j];
             deap[j]=tmp;
//             adjust_min_b(deap,parent);
             adjust_max_b(deap,j);
       }
       else
      {
             deap[parent]=tmp;
             adjust_min_b(deap,parent);
       }
       return 1;
  }
//删除最大值
  int  removeMaxOfDeap(int  *deap,int *max)
 {
       int  child,parent;
       int  tmp,j,len;
       
       if(*deap<2)
      {
            printf("删除错误，堆已经为空!\n");
            return 0;
       }
       if(*deap==2)
      {
            *max=deap[2];
            --*deap;
            return 1;
       }
       if(*deap==3)
      {
            *max=deap[3];
            --*deap;
            return 1;
       }
//对于一般情况
       *max=deap[3];
       len=--*deap;
       tmp=deap[len+1];
       parent=3;
       for(child=parent<<1;child<=len;  )
      {
             if(child<len  &&  deap[child]<deap[child+1])
                     ++child;
             deap[parent]=deap[child];
             parent=child;
             child<<=1;
       }
//下面的步骤很重要，注意
       j=find_min(parent);
       child=j<<1;

       if(child<=len)
      {
             j=child;
             if(child<len && deap[child]<deap[child+1])
                  ++j;
       }
       
       if(deap[j]>tmp)
      {
             deap[parent]=deap[j];
             deap[j]=tmp;
             adjust_min_b(deap,j);
//             adjust_max_b(deap,parent);
       }
       else
      {
             deap[parent]=tmp;
             adjust_max_b(deap,parent);
       }
       return 1;
  }
//*************************************************************************
  int  GetMinOfDeap(int *deap,int *min)
 {
       return 1;
  }
  int  FetMaxOfDeap(int *deap,int *max)
 {
       return 1;
  }
//****************************************************************************
  int  main(int  argc,char *argv[])
 {
       int   deap[DEAP_MAX_SIZE];
       int   tmp[DEAP_MAX_SIZE];
       int   i,value,seed;

       seed=time(NULL);
       for(i=2;i<=INIT_DEAP_SIZE;++i)
             deap[i]=rand();
       deap[0]=INIT_DEAP_SIZE;
       deap[1]=DEAP_MAX_SIZE;

       printf("现在开始创建双端堆!\n");
       CreateDeap(deap);

       for(i=0;i<=INIT_DEAP_SIZE;++i)
             tmp[i]=deap[i];

       display_deap(deap);
       printf("现在开始按最小值的方式对堆中的元素进行删除...\n");
       for(i=2;i<=INIT_DEAP_SIZE;++i)
      {
            removeMinOfDeap(deap,&value);
            printf("第%d个元素为%d\n",i,value);
       }
       printf("*******************************************************\n");

       printf("现在按最大值的方式进行删除操作..\n");
       for(i=2;i<=INIT_DEAP_SIZE;++i)
      {
            removeMaxOfDeap(tmp,&value);
            printf("第%d个元素为%d \n",i,value);
       }
       printf("现在向堆中插入元素。。。%d\n",deap[0]);
       deap[0]=1;
       for(i=0;i<16;++i)
      {
            value=rand();
            printf("%d  ",value);
            insertItem(deap,value);
       }
       printf("进行插入操作后，堆中的内容如下:\n");
       display_deap(deap);
       printf("\n");
       return 0;
  }
      