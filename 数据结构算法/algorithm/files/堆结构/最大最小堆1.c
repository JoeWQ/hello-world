//ʵ�������С�ѵĲ�����ɾ������
  #include<stdio.h>
  #include<stdlib.h>
  #define  MAX_SIZE   9
  #define  LIMIT_N    16
  #define  SEED_T     0x1234
//�жϵ�ǰ�����ڵ����ڲ����������С��  
  int   level(int);
//��ǰ���в���һ��Ԫ��
  void  insert(int *,int *,int);
//����һ�������С��
  void  CreateMaxMinHeap(int *,int);
//ɾ�������С�ѵ���СԪ��
  int  delete_min(int *,int *);
//ɾ�������С�ѵ����Ԫ��
  int  delete_max(int *,int *);
//�������С���������Ԫ��
  void  verify_max(int *,int,int);
  void  verify_min(int *,int,int);
//**********************************************************
  int  level(int index)
 {
      int i=0;
      while(index>0)
     {
           index>>=1;
           ++i;
      }
//���������ͷ���0�����򷵻�1
      return i&0x1;
  }
//�����ѽṹ
  void  adjust(int *heap,int nsize,int i)
 {
      int  child,parent,grand;
      int  len=nsize-1,tmp;
//����ýڵ�������
      if(!level(i))
     {
          child=i;
//��������
          while(child>0)
         {
               grand=child>>2;
               if(child<=len && heap[child]<heap[child+1])  //�ҵ��ϴ�ֵ
                     ++child;
               tmp=heap[child];
               if(grand>0 && heap[grand]<tmp)
              {
                     heap[child]=heap[grand];
                     heap[grand]=tmp;
               }
               child=grand;
           }
           child=i;
//����
           while(child>0)
          {
               parent=child>>1;
               if(child<=len && heap[child]>heap[child+1])  //�ҵ�һ����С�Ľڵ���丸�ڵ�
                    ++child;                               //���Ƚ�
               if(parent>0 && heap[parent]>heap[child])
              {
                    tmp=heap[child];
                    heap[child]=heap[parent];
                    heap[parent]=tmp;
               }
               child=parent>>1;
           }
      }
//����ýڵ�����С��
      else
     {
           child=i;
           while(child>0)
          {
               grand=child>>2;
               if(child<=len && heap[child]>heap[child+1])  //�ҵ���Сֵ
                    ++child;
               if(grand>0 && heap[grand]>heap[child])
              {
                    tmp=heap[child];
                    heap[child]=heap[grand];
                    heap[grand]=tmp;
               }
               child=grand;
           }
           child=i;
//���������С�ѵĽṹ
           while(child>0)
          {
               parent=child>>1;
//�ҵ�һ�����ڵ���丸�ڵ���Ƚ�
               if(child<=len && heap[child]<heap[child+1])  
                      ++i;
               if(parent>0 && heap[parent]<heap[child])
              {
                    tmp=heap[parent];
                    heap[parent]=heap[child];
                    heap[child]=tmp;
               }
               child=parent>>1;
           }
      }
  }
  void  CreateMaxMinHeap(int *heap,int nsize)
 {
      int  len=nsize-1;
      int  i;

      len=nsize>>1;
      for(i=nsize;i>len;--i)
           adjust(heap,nsize,i);
  }
//�������С���в���һ��Ԫ��
  void  insert(int *heap,int *nsize,int key)
 {
      int  parent,len;
      if(*nsize>=LIMIT_N)
     {
          printf("�ѽṹ�Ѿ����������¹���!\n"); 
          return;
      }
      len=++(*nsize);
//���Ҫ����Ľڵ�����������
      if(!level(len))
     {
           parent=len>>1;
           if(key<heap[parent])
          {
               heap[len]=heap[parent];
               verify_min(heap,parent,key);
           }
           else
               verify_max(heap,len,key);
      }
      else
     {
           parent=len>>1;
           if(key>heap[parent])
          {
                heap[len]=heap[parent];
                verify_max(heap,parent,key);
           }
           else
               verify_min(heap,len,key);
      }
  }
