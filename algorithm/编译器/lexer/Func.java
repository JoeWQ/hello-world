/*
  *@aim:函数的实现,我们定义的函数不允许嵌套,这里我们暂时不支持返回函数类型,
  *@date:2015-10-19 09:55:43
  *@author:狄建彬
  */
  package     lexer;
  import      java.util.ArrayList;
  public     class        Func     extends        Word
 {
//函数的定义在源文件的行
              private       final         int                            line;
//函数的返回类型
               public        final         Type                          returnType;
//是否有返回语句出现
               public        boolean                                     hasReturnStamt;
//函数的形参类型参数列表,注意我们不会将形参的名字写入其,
//至于检测形参的名字是否重复是由语法分析阶段来保证
               public        final          ArrayList<Type>    paramList;
//辅助字段，当函数的形参列表为空的时候，可以直接使用这个字段，而不用再创建对象
               public        static       final        ArrayList<Type>    globalParamList=new   ArrayList<Type>();
//构造函数中,_paramList可以不可以为空,但是长度可以为0
               public       Func(Type   _returnType,String    funcName,ArrayList<Type>    _paramList)
              {
//向上传回函数名和标识符Tag.FUNC
                              super(funcName,Tag.FUNC);
                              this.returnType=_returnType;
                              this.paramList=_paramList;
                              this.line=Lexer.lines;
//产检类型,参数列表中的形参类型不能为void类型,这个约定需要调用着自己保证
                              for(int  i=0;i<_paramList.size();++i)
                             {
                                              if(_paramList.get(i)==Type.Void)
                                                         error("Syntax error:formal paramater of function  defination   can not be type 'void' ");
                              }
               }
//用在创建全局标识对象上，不允许其他类调用这个方法
               private      Func()
              {
                          super("",Tag.FUNC);
                          this.line=Lexer.lines;
                          this.returnType=Type.Void;
                          this.paramList=Func.globalParamList;
               }
               public     void      error(String    s)
              {
                              throw   new     Error(s+this.line);
               }
               public    String     toString()
              {
                              return    returnType+"   "+lexeme;
               }
//函数块,用在return语句中
              public         static      final             Func       Null=new   Func();
//return语句的外围函数
              public         static      Func             Enclosing=Func.Null;
  }