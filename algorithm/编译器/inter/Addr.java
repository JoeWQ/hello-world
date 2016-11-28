/*
  *@aim:取地址运算符
  *@date:2015-10-28 11:36:56
  *@author:狄建彬
  *@date:2015-11-6 15:12:29
  *@aim:对由数组算术运算和指针算术运算所产生的表达式进行了语法分析
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Pointer;
  import    lexer.Word;
  public      class    Addr    extends    Op
 {
             public       Expr        expr;
             public       Addr(Expr     _expr)
            {
                            super(Word.addr,_expr.type);
//检测取地址运算符的目标类型,必须是标识符,或者可以生成标识符的对象
                           if( !(_expr   instanceof    Id)  && !( _expr instanceof Access) && !(_expr instanceof AccessStruct) && !(_expr instanceof AccessStructByPointer) && !(_expr  instanceof  Value))
                                        error("syntax error:'&' operator can only operate identifier or array or struct member  variable,but gived is :"+_expr);
                           this.expr=_expr;
                           this.type=new      Pointer(_expr.type);
             }
//生成右侧代码
             public      Expr      gen()
            {
//如果目标是取内容表达式
 //                         System.out.println("Addr gen():"+expr);
                          if( expr  instanceof   Value)
                                     return    ((Value)expr).expr.gen();
                          else
                                    expr=expr.gen();
                          return   this;
             }
//规约为单一的变量
            public     Expr       reduce()
           {
//注意我们的约定规则,每一种构造类型在全局内只能有一个对象
                         Temp       t=new     Temp(new    Pointer(expr.type));
                         Expr         _expr=null;
                         if(  expr   instanceof   Value )
                                         _expr=((Value)expr).expr.reduce();
                         else
                                        _expr=expr.reduce();
                         emit(t.type+"\t"+t+"="+_expr);
                         return    t;
            }
            public    String    toString()
           {
                         return     "&"+expr;
            }
  }