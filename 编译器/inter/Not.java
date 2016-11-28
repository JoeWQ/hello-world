/*
  *@aim:取反运算符
  *@date:2015/10/7
  */
  package    inter;
  
  import    lexer.Token;
  import    lexer.Word;
  import    lexer.Type;

  public    class    Not    extends    Logic
 {
//两个表达式共用一个
              public    Not(Expr     expr)
             {
                          super(Word.not,expr,expr);
              }
//简化成常量,如果有可能
              public    Expr       reduceConstant()
             {
                             Expr    _expr=this;
                             if( left instanceof   Not )
                                          _expr=((Not)left).left;
                             if( left   instanceof    Constant  )
                            {
                                          if( left==Constant.True)
                                                    return   Constant.False;
                                          else
                                                    return   Constant.True;
                             }
                             return   _expr;
              }
              public    Expr      reduce()
             {
                             if( left  instanceof   Not   )
                                       return     ((Not)left).left;
//如果对方是布尔常量,则可以肯定必居以下两者其一
                             if( left   instanceof    Constant  )
                            {
                                          if( left==Constant.True)
                                                    return   Constant.False;
                                          else
                                                    return   Constant.True;
                             }
                             return   this;
              }
//生成跳转指令
              public      void     jumping(int     tport,int  fport)
             {
                          this.left.jumping(fport,tport);
              }
              public     String     toString()
             {
                          return     this.tok.toString()+" "+this.left.toString();
              }
  }