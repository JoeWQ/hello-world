//˫�˶ѵ���ز���
  #include<stdio.h>
  #include<stdlib.h>
  #include<time.h>

  #define  SEED_T     0x8730
  #define  MAX_SIZE   9
  #define  LIMIT_T    24
//��˫�˶��в���һ��Ԫ��
  void  insert(int *,int *n,int);
  void  max_insert(int *,int,int);
  void  min_insert(int *,int,int);
//����һ��˫�˶�
  void  CreateDeap(int *,int);
//ɾ��˫�˶ѵ���СԪ��ֵ
  int   delete_min(int *,int *);
//ɾ��˫�˶ѵ���СԪ��ֵ
  int   delete_max(int *,int *);
//�ҳ��������С���������Ӧ����������
  int   find_max(int ,int);
//�ҳ�����������������Ӧ����С������
  int   find_min(int,int);
//ȷ�������������Ǵ��������л�������С����
  int   level(int);
//�����ѽṹ
  void  adjust_max(int *,int,int);
  void  adjust_max(int *,int,int);
//����������������Ӧ������
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
//�жϵ�ǰ�����������ڵ������������ѻ�������С����,ע������û�м�鼯����������
  int  level(int i)
 {
       while(i!=2 && i!=3)
      {
            i>>=1;
       }
       return (i==2)?0:1;
  }
//�����ѽṹ      
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
//�����������
           if(level(i))
                adjust_max(deap,nsize,i);
           else
                adjust_min(deap,nsize,i);
      }
      for(i=nsize;i>=len;--i)
     {
//�����������
           if(level(i))
                adjust_max(deap,nsize,i);
           else
                adjust_min(deap,nsize,i);
      }
  }
//����в���Ԫ��
  void  insert(int *deap,int *nsize,int key)
 {
       int  partner;
       int  len=++(*nsize);
//���Ҫ����ĵط�������
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
//�����������������
       if(level(len))
      {
           partner=find_min(len,len);
           printf("��ǰ����%d����������:%dֵΪ%d\n",len,partner,deap[partner]);
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
printf("��ǰ����%d����������:%dֵΪ%d\n",len,partner,deap[partner]);
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
//�������в���Ԫ��
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
//����С���в���Ԫ��
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
//��˫�˶���ɾ��������СԪ��
  int  delete_min(int *deap,int *nsize)
 {
       int  parent,child;
       int  key,tmp,len,partner;

       if(*nsize<=1) 
      {
           printf("���е�����Ԫ�ض��Ѿ���ɾ�����!\n");
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
//ע��ɾ�����ڵ�Ĳ���Ҫ��ɾ����С�ڵ�Ҫ���ӵö࣬����ÿ��ǵ����е����
  int  delete_max(int *deap,int *nsize)
 {
       int  parent,child,key;
       int  tmp,len,partner;

       len=*nsize;
       if(len<=1)
      {
           printf("���е�����Ԫ�ض��Ѿ���ɾ�����!\n");
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
//ע���������һ���жϲ��������û�У����ڼ��ַǳ����Բ��������³�������len=5(����*nsize>=6,���Լ�����len>=5��)
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

      printf("��ʼ������:\n");
      srand(0x569043);
      nsize=MAX_SIZE+2;
      for(i=2;i<=nsize;++i)
     {
          deap[i]=rand();
          printf("  %d  ",deap[i]);
      }

      printf("\n************************����˫�˶�*****************************\n");
      CreateDeap(deap,nsize);
      printf("��������е�Ԫ�طֱ�Ϊ:\n");
      for(i=2;i<=nsize;++i)
         printf("  %d  ",deap[i]);
      
      printf("\n�����������в���4��Ԫ��:\n");
      for(i=0;i<4;++i)
     {
          tmp=rand();
          insert(deap,&nsize,tmp);
          printf("�����%d��Ԫ�� %d�����ڵ���������Ϊ:\n  ",i,tmp);
 
          for(k=2;k<=nsize;++k)
               printf("  %d  ",deap[k]);
          putchar('\n');
          
      }
//      printf("\n�����Ԫ�ص�˳��Ϊ:\n");
//      for(i=2;i<=nsize;++i)
 //          printf("  %d  ",deap[i]);
 
      printf("\nɾ��ǰnsize��ֵΪ:%d\n",nsize);
      for(i=2;i<=nsize;++i)
          copy[i]=deap[i];
      tmp=nsize;
      
      printf("\n������ɾ����Сֵ�ķ�ʽ��˫�˶�ɾ����Ԫ��!\n");
      for(i=2;i<=tmp;++i)
     {
          printf("  %d  ",delete_min(deap,&nsize));
//          printf("\nɾ����%d��Ԫ�غ�nsize��ֵΪ:%d \n",i,nsize);
      }
      printf("\n__________________________________________________\n"); 
    
      printf("������ɾ�����ֵ�ķ�ʽ��˫�˶��е�Ԫ�ؽ���ɾ��!\n");
      nsize=tmp;
      for(i=2;i<nsize;++i)
     {
//          putchar('\n');
//          for(k=2;k<=tmp;++k)
//               printf("  %d  ",deap[k]);
          printf("  %d  \n",delete_max(copy,&tmp));
//          printf("\n____________________________________________________________\n");
      }
      printf("\n����ɾ��Ԫ�����!\n");
      return 0;
  }