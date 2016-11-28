//2012/11/7/18:25
//**����˫�˶ѵ���ز���*/
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>
 
  #define   DEAP_MAX_SIZE    48
  #define   INIT_DEAP_SIZE   19

  #include"display_dp.c"
//����˫�˶�
  void  CreateDeap(int *);
//����в���һ��Ԫ��
  int   insertItem(int *,int);
//��ѯ���ֵ
  int   GetMaxOfDeap(int *,int *);
//��ѯ��Сֵ
  int   GetMinOfDeap(int *,int *);
//ɾ�����ֵ
  int   removeMaxOfDeap(int *,int *);
//ɾ����Сֵ
  int   removeMinOfDeap(int *,int *);

//����һ����С���еĽ����±����������������Ӧ�����������Ӧ�Ľ����±�����
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
//����������������еĽ�����Ӧ����С���еĽ������
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
//�жϸ����Ľ�����������л�������С���У�������С�ѷ���0�����򷵻�1
  static  int  level(int i)
 {
       while(i!=2 &&  i!=3)
           i>>=1;

       return i&1;
  }
//�Զѽṹ���е���,���ȸ����С�Ľ���������ƶ�
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
//�������ѽṹ�����ȸ�����Ľ���������ƶ�
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
//���µ��϶���С�ѵĶѽṹ���е���
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
//���µ��϶����ѵöѽṹ���е���
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
//����˫�˶�(��ԭ������ֱ��ʵ��),������±�����0�洢������ĵ�ǰ���ȣ�1Ϊ��󳤶�
  void   CreateDeap(int *deap)
 {
      int  len=*deap;
      int  i,j,tmp;
//�Ƚ��������Ѻ���С�ѣ�Ȼ���ٶ����в�����Ҫ��Ľ�����½��е���
      for(i=len>>1;i>=2;--i)
     {
           if(!  level(i))
                adjust_min(deap,i);
           else
                adjust_max(deap,i);
      }
//��ʼ�����ص���,ע�⣬����֮���п��ܻ�������Ѻ���С�ѵĽṹ�����ʱ�����
//���д��µ��Ͻ����ٴε���
      for(i=len;i>=2;--i)
     {
//�����λ����С����
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
//����в���Ԫ��
  int  insertItem(int  *deap,int  item)
 {
       int   len,j;
       int   parent;

       if(*deap>=deap[1])
      {
            printf("һ�����󣬶��еĿռ�������\n");
            return 0;
       }
       len=++*deap;
       parent=len>>1;
//�����Ϊ�գ���ֱ�Ӳ���
       if(len==2)
      {
            deap[2]=item;
            return 1;
       }
//��������λ������������С����
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
//ɾ����Сֵ
  int  removeMinOfDeap(int *deap,int *min)
 {
       int  parent,child;
       int  tmp,len,j;

       if(*deap<2)
      {
           printf("ɾ�����󣬶��е�Ԫ���Ѿ�Ϊ��!\n");
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
//����С���еĽ�СԪ���������ƶ�
       for(child=parent<<1;child<=len;  )
      {
            if(child<len  &&  deap[child]>deap[child+1])
                  ++child;
            deap[parent]=deap[child];
            parent=child;
            child<<=1;
       }
//ע������Ĳ���
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
//ɾ�����ֵ
  int  removeMaxOfDeap(int  *deap,int *max)
 {
       int  child,parent;
       int  tmp,j,len;
       
       if(*deap<2)
      {
            printf("ɾ�����󣬶��Ѿ�Ϊ��!\n");
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
//����һ�����
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
//����Ĳ������Ҫ��ע��
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

       printf("���ڿ�ʼ����˫�˶�!\n");
       CreateDeap(deap);

       for(i=0;i<=INIT_DEAP_SIZE;++i)
             tmp[i]=deap[i];

       display_deap(deap);
       printf("���ڿ�ʼ����Сֵ�ķ�ʽ�Զ��е�Ԫ�ؽ���ɾ��...\n");
       for(i=2;i<=INIT_DEAP_SIZE;++i)
      {
            removeMinOfDeap(deap,&value);
            printf("��%d��Ԫ��Ϊ%d\n",i,value);
       }
       printf("*******************************************************\n");

       printf("���ڰ����ֵ�ķ�ʽ����ɾ������..\n");
       for(i=2;i<=INIT_DEAP_SIZE;++i)
      {
            removeMaxOfDeap(tmp,&value);
            printf("��%d��Ԫ��Ϊ%d \n",i,value);
       }
       printf("��������в���Ԫ�ء�����%d\n",deap[0]);
       deap[0]=1;
       for(i=0;i<16;++i)
      {
            value=rand();
            printf("%d  ",value);
            insertItem(deap,value);
       }
       printf("���в�������󣬶��е���������:\n");
       display_deap(deap);
       printf("\n");
       return 0;
  }
      