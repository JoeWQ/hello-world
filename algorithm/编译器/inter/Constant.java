/*
  *@aim:布尔表达式常量,或者整数/浮点数常量
  *@date:2015/10/6
  */
  package    inter;
  import    lexer.Word;
  import    lexer.Type;
  import    lexer.Token;
  import    lexer.Float;
  import    lexer.Num;
  import    lexer.Char;
  import    lexer.CString;
  import    lexer.Pointer;
 //常量,包括整型,字符型,单浮点型,字符串类型
  public      class       Constant   extends    Expr
 {
//单浮点类型
               public     Constant(float    value)
              {
                           super(new    Float(value),Type.Float);
               }
//整型
               public    Constant(int    value)
              {
                           super(new    Num(value),Type.Int);
               }
//字符类型
               public     Constant(char   value)
              {
                           super(new   Char(value),Type.Char);
               }
//字符串类型
               public     Constant(String    _string )
              {
                          super(new   CString(_string),Pointer.CharPointer);
               }
               public    Constant(Token  tok,Type type)
              {
                           super(tok,type);
               }
               public     void     jumping(int   tport,int   fport)
              {
//以下的语句实际上就是Expr jumping函数的简化,去掉了测试指令,和实际的语句特征无关
//用在do while语句,在if/while语句中肯定不会发生跳转
                           if(this==Constant.True  && tport!=0)
                                       emit("jmp    L"+tport);
//用在if /while语句
                           else if(this==Constant.False && fport!=0)
                                       emit("jmp   L"+fport);
               }
//两个布尔常量
               public     static    final      Constant     True=new    Constant(Word._true,Type.Bool);
               public     static    final      Constant     False=new    Constant(Word._false,Type.Bool);
  }