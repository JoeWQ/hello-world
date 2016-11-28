/*
  *@aim:�﷨������
  *@date:2015-10-07 12:53:11
  *@date:2015-10-20 11:09:38
  *@date:2015-11-5 11:38:12@aim:���ṹ���ָ���������Ͻ������ĵ���
  */
  package     inter;
  
  import    java.io.IOException;
  import    lexer.Type;
  import    lexer.Token;
  import    lexer.Word;
  import    lexer.Lexer;
  import    lexer.Tag;
  import    lexer.Num;
  import    lexer.Char;
  import    lexer.Float;
  import    lexer.Array;
  import    lexer.Func;
  import    lexer.Pointer;
  import    lexer.FuncPointer;
  import    lexer.Struct;
  import    lexer.Member;
  import    java.util.HashMap;
  import   java.util.ArrayList;
 //�����
  import    symbol.Env;
  
  public    class    Parser
 {
             private        Lexer       lex;
             private        Env          top;
//��ǰ�ʷ���Ԫ
             private        Token      look;
//ƫ��
             private         int          offset;
//ȫ�ֱ�����ƫ�Ƶ�ַ
             private         static     int           globleOffset;
//ȫ�ֺ������ű�,һ���ļ���Ӧһ��
             private         static   HashMap<String,Func>        funcEnv;
             public    Parser(Lexer    _lex)throws IOException
            {
                           this.lex=_lex;
//���������ű�
                           funcEnv=new    HashMap<String,Func>();
                           this.move();
             }
//ȫ�ֱ������ʽ��������
             public    void    move()throws IOException
            {
                           look=lex.scan();
//                           System.out.print("get lexeme:  "+look+"\n");
             }
             public     void      error(String    s)
            {
                           throw   new  Error("\t"+s+" in line "+lex.lines);
             }
//ƥ��
             public    void     match(int   _char)throws  IOException
            {
                           if(look.tag == _char )
                                      move();
                           else
                                      error("Syntax error,wanted char '"+(char)_char+"' ,but real is char '"+look+"");
             }
//���ɳ���
             public    void      program()throws  IOException
            {
                           Expr     x;
//������¼ȫ�ֱ��������ķ��ű�
                           top=new    Env(null);
//����������,��һ�����Ǽ���ֻ�к����Ķ���
                           while(  look.tag==Tag.BASIC  || look.tag==Tag.VOID || look.tag==Tag.STRUCT)
                          {
//����ǽṹ������,�п�����Ҫ����,�������ǽ���ʱ�����з�������Ϊ�ṹ�ĺ��������﷨����
//ֻ�������Ͷ���Ϊ�ṹ�����͵��﷨����
                                     Type     _type=null;
                                     Token   _tok;
                                     if(look.tag==Tag.STRUCT)
                                    {
                                                     _type=(Type)look;
                                                     move();
                                                     if( look.tag != Tag.ID   )
                                                                error("syntax error:struct type want name,but gived is '"+look+"'");
                                                     _tok=look;
                                                     match(Tag.ID);
//�ж������Ͷ��廹�����ͱ�������
                                                     lex.rollBack(_type);
                                                     lex.rollBack(_tok);
                                                     lex.rollBack(look);
                                                     if(look.tag=='{')//��������Ͷ���,���ݲ����ɽṹ������
                                                    {
                                                                  move();
                                                                  this.genStructType();
                                                                  continue;
                                                     }
                                                    move();
                                     }
                                      int     _offset=4;//�������ջ��ƫ��
//����ʱ������ʶ��������
                                      Temp.temp_count=0;
//���ñ�ǩ
                                      Node.labels=0;
                                      _type=this.genTypes();
                                      if( look.tag!=Tag.ID)
                                                error("syntax error,want identifier but gived is:"+look);
                                      Token  tok=look;
                                      move();//�ƶ���������
//��ʱ���˱�ʶ���Ǻ�������һ������
                                      if(look.tag != '(')//��ȫ�ֱ���������
                                     {
                                                     lex.rollBack(tok);
                                                     lex.rollBack(look);//����һ����Ҫ�����Լ��ֹ���look��ֵ,��ʹ�����������Ч
                                                     move();
                                          //           System.out.println("entry look:"+look);
                                                     this.variable_define_globle(_type);
                                                     continue;
                                      }
                                      match('(');
                                      ArrayList<Type>       paramList=null;
                                      ArrayList<String>     paramName=null;
                                      Env     env=null;
//���û���κεĲ���
                                     if(look.tag==')')
                                                     paramList=Func.globalParamList;
                                     else
                                    {
                                                      env=new    Env(top);
                                                      paramList=new   ArrayList<Type>();
                                                      paramName=new   ArrayList<String>();
                                                      int    i;
                                                      for(i=0;look.tag==Tag.BASIC || look.tag==Tag.STRUCT || look.tag==Tag.VOID;++i)
                                                     {
                                                                   Type   p=(Type)this.genTypes3();
                                                                   paramList.add(p);
                                                                   if(look.tag!=Tag.ID)
                                                                             error("syntax error:type define need identifier,but gived is :"+look);
//����ʶ���Ƿ��Ѿ���������
                                                                   if(env.exist_define(look)!=null)
                                                                             error("syntax error:normal params have mutiple defination with "+look);
                                                                   paramName.add(look.toString());
                                                                   Id     d=new    Id((Word)look,p,_offset);
                                                                   if(_offset%p.alignWidth!=0)
                                                                              _offset+=p.alignWidth-_offset%p.alignWidth;
                                                                   _offset+=p.width;
                                                                   env.put(look,d);
                                                                   move();
                                                //����Ƕ��ŷָ���,�������
                                                                   if(look.tag==',')
                                                                             move();
                                                      }
                                     }
                                     match(')');
//������������
                                      Func     func=new   Func(_type,tok.toString(),paramList);
//���뵽ȫ�ֺ������ű���
                                      Parser.funcEnv.put(tok.toString(),func);
                                      Func.Enclosing=func;
//������д������������
                                      Node.emit(func,paramName);
                                      Stamt      stamt=block(env);
                                      int           before=stamt.new_label();
                                      int           after=stamt.new_label();
                                      stamt.emit_label(before);
                                      stamt.gen(after,before);
                                      stamt.emit_label(after);
                                      if( func.returnType!=Type.Void && !func.hasReturnStamt )
                                                   error("syntax error :function "+func+" has return type: "+func.returnType+" but it's body does not has return  stament.");
//Ԥʾ�ź�������ʽ����
                                      Node.emit("\n@end");
                                      Func.Enclosing=Func.Null;
                         }
//������ʱ���������ǿ��ַ�0
                        if(look.tag !=0)
                                   error("syntax error:want file end flag EOF,but gived is: "+look.tag);
//�����ű��˳�,�ڱ�����һ���ļ���ʱ�������½���
                        top=top.prev;
             }
//��Ŀ�ʼ
             public     Stamt       block(Env    _top)throws   IOException
            {
//
                           match('{');  
                           if(_top!=null)
                                    top=_top;
                           else
                                   top=new     Env(top);
//��������
                           decls();
                           Stamt      st=stamts();
                           top=top.prev;
                           match('}');
                           return    st;
             }
//����������
             public      void     decls()throws   IOException
            {
                           while(look.tag==Tag.BASIC || look.tag== Tag.STRUCT || look.tag==Tag.VOID)
                          {
                                        Type                         _type=this.genTypes2();
//�ſ�һ��ֻ������һ������������2015-10-9 14:58:20
                                         Token                       _tok;
                                         boolean                  _first=true;
                                        do
                                       {
//����֮��������ôһ��������Ϊ������Ĵ�����look�Ѿ�ָ����ID,���������ѭ�������ĺ��岻һ��,
                                                     if(  _first  )
                                                              _first=false;
                                                     else
                                                               match(',');
                                                     _tok=look;
                                                     match(Tag.ID);
//����Ƿ��Ѿ�������
                                                      if( top.exist_define(_tok)!=null)
                                                                error("Syntax error,multiple defination with '"+_tok+"'");
                                                     Id    id=new    Id((Word)_tok,_type,offset);
                                                     top.put(_tok,id);
//����û�п��ǵ��ֽڶ�������,���ڽ��˼�������,ע�����ķ�ʽ
                                                     if( offset%_type.alignWidth!=0 )
                                                                    offset+=_type.alignWidth-offset%_type.alignWidth;//������Ҫ���Ŀռ�
                                                     offset+=_type.width;
                                                     _tok=look;
//���Ϊ=��,Ҳ�����и�ֵ������
                                                     if(look.tag=='=')
                                                   {
                                                                move();
                                                                Expr      expr=new    Assign(id,assign());
                                                                expr.gen();
                                                    }

                                        }while(look.tag==',');
                                        match(';');//�ֺŽ���
                           }
             }
//��������,�м�ֻ����ȫ�ֱ�������ʱ�ſ��Ե��ô˺���
             public    void       variable_define_globle(Type    _type)throws  IOException
            {
//�����ж��ǹ������ͻ��ǻ�������
//                           Type                    _type=this.genTypes2();
                           if( _type == Type.Void)
                                         error("syntax error:variable defination cannot be type 'void'");
//�������ﲻ���б����ĳ�ʼ��
                           Token                  _tok=look;
//�Ƿ��ǵ�һ�ν���ѭ��
                            boolean             _first=true;
//��ӡ������
                           StringBuilder        build=new         StringBuilder(_type.toString());
                           build.append("\t\t");
                            do
                            {
                                             if(    _first   )
                                                      _first=false;
                                             else
                                                      match(',');
                                             _tok=look;
                                             match(Tag.ID);
//�������Ƿ��Ѿ��ظ�����
                                             if( top.exist_define(_tok) !=null  )
                                                           error("syntax error:globle  variable '"+_tok+"' is defined mutiply ");
                                             if(Parser.globleOffset%_type.alignWidth !=0 )
                                                      Parser.globleOffset+=_type.alignWidth-Parser.globleOffset%_type.alignWidth;
                                             Id        _id=new     Id((Word)_tok,_type,Parser.globleOffset);
                                             Parser.globleOffset+=_type.width;
                                             top.put(_tok,_id);
                                             build.append("\t").append(_tok).append(",");
//�����ǳ�ʼ������,�Ժ���ʵ��
//@version:ʵ�����ݶ���ʱ��ʼ��
                             }while(look.tag==',');
                             match(';');
                             build.deleteCharAt(build.length()-1);
                             Node.emit_globle(build.toString());
             }
//�ֲ������Ķ���
             private        void             variable_define_local()throws   IOException
            {
            
             }
//�������
             public    Stamt     stamts()throws  IOException
            {
//������,�Զ�����
                          ArrayList<Stamt>        stamt_list=new   ArrayList<Stamt>(16);
//�����û�е���������еľ�ͷ
                          while(look.tag!='}'   )
                         {
                                          Stamt    st=stamt();
                                          stamt_list.add(st);
                          }
                          stamt_list.add(Stamt.Null);
//�����������,����ʽ������������ݹ�
                         int     i;
                         Seq        seq=new    Seq(stamt_list.get(0),Stamt.Null);
                         for( i=1;i<stamt_list.size();++i )
                                       seq=new    Seq(seq,stamt_list.get(i));
                         return    seq;
             } 
//�ֶ����
             public    Stamt        stamt()throws   IOException
            {
                           Expr            x;
                           Stamt          s1,s2;
                           Stamt          savedStamt;
                           switch(look.tag)
                          {
                                          case    ';':
                                                       move();return    Stamt.Null;
                                          case    Tag.IF:
                                                       match(Tag.IF);match('(');  x=assign();   match(')');
                                                       s1=stamt();
                                                       if(look.tag != Tag.ELSE)
                                                                return      new     If(x,s1);
                                                      match(Tag.ELSE);
                                                       s2=stamt(); 
                                                       return    new     Else(x,s1,s2);
                                          case     Tag.WHILE:
                                                       match(Tag.WHILE);match('(');x=assign();match(')');
                                                       savedStamt=Stamt.Enclosing;
                                                       While    node=new   While();
                                                       Stamt.Enclosing=node;
                                                       s1=stamt();
                                                       node.init(x,s1);
                                                       Stamt.Enclosing=savedStamt;
                                                       return    node;
                                          case     Tag.DO:
                                                       savedStamt=Stamt.Enclosing;
                                                       Do     node2=new   Do();
                                                       Stamt.Enclosing=node2;
                                                       match(Tag.DO);
                                                       s1=stamt();
                                                       match(Tag.WHILE);match('(');x=assign();match(')');match(';');
                                                       //System.out.println("-------  "+x);
                                                       node2.init(x,s1);
                                                       Stamt.Enclosing=savedStamt;
                                                       return   node2;
                                           case    Tag.BREAK:
                                                       match(Tag.BREAK);match(';');
                                                       return    new   Break();
                                           case    Tag.CONTINUE:
                                                        match(Tag.CONTINUE);match(';');
                                                        return    new    Continue();
//������return���,return�������ʲô��û����
                                           case     Tag.RETURN:
                                                        match(Tag.RETURN);
                                                        if(  look.tag==';'  )
                                                                   return    new    Return(Void.Null);
                                                        x=assign();match(';');
                                                        return    new  Return(x);
                                           case    '{':
                                                       return     block(null);
//����λ�﷨����
                                         //  case    Tag.ELSE:
                                          //              error("Syntax error,lack of 'if' stament.");
                                          //              break;
                                           default://Ĭ�ϾʹӸ�ֵ��俪ʼ
                                                        return   genStamt();
                           }
                        //   return   null;
             }
//��������װ
             Stamt          genStamt()throws    IOException
            {
                           Expr      x=assign();
//��ʶ�����Ľ���
                           match(';');
                           return     new   Stamt(x);     
             }
//��ֵ���,һ�µĴ��뼸���������Ƶģ���������ȼ���ʼ��������ݹ�
             Expr          assign()throws    IOException
            {
                          Expr     expr=null;
//�����ȼ��踳ֵ����һ������������Ժ�İ汾�����ǽ��˹��ܼ�������
//ʵ�ָ�ֵ���ʽ2015-10-23 12:13:46
                          expr=bool();
                          Expr         x=expr;
//Ϊ��������ֵ����ĵݹ����Զ�����ĸ�ֵ�����
//ʵ���ϳ��������Ⱥŵ����ֻ�����ǣ������ı�ʶ����ֵ,�����м��漰������,�ṹ���Ա�ĸ�ֵ
                          ArrayList<Expr>       assign_list=null;
                          while(look.tag=='=' )
                         {
//����ֵ�Ķ��������һ����ʶ��
                                         move();
                                         if(assign_list ==null)
                                        {
                                                     assign_list=new    ArrayList<Expr>(16);//�Ѿ����������������ĸ�ֵ���
                                                     assign_list.add(x);
                                         }
//���id����һ������
                                         x=bool();
                                         assign_list.add(x);
                          }
//������ֵ���
                          if( assign_list!=null)//size>1
                         {
                                             int          i=assign_list.size()-1;
                                             expr=assign_list.get(i--);
                                             do
                                            { 
                                                          x=assign_list.get(i);
//���������鸳ֵ��ͨ��ֵ
                                                         if( x instanceof   Access )//������������
                                                                       expr=new     AssignArray((Access)x,expr);
                                                         else if(( x instanceof  Id) || (x instanceof  Value))
                                                                       expr=new     Assign(x,expr);
                                                         else if( (x instanceof  AccessStruct) ||(x instanceof AccessStructByPointer)) 
                                                                      expr=new    AssignStruct(x,expr);
                                                         else 
                                                                       error("syntax error: can not assign express '"+expr+"' to a non left-value "+x+"' ");    
                                                         --i;
                                             }while(i>=0);
                          }
                          return    expr;
             }
//�Ӳ�����俪ʼ || 
             Expr         bool()throws  IOException
            {
                          Expr     x=join();
                          while(look.tag== Tag.OR)
                         {
                                     Token    tok=look;
                                      move();
                                      x=new     Or(tok,x,join());
                          }
                          return    x;
             }
             Expr         join()throws  IOException
            {
                          Expr     x=equality();
                          while(look.tag==Tag.AND)
                         {
                                       Token  tok=look;
                                       move();
                                       x=new    And(tok,x,equality());
                          }
                          return  x;
             }
             Expr        equality()throws  IOException
            {
                          Expr      x=rel();
                          while(look.tag == Tag.EQUAL || look.tag==Tag.NE)
                         {
                                       Token  tok=look;
                                       move();
                                       x=new   Rel(tok,x,rel());
                          }
                          return   x;
             }
             Expr        rel()throws  IOException
            {
                          Expr       x=arith1();
                          while(look.tag=='>' || look.tag=='<' || look.tag==Tag.GE || look.tag==Tag.LE)
                         {
                                       Token  tok=look;
                                       move();
                                       x=new    Rel(tok,x,arith1());
                          }
                          return   x;
             }
//��ѧ���ʽ,+-��
             Expr        arith1()throws  IOException
            {
                          Expr       x=arith2();
                          Expr       p;
                          while(look.tag=='+' || look.tag=='-')
                         {
                                        Token    tok=look;
                                        move();
//���ݱ��ʽ�����Ͳ�ͬʹ�ò�ͬ�����ͱ��ʽ
                                       p=arith2();
                                       if( (x.type  instanceof   Pointer) ||  (p.type  instanceof Pointer) || ( x.type instanceof Array)|| (p.type instanceof Array) )
                                      {
                                                     if(tok.tag=='+')
                                                               x=new     PointerAdd(x,p);
                                                     else
                                                               x=new     PointerSub(x,p);
                                       }
                                       else
                                      {
                                                 if( tok.tag=='+')
                                                           x=new     Add(x,p);
                                                 else
                                                           x=new     Sub(x,p);
                                       }
                                        x=x.reduceConstant();
                          }
                          return   x;
             }
//�˷�
             Expr        arith2()throws  IOException
            {
                            Expr      x=unary();
                            while(look.tag=='*' || look.tag=='/' || look.tag=='%')
                           {
                                          Token   tok=look;
                                          move();
                                          Arith        y=null;
                                          if(tok.tag=='*')
                                                    y=new    Mul(x,unary());
                                          else if(tok.tag=='/')
                                                     y=new    Div(x,unary());
                                          else
                                                     y=new    Mod(x,unary());
                                          x=y.reduceConstant();
                            }
                            return   x;
             }
//���������,&*-+!
             Expr       unary()throws  IOException
            {
                            Expr      expr;
                            ArrayList<Token>    tok_list=null;
                            while(look.tag=='-' || look.tag=='!' || look.tag=='&' || look.tag=='*')
                           {
                                         if(tok_list==null)
                                                    tok_list=new    ArrayList<Token>(16);
                                         tok_list.add(look);
                                         move();
                            }
//���,�������ܵĻ�����ʽ
                            if(tok_list!=null)
                           {
                                          expr=value();
                                          int        i=tok_list.size()-1;
                                          for(    ;i>=0;--i)////��һ�ּ�,�Ա��ʽ�ļ��Ѿ���������ص�����,
                                        {
                                                        Token  tok=tok_list.get(i);
                                                        if( tok.tag=='-' )
                                                                     expr=(new   Neg(expr)).reduceConstant();
                                                        else if(tok.tag=='!')
                                                                     expr=(new    Not(expr)).reduceConstant();
                                                        else if(tok.tag=='&')
                                                                      expr=new    Addr(expr);
                                                        else// if(tok.tag=='*')
                                                                     expr=new    Value(expr);
                                                                     
                                         }
                                         return    expr;
                            }
                            return    value();
             }
//ֻ�����������������.�������㽫�ᱻ�ϲ�
            private  Expr             value()throws  IOException
           {
                            Expr        x;
                            Expr        _expr;
                            
                            _expr=factor();
//ָ��ȡ����,���ߵ��ȡ����,�������ǵĳ����趨,�����ÿ��ѭ���лᱻ�����Ķ�η���,����->ÿ��ѭ��
//ֻ�ᱻ����һ��,
//ע��,���ɵĽṹ��������ֻ�ᱻ��Ϊһ����ʶ��ʹ��
                            while( look.tag==Tag.ACCESS_STRUCT  ||  look.tag=='.')
                           {
                                           move();
                                           _expr=this.genAccessStruct(_expr);
                            }
                            return    _expr;
            }
//���ʽ����
             Expr      factor()throws  IOException
            {
                            Expr      x=null;
                            switch(look.tag)
                          {
                                         case   '(':
                                                       move();   
                                    //����Ƿ���ǿ������ת�� 
                                                       if(look.tag==Tag.BASIC || look.tag==Tag.VOID || look.tag==Tag.STRUCT)
                                                      {
                                                                   Type    p=this.genTypes2();
                                                                   match(')');
//ע������ת�������ȼ��Ƚϸ�,ֻ��ת�����������ŵı��������ű��ʽ��������,�������������������ʽ
                                                                   x=unary();
                                                                   return     new    Cast(p,x);
                                                       }
                                                       x=assign();match(')');
                                                      break;
                                         case    Tag.NUM:
                                                       x=new     Constant(((Num)look).value);
                                                       move();
                                                       break;
                                         case    Tag.FLOAT:
                                                       x=new      Constant(((Float)look).value);
                                                       move();
                                                       break;
                                         case    Tag.TRUE:
                                                       x=Constant.True;
                                                       move();
                                                       break;
                                         case      Tag.FALSE:
                                                        x=Constant.False;
                                                        move();
                                                        break;
                                         case      Tag.ID:
                                                        Id           id=top.get(look);
                                                        Token    tok=look;
//����ڱ������ű���û���ҵ�,���߱�ʶ���������һ��������,�Ͳ���ȫ�ֺ������ű�
                                                        if(id ==null )
                                                       {
                                                                   Func      func=Parser.funcEnv.get( look.toString() );
                                                                   if( func==null)
                                                                           error("Syntax error to use undeclare variable "+look);
                                                                   move();
                                                                   return     genCall(func);
                                                        }
                                                        move();
                                                        if( look.tag!='[' )
                                                       {
                                                                   if(look.tag=='(' )
                                                                  {
                                                                                  Func      func=Parser.funcEnv.get( tok.toString() );
                                                                                  if( func==null)
                                                                                          error("Syntax error to use undeclare variable "+look);
                                                                                  return     genCall(func);
                                                                   }
                                                                   return    id;
                                                        }
                                                        else 
                                                                   return    offset(id);
                                          default:
                                                       error("Syntax error,token '"+look+"' can not identify.");
                                                       return   null;
                           }
                           return   x;
             }
//���������ƫ��
             Access        offset(Expr    id)throws  IOException
            {
                           Expr      index;//����
//t2��ʾ�������ʽ,t1��ʾ��λ�ñ����ı��ʽ
                           Expr      t1=null,t2=null;
                           
                           match('[');
                           index=assign();
                           match(']');
//��ȡ���������
//����Ƿ�Ϊ��������
                          if(  ! (id.type instanceof  Array) )
                                       error("normal  variable "+id+" could not be used as a array.");
//id.type����ΪArray,�Ȱ�ȥһ��
                           Type       type=((Array)id.type).type;
//���ͼ��,�������ͱ���������
                          if(index.type!=Type.Int && index.type!=Type.Char)
                                        error("array index type want type 'int' or 'char' ,but gived type is "+index.type);
//��������Ҫ������ֵ,�������ǽ�����һЩ�Ż�,�������ļ���ֱ�ӷŵ��˱���ʱ
                           int              value=0;
                           if( index  instanceof  Constant)
                                         value=((Num)index.tok).value*type.width;
                           else
                                         t1=new   Mul(index,new  Constant(type.width));
                           while(look.tag=='[')
                          {
                                          move();
                                          index=assign();
                                          match(']');
//���ͼ�⣬���ʹ�õ���������������Ķ���ά��
                                          if(  !(type instanceof  Array) )
                                                       error("use  more dimension than  defination for array "+id);
                                          type=((Array)type).type;
//���ͼ��
                                          if( index.type!=Type.Int && index.type!=Type.Char)
                                                       error("array index type want type 'int' or 'char' ,but gived type is "+index.type);
//������Ȼ���б���ʱ�Ż�
                                          int             minor;
                                          if(index instanceof   Constant)
                                         { 
                                                          minor=((Num)index.tok).value*type.width;
//����һ��,��������һ��������������Ժϲ�
                                                           value+=minor;
                                          }
                                          else
                                         {
                                                         t2=new   Constant(type.width);
                                                         t2=new   Mul(index,t2);
                                                         if( t1 != null)
                                                                      t1=new    Add(t1,t2);
                                                          else
                                                                      t1=t2;
                                          }
                           }
//����Ƿ���ȷʹ���������ά��,��ʵ����,��Ϊָ��Ĵ���,�����޷�ȷ���û�����ʹ�����յ�����
//�����㽭������Ϊһ��ָ��ʹ��,������һ�������м��,�������������н���
//                           if( type instanceof  Array  )
//                                        error("use too few  dimension of array "+id);
//���value!=0 һ����˵���б���ʱ��������,����ҲҪ������ʱ����Ϊ0�����
                           if( value!=0 && t1!=null )
                                         t1=new     Add(new  Constant(value),t1);
                           else if( t1==null )
                                         t1=new   Constant(value);
                         //  System.out.println("array type:"+type);
                           return    new   Access(id,t1,type);
               }
//���ɺ�������,
//modify at 2015-11-5 11:43:27
//@aim:�����˽ṹ���ָ��Ĵ���
              Call                  genCall( Func      func   )throws   IOException
             {
                            match('(');
                            Expr         y;
//�������������б�
                            ArrayList<Expr>      param=null;
                            if(look.tag==')')
                                          param=Call.glogalNull;
                            else
                          {
                                          param=new      ArrayList<Expr>();
                                          while(look.tag!=')'  )
                                         {
                                                          y=assign();
                                                          param.add(y);
//����һ�����ж�,��Ϊ���һ������������û�ж��ŵ�
                                                          if( look.tag==')')
                                                                   break;
                                                          match(',');   
                                          }
                           }
                            match(')');
                           return    new     Call(func,param);
              }
//���ɽṹ�����
              public        Struct           genStructType()throws   IOException
             {
                           Struct         struct=null;
                           match(Tag.STRUCT);
                           Token         _tok=look;
                           if(look.tag != Tag.ID )
                                      error("syntax error:after name struct,syntax want  identifier,but gived is : "+look);
//�����������Ƿ��Ѿ���������
                           Type    _type=Type.get_type("struct@"+look);
                           if(  _type !=null )
                                      error("syntax error:struct "+look+" has been defined in line "+((Struct)_type).define_line);
//�����ṹ�����
                          struct=new     Struct(look.toString());
//��ӵ����ͷ��ű���
                          Type.put("struct@"+look.toString(),struct);
//�ƶ����������
                          match(Tag.ID);
                          match('{');
//����ѭ��,���������ֹ涨ÿһ��ֻ����һ������,�Ժ����ǽ�����������
                          while(look.tag==Tag.BASIC || look.tag== Tag.STRUCT || look.tag==Tag.POINTER)
                         {
//����ǻ�������
                                          _type=this.genTypes2();
//����Ƿ��Ǳ�ʶ��
                                          _tok=look;
                                          match(Tag.ID);
                                          struct.addMember(_tok.toString(),_type);
                                          match(';');
                          }
                          match('}');match(';');
                          return     struct;
              }
//��������,�������ɺ����ķ�������
              public         Type            genTypes()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//������
//�ӻ������Ϳ�ʼ
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//����ǽṹ������
                            {
//�����ͱ��в��� 
                                           move();
                                           _tok=look;
                                           if( _tok.tag != Tag.ID)
                                                       error("syntax error:struct want identifier,but gived is '"+_tok+"'");
                                           _type=Type.get_type("struct@"+look);
                                           if(_type == null )
                                                       error("syntax error:struct "+_tok+" was not defined ");
                             }
                             else
                                          error("want   type,unexpect  symbol '"+_tok+"'");
//��һ������Ƿ���ָ������,ע��*�ű����Ǻ�ǩ���������ǽ����ŵ�
                            move();
                            if( look.tag=='*'   )
                           {
//����м��пհ׷�����,��ʱ���͵Ķ����ǲ���ȷ��,��Ҫ�������Ե�ʹ����
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//����ָ������
                                         _type=new    Pointer(_type);
                                         move();
                            }
//�����ж��Ƿ�Ϊ��������
                            _tok=look;
                            if(_tok.tag=='[')
                           {
                                          type_list=new    ArrayList<Num>();
                                          Type                p;
                                          while(look.tag=='[')
                                         {
                                                          move();
                                                          if( look.tag != Tag.NUM  )
                                                                    error("syntax error:array dimision  want  number ,but gived is "+look);
                                                          type_list.add((Num)look);
                                                          move();
                                                          match(']');
                                          }
//�����������
                                          int          i;
                                          p=_type;
                                          for(i=type_list.size()-1;i>=0;--i)
                                                         p=new    Array(type_list.get(i).value,p);
                                          _type=p;
                            }
                            return    _type;
              }
