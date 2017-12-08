/*
  *@instruction:词法单元
  *@包括词素,属性
  */
  package    lexer;
  
  public    class     Word    extends    Token
 {
             public     final    String    lexeme;
             
             public    Word(String    _lex,int    property)
            {
                         super(property);
                         this.lexeme=_lex;
             }
             public     String      toString()
            {
                         return      this.lexeme;
             }
//静态对象
//下面的几个的存在是为了减少所要创建的对象的数目
            public     static     final       Word      assign=new     Word("=",'=');
//对数组进行赋值
            public     static     final       Word      assign_array=new     Word("[]=",'=');
            public     static     final       Word      add=new    Word("+",'+');
            public     static     final       Word      sub=new     Word("-",'-');
            public     static     final       Word      mul=new     Word("*",'*');
            public     static     final       Word      div=new       Word("/",'/');
            public     static     final        Word     mod=new     Word("%",'%');
//指针
            public    static      final        Word     addr=new     Word("&",'&');
            public    static      final        Word     pointer=new   Word("*",'*');
//结构体
            public    static      final        Word     access_struct=new    Word("->",Tag.ACCESS_STRUCT);
//关系
            public     static     final       Word      and=new    Word("&&",Tag.AND);
            public     static     final       Word      or=new    Word("||",Tag.OR);
            public     static     final       Word      equal=new    Word("==",Tag.EQUAL);
            public     static     final       Word      ne=new     Word("!=",Tag.NE);
            public     static     final       Word      le=new     Word("<=",Tag.LE);
            public     static     final       Word      ge=new    Word(">=",Tag.GE);
//单字符关系
//移位
            public     static     final       Word      shift_left=new    Word("<<",Tag.SHIFT_LEFT);
            public     static     final       Word      shift_right=new  Word(">>",Tag.SHIFT_RIGHT);
//
            public     static     final       Word      neg=new   Word("-",Tag.NEG);
            public     static     final       Word      _true=new   Word("true",Tag.TRUE);
            public     static     final       Word      _false=new   Word("false",Tag.FALSE);
            public     static     final       Word      temp=new    Word("t",Tag.TEMP);
            public     static     final       Word      not=new    Word("!",Tag.NOT);
//返回语句
            public     static     final       Word      _return=new    Word("return",Tag.RETURN);
//注意"func"不是关键字也不是标识符,它只是作为编译器内部使用的符号
            public     static     final        Word     func=new   Word("func",Tag.FUNC);
//强制类型转换
            public     static     final        Word     cast=new      Word("cast",Tag.CAST);
//void
  }