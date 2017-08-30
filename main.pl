#!/usr/bin/perl
use v5.14.2;
use Pcb ;
use threads;
use threads::shared;
our $p=&shared_clone(Pcb->new());#创建一个空的Pcb对象，p变量为该对象的引用
our $nid=1;
our @cstate=("ready","run","stop");
sub stoppcb;
sub start;
sub show;
sub check;
sub helptxt{
   my $filename=shift;                                    
   open(MYFILE,"<",$filename)|| die "error opening file";   #打开文件
   my @array=<MYFILE>;                                #将文件读入字符串数组@array中
   foreach(@array){                                   #打印文件内容
      print $_;
   }
   close(MYFILE);
}
sub create{                                          #创建模拟进程的函数
   my $PCB=$p;
   if($PCB->get_next()!=undef)
   {
      while($PCB->if_next_null())
      {
         $PCB=$PCB->get_next();
      }
   }
   print "please enter processes' informations(if you want to finsh please enter end)\n";
   print "please enter name\n";
   my $n;
   $n=<STDIN>;
   chomp($n);#删除换行符;
   my $s;
   my $r;
   while($n ne "end")                               #ne相当于c语言中的==
   {
      print "please enter runtime\n";
      $r=<STDIN>;                                   #输入
      chomp($r);                                    #chomp是删除$r在输入时传入的换行符
      print "please enter super\n";
      $s=<STDIN>;
      chomp($s);
      my $tmp=&shared_clone(Pcb->new($nid,$n,$r,0,$s,undef));
      $PCB->set_next($tmp);
      $nid=$nid+1;
      $PCB=$PCB->get_next();
      print "please enter name (if you want to finsh please enter end)\n";
      $n=<STDIN>;
      chomp($n);
   }
}
sub running{
   while(1==1)
   {
      my $flag=1;
      my $PCB=$p->get_next();
      while(defined($PCB))                      #defined函数是判定变量是否有值。
      {
         if($PCB->get_sper()==1)
         {
            $PCB->set_nstate(1);
         }
         $PCB=$PCB->get_next();
      }
      $PCB=$p->get_next();
      while(defined($PCB))
      {
         if($PCB->get_nstate()==1)
         {
            my $tmp_rtime=$PCB->get_rtime();
            --$tmp_rtime;
            $PCB->set_rtime($tmp_rtime);
            if($PCB->get_rtime()==0)
            {
               my $tmp_sper=$PCB->get_sper();
               --$tmp_sper;
               $PCB->set_sper($tmp_sper); 
               $PCB->set_nstate(2);
            }
            $flag=0;
         }
         $PCB=$PCB->get_next();
      };
      sleep(5);
      $PCB=$p->get_next();
      if($flag==1)
      {
         while(defined($PCB))
         {
            if($PCB->get_sper()>1)
            {
               my $tmp_sper=$PCB->get_sper();
               --$tmp_sper;
               $PCB->set_sper($tmp_sper); 
               if($PCB->get_sper()==1)
               {
                  $PCB->set_nstate(1);
               } 
            }
         $PCB=$PCB->get_next();
        }
      }
   }
}
sub check{
   my $PCB=$p;
   while(defined($PCB->get_next()))
   {
      my $t=$PCB->get_next();
      if($t->get_super()==0)
      {
         $PCB->set_next($t->get_next());
      }
      $PCB=$PCB->get_next();
   }
}
sub setpcb{
   if(!defined($p->get_next()))
   {
      die "the queue is NULL";
   }
   print "******************************************************\n";
   print "                      Setup Mode                      \n";
   print "stop-------------------------stop one/all process(es)\n";
   print "start------------------------------start one prorcess\n";
   print "exit-----------------------------------return to menu\n";
   print "help-------------------help you to check the commands\n";
   my $m;
   print "please enter your command\n";
   LINE:while($m=<STDIN>)
   {
      chomp($m);
      if($m eq "stop")
      {
         &stoppcb();
      }
      elsif($m eq "start")
      {
         &start();
      }
      elsif($m eq "show")
      {
         &show();
      }
      elsif($m eq "help")
      {
         &helptxt("sethelp.txt");
      }
      elsif($m eq "exit")
      {
          return ;
      }
      elsif(defined($m))
      {
         print "please enter your command:";
         next LINE;
      }
      else
      {
         print "cannot find that command\n";
         print "write help to inquire the command\n";
         next LINE;
      }
   }
}
sub stoppcb{
   print "******************************************************\n";
   print "                      Stop Mode                       \n";	
   print "single---------------------------------stop a process\n";
   print "all--------------------------------stop all processes\n";
   print "exit-----------------------------------return to menu\n";
   print "help-------------------help you to check the commands\n";
   my $PCB=$p->get_next();
   my $PCB2=$p;
   print "Please enter your command(you can enter \"-help\"to look the commands):";
   my $m;
   LINE1:while($m=<STDIN>)
   {
      chomp($m);
      if($m eq "all")
      {
         my $Ptr=$PCB->get_next();
         $PCB="";
         $p->set_next("");
         while(defined($Ptr))
         {
            my $t=$Ptr;
            $Ptr=$Ptr->get_next();
            $t="";
         }
      }
      elsif($m eq "single")
      {
         my $DID;
         &show();
         print "please enter the ID you want to delete ('q' to quit)\n";
         LINE2:while($DID=<STDIN>)
         {
            chomp($DID);
            if($DID eq 'q')
            {
               print "finish enter id\n";
               last LINE2;
            }
            while(defined($PCB2)&&$PCB2->get_next()->get_id()!=$DID)
            {
               $PCB2=$PCB2->get_next();
            }
            if(defined($PCB2))
            {
               my $t=$PCB2->get_next();
               $PCB2->set_next($t->get_next());
               $t="";
            }
            else
            {
               print "cannot find the process\n";
               print "u can wirte \"show\" to check the process statue";
               next LINE2; 
            }
            print "please enter the ID you want to delete\n";
         }
      }
      elsif($m eq "help")
      {
         &helptxt("stophelp.txt");
      }
      elsif($m eq "exit")
      {
         last LINE1;
      }
      elsif(defined($m))
      {
         print "please enter the command\n";
         next LINE1;
      }
      else 
      {
         print "cannot find that command\nwrite \"help\" to inquire the command\n";
         next LINE1;
      }
   print "******************************************************\n";
   print "                      Stop Mode                       \n";	
   print "single---------------------------------stop a process\n";
   print "all--------------------------------stop all processes\n";
   print "exit-----------------------------------return to menu\n";
   print "help-------------------help you to check the commands\n";
   }
}
sub start(){
   my $n;
   my $PCB=$p;
   print "******************************************************\n";
   print "                      Start Mode                      \n";
   &show();
   print "Please enter id number you want to start(enter 0 to exit):";
   $n=<STDIN>;
   chomp($n);
   if($n==0)
   {
      return ;
   }
   if($n>$nid)
   {
      print "cannot find the process \nplease write \"show\" to check the process\n";
      return ;
   }
   while($PCB->get_id()!=$n&&defined($PCB))
   {
      $PCB=$PCB->get_next();
   }
   if(defined($PCB))
   {
      if($PCB->get_nstate()!=1&&($PCB->get_rtime()>0))
      {
         $PCB->set_nstate(1);
         return ;
      }
   }
   else
   {
      print "cannot find the process \nplease write \"show\" to check the process\n";
      return ;
   }
}
sub show(){
   print "ID NAME SPER STATE RUNTIME\n";
   my $PCB=$p;
   my $count=0;
   LINE:while($PCB!=undef)
   {
      if($count==0)
      {
         ++$count;
         $PCB=$PCB->get_next();
         next LINE;
      }
      print" ";print$PCB->get_id();print"  ";print$PCB->get_name();print"    ";print$PCB->get_sper();print" ";print $cstate[$PCB->get_nstate()];print"      ";print$PCB->get_rtime();print"\n";
      $PCB=$PCB->get_next();
   }
}
sub input(){
   my $t1;
   my $n;
   print "please enter the commands:set,running,create,show,help or exit\n";
   while(1==1)
   {
      LINE:while($n=<STDIN>)
      {
         chomp($n);
         if($n eq "set")
         {
            &setpcb();
         }
         elsif($n eq "running")
         {
            $t1=threads->new(\&running);
         }
         elsif($n eq "create")
         {
            &create();
         }
         elsif($n eq "show")
         {
            &show();
         }
         elsif($n eq "help")
         {
            &helptxt("menuhelp.txt");
         }
         elsif($n eq "exit")
         {
            return ;
         }
         elsif(defined($n))
         {
            print "please enter the commands\n";
            next LINE;
         }
         else
         {
            print "cannot find the command\n write \"help\" to inquire the command";
            next LINE;
         }

      }
   }
}



#以下是主程序
	print "******************************************************\n";
	print "       Welcome to use my process simulation           \n";
	print "      This program is written by syz and wxy          \n";
	print "please enter commands(you can enter \"help\" to check the commands):";
        &input();
    	return 0;