//�������С����Ƕ��Ԫ��
  void  verify_min(int *heap,int n,int key)
 {
      int  grand=n>>2;
      while(grand>0)
     {
          if(heap[grand]>key)
         {
              heap[n]=heap[grand];
              n=grand;
              grand>>=2;
          }
          else
              break;
      }
      heap[n]=key;
  }
  void  verify_max(int *heap,int n,int key)
 {
      int  grand=n>>2;
      while(grand>0)
     {
          if(heap[grand]<key)
         {
              heap[n]=heap[grand];
              n=grand;
              grand>>=2;
          }
          else
              break;
      }
      heap[n]=key;
  }
  //���ұȸ���������Ԫ�ش�С��Ԫ�ص�����
  int  find_min(int *heap,int nsize,int i)
 {
       int  child,limit,key;
       if(!nsize)
      {
            printf("�����Ѿ�û��Ԫ�أ���Сֵ����ʧ��!\n");
            return -1;
       }
       if(nsize==1)
          return 1;
//����һ��ѡ���С�ڵ�
       if(nsize>=(i<<1) && nsize<(i<<2))
      {
            child=i<<1;
            if(child<nsize && heap[child]>heap[child+1])
                    ++child;
            return child;
       }
//����ڵ�ѡ���С�ڵ�
       child=i<<2;
       limit=child+3;
       limit=limit>nsize?nsize:limit;
       key=heap[child];
       i=child;
       for(++child;child<=limit;++child)
      {
             if(key>heap[child])
            {
                 i=child;
                 key=heap[child];
             }
       }
       return i;
  }
//���ұȸ����������δ��Ԫ������
  int  find_max(int  *heap,int  nsize,int  i)
 {
        int  child,limit,key;
 
        if(!nsize)
       {
            printf("���е�����Ԫ���Ѿ���ɾ�����!\n");
            return -1;
        }
        if(nsize==1)
           return 1;
//���ӽڵ���ѡ���С�ڵ�
        if(nsize>=(i<<1)  &&  nsize<(i<<2))
       {
            child=i<<1;
            if(child<nsize && heap[child]<heap[child+1])
                ++child;
 //           printf("ѡ����Ԫ��%d \n",child);
            return child;
        }
//����ڵ���ѡ���С�ڵ�
        child=i<<2;
        limit=child+3;
        limit=limit>nsize?nsize:limit;
        key=heap[child];
        i=child;
        //�ں���ڵ����ҵ����ڵ�
        for(++child;child<=limit;++child)
       {
              if(key<heap[child])
             {
                  key=heap[child];
                  i=child;
              }
        }
//        printf("ѡ����Ԫ��%d\n",i);
        return  i;
  }   
//�������С����ɾ����СԪ��
  int  delete_min(int *heap,int *nsize)
 {
      int  parent,child,key,k,tmp;
      int  len=*nsize,i;
      if(! len)
     {
           printf("���Ѿ�Ϊ�գ�������ɾ����Ԫ��Ԫ��!\n");
           return  -1;
      }
      --(*nsize);
      heap[0]=heap[1];
      key=heap[len];
      k=(--len)>>1;
      for(i=1;i<=k;)
     {
            child=find_min(heap,len,i);
            if(key<=heap[child])
                 break;
            heap[i]=heap[child];
            if(child<=((i<<1)+1))
           {
                 i=child;
                 break;
            }
            parent=child>>1;
            if(heap[parent]<key)
           {
                 tmp=heap[parent];
                 heap[parent]=key;
                 key=tmp;
            }
            i=child;
      }
      heap[i]=key;
      printf("����ɾ����Ԫ����:%d\n",heap[0]);
      return heap[0];
  }
