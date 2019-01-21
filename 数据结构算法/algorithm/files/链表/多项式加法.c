//����ʽ�ӷ�
  #include<stdio.h>
  #include<stdlib.h>
 // #include<string.h>
//**********************************
  typedef struct _Poly
 {
     float coef;  //����ʽ��ϵ��
     int   exp;   //ָ��
     struct _Poly   *next;
  }Poly;
//����ʽ�������Ϣ
  typedef struct _PolyInfo
 {
     int itemc;  //����ʽ������
     struct _Poly  *front;  //ָ�����ʽ��ͷָ��
     struct _Poly  *rear;
  }PolyInfo;
 //*************************************************
  PolyInfo  *polyAddtion(PolyInfo  *,PolyInfo *);
  void  printPoly(PolyInfo *);
  void  freePoly(PolyInfo *);
 
  int main(int argc,char *argv[])
 {
     PolyInfo *ainfo=NULL,*binfo=NULL;
     Poly     *tmp;
     PolyInfo  *ninfo;
     float coef;
     int   exp;
     int   i=0;
     printf("�������һ������ʽ!��������Ϊ:ϵ��,ָ��,���밴�������.\n�����ָ������Ϊ����.����0,-1����\n");
     ainfo=(PolyInfo *)malloc(sizeof(PolyInfo));
     ainfo->front=NULL;
     ainfo->rear=NULL;
     ainfo->itemc=0;
     while(1)
    {
         coef=0;
         exp=0;
         printf("�������%u ��:",i);
         scanf("%f %d",&coef,&exp);
         if(coef==0 && exp==-1)
             break;
         if(exp<0)
        {
             printf("ָ��������Ƿ�������������!\n");
             continue;
         }
         tmp=(Poly *)malloc(sizeof(Poly));
         tmp->coef=coef;
         tmp->exp=exp;
         tmp->next=NULL;
         if(!ainfo->front)
        {
            ainfo->front=tmp;
            ainfo->rear=tmp;
            ++ainfo->itemc;
         }
         else
        {
            ainfo->rear->next=tmp;
            ainfo->rear=tmp;
            ++ainfo->itemc;
         }
         ++i;
        putchar('\n');
     }
//.............................................................
     printf("������ڶ�������ʽ!����͵�һ������ʽ��ͬ\n");
     binfo=(PolyInfo *)malloc(sizeof(PolyInfo));
     binfo->front=NULL;
     binfo->rear=NULL;
     binfo->itemc=0;
     i=0;
     while(1)
    {
        coef=0;
        exp=0;
        printf("�������%u��:",i);
        scanf("%f %d",&coef,&exp);
        if(coef==0 && exp==-1)
            break;
        if(exp<0)
       {
            printf("ָ������Ƿ�,����������!\n");
            continue;
        }
        tmp=(Poly *)malloc(sizeof(Poly));
        tmp->coef=coef;
        tmp->exp=exp;
        tmp->next=NULL;
        if(!binfo->front)
       {
            binfo->front=tmp;
            binfo->rear=tmp;
            ++binfo->itemc;
        }
        else
       {
            binfo->rear->next=tmp;
            binfo->rear=tmp;
            ++binfo->itemc;
        }
        ++i;
        putchar('\n');
    }
//��ʼ���ж���ʽ�ӷ�
    printf("��һ������ʽΪ:");
    printPoly(ainfo);
//    putchar('\n');
    printf("��һ������ʽΪ:");
    printPoly(binfo);
//    putchar('\n');
    ninfo=polyAddtion(ainfo,binfo);
    printf("����ʽ��Ӻ�Ľ��Ϊ:");
    printPoly(ninfo);
//    putchar('
    freePoly(ainfo);
    freePoly(binfo);
    freePoly(ninfo);
    return 0;
  }
