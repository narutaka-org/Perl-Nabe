
#----------------------------------------------------------------------------------------------------------
#	全く意味はないがPerlでオーバーロードっぽいことやったらどうなるかと思って
#----------------------------------------------------------------------------------------------------------

use utf8;
use strict;
use warnings;
use Math::BigInt;
use Math::BigFloat;
use Data::Dumper;

#----------------------------------------------------------------------------------------------------------
#	Test Main
#----------------------------------------------------------------------------------------------------------

	#----------------------------------------------------------
	#テストコード
	#----------------------------------------------------------

	#２点作る
	my $p1 = myPoint->new(0,0,0);
	my $p2 = myPoint->new(4,4,0);

	#線分作る
	my $l1 = myLine->new($p1,$p2);

	#2点の距離or線分の長さ
	print qq(\n-length-\n);
	my $x1 = myGeometry::distance($p1,$p2);
	my $x2 = myGeometry::distance($l1);
	print qq($x1\n$x2\n);

	#２点の中心or線分の中心
	print qq(\n-Coordinate-\n);
	my @x3 = myGeometry::midpoint($p1,$p2);
	my @x4 = myGeometry::midpoint($l1);
	print qq($x3[0],$x3[1],$x3[2]\n$x4[0],$x4[1],$x4[2]\n);

	#ヘロンの公式
	my $p3 = myPoint->new(4,4,4);
	print qq(\n-area-\n);
	my $x5 = myGeometry::herons($p1,$p2,$p3);
	my $x6 = myGeometry::herons($l1,$p3);
	my $x7 = myGeometry::herons($p3,$l1);
	print qq($x5\n$x6\n$x7\n);

#----------------------------------------------------------------------------------------------------------
#	myGeometry
#----------------------------------------------------------------------------------------------------------

package myGeometry;

use strict;
use Math::BigInt;
use Math::BigFloat;
use Data::Dumper;

	#２点の距離	&distance(myPoint,myPoint)
	#線分の長さ	&distance(myLine)
	sub distance
	{
		my (@p1,@p2);
		if( ref($_[0]) eq "myLine" )
		{
			my @l1 = $_[0]->lab;		
			@p1 = $l1[0]->pxyz;
			@p2 = $l1[1]->pxyz;
		}
		if( ref($_[0]) eq "myPoint" && ref($_[1]) eq "myPoint" )
		{
			@p1 = $_[0]->pxyz;
			@p2 = $_[1]->pxyz;
		}
		my $nx = $p2[0] - $p1[0];
		my $ny = $p2[1] - $p1[1];
		my $nz = $p2[2] - $p1[2];

		my $x = abs($nx*$nx + $ny*$ny + $nz*$nz);
		return sqrt($x);
	}

	#２点の中心	&distance(myPoint,myPoint)
	#線分の中心	&distance(myLine)	
	sub midpoint
	{
		my (@p1,@p2);
		if( ref($_[0]) eq "myLine" )
		{
			my @l1 = $_[0]->lab;		
			@p1 = $l1[0]->pxyz;
			@p2 = $l1[1]->pxyz;
		}
		if( ref($_[0]) eq "myPoint" && ref($_[1]) eq "myPoint" )
		{
			@p1 = $_[0]->pxyz;
			@p2 = $_[1]->pxyz;
		}
		my $nx = ($p1[0] + $p2[0])/2;
		my $ny = ($p1[1] + $p2[1])/2;
		my $nz = ($p1[2] + $p2[2])/2;
		return ($nx,$ny,$nz);
	}

	#３点の三角形面積
	#１点と１線の三角形面積
	sub herons
	{
		my ($p1,$p2,$p3);
		if( ref($_[0]) eq "myPoint" && ref($_[1]) eq "myPoint" && ref($_[2]) eq "myPoint" )
		{
			$p1 = $_[0];
			$p2 = $_[1];
			$p3 = $_[2];
		}
		if( ref($_[0]) eq "myLine" && ref($_[1]) eq "myPoint" )
		{
			$p1 = $_[1];
			my @l1 = $_[0]->lab;		
			$p2 = $l1[0];
			$p3 = $l1[1];
		}
		if( ref($_[0]) eq "myPoint" && ref($_[1]) eq "myLine" )
		{
			$p1 = $_[0];
			my @l1 = $_[1]->lab;		
			$p2 = $l1[0];
			$p3 = $l1[1];
		}		
		my $l1 = distance($p1,$p2);
		my $l2 = distance($p2,$p3);
		my $l3 = distance($p3,$p1);
		my $st = ($l1+$l2+$l3)/2;
		my $x = $st*($st-$l1)*($st-$l2)*($st-$l3);
		return sqrt($x);
	}	

#----------------------------------------------------------------------------------------------------------
#	myLine
#----------------------------------------------------------------------------------------------------------

package myLine;

use strict;
use Math::BigInt;
use Math::BigFloat;
use Data::Dumper;

	#myLine->new( nmPoint, nmPoint );	#Line生成
	sub new
	{
		my $self  = {};
		$self->{A} = undef;
		$self->{B} = undef;
		if (@_) 
		{
			shift;
			$self->{A} = shift;
			$self->{B} = shift;
		}
		bless($self);
		return $self;
	}

	#PointAを返す、または設定
	sub la 
	{
		my $self = shift;
		if (@_) { $self->{A} = shift; }
		return $self->{A};
	}

	#PointBを返す、または設定
	sub lb 
	{
		my $self = shift;
		if (@_) { $self->{B} = shift; }
		return $self->{B};
	}

	#PointA,Bを返す、または設定
	sub lab 
	{
		my $self = shift;
		if (@_) 
		{
			$self->{A} = shift;
			$self->{B} = shift;
		}
		return ($self->{A},$self->{B});
	}

#----------------------------------------------------------------------------------------------------------
#	myPoint
#----------------------------------------------------------------------------------------------------------

package myPoint;

use strict;
use Math::BigInt;
use Math::BigFloat;
use Data::Dumper;

	#myPoint->new( bigint, bigint, bigint );		#Point生成
	sub new 
	{
		my $self  = {};
		$self->{X} = undef;
		$self->{Y} = undef;
		$self->{Z} = undef;
		if (@_) 
		{
			shift;
			$self->{X} = shift;
			$self->{Y} = shift;
			$self->{Z} = shift;
		}
		bless($self);
		return $self;
	}

	sub px 
	{
		my $self = shift;
		if (@_) { $self->{X} = shift; }
		return $self->{X};
	}

	sub py 
	{
		my $self = shift;
		if (@_) { $self->{Y} = shift; }
		return $self->{Y};
	}

	sub pz 
	{
		my $self = shift;
		if (@_) { $self->{Z} = shift; }
		return $self->{Z};
	}

	sub pxy 
	{
		my $self = shift;
		if (@_) 
		{
			$self->{X} = shift;
			$self->{Y} = shift;
		}
		return ($self->{X},$self->{Y});
	}

	sub pxyz 
	{
		my $self = shift;
		if (@_) 
		{
			$self->{X} = shift;
			$self->{Y} = shift;
			$self->{Z} = shift;
		}
		return ($self->{X},$self->{Y},$self->{Z});
	}

#----------------------------------------------------------------------------------------------------------
0;