//ɾ�����Ԫ��
  int  delete_max(int  *heap,int *nsize)
 {
       int  child,parent,tmp;
       int  i=2,len,key,n;
       if(!*nsize)
      {
           printf("���������ڵ�ֵ!\n");
           return -1; 
       }
       if(*nsize==1)
      {
            --(*nsize);
            heap[0]=heap[1];
            goto en_o;
       }
       len=(*nsize)--;
       key=heap[len];
       if(i<len && heap[i]<heap[i+1])
           ++i;
       heap[0]=heap[i];
       if(len<=3)
      {
           if(len==2)
              goto en_o;
           if(i==2)
              heap[2]=heap[3];
           goto en_o;
       }
    //   printf("keyΪ%d \n",key);
       for(--len,n=len>>1;i<=n;)
      {
            child=find_max(heap,len,i);
       //     printf("ѡ��Ĵδ�Ԫ��Ϊ:%d \n",heap[child]);
            if(key>=heap[child])
               break;
            heap[i]=heap[child];
            if(child<=((i<<1)+1))
           {
                 i=child;
                 break;
            }
            parent=child>>1;
            if(key<heap[parent])
           {
                tmp=key;
                key=heap[parent];
                heap[parent]=tmp;
            }
            i=child;
       }
       heap[i]=key;
    en_o:
       printf("����ɾ����Ԫ����%d \n",heap[0]);
       return heap[0];
   }   
  int  main(int argc,char *argv[])
 {
      int  i=0,tmp,k;
      int  nsize;
      int  heap[LIMIT_N+1];
      int  copy[LIMIT_N+1];
      srand(SEED_T);
      printf("���鱻��ʼ����Ľ��Ϊ:\n");
      for(i=1;i<=MAX_SIZE;++i)
     {
          heap[i]=tmp=rand();
          printf(" %d  ",tmp);
      }
      printf("\n********************************************************\n");
      CreateMaxMinHeap(heap,MAX_SIZE);
      nsize=MAX_SIZE;
      printf("�����������С��Ϊ:%d,��Ԫ������:\n",nsize);
      for(i=1;i<=MAX_SIZE;++i)
     {
          printf("  %d  ",heap[i]);
      }
      printf("\n*************************************************************\n");

      for(i=0;i<4;++i)
     {
          tmp=rand();
          printf("���ڿ�ʼ����һ���ڵ�:%d!\n",tmp);
          insert(heap,&nsize,tmp);
      }
      printf("�������е�Ԫ��Ϊ:\n");
      for(i=1;i<=nsize;++i)
          printf("  %d  ",heap[i]);
      printf("\n*****************************************************************\n");

//������Ԫ�ظ����������Ա�Ժ���������ֵɾ����ʽ�Ľ��в���
      for(i=1;i<=nsize;++i)
          copy[i]=heap[i];

      printf("���ڿ�ʼɾ�������е�Ԫ��!\n");
      for(i=1,tmp=nsize;i<=tmp;++i)
          delete_min(heap,&nsize);
      if(!nsize)
          printf("�ɹ��Ĳ��������е�Ԫ�ض���ɾ��!\n");
      else
          printf("�����������%d��Ԫ��δ��ɾ����!\n",nsize);
      printf("\n***************************************************************\n");

      printf("\n_____________________________________________________________________\n");
      printf("������ɾ�����ֵ�ķ�ʽ����ɾ������!\n");
      nsize=tmp;
      for(i=1;i<=tmp;++i)
     {
           
  //         for(k=1;k<=nsize;++k)
  //             printf("  %d  ",copy[k]);
  //         putchar('\n');
           delete_max(copy,&nsize);
      }
      printf("\n______________________________________________________________________\n");
      if(!nsize)
          printf("��ɾ�����ֵ�ķ�ʽɾ��Ԫ�����!\n");
      else
          printf("��ɾ�����Ԫ��ɾ��Ԫ��ʧ�ܣ�����%d��Ԫ��δ��ɾ��\n",nsize);      
      return 0;
  }
