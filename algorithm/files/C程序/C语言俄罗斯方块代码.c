//C语言俄罗斯方块代码
/*
        已在TC运行
                                        注意请重新设定：
                                                1.registerbgidriver(EGAVGA_driver) 在main（）中被注释掉，
                                                建立图像独立运行程序，注意使用。
                                                 2.initgraph(&gd,&gm,"D:\\JMSOFT\\CYuYan\\bin") 在main() 中
*/
#include<stdio.h>
#include<stdlib.h>
#include<dos.h>
#include<graphics.h>


#define VK_LEFT        0x4b00
#define VK_RIGHT        0x4d00
#define VK_DOWN        0x5000
#define VK_UP                0x4800
#define VK_ESC        0x011b
#define TIMER                0x1c

#define MAX_BOX        19
#define BSIZE                20
#define Sys_x                160
#define Sys_y                25
#define Horizontal_boxs        10
#define Vertical_boxs                15
#define Begin_boxs_x Horizontal_boxs/2
#define FgColor        3
#define BgColor        0
#define LeftWin_x Sys_x+Horizontal_boxs*BSIZE+46
#define false                0
#define true                1
#define MoveLeft        1
#define MoveRight        2
#define MoveDown        3
#define MoveRoll        4
int current_box_numb;
int Curbox_x = (Sys_x + Begin_boxs_x * BSIZE),Curbox_y = Sys_y;
int flag_newbox = false;
int speed = 1;
int score = 0;
int speed_step = 30;
void interrupt (*oldtimer) (void);
struct BOARD
{
        int var;
        int color;
}Table_board[Vertical_boxs] [Horizontal_boxs];

struct SHAPE
{
        char box[2];
        int color;
        int next;
};
struct SHAPE shapes[MAX_BOX] =
{
        {0x88,0xc0,CYAN,        1},
        {0xe8,0x0,CYAN,        2},
        {0xc4,0x40,CYAN,        3},
        {0x2e,0x0,CYAN,        0},
        
        {0x44,0xc0,MAGENTA,        5},
        {0x8e,0x0,MAGENTA,                6},
        {0xc8,0x80,MAGENTA,        7},
        {0xe2,0x0,MAGENTA,                4},
        
        {0x8c,0x40,YELLOW,        9},
        {0x6c,0x0,YELLOW,        8},
        
        {0x4c,0x80,BROWN,        11},
        {0xc6,0x0,BROWN,        10},
        
        {0x4e,0x0,WHITE,                13},
        {0x8c,0x80,WHITE,        14},
        {0xe4,0x0,WHITE,        15},
        {0x4c,0x40,WHITE,        12},
        
        {0x88,0x88,RED,        17},
        {0xf0,0x0, RED,        16},
        
        {0xcc,0x0,BLUE,        18}
};

unsigned        int TimerCounter = 0;
void interrupt newtimer(void)
{
        (*oldtimer)();
        TimerCounter++;
}
void SetTimer(void interrupt (*IntProc)(void))
{
        oldtimer = getvect(TIMER);
        disable();
        setvect(TIMER,IntProc);
        enable();
}
void KillTimer()
{
        disable();
        setvect(TIMER,oldtimer);
        enable();
}
int DelFullRow(int y)
{
        int n,top = 0;
        register int m,totoal;
        for(n =y;n>=0;n--)
        {
                totoal = 0;
                for(m=0;m<Horizontal_boxs;m++)
                {
                        if(!Table_board[n][m].var)
                                totoal++;
                        if(Table_board[n][m].var !=Table_board[n-1][m].var)
                        {
                                Table_board[n][m].var = Table_board[n-1][m].var;
                                Table_board[n][m].color = Table_board[n-1][m].color;
                        }
                }
                if(totoal ==Horizontal_boxs)
                {
                        top = n;
                        break;
                }
        }
        return (top);
}
void ShowSpeed(int speed)
{
        int x,y;
        char speed_str[5];
        setfillstyle(SOLID_FILL,BgColor);
        x = LeftWin_x;
        y =150;
        bar(x-BSIZE,y,x+BSIZE*3,y+BSIZE*3);
        sprintf(speed_str,"%3d",speed);
        outtextxy(x,y,"Leve");
        outtextxy(x,y+10,speed_str);
        outtextxy(x,y+50,"Nextbox");
}
void ShowScore(int score)
{
        int x,y;
        char score_str[5];
        setfillstyle(SOLID_FILL,BgColor);
        x = LeftWin_x;
        y =100;
        bar(x-BSIZE,y,x+BSIZE*3,y+BSIZE*3);
        sprintf(score_str,"%3d",score);
        outtextxy(x,y,"SCORE");
        outtextxy(x,y+10,score_str);
}
void setFullRow(int t_boardy)
{
        int n,full_numb = 0,top = 0;
        register m;
        for(n=t_boardy+3;n>=t_boardy;n--)
        {
                if(n<0 || n>Vertical_boxs)
                        continue;
                for(m=0;m<Horizontal_boxs;m++)
                {
                        if(!Table_board[n+full_numb][m].var)
                                break;
                }
                if(m==Horizontal_boxs)
                {
                        if(n==t_boardy+3)
                                top =DelFullRow(n+full_numb);
                        else
                                DelFullRow(n+full_numb);
                        full_numb++;
                }
        }
        if(full_numb)
        {
                int oldx,x = Sys_x,y = BSIZE*top+Sys_y;
                oldx = x;
                score = score +full_numb*10;
                for(n =top;n<t_boardy+4;n++)
                {
                        if(n>=Vertical_boxs) 
                                continue;
                        for(m = 0;m<Horizontal_boxs;m++)
                        {
                                if(Table_board[n][m].var)
                                        setfillstyle(SOLID_FILL,Table_board[n][m].color);
                                else
                                        setfillstyle(SOLID_FILL,BgColor);
                                bar(x,y,x+BSIZE,y+BSIZE);
                                line(x,y,x+BSIZE,y);
                                line(x,y,x,y+BSIZE);
                                line(x+BSIZE,y,x+BSIZE,y+BSIZE);
                                line(x,y+BSIZE,x+BSIZE,y+BSIZE);
                                x+=BSIZE;
                        }
                        y+=BSIZE;
                        x = oldx;
                }
                ShowScore(score);
                if(speed!=score/speed_step)
                {
                        speed = score/speed_step;
                        ShowSpeed(speed);
                }
                else
                {
                        ShowSpeed(speed);
                }
        }
        
}

