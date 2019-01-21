//2013年4月7日17:42:27
//在图形界面上计算给定的N个点的最小凸多边形
  import  javax.swing.JFrame;
  import  javax.swing.JButton;
  import  javax.swing.JLabel;
  import  javax.swing.JComponent;
  import  javax.swing.JPanel;

  import  java.awt.EventQueue;
  import  java.awt.Graphics;
  import  java.awt.Point;
  import  java.awt.Color;
  import  java.awt.BorderLayout;
  import  java.awt.BasicStroke;
  import  java.awt.Graphics2D;

  import  java.awt.event.ActionEvent;
  import  java.awt.event.ActionListener;

  import  java.util.LinkedList;

  public  class  GrahamScan extends  JFrame implements ActionListener
 {
         private   JButton        drawPoint=new  JButton("绘点");
         private   JButton        submit=new  JButton("描点");
         private   PointCanvas    canvas=new  PointCanvas(24);

         public  GrahamScan(String  title)
        {
                 this.setTitle(title);
                 JPanel   panel=new  JPanel();
                 panel.add(drawPoint);
                 panel.add(submit);
                 this.add(panel,BorderLayout.NORTH);
                 this.add(canvas,BorderLayout.CENTER);

                 drawPoint.addActionListener(this);
                 submit.addActionListener(this);
 
                 this.setBounds(125,135,480,360);
                 this.setVisible(true);
                 this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                 canvas.repaint();
         }
 //事件监听器
         public  void  actionPerformed(ActionEvent  event)
        {
                 if(event.getSource()==drawPoint)
                        canvas.setPointDrawing(false);
                 else
                        canvas.setPointDrawing(true);
                 canvas.repaint();
         }
     public  static  void  main(String[] argv)
    {
             EventQueue.invokeLater(new  Runnable(){
                    public  void   run()
                   {
                            new  GrahamScan("Graham 最小多边形算法测试!");
                    }});
     }
   }
