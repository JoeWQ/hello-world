/*
  *@aim:�ʷ���Ԫ������
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
             private        boolean                                 end_point;//�Ƿ��Ѿ������յ�
             public         static         int           lines=1;//��¼��ǰ������Դ�������
//Ϊ�˼ӿ��������ж������Ŀ��ٺϷ��ַ��жϱ��
             private         static         final        boolean[]          first_char_table;
             private         static         final        boolean[]          second_char_table;
             static
            {
                        first_char_table=new    boolean[256];
                        second_char_table=new    boolean[256];
                        int      i;
//����ĸ
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
//�ڶ�����
                        for(i='0';i<='9';++i)
                                     second_char_table[i]=true;
                        first_char_table['_']=true;
                        second_char_table['_']=true;
             }
             private       int               peek;//��ǰ������ַ�
             private       boolean      blank_char_between;
//���ݵ�ʱ�򱣴���ӵĶ���,������ݽṹ��Ҫ���ڽṹ���͵�����,��������ָ������
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
//func���ǹؼ���Ҳ���Ǳ�ʶ��,ֻ���ڱ���������Ϊһ���ڲ�����ʹ��
                           peek=' ';
                           blank_char_between=false;
                           roll_back_list=new     LinkedList<Token>();
             } 
//����,��ӵ����е�ĩβ
             public      void          rollBack(Token    tok)
            {
                            roll_back_list.addLast(tok);
             }
//������
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
//�����Ƿ������ִ�֮���пհ׷�,���������ר��Ϊ���������е�ָ������׼����
//ָ�����ͱ��������ͺ��������*��,�������
            public    boolean       isBlankCharBetween()
           {
                           return    blank_char_between;
            }
//��ȡ�����Ĵʷ���Ԫ
             public        Token         scan()throws  IOException
            {
//����ִʶ��в�Ϊ��
                          if(roll_back_list.size()>0)
                                     return     roll_back_list.removeFirst();
//��һ�����Կհ׷�
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
//�ӵ�һ���ǿհ׷��ų���
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
//���peek������
                         int              value=0;
                         if(peek>='0' && peek<='9')
                        {
                                       do
                                      {
                                                    value=value*10+peek-'0';
                                                    this.read_char();
                                       }while(peek>='0' && peek<='9');
//����Ǹ�����
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
//�������ĸ�����»���
                        if(Lexer.first_char_table[peek])
                       {
                                      StringBuilder   b=new    StringBuilder();
                                      do
                                     {
                                                   b.append((char)peek);
                                                   this.read_char();
                                      }while(Lexer.second_char_table[peek]);
//����ڷ��ű��в��ҵ��˵�ǰ����,ֱ�ӷ��ط��ű��еĶ���
                                      String     symbol=b.toString();
                                      Token   tok=table.get(symbol);
                                      if( tok !=null)
                                                   return     tok;
                                      Word w=new   Word(symbol,Tag.ID);
                                      table.put(symbol,w);
                                      return     w;
                        }
//��ʱ���ص����ַ�
                        Token  tok= new    Token(peek);
                        peek=' ';
                        return    tok;
             }
  }