void show_help(int xs,int ys)
{
        char stemp[50];
        setcolor(15);
        rectangle(xs,ys,xs+239,ys+100);
        sprintf(stemp,"-Roll -Downwards");
        stemp[0] = 24;
        stemp[8] = 25;
        setcolor(14);
        outtextxy(xs+40,ys+30,stemp);
        sprintf(stemp," -Turn Left  -Turn Right");
        stemp[0] = 27;
        stemp[13] = 26;
        outtextxy(xs+40,ys+45,stemp);
        outtextxy(xs +40,ys+60,"Esc-Exit");
        setcolor(1);
        outtextxy(xs +400,ys+100,"Rong");
        setcolor(FgColor);
}
void show_box(int x,int y,int box_numb,int color)
{
        int i,ii,ls_x = x;
        if(box_numb<0||box_numb>=MAX_BOX)
                box_numb = MAX_BOX/2;
        setfillstyle(SOLID_FILL,color);
        for(ii=0;ii<2;ii++)
        {
                int mask = 128;
                for(i=0;i<8;i++)
                {
                        if(i%4 ==0&&i!=0)
                        {
                                y+=BSIZE;
                                x=ls_x;
                        }
                        if((shapes[box_numb].box[ii])&mask)
                        {
                                bar(x,y,x+BSIZE,y+BSIZE);
                                line(x,y,x+BSIZE,y);
                                line(x,y,x,y+BSIZE);
                                line(x+BSIZE,y,x+BSIZE,y+BSIZE);
                                line(x,y+BSIZE,x+BSIZE,y+BSIZE);
                        }
                        x+=BSIZE;
                        mask/=2;
                }
                y+=BSIZE;
                x = ls_x;
        }
}
void EraseBox(int x,int y,int box_numb)
{
        int mask = 128,t_boardx,t_boardy,n,m;
        setfillstyle(SOLID_FILL,BgColor);
        for(n =0;n<4;n++)
        {
                for(m=0;m<4;m++)
                {
                        if((shapes[box_numb].box[n/2])&mask)
                        {
                                bar(x+m*BSIZE,y+n*BSIZE,x+m*BSIZE+BSIZE,y+n*BSIZE+BSIZE);
                                line(x+m*BSIZE,y+n*BSIZE,x+m*BSIZE,y+n*BSIZE+BSIZE);
                                line(x+m*BSIZE,y+n*BSIZE,x+m*BSIZE+BSIZE,y+n*BSIZE);
                                line(x+m*BSIZE+BSIZE,y+n*BSIZE,x+m*BSIZE+BSIZE,y+n*BSIZE+BSIZE);
                                line(x+m*BSIZE,y+n*BSIZE+BSIZE,x+m*BSIZE+BSIZE,y+n*BSIZE+BSIZE);
                        }
                        mask = mask/2;
                        if(mask ==0) 
                                mask = 128;
                }
        }
}
void ErasePreBox(int x,int y,int box_numb)
{
        int mask = 128,t_boardx,t_boardy,n,m;
        setfillstyle(SOLID_FILL,BgColor);
        for(n=0;n<4;n++)
        {
                for(m =0;m<4;m++)
                {
                        if((shapes[box_numb].box[n/2])&mask)
                        {
                                bar(x+m*BSIZE,y+n*BSIZE,x+m*BSIZE+BSIZE,y+n*BSIZE+BSIZE);
                        }
                        mask = mask/2;
                        if(mask == 0) mask = 128;
                }
        }
}

