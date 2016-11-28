/*
  *@aim:ָ������ָ��,��Ҫ˵������,ÿһ�ַǻ�������,�κε����ͷ��ű���ֻ�ܱ�����һ��
  *@date:2015��10��27��15:29:04
  *@author:�ҽ���
  */
  package     lexer;
  import    java.util.ArrayList;
  
  public    class      FuncPointer      extends     Type
 {
//��������
                 public       final          Type                          returnType;
//�β������б�
                 public       final          ArrayList<Type>     paramTypeList;
//�����Ĳ�������Ϊ��,��ʹ�б������Ϊ��
                 public       FuncPointer(Type    _returnType,ArrayList<Type>    _paramType)
                {
                                   super("func pointer",Tag.FUNC_POINTER,4,4);
                                   this.returnType=_returnType;
                                   this.paramTypeList=_paramType;
                 }
/*
//�ж�,���������Ƿ�ȼ�
                 public      boolean         equals(Object    _object)
                {
                                  if(!(_object  instanceof  FuncPointer))
                                               return   false;
                                  FuncPointer     object=(FuncPointer)_object;
//�������͵ȼ�
                                  if(returnType != object.returnType)
                                               return    false;
//�β������б�ȼ�
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