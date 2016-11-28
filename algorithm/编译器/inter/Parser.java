/*
  *@aim:语法分析器
  *@date:2015-10-07 12:53:11
  *@date:2015-10-20 11:09:38
  *@date:2015-11-5 11:38:12@aim:将结构体和指针类型整合进函数的调用
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
 //运算符
  import    symbol.Env;
  
  public    class    Parser
 {
             private        Lexer       lex;
             private        Env          top;
//当前词法单元
             private        Token      look;
//偏移
             private         int          offset;
//全局变量的偏移地址
             private         static     int           globleOffset;
//全局函数符号表,一个文件对应一个
             private         static   HashMap<String,Func>        funcEnv;
             public    Parser(Lexer    _lex)throws IOException
            {
                           this.lex=_lex;
//窗函数符号表
                           funcEnv=new    HashMap<String,Func>();
                           this.move();
             }
//全局变量表达式代码生成
             public    void    move()throws IOException
            {
                           look=lex.scan();
//                           System.out.print("get lexeme:  "+look+"\n");
             }
             public     void      error(String    s)
            {
                           throw   new  Error("\t"+s+" in line "+lex.lines);
             }
//匹配
             public    void     match(int   _char)throws  IOException
            {
                           if(look.tag == _char )
                                      move();
                           else
                                      error("Syntax error,wanted char '"+(char)_char+"' ,but real is char '"+look+"");
             }
//生成程序
             public    void      program()throws  IOException
            {
                           Expr     x;
//用来记录全局变量声明的符号表
                           top=new    Env(null);
//函数的声明,这一版我们假设只有函数的定义
                           while(  look.tag==Tag.BASIC  || look.tag==Tag.VOID || look.tag==Tag.STRUCT)
                          {
//如果是结构体类型,有可能需要回溯,这里我们将暂时不进行返回类型为结构的函数进行语法分析
//只进行类型定义为结构体类型的语法分析
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
//判断是类型定义还是类型变量定义
                                                     lex.rollBack(_type);
                                                     lex.rollBack(_tok);
                                                     lex.rollBack(look);
                                                     if(look.tag=='{')//如果是类型定义,回溯并生成结构体类型
                                                    {
                                                                  move();
                                                                  this.genStructType();
                                                                  continue;
                                                     }
                                                    move();
                                     }
                                      int     _offset=4;//函数外堆栈的偏移
//将临时变量标识计数重置
                                      Temp.temp_count=0;
//重置标签
                                      Node.labels=0;
                                      _type=this.genTypes();
                                      if( look.tag!=Tag.ID)
                                                error("syntax error,want identifier but gived is:"+look);
                                      Token  tok=look;
                                      move();//移动到左括号
//此时检测此标识符是函数还是一个函数
                                      if(look.tag != '(')//是全局变量的声明
                                     {
                                                     lex.rollBack(tok);
                                                     lex.rollBack(look);//程序一定不要尝试自己手工给look赋值,即使这样程序更高效
                                                     move();
                                          //           System.out.println("entry look:"+look);
                                                     this.variable_define_globle(_type);
                                                     continue;
                                      }
                                      match('(');
                                      ArrayList<Type>       paramList=null;
                                      ArrayList<String>     paramName=null;
                                      Env     env=null;
//如果没有任何的参数
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
//检测标识符是否已经被定义了
                                                                   if(env.exist_define(look)!=null)
                                                                             error("syntax error:normal params have mutiple defination with "+look);
                                                                   paramName.add(look.toString());
                                                                   Id     d=new    Id((Word)look,p,_offset);
                                                                   if(_offset%p.alignWidth!=0)
                                                                              _offset+=p.alignWidth-_offset%p.alignWidth;
                                                                   _offset+=p.width;
                                                                   env.put(look,d);
                                                                   move();
                                                //如果是逗号分隔符,否就跳离
                                                                   if(look.tag==',')
                                                                             move();
                                                      }
                                     }
                                     match(')');
//创建函数对象
                                      Func     func=new   Func(_type,tok.toString(),paramList);
//加入到全局函数符号表中
                                      Parser.funcEnv.put(tok.toString(),func);
                                      Func.Enclosing=func;
//在首行写出函数的名字
                                      Node.emit(func,paramName);
                                      Stamt      stamt=block(env);
                                      int           before=stamt.new_label();
                                      int           after=stamt.new_label();
                                      stamt.emit_label(before);
                                      stamt.gen(after,before);
                                      stamt.emit_label(after);
                                      if( func.returnType!=Type.Void && !func.hasReturnStamt )
                                                   error("syntax error :function "+func+" has return type: "+func.returnType+" but it's body does not has return  stament.");
//预示着函数的正式结束
                                      Node.emit("\n@end");
                                      Func.Enclosing=Func.Null;
                         }
//结束的时候期望的是空字符0
                        if(look.tag !=0)
                                   error("syntax error:want file end flag EOF,but gived is: "+look.tag);
//将符号表退出,在编译下一个文件的时候再重新建立
                        top=top.prev;
             }
//块的开始
             public     Stamt       block(Env    _top)throws   IOException
            {
//
                           match('{');  
                           if(_top!=null)
                                    top=_top;
                           else
                                   top=new     Env(top);
//查找声明
                           decls();
                           Stamt      st=stamts();
                           top=top.prev;
                           match('}');
                           return    st;
             }
//变量的声明
             public      void     decls()throws   IOException
            {
                           while(look.tag==Tag.BASIC || look.tag== Tag.STRUCT || look.tag==Tag.VOID)
                          {
                                        Type                         _type=this.genTypes2();
//放开一次只能声明一个变量的限制2015-10-9 14:58:20
                                         Token                       _tok;
                                         boolean                  _first=true;
                                        do
                                       {
//这里之所以有这么一步，是因为在上面的代码中look已经指向了ID,因而导致了循环体代码的含义不一致,
                                                     if(  _first  )
                                                              _first=false;
                                                     else
                                                               match(',');
                                                     _tok=look;
                                                     match(Tag.ID);
//检测是否已经定义了
                                                      if( top.exist_define(_tok)!=null)
                                                                error("Syntax error,multiple defination with '"+_tok+"'");
                                                     Id    id=new    Id((Word)_tok,_type,offset);
                                                     top.put(_tok,id);
//这里没有考虑到字节对齐的情况,现在将此计算在内,注意计算的方式
                                                     if( offset%_type.alignWidth!=0 )
                                                                    offset+=_type.alignWidth-offset%_type.alignWidth;//加上需要填充的空间
                                                     offset+=_type.width;
                                                     _tok=look;
//如果为=号,也就是有赋值语句存在
                                                     if(look.tag=='=')
                                                   {
                                                                move();
                                                                Expr      expr=new    Assign(id,assign());
                                                                expr.gen();
                                                    }

                                        }while(look.tag==',');
                                        match(';');//分号结束
                           }
             }
//变量定义,切记只有在全局变量定义时才可以调用此函数
             public    void       variable_define_globle(Type    _type)throws  IOException
            {
//不能判定是构造类型还是基本类型
//                           Type                    _type=this.genTypes2();
                           if( _type == Type.Void)
                                         error("syntax error:variable defination cannot be type 'void'");
//假设这里不进行变量的初始化
                           Token                  _tok=look;
//是否是第一次进入循环
                            boolean             _first=true;
//打印出变量
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
//检测变量是否已经重复定义
                                             if( top.exist_define(_tok) !=null  )
                                                           error("syntax error:globle  variable '"+_tok+"' is defined mutiply ");
                                             if(Parser.globleOffset%_type.alignWidth !=0 )
                                                      Parser.globleOffset+=_type.alignWidth-Parser.globleOffset%_type.alignWidth;
                                             Id        _id=new     Id((Word)_tok,_type,Parser.globleOffset);
                                             Parser.globleOffset+=_type.width;
                                             top.put(_tok,_id);
                                             build.append("\t").append(_tok).append(",");
//以下是初始化部分,以后再实现
//@version:实现数据定义时初始化
                             }while(look.tag==',');
                             match(';');
                             build.deleteCharAt(build.length()-1);
                             Node.emit_globle(build.toString());
             }
//局部变量的定义
             private        void             variable_define_local()throws   IOException
            {
            
             }
//整理语句
             public    Stamt     stamts()throws  IOException
            {
//语句队列,自顶向下
                          ArrayList<Stamt>        stamt_list=new   ArrayList<Stamt>(16);
//如果还没有到达语句序列的尽头
                          while(look.tag!='}'   )
                         {
                                          Stamt    st=stamt();
                                          stamt_list.add(st);
                          }
                          stamt_list.add(Stamt.Null);
//创建语句序列,在形式上是消除了左递归
                         int     i;
                         Seq        seq=new    Seq(stamt_list.get(0),Stamt.Null);
                         for( i=1;i<stamt_list.size();++i )
                                       seq=new    Seq(seq,stamt_list.get(i));
                         return    seq;
             } 
//分段语句
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
//加上了return语句,return右面可能什么都没有用
                                           case     Tag.RETURN:
                                                        match(Tag.RETURN);
                                                        if(  look.tag==';'  )
                                                                   return    new    Return(Void.Null);
                                                        x=assign();match(';');
                                                        return    new  Return(x);
                                           case    '{':
                                                       return     block(null);
//以下位语法错误
                                         //  case    Tag.ELSE:
                                          //              error("Syntax error,lack of 'if' stament.");
                                          //              break;
                                           default://默认就从赋值语句开始
                                                        return   genStamt();
                           }
                        //   return   null;
             }
//生成语句封装
             Stamt          genStamt()throws    IOException
            {
                           Expr      x=assign();
//标识着语句的结束
                           match(';');
                           return     new   Stamt(x);     
             }
//赋值语句,一下的代码几乎都是相似的，从最低优先级开始逐步消除左递归
             Expr          assign()throws    IOException
            {
                          Expr     expr=null;
//这里先假设赋值不是一种运算符，在稍后的版本中我们将此功能加入其中
//实现赋值表达式2015-10-23 12:13:46
                          expr=bool();
                          Expr         x=expr;
//为了消除赋值运算的递归特性而引入的赋值语句链
//实际上出现连续等号的情况只可能是，连续的标识符赋值,或者中间涉及到数组,结构体成员的赋值
                          ArrayList<Expr>       assign_list=null;
                          while(look.tag=='=' )
                         {
//被赋值的对象必须是一个标识符
                                         move();
                                         if(assign_list ==null)
                                        {
                                                     assign_list=new    ArrayList<Expr>(16);//已经可以满足绝大多数的赋值语句
                                                     assign_list.add(x);
                                         }
//如果id不是一个数组
                                         x=bool();
                                         assign_list.add(x);
                          }
//创建赋值语句
                          if( assign_list!=null)//size>1
                         {
                                             int          i=assign_list.size()-1;
                                             expr=assign_list.get(i--);
                                             do
                                            { 
                                                          x=assign_list.get(i);
//必须是数组赋值普通赋值
                                                         if( x instanceof   Access )//如果是数组访问
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
//从布尔语句开始 || 
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
//数学表达式,+-法
             Expr        arith1()throws  IOException
            {
                          Expr       x=arith2();
                          Expr       p;
                          while(look.tag=='+' || look.tag=='-')
                         {
                                        Token    tok=look;
                                        move();
//依据表达式的类型不同使用不同的类型表达式
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
//乘法
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
//左结合运算符,&*-+!
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
//检测,并尽可能的化简表达式
                            if(tok_list!=null)
                           {
                                          expr=value();
                                          int        i=tok_list.size()-1;
                                          for(    ;i>=0;--i)////另一种简化,对表达式的简化已经包含在相关的类中,
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
//只有两种运算符连续的.符号运算将会被合并
            private  Expr             value()throws  IOException
           {
                            Expr        x;
                            Expr        _expr;
                            
                            _expr=factor();
//指针取内容,或者点号取内容,依据我们的程序设定,点号在每轮循环中会被连续的多次分析,但是->每轮循环
//只会被分析一次,
//注意,生成的结构在整体上只会被作为一个标识符使用
                            while( look.tag==Tag.ACCESS_STRUCT  ||  look.tag=='.')
                           {
                                           move();
                                           _expr=this.genAccessStruct(_expr);
                            }
                            return    _expr;
            }
//表达式因子
             Expr      factor()throws  IOException
            {
                            Expr      x=null;
                            switch(look.tag)
                          {
                                         case   '(':
                                                       move();   
                                    //检测是否是强制类型转换 
                                                       if(look.tag==Tag.BASIC || look.tag==Tag.VOID || look.tag==Tag.STRUCT)
                                                      {
                                                                   Type    p=this.genTypes2();
                                                                   match(')');
//注意类型转换的优先级比较高,只会转换和它紧挨着的变量和括号表达式或函数调用,而不会作用于整个表达式
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
//如果在变量符号表中没有找到,或者标识符后面跟着一个左括号,就查找全局函数符号表
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
//计算数组的偏移
             Access        offset(Expr    id)throws  IOException
            {
                           Expr      index;//索引
//t2表示常量表达式,t1表示有位置变量的表达式
                           Expr      t1=null,t2=null;
                           
                           match('[');
                           index=assign();
                           match(']');
//获取数组的类型
//检测是否为数组类型
                          if(  ! (id.type instanceof  Array) )
                                       error("normal  variable "+id+" could not be used as a array.");
//id.type类型为Array,先剥去一重
                           Type       type=((Array)id.type).type;
//类型检测,索引类型必须是整数
                          if(index.type!=Type.Int && index.type!=Type.Char)
                                        error("array index type want type 'int' or 'char' ,but gived type is "+index.type);
//计算所需要索引的值,这里我们进行了一些优化,将常数的计算直接放到了编译时
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
//类型检测，如果使用的重数超过了数组的定义维数
                                          if(  !(type instanceof  Array) )
                                                       error("use  more dimension than  defination for array "+id);
                                          type=((Array)type).type;
//类型检查
                                          if( index.type!=Type.Int && index.type!=Type.Char)
                                                       error("array index type want type 'int' or 'char' ,but gived type is "+index.type);
//这里依然进行编译时优化
                                          int             minor;
                                          if(index instanceof   Constant)
                                         { 
                                                          minor=((Num)index.tok).value*type.width;
//更进一步,如果上面的一步是整数，则可以合并
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
//检测是否正确使用了数组的维数,在实际中,因为指针的存在,所以无法确定用户是想使用最终的数字
//还是香江数组作为一个指针使用,所以这一步不进行检测,而留待个各类中进行
//                           if( type instanceof  Array  )
//                                        error("use too few  dimension of array "+id);
//如果value!=0 一定能说明有编译时常量存在,但是也要考虑有时索引为0的情况
                           if( value!=0 && t1!=null )
                                         t1=new     Add(new  Constant(value),t1);
                           else if( t1==null )
                                         t1=new   Constant(value);
                         //  System.out.println("array type:"+type);
                           return    new   Access(id,t1,type);
               }
//生成函数调用,
//modify at 2015-11-5 11:43:27
//@aim:加入了结构体和指针的传入
              Call                  genCall( Func      func   )throws   IOException
             {
                            match('(');
                            Expr         y;
//创建函数参数列表
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
//在这一步做判断,因为最后一个参数后面是没有逗号的
                                                          if( look.tag==')')
                                                                   break;
                                                          match(',');   
                                          }
                           }
                            match(')');
                           return    new     Call(func,param);
              }
//生成结构体对象
              public        Struct           genStructType()throws   IOException
             {
                           Struct         struct=null;
                           match(Tag.STRUCT);
                           Token         _tok=look;
                           if(look.tag != Tag.ID )
                                      error("syntax error:after name struct,syntax want  identifier,but gived is : "+look);
//检查这个名字是否已经被定义了
                           Type    _type=Type.get_type("struct@"+look);
                           if(  _type !=null )
                                      error("syntax error:struct "+look+" has been defined in line "+((Struct)_type).define_line);
//创建结构体对象
                          struct=new     Struct(look.toString());
//添加到类型符号表中
                          Type.put("struct@"+look.toString(),struct);
//移动到左大括号
                          match(Tag.ID);
                          match('{');
//进入循环,这里我们现规定每一行只能有一个声明,稍后我们将解除这个限制
                          while(look.tag==Tag.BASIC || look.tag== Tag.STRUCT || look.tag==Tag.POINTER)
                         {
//如果是基本类型
                                          _type=this.genTypes2();
//检查是否是标识符
                                          _tok=look;
                                          match(Tag.ID);
                                          struct.addMember(_tok.toString(),_type);
                                          match(';');
                          }
                          match('}');match(';');
                          return     struct;
              }
//生成类型,用于生成函数的返回类型
              public         Type            genTypes()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//类型链
//从基本类型开始
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//如果是结构体类型
                            {
//从类型表中查找 
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
//进一步检查是否是指针类型,注意*号必须是和签名的类型是紧挨着的
                            move();
                            if( look.tag=='*'   )
                           {
//如果中间有空白符介入,此时类型的定义是不正确的,需要提醒语言的使用者
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//创建指针类型
                                         _type=new    Pointer(_type);
                                         move();
                            }
//接着判断是否为数组类型
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
//生成数组对象
                                          int          i;
                                          p=_type;
                                          for(i=type_list.size()-1;i>=0;--i)
                                                         p=new    Array(type_list.get(i).value,p);
                                          _type=p;
                            }
                            return    _type;
              }
//用于生成变量被声明和定义时的类型
              public         Type            genTypes2()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//类型链
//从基本类型开始
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//如果是结构体类型
                            {
//从类型表中查找 
                                           move();
                                           _tok=look;
                                           if( look.tag != Tag.ID  )
                                                       error("syntax error:struct want identifier,but gived is '"+look+"' ");
                                           _type=Type.get_type("struct@"+look);
//检测类型是否已经定义
                                           if(_type  == null )
                                                      error("syntax error:struct "+_tok+" was not defined ");
                             }
                             else
                                          error("want   type,unexpect  symbol '"+_tok+"'");
//进一步检查是否是指针类型,注意*号必须是和签名的类型是紧挨着的
                            move();
                            if( look.tag=='*'   )
                           {
//如果中间有空白符介入,此时类型的定义是不正确的,需要提醒语言的使用者
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//创建指针类型
                                         _type=new    Pointer(_type);
                                         move();
                            }
                            else   if(_type==Type.Void)//如果是void类型,因为不能确定其大小,此时就要报错
                                         error("syntax error:type  'void' cannot confirm size in  compile time.");
//接着判断是否为数组类型
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
//生成数组对象
                                          int          i;
                                          p=_type;
                                          for(i=type_list.size()-1;i>=0;--i)
                                                         p=new    Array(type_list.get(i).value,p);
                                          _type=p;
                            }
                            return    _type;
              }
//用于生成形参类型,生成的类型中不会有数组,值会有指针,结构体,基本类型
              public         Type            genTypes3()throws   IOException
             {
                             ArrayList<Num>          type_list=null;//类型链
//从基本类型开始
                             Token          _tok=look;
                             Type            _type=null;
                             if(_tok.tag==Tag.BASIC || _tok.tag==Tag.VOID)
                                            _type=(Type)look;
                             else if( _tok.tag==Tag.STRUCT )//如果是结构体类型
                            {
//从类型表中查找 
                                           move();
                                           _tok=look;
                                           if( look.tag != Tag.ID  )
                                                       error("syntax error:struct want identifier,but gived is '"+look+"' ");
                                           _type=Type.get_type("struct@"+look);
//检测类型是否已经定义
                                           if(_type  == null )
                                                      error("syntax error:struct "+_tok+" was not defined ");
                             }
                             else
                                          error("want   type,unexpect  symbol '"+_tok+"'");
//进一步检查是否是指针类型,注意*号必须是和签名的类型是紧挨着的
                            move();
                            if( look.tag=='*'   )
                           {
//如果中间有空白符介入,此时类型的定义是不正确的,需要提醒语言的使用者
                                         if( lex.isBlankCharBetween())
                                                    error("type defination error,with pointer type,'*' must be next to type "+_type+" without blank char.");
//创建指针类型
                                         _type=new    Pointer(_type);
                                         move();
                            }
                            else   if(_type==Type.Void)//如果是void类型,因为不能确定其大小,此时就要报错
                                         error("syntax error:type  'void' cannot confirm size in  compile time.");
//接着判断是否为数组类型
                            _tok=look;
                            if(_tok.tag=='[')
                           {
                                          type_list=new    ArrayList<Num>();
//是否是第一次进入
                                          boolean             _first=true;
                                          while(look.tag=='[')
                                         {
                                                          move();
                                                          if( _first )//如果是第一次进入,最左侧的维数是可选的
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
//生成数组对象
                                          int          i;
                                          for(i=type_list.size()-1;i>0;--i)
                                                         _type=new    Array(type_list.get(i).value,_type);
                                          
                                          _type=new   Pointer(_type);
                            }
                            return    _type;
              }
//函数指针类型,留待以后再实现
              public         FuncPointer        genFuncPointer()throws   IOException
             {
                            FuncPointer          pf;
                            Type                       _returnType;
                            ArrayList<Type>  _param_list;
//检测是否是void类型
                            _returnType=Type.Void;
                            if( look.tag != Tag.VOID  )
                                         _returnType=this.genTypes();
                            _param_list=new     ArrayList<Type>();
//函数的形参类型
                            return   null;
              }
//生成访问结构体表达式,将所有的结构体链式访问合并为一步
             private       Expr          genAccessStruct(Expr    _expr)throws   IOException
            {
                            Expr                        _access=null;
                            Struct                     _struct=null;
                            Type                       _type;
//_expr或者为id，或者为可以产生结构体指针类型的表达式
                            if(   _expr.type    instanceof    Struct  )
                                               _struct=(Struct)_expr.type;
                            else if((_expr.type instanceof  Pointer) &&(    ((Pointer)_expr.type).type  instanceof  Struct )  )
                                               _struct=(Struct) ((Pointer) _expr.type).type;
                            if( _struct ==null  )
                                         error("syntax error:connot apply '->' operator to non struct  type :"+_expr.type);
//开始寻址,连续寻址的条件是中间一直有点号.
                            int                 index=0;
                            Expr              _index=null;
                            Member        _mem=null;
                            Array             _array=null;
//当前已经越过了点号.或者->,已经定位到标识符
                            Token    tok=null;
                            int            offset_value=0;
//第一次成员类型获取需要从_struct中获取
                            boolean             first=true;
                            do
                           {
                                          if( !first    )
                                                    match('.');
                                          tok=look;
                                          match(Tag.ID);
//获取该成员的信息
                                          if(first  )
                                                        first=false;
                                          else
                                         {
//类型检查,防止引用不是结构体的类型
                                                        _struct=null;
                                                        if(_mem.type  instanceof Struct )
                                                                         _struct=(Struct)_mem.type;
                                                        else if( _mem.type instanceof   Array)//如果是数组,查找数组的最低层数据类型
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
//检查结构体内是否有这个数据
                                          if(_mem == null )
                                                       error("syntax error,struct "+_struct.struct_name+" does not have member '"+tok.toString()+"'");
                                          _type=_mem.type;
//将偏移累加
                                          index+=_mem.offset;
//检测是否是中括号分量,如果是中括号,依据括号内的内容而决定是否要采用直接寻址
                                          if(look.tag=='[' )
                                         {
                                                       if(_expr.type   instanceof   Pointer)
                                                                     _access=new    AccessStructByPointer(_expr,new  Constant(index),_type);
                                                       else
                                                                    _access=new     AccessStruct(_expr,new  Constant(index),_type);
                                                       Access     access_array=offset(_access);
//剥夺到最底层类型
                                                       _type=access_array.type;
//判断访问数组的各个分量
                                                       if(access_array.index  instanceof  Constant )
                                                     {
                                                                     Constant      param=(Constant)access_array.index;
                                                                     if(access_array.index.type ==Type.Int)
                                                                                   offset_value=((Num)param.tok).value;
                                                                      else
                                                                                   offset_value=((Char)param.tok).value;
                                                                      index+=offset_value;
                                                      }
//如果不是常数数组分量索引,需要重构结构体访问,因为此时不确定接下来的结构内偏移
                                                      else
                                                     {
                                                                      if(_index != null)
                                                                                 _index=new    Add(_index,access_array.index);
                                                                      else
                                                                                 _index=access_array.index;
                                                      }
                                          }
                            }while(look.tag=='.');
//如果遇到了中括号
//将计算出来的结果添加到将要生成的对象中
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