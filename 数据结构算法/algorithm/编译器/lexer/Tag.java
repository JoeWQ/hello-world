/*
  *@instruction:词法单元类型枚举
  */
  
    package    lexer;
    
    public    class   Tag
   {
//文件结束标志
              public    static    final     int     EOF=0;
//类型
              public    static    final      int    BASIC=256;//基本类型
//标识符,可作为变量名也可以作为函数名
              public    static    final      int    ID=257;
//复合运算符
              public    static    final      int    AND=258;//&&
              public    static    final      int    OR=259;// ||
              public    static    final      int    NOT=260;// !,与其他符合运算符不同，次运算符无二义性
              public    static    final      int    EQUAL=261;//==
              public    static    final      int    NE=262;//!=
              public    static    final      int    GE=263;//>=
              public    static    final      int    LE=264;//<=
              public    static    final      int    INDEX=265;//数组索引
//以下两个在实际中并不使用
              public    static    final      int    NEG=266;//取负
              public    static    final      int    POV=267;//取正
//移位
              public    static    final      int    SHIFT_LEFT=268;//左移
              public    static    final      int    SHIFT_RIGHT=269;//右移
//指针访问结构体类型
              public    static    final      int    ACCESS_STRUCT=270;
//              public    static    final      int    DOT;
//语句
              public    static    final      int    IF=274;//
              public    static    final      int    ELSE=275;
              public    static    final      int    WHILE=276;
              public    static    final      int    DO=277;
              public    static    final      int    BREAK=278;
              public    static    final      int    CONTINUE=279;
//中间标量,临时变量
              public    static    final      int    TEMP=280;
//常数
              public    static    final      int    TRUE=281;//true
              public    static    final      int    FALSE=282;//false
              public    static    final      int    NUM=283;//整数
              public    static    final      int    FLOAT=284;//浮点
//字符类型
              public    static    final      int    CHAR=285;
//关于特殊的函数返回类型
              public    static    final      int    VOID=286;
//函数类型
              public    static    final      int     FUNC=287;
//返回语句
              public    static    final      int     RETURN=288;
//强制类型转换
              public    static    final      int      CAST=289;
// 数组类型
              public    static    final      int      ARRAY=290;
//访问结构体
              
//结构体类型
              public    static    final      int      STRUCT=291;
//指针类型,泛指
              public    static    final      int      POINTER=292;
//字符串类型
              public    static   final       int      STRING=294;
//函数指针
              public    static   final       int      FUNC_POINTER=295;
    }