//�������ɱ����������Ͷ���ʱ������
              public         Type            genTypes2()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//������
//�ӻ������Ϳ�ʼ
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//����ǽṹ������
                            {
//�����ͱ��в��� 
                                           move();
                                           _tok=look;
                                           if( look.tag != Tag.ID  )
                                                       error("syntax error:struct want identifier,but gived is '"+look+"' ");
                                           _type=Type.get_type("struct@"+look);
//��������Ƿ��Ѿ�����
                                           if(_type  == null )
                                                      error("syntax error:struct "+_tok+" was not defined ");
                             }
                             else
                                          error("want   type,unexpect  symbol '"+_tok+"'");
//��һ������Ƿ���ָ������,ע��*�ű����Ǻ�ǩ���������ǽ����ŵ�
                            move();
                            if( look.tag=='*'   )
                           {
//����м��пհ׷�����,��ʱ���͵Ķ����ǲ���ȷ��,��Ҫ�������Ե�ʹ����
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//����ָ������
                                         _type=new    Pointer(_type);
                                         move();
                            }
                            else   if(_type==Type.Void)//�����void����,��Ϊ����ȷ�����С,��ʱ��Ҫ����
                                         error("syntax error:type  'void' cannot confirm size in  compile time.");
//�����ж��Ƿ�Ϊ��������
                            _tok=look;
                            if(_tok.tag=='[')
                           {
                                          type_list=new    ArrayList<Num>();
                                          Type                p;
                                          while(look.tag=='[')
                                         {
                                                          move();
                                                          if( look.tag != Tag.NUM  )
                                                                    error("syntax error:array dimision  want  number ,but gived is "+look);
                                                          type_list.add((Num)look);
                                                          move();
                                                          match(']');
                                          }
//�����������
                                          int          i;
                                          p=_type;
                                          for(i=type_list.size()-1;i>=0;--i)
                                                         p=new    Array(type_list.get(i).value,p);
                                          _type=p;
                            }
                            return    _type;
              }