//����ʽ�ļӷ�
  PolyInfo  *polyAddtion(PolyInfo *ainfo,PolyInfo *binfo)
 {
    PolyInfo *ninfo;
    Poly     *tmp,*atp,*btp,*ctp;
    float   coef;
    int     exp;
    int i,k;
    int alen,blen;
//**********************
    if(!ainfo && !binfo)
        return NULL;
    ninfo=(PolyInfo *)malloc(sizeof(PolyInfo));
    ninfo->front=NULL;
    ninfo->rear=NULL;
    ninfo->itemc=0;
    if(ainfo && !binfo)
   {
        atp=ainfo->front;
        btp=NULL;
        goto mergea;
    }
    else if(!ainfo && binfo)
   {
        atp=NULL;
        btp=binfo->front;
        goto mergeb;
    }
//��ʼ��
    alen=ainfo->itemc;
    blen=binfo->itemc;
    atp=ainfo->front;
    btp=binfo->front;

    for(i=0,k=0;i<alen && k<blen;++i,++k)
   {
        if(atp->exp==btp->exp)
       {
           coef=atp->coef+btp->coef;
           exp=atp->exp;
           if(coef==0)
          {
              atp=atp->next;
              btp=btp->next;
              continue;
           }
           tmp=(Poly *)malloc(sizeof(Poly));
           tmp->coef=coef;
           tmp->exp=exp;
           tmp->next=NULL;
           if(!ninfo->front)
          {
               ninfo->front=tmp;
               ninfo->rear=tmp;
           }
           else
          {
               ninfo->rear->next=tmp;
               ninfo->rear=tmp;
           }
           ++ninfo->itemc;
           atp=atp->next;
           btp=btp->next;
           continue;
        }
        else if(atp->coef>btp->exp)
       {
           ctp=atp;
        }
        else
       {
           ctp=btp;
        }
        coef=ctp->coef;
        exp=ctp->exp;
        tmp=(Poly *)malloc(sizeof(Poly));
        tmp->coef=coef;
        tmp->exp=exp;
        tmp->next=NULL;
        if(!ninfo->front)
       {
            ninfo->front=tmp;
            ninfo->rear=tmp;
         }
        else
       {
            ninfo->rear->next=tmp;
            ninfo->rear=tmp;
        }
        ++ninfo->itemc;
        if(ctp==atp)
          atp=atp->next;
        else
          btp=btp->next;
        
   }
//��ʣ�����ȫ�����Ƶ��½���������
  mergea:
   while(atp)
  {
       tmp=(Poly *)malloc(sizeof(Poly));
       tmp->coef=atp->coef;
       tmp->exp=atp->exp;
       tmp->next=NULL;
       if(ninfo->itemc)
      {
          ninfo->rear->next=tmp;
          ninfo->rear=tmp;
       }
       else
      {
          ninfo->front=tmp;
          ninfo->rear=tmp;
       }
       ++ninfo->itemc;
       atp=atp->next;
   }
  mergeb:
   while(btp)
  {
       tmp=(Poly *)malloc(sizeof(Poly));
       tmp->coef=btp->coef;
       tmp->exp=btp->exp;
       tmp->next=NULL;
       if(ninfo->itemc)
      {
          ninfo->rear->next=tmp;
          ninfo->rear=tmp;
       }
       else
      {
          ninfo->front=tmp;
          ninfo->rear=tmp;
       }
       ++ninfo->itemc;
       btp=btp->next;
    }
   return ninfo;
 }
//�������ʽ
  void  printPoly(PolyInfo *info)
 {
     int i,len;
     Poly  *tmp;
     len=info->itemc;
     tmp=info->front;
     if(!len)
       return;
     printf("%.1f*x(%d)",tmp->coef,tmp->exp);   
	 tmp=tmp->next;
     for(i=1;i<len;++i)
    {
		 if(tmp->coef>0)
             printf("+%.1f*x(%d)",tmp->coef,tmp->exp);
		 else if(tmp->coef<0)
			 printf("%.1f*x(%d)",tmp->coef,tmp->exp);
         tmp=tmp->next;
     }
     putchar('\n');
  }
//�ͷŶ���ʽ��ռ�õĿռ�
  void freePoly(PolyInfo *info)
 {
      Poly  **poly;
      Poly  *tmp;
      int i,len;
//ʹ�ö���Ŀռ��¼���еĽڵ��ַ,�Է�����ͷſռ�
      poly=(Poly **)malloc(sizeof(int)*info->itemc);
      tmp=info->front;
      len=info->itemc;
//�Ѽ��ڵ�ĵ�ַ
      for(i=0;i<len && tmp;++i)
     {
          poly[i]=tmp;
          tmp=tmp->next;
      }
      for(i=0;i<len;++i)
        free(poly[i]);
      free(info);
      free(poly);
  }