/*
  *@aim:指向函数的指针,需要说明的是,每一种非基本类型,任何的类型符号表中只能保存有一种
  *@date:2015年10月27日15:29:04
  *@author:狄建彬
  */
  package     lexer;
  import    java.util.ArrayList;
  
  public    class      FuncPointer      extends     Type
 {
//返回类型
                 public       final          Type                          returnType;
//形参类型列表
                 public       final          ArrayList<Type>     paramTypeList;
//函数的参数不能为空,即使列表的内容为空
                 public       FuncPointer(Type    _returnType,ArrayList<Type>    _paramType)
                {
                                   super("func pointer",Tag.FUNC_POINTER,4,4);
                                   this.returnType=_returnType;
                                   this.paramTypeList=_paramType;
                 }
/*
//判断,两种类型是否等价
                 public      boolean         equals(Object    _object)
                {
                                  if(!(_object  instanceof  FuncPointer))
                                               return   false;
                                  FuncPointer     object=(FuncPointer)_object;
//返回类型等价
                                  if(returnType != object.returnType)
                                               return    false;
//形参类型列表等价
                                  if(paramTypeList.size() != object.paramTypeList.size())
                                               return    false;
                                  int   i;
                                  for(i=0;i<paramTypeList.size();++i)
                                              if(paramTypeList.get(i) != paramTypeList.get(i))
                                                             return    false;
                                  return    true;
                 }
 */
                 public      String     toString()
                {
                                 StringBuilder     build=new   StringBuilder(returnType.toString());
                                 build.append("*").append("(");
                                 int             i;
                                 for(i=0;i<paramTypeList.size();++i)
                                                build.append(paramTypeList.get(i)).append(",");
                                 if(paramTypeList.size()!=0)
                                                build.deleteCharAt(build.length()-1);
                                 build.append(")");
                                 return    build.toString();
                 }
  }