//���������β�����,���ɵ������в���������,ֵ����ָ��,�ṹ��,��������
              public         Type            genTypes3()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//������
//�ӻ������Ϳ�ʼ
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//����ǽṹ������
                            {
//�����ͱ��в��� 
                                           move();
                                           _tok=look;
                                           if( look.tag != Tag.ID  )
                                                       error("syntax error:struct want identifier,but gived is '"+look+"' ");
                                           _type=Type.get_type("struct@"+look);
//��������Ƿ��Ѿ�����
                                           if(_type  == null )
                                                      error("syntax error:struct "+_tok+" was not defined ");
                             }
                             else
                                          error("want   type,unexpect  symbol '"+_tok+"'");
//��һ������Ƿ���ָ������,ע��*�ű����Ǻ�ǩ���������ǽ����ŵ�
                            move();
                            if( look.tag=='*'   )
                           {
//����м��пհ׷�����,��ʱ���͵Ķ����ǲ���ȷ��,��Ҫ�������Ե�ʹ����
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//����ָ������
                                         _type=new    Pointer(_type);
                                         move();
                            }
                            else   if(_type==Type.Void)//�����void����,��Ϊ����ȷ�����С,��ʱ��Ҫ����
                                         error("syntax error:type  'void' cannot confirm size in  compile time.");
