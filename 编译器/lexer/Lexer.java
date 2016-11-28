/*
  *@aim:词法单元分析器
  *@date:2015/10/6
  */
  package    lexer;
  import     java.util.TreeMap;
  import     java.util.LinkedList;
  import     java.io.IOException;
  import     tool.FileManager;
  public    class    Lexer
 {
             private       TreeMap<String,Word>       table;
             private        boolean                                 end_point;//是否已经到达终点
             public         static         int           lines=1;//记录当前分析的源程序的行
//为了加快程序的运行而建立的快速合法字符判断表格
             private         static         final        boolean[]          first_char_table;
             private         static         final        boolean[]          second_char_table;
             static
            {
                        first_char_table=new    boolean[256];
                        second_char_table=new    boolean[256];
                        int      i;
//首字母
                        for(i='A';i<='Z';++i)
                       {
                                      first_char_table[i]=true;
                                      second_char_table[i]=true;
                        }
                        for(i='a';i<='z';++i)
                       {
                                      first_char_table[i]=true;
                                      second_char_table[i]=true;
                        }
//第二分量
                        for(i='0';i<='9';++i)
                                     second_char_table[i]=true;
                        first_char_table['_']=true;
                        second_char_table['_']=true;
             }
             private       int               peek;//当前读入的字符
             private       boolean      blank_char_between;
//回溯的时候保存分子的队列,这个数据结构主要用于结构类型的生成,不能用于指针类型
             private       final           LinkedList<Token>     roll_back_list;
             public      Lexer()
            {
                           table=new    TreeMap<String,Word>();
                           lines=1;
                           reserve(new    Word("if",Tag.IF));
                           reserve(new    Word("else",Tag.ELSE));
                           reserve(new   Word("while",Tag.WHILE));
                           reserve(new    Word("do",Tag.DO));
                           reserve(new    Word("break",Tag.BREAK));
                           reserve(new    Word("continue",Tag.CONTINUE));
                           
                           
                           reserve(Word._true);
                           reserve(Word._false);
                           reserve(Type.Int);
                           reserve(Type.Float);
                           reserve(Type.Char);
                           reserve(Type.Bool);
                           reserve(Type.Struct);
                           reserve(Type.Void);
                           reserve(Word._return);
//func不是关键字也不是标识符,只是在编译器中作为一个内部符号使用
                           peek=' ';
                           blank_char_between=false;
                           roll_back_list=new     LinkedList<Token>();
             } 
//回溯,添加到队列的末尾
             public      void          rollBack(Token    tok)
            {
                            roll_back_list.addLast(tok);
             }
//保留字
             public        void        reserve(Word    word)
            {
                           table.put(word.lexeme,word);
             }
             private      void          read_char()throws    IOException
            {
                        if(  !end_point )
                       {
                               peek=FileManager.input.read();
                               if(peek==-1)
                              {
                                       end_point=true;
                                       peek=0;
                                }
                        }
                        else
                               peek=0;
             } 
             private      boolean    read_char(char   _char)throws  IOException
            {
                           if(end_point)
                                        return  false;
                           this.read_char();
                           if(peek != _char)
                                    return     false;
                           peek=' ';
                           return    true;
             }
//返回是否两个分词之间有空白符,这个函数是专门为构造类型中的指针类型准备的
//指针类型必须是类型后面紧跟着*号,否则出错
            public    boolean       isBlankCharBetween()
           {
                           return    blank_char_between;
            }
//获取完整的词法单元
             public        Token         scan()throws  IOException
            {
//如果分词队列不为空
                          if(roll_back_list.size()>0)
                                     return     roll_back_list.removeFirst();
//第一步忽略空白符
                           blank_char_between=false;
                           for(  ;    ; this.read_char())
                          {
                                      if(  peek==' ' || peek=='\t' || peek ==0x0d)
                                     {
                                                    blank_char_between=true;
                                                    continue;
                                      }
                                      else if(peek=='\n' )
                                     {
                                                    Lexer.lines+=1;
                                                    blank_char_between=true;
                                                    continue;
                                      }
                                      else
                                                     break;
                           }
//从第一个非空白符号出发
                           switch(  peek )
                         {
                                         case   '&':
                                                    if(  this.read_char('&') )
                                                                return    Word.and;
                                                    else
                                                                 return    new     Token('&');
                                         case   '|'  :
                                                    if(  this.read_char('|'))
                                                                return    Word.or;
                                                    else
                                                                 return      new    Token('|');
                                        case   '=':
                                                     if(this.read_char('='))
                                                                 return     Word.equal;
                                                     else
                                                                 return     new    Token('=');
                                        case   '>':
                                                      if(this.read_char('='))
                                                                 return    Word.ge;
                                                      else
                                                                 return     new     Token('>');
                                        case    '<':
                                                      if(this.read_char('='))
                                                                 return      Word.le;
                                                      else
                                                                 return      new    Token('<');
                                        case    '!':
                                                     if(this.read_char('='))
                                                                 return     Word.ne;
                                                     else
                                                                 return     new     Token('!');
                                        case    '-':
                                                     if(this.read_char('>'))
                                                                 return     Word.access_struct;
                                                     else
                                                                 return      Word.sub;
                          }
//如果peek是数字
                         int              value=0;
                         if(peek>='0' && peek<='9')
                        {
                                       do
                                      {
                                                    value=value*10+peek-'0';
                                                    this.read_char();
                                       }while(peek>='0' && peek<='9');
//如果是浮点数
                                      if(peek != '.')
                                                 return     new    Num(value);
                                      float         v2=0;
                                      float         d=10;
                                      for(  ;  ;)
                                     {
                                                   this.read_char();
                                                   if( peek>='0' && peek<='9')
                                                  {
                                                                v2=v2+(peek-'0')/d;
                                                                d*=10;
                                                    }
                                                    else
                                                                 break;
                                      }
                                      return     new    Float(value+v2);
                         }
//如果是字母或者下划线
                        if(Lexer.first_char_table[peek])
                       {
                                      StringBuilder   b=new    StringBuilder();
                                      do
                                     {
                                                   b.append((char)peek);
                                                   this.read_char();
                                      }while(Lexer.second_char_table[peek]);
//如果在符号表中查找到了当前符号,直接返回符号表中的对象
                                      String     symbol=b.toString();
                                      Token   tok=table.get(symbol);
                                      if( tok !=null)
                                                   return     tok;
                                      Word w=new   Word(symbol,Tag.ID);
                                      table.put(symbol,w);
                                      return     w;
                        }
//此时返回单个字符
                        Token  tok= new    Token(peek);
                        peek=' ';
                        return    tok;
             }
  }