//下面是整个点和凸多边形的生成类
   class   PointCanvas  extends  JComponent
  {
           private   final        int   point_num;
           private   Point[]       points;
           private   float[]      arc;
           private   boolean      point_drawing;
           private   BasicStroke   line_stroke;
           private   BasicStroke   point_stroke; 
           private   Color         point_color;
           private   Color         line_color;
           

           public  PointCanvas(int  point_num)
          {
                   this.point_num=point_num;
                   arc=new  float[point_num];
                   points=new  Point[point_num];
                   point_color=Color.GREEN;
                   line_color=Color.RED;
                   point_stroke=new  BasicStroke(6);
                   line_stroke=new  BasicStroke(2);
           }
           public  void  setPointDrawing(boolean  point_drawing)
          {
                   this.point_drawing=point_drawing;
           }
//计算点得相对角度，这里不是以绝对的较出现的
           private  float  relative_local(Point  p,Point  q)
          {
                   float   pf;
                   double  x,y;
                   if(p.x<q.x)
                  {
                         x=q.x-p.x;
                         y=p.y-q.y;
                         pf=(float)(y/Math.sqrt((x*x+y*y)));
                   }
                   else
                  {
                         x=p.x-q.x;
                         y=p.y-q.y;
                         pf=(float)(x/Math.sqrt((x*x+y*y))+1);
                   }
                   return pf;
           }
//下面是重绘界面
           public  void  paint(Graphics  g)
          {
                   Graphics2D          gg=(Graphics2D)g;
//如果point_drawing 为真，则执行描点，否则执行计算最小凸多边形的任务
                   int                 i,j,width,height;
                   LinkedList<Point>   stack;
                   Point               p,q,t;

                   width=this.getWidth();
                   height=this.getHeight();
                   if(! point_drawing )
                  {
                         for(i=0;i<point_num;++i)
                               points[i]=new  Point((int)(Math.random()*width),(int)(Math.random()*height));
//下面将这些点描绘出来
                         gg.setPaint(point_color);
                         gg.setStroke(point_stroke);
                         for(i=0;i<point_num;++i)
                               gg.drawLine(points[i].x,points[i].y,points[i].x,points[i].y);
                         return;
                   }
//描点
                   gg.setStroke(point_stroke);
                   gg.setPaint(point_color);
                   for(i=0;i<point_num;++i)
                  {
                         p=points[i];
                         gg.drawLine(p.x,p.y,p.x,p.y);
                   }
                   gg.setPaint(line_color);
                   gg.setStroke(line_stroke);
//下面是计算所有生成的点得最小凸多边形
                   stack=new  LinkedList<Point>();
                   p=q=null;
//找出在屏幕坐标系中，x值最小，且y坐标最大的点
                   p=points[0];
                   j=0;
                  for(i=1;i<point_num;++i)
                 {
                         if(p.y<points[i].y)
                        {
                                p=points[i];
                                j=i;
                         }
                         else if(p.y==points[i].y && p.x>points[i].x)
                        {
                                p=points[i];
                                j=i;
                         }
                  }
//将p从目标数组中剔除掉
                  p=new  Point(p.x,p.y);
                  for(i=j;i>0;--i)
                         points[i]=points[i-1];
                  
//下面计算points数组中的点相对于点p得角度
                  width=point_num-1;
                  for(i=1;i<=width;++i)
                         arc[i]=relative_local(p,points[i]);
//对所有的点，按照arc的大小进行排序
                  sortPoint();
//下面利用Graham 算法计算N个点得最小凸多边形
                  stack.addFirst(p);
                  stack.addFirst(points[1]);
                  stack.addFirst(points[2]);
//进入下面的循环
                  for(i=3;i<=width;++i)
                 {
                        t=points[i];
                        do
                       {
                               q=stack.removeFirst();
                               p=stack.removeFirst();
                               stack.addFirst(p);
                               stack.addFirst(q);
                               if((q.x-p.x)*(t.y-q.y)-(t.x-q.x)*(q.y-p.y)>=0)
                                       stack.removeFirst();
                               else
                                       break;
                        }while(stack.size()!=0);
                        stack.addFirst(t);
                  }
//对stack中的点进行作图
                  t=stack.removeFirst();
                  p=t;
                  for(    ;stack.size()!=0;  )
                 {
                         q=stack.removeFirst();
//画线
                         gg.drawLine(p.x,p.y,q.x,q.y);
                         p=q;
                  }
                  gg.drawLine(t.x,t.y,p.x,p.y);
       }
//根据arc中的大小对所有的点进行升序排序
       private  void  sortPoint()
      {
             int  size=point_num-1;
             int  i;
             Point  p=null;
             float  pf;
             for(i=size>>1; i>=1; --i)
                    adjust(i,size);
//排序
             for(i=size;i>1;   )
            {
                     p=points[i];
                     points[i]=points[1];
                     points[1]=p;

                     pf=arc[i];
                     arc[i]=arc[1];
                     arc[1]=pf;
                     
                     adjust(1,--i);
             }
       }
//对最大堆进行调整
      private  void  adjust(int  parent,int  size)
     {
             int     child;
             Point   p;
             float  pf;

             p=points[parent];
             pf=arc[parent];
             for(child=parent<<1;child<=size;  )
            {
                    if(child<size && arc[child]<arc[child+1])
                             ++child;
                    if(pf<arc[child])
                   {
                           arc[parent]=arc[child];
                           points[parent]=points[child];
                    }
                    else  if(pf==arc[child] )
                   {
//将x坐标比较大的点放在堆的靠上位置
                           if(pf<1 && p.x<points[child].x)
                          {
                          
                                 arc[parent]=arc[child];
                                 points[parent]=points[child];
                           }
//将x坐标比较小得点放在堆de靠上位置
                           else if(pf>1 && p.x>points[child].x)
                          {
                                 arc[parent]=arc[child];
                                 points[parent]=points[child];
                           }
                           else
                                 break;
                    } 
                    else
                           break;
                    parent=child;
                    child<<=1;
             }
             points[parent]=p;
             arc[parent]=pf;
      }
  }