//�����ж��Ƿ�Ϊ��������
                            _tok=look;
                            if(_tok.tag=='[')
                           {
                                          type_list=new    ArrayList<Num>();
//�Ƿ��ǵ�һ�ν���
                                          boolean             _first=true;
                                          while(look.tag=='[')
                                         {
                                                          move();
                                                          if( _first )//����ǵ�һ�ν���,������ά���ǿ�ѡ��
                                                         {
                                                                         _first=false;
                                                                         if(  look.tag==']' )
                                                                        {
                                                                                    type_list.add(null);
                                                                                    move();
                                                                                    continue;
                                                                         }
                                                          }
                                                          if( look.tag != Tag.NUM  )
                                                                    error("syntax error:array dimision  want  number ,but gived is "+look);
                                                          type_list.add((Num)look);
                                                          move();
                                                          match(']');
                                          }
//�����������
                                          int          i;
                                          for(i=type_list.size()-1;i>0;--i)
                                                         _type=new    Array(type_list.get(i).value,_type);
                                          
                                          _type=new   Pointer(_type);
                            }
                            return    _type;
              }
//����ָ������,�����Ժ���ʵ��
              public         FuncPointer        genFuncPointer()throws   IOException
             {
                            FuncPointer          pf;
                            Type                       _returnType;
                            ArrayList<Type>  _param_list;
//����Ƿ���void����
                            _returnType=Type.Void;
                            if( look.tag != Tag.VOID  )
                                         _returnType=this.genTypes();
                            _param_list=new     ArrayList<Type>();
//�������β�����
                            return   null;
              }
