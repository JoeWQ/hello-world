//2012/12/20/14:47
//�����������C����ʵ��
  #include<stdio.h>
  #include<stdlib.h>
  #include<string.h>
  #include<time.h>
//Ϊ��������������Ƶ����ݽṹ
  typedef  struct  _HufmanTree
 {
//Ȩֵ
        int   weight;
//ָ����������ָ��
		int   parent;
        int   lchild;
        int   rchild;
//��¼�Ƿ��Ѿ���ѡ���
        int   v;
  }HufmanTree;
//��ѡ�������������С����
  void  Select(HufmanTree *hf,int *min1,int *min2,int n)
 {
        int         i,min,j;
        HufmanTree  *p=hf+1;

        min=0x7FFFFFFF;
        j=-1;
        for(i=1;i<=n;++i,++p)
       {
             if( !p->v && p->weight<min)
            {
                  min=p->weight;
                  j=i;
             }
        }
        hf[j].v=1;
        *min1=j;

       p=hf+1;
       min=0x7FFFFFFF;
       j=-1;
       for(i=1;i<=n;++i,++p)
      {
             if(!p->v && p->weight<min)
            {
                  min=p->weight;
                  j=i; 
             }
       }
       hf[j].v=1;
       *min2=j;
  }
//����������ʵ��,������0�У�����������hf��ʵ�ʳ��ȼ�:hf->weight
  void  HufmanCode(HufmanTree  *hf,char  **hfCode)
 {
       int         i,j,n,m;
       int         ms1,ms2;
       char        *vbuf,*p;

       n=hf->weight;
       m=(n<<1)-1;
       for(i=0;i<=m;++i)
      {
            hf[i].v=0;
            hf[i].parent=0;
            hf[i].lchild=0;
            hf[i].rchild=0;
       }
       for(i=n+1;i<=m;++i)
      {
            Select(hf,&ms1,&ms2,i-1);
            printf("ms1:%d,ms2:%d \n",ms1,ms2);
            hf[i].weight=hf[ms1].weight+hf[ms2].weight;
            hf[ms1].parent=i;
            hf[ms2].parent=i;
            hf[i].lchild=ms1;
            hf[i].rchild=ms2;
       }
//��ʼ����
       vbuf=(char *)malloc(sizeof(char)*n+2);
       vbuf[n]='\0';
       for(i=1;i<=n;++i)
      {
            ms1=n;
            m=0;
            for(j=i,ms2=hf[j].parent; ms2 ;j=ms2,ms2=hf[ms2].parent)
           {
                  if(j==hf[ms2].lchild)
                      vbuf[--ms1]='0';
                  else
                      vbuf[--ms1]='1';
                  ++m;
            }
            p=(char *)malloc(sizeof(char)*m+2);
            strcpy(p,&vbuf[ms1]);
            hfCode[i]=p;
      }
      free(vbuf);
  }
//**********************************************************************
  int  main(int argc,char *argv[])
 {
      int  vbuf[36];
      int  size=32;
      int  i;
      char  *hfCode[36];
      HufmanTree  hf[72];
      
      srand(0x807F);
      printf("ʹ��������������......\n");
      for(i=1;i<=size;++i)
     {
            vbuf[i]=rand(); 
            printf("  %d  ",vbuf[i]);
            if(!(i & 0x7))
                printf("\n");
      }
      
      printf("��ʼ���������������...\n");
      for(i=1;i<=size;++i)
          hf[i].weight=vbuf[i];
      hf[0].weight=size;

      printf("��ʼ�Թ�����������...\n");
      HufmanCode(hf,hfCode);
      
      printf("��������...\n");
      for(i=1;i<=size;++i)
     {
           printf("%d :%d--->%s\n",i,vbuf[i],hfCode[i]);
//�ͷ��ڴ�
           free(hfCode[i]);
      }
      return 0;
  }