int MkNextBox(int box_numb)
{
        int mask = 128,t_boardx,t_boardy,n,m;
        t_boardx = (Curbox_x-Sys_x)/BSIZE;
        t_boardy = (Curbox_y-Sys_y)/BSIZE;
        for(n =0;n<4;n++)
        {
                for(m = 0;m<4;m++)
                {
                        if(((shapes[current_box_numb].box[n/2]) & mask))
                        {
                                Table_board[t_boardy+n][t_boardx+m].var = 1;
                                Table_board[t_boardy+n][t_boardx +m].color = shapes[current_box_numb].color;
                        }
                        mask = mask/2;
                        if(mask == 0)
                                mask = 128;
                }
        }
        setFullRow(t_boardy);
        Curbox_x = Sys_x+Begin_boxs_x*BSIZE,Curbox_y = Sys_y;
        if(box_numb == -1)
                box_numb =rand()%MAX_BOX;
        current_box_numb = box_numb;
        flag_newbox = false;
        return (rand()%MAX_BOX);
}

void initialize(int x,int y,int m,int n)
{
        int  i,j,oldx;
        oldx = x;
        for(j = 0;j<n;j++)
        {
                for(i = 0;i<m;i++)
                {
                        Table_board[j][i].var = 0;
                        Table_board[j][i].color = BgColor;
                        line(x,y,x+BSIZE,y);
                        line(x,y,x,y+BSIZE);
                        line(x+BSIZE,y,x+BSIZE,y+BSIZE);
                        line(x,y+BSIZE,x+BSIZE,y+BSIZE);
                        x+=BSIZE;
                }
                y+=BSIZE;
                x = oldx;
        }
        Curbox_x = x;
        Curbox_y = y;
        flag_newbox = false;
        speed = 1;
        score = 0;
        ShowScore(score);
        ShowSpeed(speed);
}
int MoveAble(int x,int y,int box_numb,int direction)
{
        int n,m,t_boardx,t_boardy;
        int mask = 128;
        if(direction == MoveLeft)
        {
                x-=BSIZE;
                t_boardx = (x - Sys_x)/BSIZE;
                t_boardy = (y -Sys_y)/BSIZE;
                for(n = 0;n<4;n++)
                {
                        for(m=0;m<4;m++)
                        {
                                if(shapes[box_numb].box[n/2] & mask)
                                {
                                        if(x + BSIZE*m <Sys_x)        return (false);
                                        else if(Table_board[t_boardy+n][t_boardx+m].var)return (false);
                                }
                                mask = mask/2;
                                if(mask == 0)                mask = 128;
                        }
                }
                return (true);
        }
        else if(direction == MoveRight)
        {
                x+=BSIZE;
                t_boardx = (x - Sys_x)/BSIZE;
                t_boardy = (y - Sys_y)/BSIZE;
                for(n = 0;n <4;n++)
                {
                        for(m = 0;m<4;m++)
                        {
                                if((shapes[box_numb].box[n/2]) & mask)
                                {
                                        if((x + BSIZE*m)>=(Sys_x + BSIZE*Horizontal_boxs))                return (false);
                                        else if(Table_board[t_boardy + n][t_boardx + m].var)                return(false);
                                }
                                mask =mask/2;
                                if(mask == 0)                mask =128;
                        }
                }
                return (true);
        }
        else if(direction == MoveDown)
        {
                y+=BSIZE;
                t_boardx = (x - Sys_x)/BSIZE;
                t_boardy = (y - Sys_y)/BSIZE;
                for(n = 0;n<4;n++)
                {
                        for(m =0;m<4;m++)
                        {
                                if((shapes[box_numb].box[n/2]) & mask)
                                {
                                        if((y+BSIZE*n)>=(Sys_y+BSIZE*Vertical_boxs) ||Table_board[t_boardy +n][t_boardx +m].var)
                                        {
                                                flag_newbox = (true);
                                                break;
                                        }
                                }
                                mask =mask/2;
                                if(mask == 0)                mask =128;
                        }
                }
                if(flag_newbox)
                        return (false);
                else
                        return (true);
        }
        else if(direction == MoveRoll)
        {
                t_boardx = (x - Sys_x)/BSIZE;
                t_boardy = (y - Sys_y)/BSIZE;
                for(n=0;n<4;n++)
                {
                        for(m =0;m<4;m++)
                        {
                                if((shapes[box_numb].box[n/2]) & mask)
                                {
                                        if((y+BSIZE*n)>=(Sys_y+BSIZE*Vertical_boxs))        return (false);
                                        if((x+BSIZE*n)>=(Sys_x+BSIZE*Horizontal_boxs))        return (false);
                                        if((x+BSIZE*m)>=(Sys_x+BSIZE*Horizontal_boxs))        return (false);
                                        else if(Table_board[t_boardy+n][t_boardx+m].var)        return (false);
                                }
                                mask =mask/2;
                                if(mask ==0)        mask = 128;
                        }
                }
                return (true);
        }
        else        return (false);
}