//���ɷ��ʽṹ����ʽ,�����еĽṹ����ʽ���ʺϲ�Ϊһ��
             private       Expr          genAccessStruct(Expr    _expr)throws   IOException
            {
                            Expr                        _access=null;
                            Struct                     _struct=null;
                            Type                       _type;
//_expr����Ϊid������Ϊ���Բ����ṹ��ָ�����͵ı��ʽ
                            if(   _expr.type    instanceof    Struct  )
                                               _struct=(Struct)_expr.type;
                            else if((_expr.type instanceof  Pointer) &&(    ((Pointer)_expr.type).type  instanceof  Struct )  )
                                               _struct=(Struct) ((Pointer) _expr.type).type;
                            if( _struct ==null  )
                                         error("syntax error:connot apply '->' operator to non struct  type :"+_expr.type);
//��ʼѰַ,����Ѱַ���������м�һֱ�е��.
                            int                 index=0;
                            Expr              _index=null;
                            Member        _mem=null;
                            Array             _array=null;
//��ǰ�Ѿ�Խ���˵��.����->,�Ѿ���λ����ʶ��
                            Token    tok=null;
                            int            offset_value=0;
//��һ�γ�Ա���ͻ�ȡ��Ҫ��_struct�л�ȡ
                            boolean             first=true;
                            do
                           {
                                          if( !first    )
                                                    match('.');
                                          tok=look;
                                          match(Tag.ID);
//��ȡ�ó�Ա����Ϣ
                                          if(first  )
                                                        first=false;
                                          else
                                         {
//���ͼ��,��ֹ���ò��ǽṹ�������
                                                        _struct=null;
                                                        if(_mem.type  instanceof Struct )
                                                                         _struct=(Struct)_mem.type;
                                                        else if( _mem.type instanceof   Array)//���������,�����������Ͳ���������
                                                       {
                                                                         _array=(Array)_mem.type;
                                                                         while(_array.type instanceof  Array)
                                                                                      _array=(Array)_array.type;
                                                                         if( !(_array.type  instanceof  Struct) )
                                                                                     error("syntax error,type '"+_array.type+"' is not a struct");
                                                                         _struct=(Struct)_array.type;
                                                        }
                                                        else
                                                                     error("syntax error,type '"+_mem.type+"' is not a struct");
                                          }
                                          _mem=_struct.getMember(tok.toString());
//���ṹ�����Ƿ����������
                                          if(_mem == null )
                                                       error("syntax error,struct "+_struct.struct_name+" does not have member '"+tok.toString()+"'");
                                          _type=_mem.type;
//��ƫ���ۼ�
                                          index+=_mem.offset;
//����Ƿ��������ŷ���,�����������,���������ڵ����ݶ������Ƿ�Ҫ����ֱ��Ѱַ
                                          if(look.tag=='[' )
                                         {
                                                       if(_expr.type   instanceof   Pointer)
                                                                     _access=new    AccessStructByPointer(_expr,new  Constant(index),_type);
                                                       else
                                                                    _access=new     AccessStruct(_expr,new  Constant(index),_type);
                                                       Access     access_array=offset(_access);
//���ᵽ��ײ�����
                                                       _type=access_array.type;
//�жϷ�������ĸ�������
                                                       if(access_array.index  instanceof  Constant )
                                                     {
                                                                     Constant      param=(Constant)access_array.index;
                                                                     if(access_array.index.type ==Type.Int)
                                                                                   offset_value=((Num)param.tok).value;
                                                                      else
                                                                                   offset_value=((Char)param.tok).value;
                                                                      index+=offset_value;
                                                      }
//������ǳ��������������,��Ҫ�ع��ṹ�����,��Ϊ��ʱ��ȷ���������Ľṹ��ƫ��
                                                      else
                                                     {
                                                                      if(_index != null)
                                                                                 _index=new    Add(_index,access_array.index);
                                                                      else
                                                                                 _index=access_array.index;
                                                      }
                                          }
                            }while(look.tag=='.');
//���������������
//����������Ľ����ӵ���Ҫ���ɵĶ�����
                           if(index>0 && _index !=null )
                                          _index=new      Add(new   Constant(index),_index);
                           else if( _index == null )
                                          _index=new  Constant(index);
                      //      System.out.println("index:"+index+"  _index:"+_index);
                           if( _expr.type  instanceof   Pointer)
                                       _access=new    AccessStructByPointer(_expr,_index,_type);
                           else
                                       _access=  new    AccessStruct(_expr,  _index,_type);
                            return   _access;
             }
  }