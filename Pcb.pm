#!/usr/bin/perl
use v5.14.2;
package Pcb;                                  #包Pcb在perl语言中相当于c++的类 
sub new                                       #Pcb类的构造函数，在perl中数据成员不单独列出而是放在构造函数中，sub声明一个函数
{
    my $invocant=shift;                        #函数的参数存放于@_数组中，shift相当于移出@_数组中第一个参数。
	my $class = ref($invocant)||$invocant;
    my $self = {                              #在这里存储着我们Pcb类中的所有数据
        id=>shift,
        name=>shift,
        rtime=>shift,
	nstate=>shift,
	sper=>shift,
	next=>shift,
	@_,
    };
    bless($self, $class);
    return $self;
}
sub set_id {                               #在这里的包括以下的函数都是都相当于该类的方法,这是设置进程id函数
    my ( $self, $id_number ) = @_;         #@_数组中存放的是函数的参数。
    $self->{id} = $id_number if defined($id_number);
    return $self->{id};
}
sub get_id {                                #获取Pcb对象id函数
    my( $self ) = @_;
    return $self->{id};
}
sub set_name{                              #设置Pcb对象的名称
    my($self,$name)=@_;
    $self->{name}=$name if defined($name);
    return $self->{name};
}
sub get_name{                             #获得对象名称
    my($self)=@_;
    return $self->{name};
}
sub set_rtime{                            #设置运行时间
    my($self,$rtime)=@_;
    $self->{rtime}=$rtime if defined($rtime);
    return $self->{rtime};
}
sub get_rtime{                             #获取运行时间
    my ($self)=@_;
    return $self->{rtime};
}
sub set_nstate{                           #设置运行状态
    my($self,$nstate)=@_;
    $self->{nstate}=$nstate if defined($nstate);
    return $self->{nstate};
}
sub get_nstate{                            #获得运行状态
    my($self)=@_;
    return $self->{nstate};
}
sub set_sper{                             #设置运行级别
    my($self,$sper)=@_;
    $self->{sper}=$sper if defined($sper);
    return $self->{sper};
}
sub get_sper{                             #获得运行级别
    my($self)=@_;
    return $self->{sper};
}
sub set_next{                              #存放下一个对象的引用（相当于指向下一个对象的指针）
    my($self,$next)=@_;
    $self->{next}=$next if defined($next);
    return $self->{next};
}
sub get_next{                             #返回下一个对象
    my($self)=@_;
    return $self->{next};
}
sub if_next_null{                       #判断该Pcb对象是否是尾节点
    my($self)=@_;
    return defined($self->{next});
}
1;
