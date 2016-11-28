/*
  *@aim:循环语句
  *@date:2015/10/7
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  //在本例中，我们不会将while语句转换为do-while语句，这个功能将留待下一个版本实现
  public    class    While    extends    Stamt
 {
              private      Expr       expr;
              private      Stamt     stamt;
              
              public    While()
             {
              }
              public    void    init(Expr    _expr,Stamt   _stamt)
             {
                            this.expr=_expr;
                            this.stamt=_stamt;
                            if(_expr.type != Type.Bool)
                                      error("syntax error in  while express caused by no matched component,require boolean,but "+_expr.type);
              }
//生成代码,将while循环转换成do-while循环
              public    void     gen(int   _after,int   _before)
             {
//记录下语句的后继和前驱,注意生成的前驱
                             int    label=new_label();
                             int    label2=new_label();
                             this.after=_after;
                             this.before=label2;
//跳转到末尾
                             expr.jumping(0,_after);
//语句的开始
                             emit_label(label);
                             stamt.gen(label2,label);
                             emit_label(label2);
                             expr.jumping(label,0);
               }
  }