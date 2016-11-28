/*
  *@aim:单目运算符取负，取正
  *@date:2015/10/6
  */
  package    inter;
  import      lexer.Token;
  import      lexer.Word;
  import      lexer.Type;
  
  public    class    Unary   extends    Op
 {
//目标表达式
            Expr           expr;
            
            public       Unary(Token  tok,Expr    _expr)
           {
                          super(tok,null);
                          this.expr=_expr;
                          this.type=Type.maxType(Type.Int,_expr.type);
                          if(type ==null)
                                    error("syntax error,caused by no matched type in Unary.");
            }
//生成三地址代码
            public       Expr        gen()
           {
                          return      new    Unary(Word.neg,expr.reduce());
            }
            public      String      toString()
           {
                         return      this.tok+" "+this.expr;
            }
  }