  #include"��ʼ���ݽṹ.c"
  #include"��׺���ʽת��׺���ʽ�Լ���׺���ʽ�ļ���.c"
  #include"�ж������ַ�������.c"
//���ʽ��ִ�а���3�����
  int  value_exp(char *,char *);
  int  exp_compute(char *,char *,int *);
  int  exc_commd(char *);
//��1��:��ֵ���
  
//���ɹ���Ϊ1������Ϊ0
  int  value_exp(char *input,char *postfix)
 {
     int  len=strlen(input);
     int  value,index,i;
	  int  *tmp,*init;
     char  c;

     if(len<2)
    {
         printf("��ֵ���ʽ�﷨����û�и�����ֵ!\n");
         return 0;
     }
     c=*input;
     tmp=0;
     if(c>='A' && c<='Z')
    {
         index=c-'A';
         tmp=gvar;
         init=ginit;
     }
     else if(c>='a' && c<='z')
    {
         index=c-'a';
         tmp=svar;
         init=sinit;
     }
     else
    {
         printf("��ֵ���ʽ�﷨����,��������ĸ����Լ���ı�����Χ!\n");
         return 0;
     }
     i=2;
     if(!infix_to_postfix(&input[2],postfix))
          return 0;
          
     if(!compute_postfix(postfix,&value))
    {
          printf("��ֵ���ʽ��ֵ���㲿���﷨����!\n");
          return 0;
     }
     tmp[index]=value;
     init[index]=1;
     printf("%c=%d\n",c,value);
     return 1;
  }
//��2��:���ʽ����
//���ɹ����򷵻�1�����򷵻�0
  int  exp_compute(char  *input,char *postfix,int *value)
 {
     if(!infix_to_postfix(input,exp))
         return 0;
     if(!compute_postfix(postfix,value))
    {
//          printf("���ʽ�����﷨����!\n");
          return 0;
     }
     printf("%d \n",*value);
     return 0;
  }
//��3��:ִ�и���������
//���ɹ�����1�����򷵻�0
  int  exec_commd(char  *input)
 {
     int i=0,k;
     int  flag;
     if(!strcmp(input,"clrscr"))
    {
         ++i;
         system("cls");
     }
//ִ��ʹ����δ��ʼ��������
     else if(!strcmp(input,"clear"))
    {
         ++i;
         for(k=0;k<globle_len;++k)
        {
              gvar[k]=svar[k]=0;
              ginit[k]=sinit[k]=0;
         }
     }
//ִ���˳�����
     else if(!strcmp(input,"exit"))
    {
         ++i;
         exit(0);
     }
//ִ��display����
     else if(startWith(input,"display"))
    {
          i=strlen("display");
          
//��������κβ���������ʾ���еı����ĵ�ǰ���
          if(input[i]!='#')
         {
              flag=0;
              for(i=0;i<26;++i)
             {
//���û�н��г�ʼ��
                 ++flag;
                 if(!sinit[i])
                      printf("%cδ��ʼ��",('a'+i));
                 else
                      printf("%c:%d ",('a'+i),svar[i]);
                 if(flag & 0x4)
                {
                     putchar('\n');
                     flag=0;
                 }
              }
              putchar('\n');
//��д�ַ�����
              flag=0;
              for(i=0;i<26;++i)
             {
                  ++flag;
                  if(!ginit[i])
                       printf("%cδ��ʼ��",('A'+i));
                  else
                       printf("%c:%d",('A'+i),gvar[i]);
                  if(flag & 0x4)
                 {
                      putchar('\n');
                      flag=0;
                  }
              }
              putchar('\n');
          }
         else
        {
              flag=0;
              for(++i;input[i];++i)
             {
                  if(input[i]>='a' && input[i]<='z')
                 {
                      ++flag;
                      k=input[i]-'a';
                      if(!sinit[k])
                           printf("����%cδ��ʼ��",input[i]);
                      else
                           printf("%c:%d, ",input[i],svar[k]);
                  }
                  else if(input[i]>='A' && input[i]<='Z')
                 {
                      ++flag;
                      k=input[i]-'A';
                      if(!ginit[k])
                            printf("����%cδ��ʼ��",input[i]);
                      else
                            printf("%c:%d, ",input[i],gvar[k]);
                  }
                  if(flag & 0x4)
                 {
                      putchar('\n');
                      flag=0;
                  }
              }
              putchar('\n');
          }
     }
     return i;
  }
  int  main(int argc,char *argv[])
 {
      int  i=0;
      int  data;
      while(1)
     {
           printf("������һ���ַ������ʽ!\n");
           delete_blank(vbuf,256);
           if(match(vbuf))
          {
               printf("С���ű��ʽ��ƥ�䣬����������.\n");
               continue;
           }
           switch(input_type(vbuf))
          {
		        case 0: printf("�޷�����������.\n");break;
//��ֵ���
                case 1: value_exp(vbuf,exp);break;
//����Ǳ��ʽ
                case 2: exp_compute(vbuf,exp,&data);break;
//�����ִ����������
                case 3: exec_commd(vbuf);break;
           }
       }
       return 0;
  }
            