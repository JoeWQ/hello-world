//���ģ��Ĺ������ж�������ַ���������
//����ֵ������ĺ�����:
//0:�޷��������ַ���
//1����ֵ���
//2:���ʽ�������
//3:����ִ�����
  int  input_type(char *);
  static int input_contains(char *,int,char);

  int  input_type(char  *input)
 { 
      int  len=strlen(input);
      if(!len)
         return 0;
//����Ǹ�ֵ���
      if(input_contains(input,len,'='))
         return 1;
//����Ǳ��ʽ����
      if(input_contains(input,len,'+') || input_contains(input,len,'-') || 
          input_contains(input,len,'*')|| input_contains(input,len,'/') ||
          input_contains(input,len,'^'))
         return 2;
//���������ִ�в���
      if(!strcmp(input,"clear") || !strcmp(input,"clrscr") || !strcmp(input,"exit")
         || startWith(input,"display"))
         return 3;
//һ�ֲ�̫���Եı��ʽ����
      if(len==1 && input[0]>='a' && input[0]<='z' || input[0]>='A' && input[0]<='Z')
           return 2;
//���򷵻�
      return 0;
  }
//����ֵ1:�ַ����к��и������ַ���0��δ����
  static int  input_contains(char *input,int len,char c)
 {
      int i;
      for(i=0;i<len;++i,++input)
     {
          if(c==*input)
             return 1;
      }
      return 0;
  }