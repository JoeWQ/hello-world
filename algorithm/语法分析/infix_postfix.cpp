/*
  *@aim:��׺���ʽ����׺���ʽ��ת��
  *@date:2015-9-17
  *@author:�ҽ���
  */
 #include<vector>
 #include<string>
 #include<stdio.h>
 /*
   *@aim:��׺���׺��ת��
   *@param:infix�������׺���ʽ
   *@param:postfix����ĺ�׺���ʽ
   */
 //��������ȷ������ʽ�����ȼ�/����ƥ��,������������в���������֣�ֻ����Сд��ĸ
 //�˴Σ����Ǽ����+�����ŵĴ���,��������ȷ�ķָ�����$
 //�Ӽ����ž����ҽ���ԣ������ȼ��Ƚϵͣ�ʹ�õ�ʱ��������С�����ڿ�����������������
   bool            convert_infix_to_postfix(std::string        *infix,std::string   *postfix)
  {
               const      char         *a=infix->c_str();
               int           i;
               char        c,top;
               bool           alpha_symbol=true;//�Ƿ�Ӽ����Ѿ�����
//��һ���ʷ���Ԫ�Ƿ���һ��������
               bool           left_bracket=true;
               std::vector<char>    astack,*y=&astack;
               y->reserve(infix->size());

               for(i=0;i<infix->size();   ++i    )
              {
                             c=a[i];
//��չ֧�ֶ��ַ�����
                             if( c>='a' && c<='z')
                                        *postfix+=c; 
                             else if(c=='+' || c=='-')
                            {
             //����Ѿ���������
                                       if( left_bracket)
                                                   *postfix+='$';
                                        while( y->size() && (top=y->at( y->size()-1))!='('  )
                                       {
                                                    *postfix+=top;
                                                    y->pop_back();
                                        }
                                        y->push_back(c);
                             }
                             else if( c=='*' || c=='/')//��ʱ��Ҫ��������������ȼ�,�ڱ�Ҫ��ʱ����Ҫ��������
                            {
//���ջ������ͬ���ȼ��Ĳ�������ֱ�����,ע�����֤��ջ�в���������2����2�����ϵ�*/�ַ�
                                        if(y->size() && (top=y->at(y->size()-1))=='*' || top=='/' )
                                       {
                                                    *postfix+=top;
                                                    y->pop_back();
                                        }
                                         y->push_back(c);
                             }
                             else if(c =='(')//������
                                        y->push_back(c);
                             else if( c==')')//������,��ʱ��Ҫ���Ѿ���յ������еı��ʽ����
                            {
                                        while(y->size() && (top=y->at(y->size()-1))!='(' )//ע��ѭ������ʽ
                                       {
                                                     *postfix+=top;
                                                     y->pop_back();
                                        }
                                        if(y->size() && y->at(y->size()-1)=='(')
                                                     y->pop_back();
//����ʱ���ķ�
                                        if(  alpha_symbol)
                                       {
                                                    printf("Syntax error:lack of component operation in column %d for '%c' \n",i,c);
                                                    return   false;
                                        }
                             }
//��ǰ�ʷ���Ԫ�Ƿ���������
                             left_bracket=c=='(';
//��ǰ�ʷ���Ԫ�Ƿ���������
                             alpha_symbol=(c=='+'||c=='-');
               }
//��ջ�в������ַ�����
              for(int i=y->size()-1;i>=0;--i )
                            *postfix+=y->at(i); 
//��������Ų�ƥ��
              if( alpha_symbol)
             {
                           printf("Syntax error: lack of component in column %d for '%c'\n",i,c);
                           return  false;
              }
              return   true;
   }
   int     main(int    argc,char   *argv[])
  {
//ע�⣬���ɵĺ�׺���ʽ�У���������ž�����ͬ�����ȼ�,�����ڿ��������ɵı��ʽ�л����һЩ��ֵĶ���
//�����ⶼ����ȷ��
              std::string    str0="-a*b+e";
              std::string    str1="(a+b)*e";
              std::string    str2="a*b/c";
              std::string    str3="(-a/(b-c+d))*(e-a)*c";
              std::string    str4="a/b-c+(-d)*e-a*c";
              std::string    str5="a+";
              std::string    str6="a-b+(-c)+d+e";
              
              std::string    *infix[7]={&str0,&str1,&str2,&str3,&str4,&str5,&str6};
              int                size=7;
              std::string    postfix;
              
              for(int  i=0;i<size;++i)
             {
                            if( convert_infix_to_postfix(infix[i],&postfix))
                                    printf("Ԫ���ʽ:%s: %s\n",infix[i]->c_str(),postfix.c_str());
                            else
                                    printf("expression %s illegal!\n",infix[i]->c_str());
                             postfix.clear();
              }
              return   0;
   }