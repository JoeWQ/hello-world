/*
  *@aim:中缀表达式到后缀表达式的转换
  *@date:2015-9-17
  *@author:狄建彬
  */
 #include<vector>
 #include<string>
 #include<stdio.h>
 /*
   *@aim:中缀向后缀的转换
   *@param:infix输入的中缀表达式
   *@param:postfix输出的后缀表达式
   */
 //函数会正确处理表达式的优先级/括号匹配,这里假设输入中不会出现数字，只出现小写字母
 //此次，我们加入对+—符号的处理,并插入正确的分隔符号$
 //加减符号就有右结合性，其优先级比较低，使用的时候必须加上小括号在可能引起歧义的情况下
   bool            convert_infix_to_postfix(std::string        *infix,std::string   *postfix)
  {
               const      char         *a=infix->c_str();
               int           i;
               char        c,top;
               bool           alpha_symbol=true;//是否加减号已经出现
//上一个词法单元是否是一个左括号
               bool           left_bracket=true;
               std::vector<char>    astack,*y=&astack;
               y->reserve(infix->size());

               for(i=0;i<infix->size();   ++i    )
              {
                             c=a[i];
//扩展支持多字符序列
                             if( c>='a' && c<='z')
                                        *postfix+=c; 
                             else if(c=='+' || c=='-')
                            {
             //如果已经有左括号
                                       if( left_bracket)
                                                   *postfix+='$';
                                        while( y->size() && (top=y->at( y->size()-1))!='('  )
                                       {
                                                    *postfix+=top;
                                                    y->pop_back();
                                        }
                                        y->push_back(c);
                             }
                             else if( c=='*' || c=='/')//此时需要考虑运算符的优先级,在必要的时候需要交换数据
                            {
//如果栈中有相同优先级的操作符就直接输出,注意可以证明栈中不会有连续2个或2个以上的*/字符
                                        if(y->size() && (top=y->at(y->size()-1))=='*' || top=='/' )
                                       {
                                                    *postfix+=top;
                                                    y->pop_back();
                                        }
                                         y->push_back(c);
                             }
                             else if(c =='(')//左括号
                                        y->push_back(c);
                             else if( c==')')//右括号,此时需要将已经封闭的括号中的表达式清理
                            {
                                        while(y->size() && (top=y->at(y->size()-1))!='(' )//注意循环的形式
                                       {
                                                     *postfix+=top;
                                                     y->pop_back();
                                        }
                                        if(y->size() && y->at(y->size()-1)=='(')
                                                     y->pop_back();
//检测此时的文法
                                        if(  alpha_symbol)
                                       {
                                                    printf("Syntax error:lack of component operation in column %d for '%c' \n",i,c);
                                                    return   false;
                                        }
                             }
//当前词法单元是否是左括号
                             left_bracket=c=='(';
//当前词法单元是否是正负号
                             alpha_symbol=(c=='+'||c=='-');
               }
//对栈中残留的字符清理
              for(int i=y->size()-1;i>=0;--i )
                            *postfix+=y->at(i); 
//如果正负号不匹配
              if( alpha_symbol)
             {
                           printf("Syntax error: lack of component in column %d for '%c'\n",i,c);
                           return  false;
              }
              return   true;
   }
   int     main(int    argc,char   *argv[])
  {
//注意，生成的后缀表达式中，负号与减号具有相同的优先级,所以在看到的生成的表达式中会出现一些奇怪的东西
//但是这都是正确的
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
                                    printf("元表达式:%s: %s\n",infix[i]->c_str(),postfix.c_str());
                            else
                                    printf("expression %s illegal!\n",infix[i]->c_str());
                             postfix.clear();
              }
              return   0;
   }