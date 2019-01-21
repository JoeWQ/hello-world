/*
  *@aim:数组访问
  *@date:2015/10/7
  */
  package    inter;
  import    lexer.Type;
  import    lexer.Array;
  import    lexer.Word;
  import    lexer.Token;
  import    lexer.Tag;
  
  public    class    Access    extends   Op
 {
               protected        Expr           array;
               protected        Expr           index;
               
               public     Access(Expr     _array,Expr  _index,Type   _type)
              {
                              super(new  Word("[]",Tag.INDEX),_type);
                              this.array=_array;
                              this.index=_index;
//类型表达式,_array的类型必须是数组
                              if( !(_array.type   instanceof    Array))
                                        error("syntax error,express type  must be  array,but gived is "+_array.type);
//检查类型
                              if(_index.type!=Type.Int && _index.type!=Type.Char)
                                        error("syntax error,access type must be 'int' or 'char'. but real is "+_index.type);
               }
//三地址代码
               public      Expr       gen()
              {
                              return     new    Access(array.reduce(),index.reduce(),this.type);
               }
               public    void       jumping(int   tport,int   fport)
              {
                              emit_jump(toString(),tport,fport);
               }
               public    String    toString()
              {
                             return     array+"["+index.toString()+"]";
               }
  }