int main()
{
        int GameOver = 0;
        int key,nextbox;
        int Currentaction = 0;
        int gd = DETECT,gm,errorcode;
        //registerbgidriver(EGAVGA_driver);
        initgraph(&gd,&gm,"D:\\JMSOFT\\CYuYan\\bin");
        errorcode = graphresult();
        if(errorcode != grOk)
        {
                printf("\nNotice :Graphics error :%s \n",grapherrormsg(errorcode));
                printf("Press any key to quit !");
                getch();
                exit(1);
        }
        setbkcolor(BgColor);
        setcolor(FgColor);
        randomize();
        SetTimer(newtimer);
        initialize(Sys_x,Sys_y,Horizontal_boxs,Vertical_boxs);
        nextbox = MkNextBox(-1);
        
        show_box(Curbox_x,Curbox_y,current_box_numb,shapes[current_box_numb].color);
        show_box(LeftWin_x,Curbox_y + 200,nextbox,shapes[nextbox].color);
        show_help(Sys_x,Curbox_y+320);
        getch();
        Currentaction = 0;
        flag_newbox = false;
        while(1)
        {
                
                if(bioskey(1))
                        key = bioskey(0);
                else
                        key = 0;
                switch(key)
                {
                        case VK_LEFT :
                                if(MoveAble(Curbox_x,Curbox_y,current_box_numb,MoveLeft))
                                {
                                        EraseBox(Curbox_x,Curbox_y,current_box_numb);
                                        Curbox_x-=BSIZE;
                                        Currentaction = MoveLeft;
                                }
                                break;
                        case VK_RIGHT:
                                if(MoveAble(Curbox_x,Curbox_y,current_box_numb,MoveRight))
                                {
                                        EraseBox(Curbox_x,Curbox_y,current_box_numb);
                                        Curbox_x+=BSIZE;
                                        Currentaction = MoveRight;
                                }
                                break;
                        case VK_DOWN :
                                if(MoveAble(Curbox_x,Curbox_y,current_box_numb,MoveDown))
                                {
                                        EraseBox(Curbox_x,Curbox_y,current_box_numb);
                                        Curbox_y+=BSIZE;
                                        Currentaction = MoveDown;
                                }
                                else
                                        flag_newbox = true;
                                break;
                        case VK_UP :
                                if(MoveAble(Curbox_x,Curbox_y,shapes[current_box_numb].next,MoveRoll))
                                {
                                        EraseBox(Curbox_x,Curbox_y,current_box_numb);
                                        current_box_numb = shapes[current_box_numb].next;
                                        Currentaction = MoveRoll;
                                }
                                break;
                        case VK_ESC :
                                GameOver = 1;
                                break;
                        default:
                                break;
                }
                if(Currentaction)
                {
                        show_box(Curbox_x,Curbox_y,current_box_numb,shapes[current_box_numb].color);
                        Currentaction = 0;
                }
                if(flag_newbox)
                {
                        ErasePreBox(LeftWin_x,Sys_y+200,nextbox);
                        nextbox = MkNextBox(nextbox);
                        show_box(LeftWin_x,Curbox_y+200,nextbox,shapes[nextbox].color);
                        if(!MoveAble(Curbox_x,Curbox_y,current_box_numb,MoveDown))
                        {
                                show_box(Curbox_x,Curbox_y,current_box_numb,shapes[current_box_numb].color);
                                GameOver = 1;
                        }
                        else
                                flag_newbox = false;
                        Currentaction = 0;
                }
                else
                {
                        if(Currentaction ==MoveDown || TimerCounter >(20 -speed*2))
                        {
                                if(MoveAble(Curbox_x,Curbox_y,current_box_numb,MoveDown))
                                {
                                        EraseBox(Curbox_x,Curbox_y,current_box_numb);
                                        Curbox_y+=BSIZE;
                                        show_box(Curbox_x,Curbox_y,current_box_numb,shapes[current_box_numb].color);
                                }

                                TimerCounter = 0;
                                        
                        }
                }
                if(GameOver)
                {
                        printf("game over ,thank you !\nyou score is %d",score);
                        getch();
                        break;
                }
                
        }
        getch();
        KillTimer();
        closegraph();
        return 0;
}