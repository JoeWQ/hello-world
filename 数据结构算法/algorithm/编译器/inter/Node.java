/*
  *@aim:语法分析树结点,是表达式结点语句节点的祖先
  *@date:2015/10/6
  */
  package    inter;
  import     tool.FileManager;
  import     lexer.Lexer;
  import     lexer.Func;
  import     lexer.Type;
  import     java.util.ArrayList;
  public    class    Node
 {
//当前节点在源代码文件中所处的行号
              int             line;
              static        int          labels=0;
//记录函数的数目在一个文件中
              private      static     int         func_count=0;
              public       Node()
             {
                           line=Lexer.lines;
              }
//打印错误消息并退出
             public     void     error(String   err)
            {
                          throw    new    Error("Error  near line "+this.line+" caused by "+err);
             }
//产生标号
             public      int          new_label()
            {
                          return     ++labels;
             }
//发行标签
             public  void    emit_label(int   label)
            {
                         FileManager.output.print("L"+label+":");
             }
//发行字符串
             public   static  void   emit(String   s)
            {
                         FileManager.output.println("\t\t\t\t"+s);
             }
//生成全局变量赋值代码
             public    static     void    emit_globle(String    s)
            {
                        FileManager.output.println("\t"+s);
             }
//函数名字
//paramName形参的名字
             public    static    void    emit(Func    func,ArrayList<String>   paramName)
            {
                           ArrayList<Type>       paramList=func.paramList;
                           StringBuilder  build;
                           if(func_count>0)
                                   build=new    StringBuilder("\n\n\t"); 
                           else
                                   build=new   StringBuilder();
//函数调用
                           build.append("\t");
                           build.append(func.toString()).append("");
                           if(paramName!=null )
                          {
                                                    build.append(":\t");
                                                    int     i=0;
                                                    for(  ;i<paramList.size();++i)
                                                                 build.append(paramList.get(i)).append("\t").append(paramName.get(i)).append(",");
//删除最后的逗点
                                                    build.deleteCharAt(build.length()-1);
                            }
                            FileManager.output.println(build.toString());
                            ++Node.func_count;
             }
  }