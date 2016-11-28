/*
  *@aim:文本加密算法实现
  *@date:2015-8-10
   */
  #include<stdio.h>
  #include<string.h>
  //加密算法
  //zhuyabin+文件长度
  //比如文件长度为64
  //char   *p="zhuyabin";
  //加密的核:int   *q=(int *)p; *q+=64,*(q+1)+=64<<1;
  
     void           encript(char    *src,char     *aim,int   size)
    {
                char       *skernel="zhuyabin";
                int          *p=(int *)skernel;
                int           kernel[2];
                
                kernel[0]=*p+size;
                kernel[1]=*(p+1)+(size<<1)+13;
//开始加密过程
                int           new_size=size>>3;
                int           *q=(int  *)aim;
                int           *y=(int *)src;
                
                int          i;
                for(i=0;i<new_size;++i,q+=2,y+=2)
               {
                               *q=*y ^ kernel[0];
                               
                               *(q+1)=*(y+1) ^ kernel[1];
                }
//处理可能的剩下的文本
               char       *a=src+(new_size<<3);
               char       *b=aim+(new_size<<3);
//
               char       *e=(char  *)kernel;
               for(i=new_size<<3;i<size;++i,++a,++b)
              {
                                *b=*a^e[i & 0x08];
               }
               *b='\0';
     }
//截断文件名,并修改名字的修饰
     void             trunc_modify(char     *name,char    *new_name)
    {
 //文件的扩展名
                char          extend[128];
//文件的名字
//                char          symbol[512];
//
                int             i=0;
                int             j=0;
                while( name[i] && name[i] !='.')
               {
                           new_name[i]=name[i];
                           ++i;
                }
                new_name[i]='\0';
//                if(name[i] == '.')
//                          ++i;
                while(name[i] )
               {
                           extend[j]=name[i];
                           ++j;
                           ++i;
                }
                extend[j]='\0';
                strcat(new_name,"_encript");
                strcat(new_name,extend);
     }
 //
     int           main(int    argc,char   *argv[])
    {
                if(  argc<2 )
               {
                             printf("Usage: %s   文件名\n",argv[0]);
                             return  1;
                }
                FILE       *file;
                file=fopen(argv[1],"rb");
                if(  !file    )
               {
                              printf("error :  file   you input does not exist!\n");
                              return   2;
                }
                FILE        *aim;
                char         symbol[512],*new_name;
                if(  argc>2   )
                           new_name=argv[2];
                else
               {
                            new_name=symbol;
                            trunc_modify(argv[1],new_name);
                }
                aim=fopen(new_name,"wb+");
                if(! aim)
               {
                            fclose(file);
                             printf("Open file %s error !\n",new_name);
                             return     3;
                }
//读取源文件
                int          length=0;
//一下为获取文件长度的过程
                fseek(file,0,SEEK_END);
                length=ftell(file);
                fseek(file,0,SEEK_SET);
//如果没有内容
                 if(! length )
                {
                            fclose(file);
                            fclose(aim);
                            printf("File %s content is empty !\n",argv[1]);
                            return     4;
                 }
//申请内存
                char         *in=new   char[length+1];
                char         *out=new   char[length+1];
//                printf("Source  file %s length is %d\n",argv[1],length);
//读取文件内容
                 fread(in,length,1,file);
                 in[length]='\0';
//加密
                encript(in,out,length);
//写入文件
                fseek(aim,0,SEEK_SET);
                fwrite(out,length,1,aim);
                fclose(file);
                fclose(aim);
                delete   in;
                delete   out;
                return     0;
     }