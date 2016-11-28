/*
  *Lua脚本分析器
  *2016-1-7 15:33:43
  */
  import      java.io.IOException;
  public     class      LuaParser
 {
               private      LuaLexer     lex;
               private      Token           look;
               public       LuaParser(LuaLexer   _lexer)throws   IOException
              {
                           this.lex=_lexer;
                           LuaLexer.Lines=1;
                           move();
               }
//语法错误
               private      void       error(String    s)
              {
                            throw   new     Error("Syntax error:because of "+s+" in line "+LuaLexer.Lines);
               }
//输出文法
               private     void       emit(String   s)
              {
                            FileManager.output.println(s);
               }
               public      void       move()throws   IOException
              {
                            look=lex.scan();
//                            System.out.println(look);
               }
//下一词法单元预测
               private      boolean      match(int     _type)throws  IOException
              {
                            if( _type != look.tag)
                                          error("want identifier "+(char)_type+" but gived is '"+look+"'");
                            move();
                            return   true;
               }
               public      void       program()throws  IOException
              {
                              this.tableHead();
                              this.tableContent();
                              this.tableTail();
               }
//开头表格分析
               private      void      tableHead()throws  IOException
              {
                            Token        _pretable=look;
                            StringBuilder     _build=new    StringBuilder();
                            
                            while(look.tag !='{' && look.tag != 0)
                           {
                                         _build.append(look);
                                         move();
                            }
//末尾一定匹配左大括号,否则为语法错误
                            _build.append(look);
                            match('{');
                            this.emit(_build.toString());
               }
//表格内容
               private     void      tableContent()throws  IOException
              {
                             int            _index=1;//起始索引
                             while( look.tag == '['  )
                            {
                                           StringBuilder    _build=new    StringBuilder("    ");
                                           Token          _ltok=look;
                                           move();
                                           Token          _rtok=look;//为数字或者右中括号
                                           if( look.tag == Tag.NUM  )
                                          {
                                                       move();
                                                       _rtok=look;
                                           }
                                           match(']');//必须为中括号匹配
                                           match('=');
                                           match('{');
                                           _build.append(_ltok);
                                           _build.append(_index);
                                           _build.append(_rtok);
                                           _build.append("=");
                                           _build.append("{").append("\n");
                                           while(look.tag == Tag.ID || look.tag == Tag.INDEX)
                                          {
                                                         _build.append("        ");
                                                         Token    _tok=look;
                                                         _build.append(look);
                                                         move();//跳过标识符
                                                         match('=');
                                                         _build.append("=");
//暂时假定右值为数字
                                                        if(_tok.tag==Tag.ID)
                                                                   _build.append(look);
                                                        else
                                                                   _build.append(_index);
                                                         if(look.tag != Tag.NUM && look.tag != Tag.FLOAT && look.tag != Tag.STRING)
                                                                        error("want  valid  data,but gived is '"+look+"'");
                                                         move();
                                                         if(look.tag == ',')
                                                        {
                                                                      _build.append(",");
                                                                      move();
                                                         }
                                                         _build.append("\n");
                                           }
                                           match('}');
                                           _build.append("    }");
                                           if(look.tag == ',')
                                          {
                                                         _build.append(",");
                                                         move();
                                           }
//                                           _build.append("\n");
                                           this.emit(_build.toString());
                                           ++_index;
                             }
               }
//表格末尾
               private     void      tableTail()throws    IOException
              {
                            match('}');
                            this.emit("}\n");
               }
  }
  