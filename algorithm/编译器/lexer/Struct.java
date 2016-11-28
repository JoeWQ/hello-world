/*
  *@aim:结构体类型,结构体的尺寸最小为4,如果里面没有任何的内容
  *@date:2015年10月24日18:58:48
  *@author:狄建彬
  */
  package     lexer;
  import    java.util.ArrayList;
  import   java.util.TreeMap;
  
  //在我们的这一版本中不会将结构体的成员进行排序,在我们的稍后版本中将会添加这个功能
  //当然这是在整个编译器完成之后,考虑到这个排序功能的实现需要用到动态规划,因此我们将要制作好
  //非常详细的文档去解释这个算法的原理
  public    class    Struct   extends    Type
 {
//结构体被定义所在的行
             public        final        int                                  define_line;
//结构体的名字
             public        final        String                            struct_name;
//标识对象
             private       final       TreeMap<String,Member>       table;
//结构体的字段内容序列,从第一个顺序到最后一个
             private       final       ArrayList<String>                       mem_name;
//对结构体进行计数(隐式的)
             private       int                                                 offset;
             private       int                                                 mem_count;
//向其中添加成员,限制包括,
//@1:成员不能重名
//@2:成员的类型不能是其外层的结构体名字,以防止数据的递归定义
             public        Struct(String   _name)
            {
//先假设结构体的对齐粒度4,大小4
                           super("struct "+_name,Tag.STRUCT,4,4);
                           this.struct_name=_name;
                           this.table=new    TreeMap<String,Member>();
                           this.mem_name=new   ArrayList<String>();
                           this.define_line=Lexer.lines;
             }
//向结构体添加成员
            public      void       addMember(String    _name,Type    _type)
           {
//检查是否在成员内部重定义了
                          if(table.get(_name) !=null  )
                                     error("syntax error:struct "+struct_name+" has same declaration of variable "+_name);
//检查是否是递归类型
                          if(_type == this)
                                     error("syntax error:recurisive defination of struct "+struct_name);
//添加成员
                          if(offset%_type.alignWidth!=0)        
                                      offset+=_type.alignWidth-offset%_type.alignWidth;
//                          System.out.println("struct member "+_name+" offset:"+offset);
                          Member    _mem=new    Member(_name,_type,offset,mem_count);
//重新计算偏移
                         offset+=_type.width;
//添加到结构体的私有符号表中
                         this.mem_name.add(_name);
                         table.put(_name,_mem);
//重新计算结构体的对齐粒度和所占据的空间
                         if(mem_count==0)//对其粒度为第一个成员的对其粒度
                                   this.alignWidth=_type.alignWidth;
                         this.width=offset;
                         ++mem_count;
            }
//给定一个名字,在结构体中查找对应的成员
            public       Member          getMember(String    _mem_name)
           {
                          return      table.get(_mem_name);
            }
//
             public      String     toString()
            {
                          return     "struct@"+struct_name;
             }
             public     void         error(String    s)
           {
                         throw   new    Error("error caused by:"+s+" in  line "+define_line);
            }
  }