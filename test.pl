# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test;
BEGIN { plan tests => 6 };
use Tie::LazyList;

$Test::Harness::verbose = 1;

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $class       = 'Tie::LazyList'; # class all arrays are tied to
my $rand_nums   = 128;   # how many random numbers will it include
my $upper_bound = 128;   # the maximal number in the test range : 0 .. max 
my $times       = 20;    # how many times every test executed
my $anim_sleep  = 0.025;
my @anim_chars  = qw ( - \ | / );
my $anim_chars  = @anim_chars;

print "Test 1 .. ";
ok( test1()); # testing APROG
print "Test 2 .. ";
ok( test2()); # testing GPROG, POW
print "Test 3 .. ";
ok( test3()); # testing APROG_SUM
print "Test 4 .. ";
ok( test4()); # testing GPROG_SUM
print "Test 5 .. ";
ok( test5()); # testing FIBON
print "Test 6 .. ";
ok( test6()); # testing FACT

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Generates array of numbers ( random, ordered or reversed ) according to the mode
# Returns ref to array
sub numbers ($){
	local $_;
	my ( $mode ) = @_;
	
	$mode = $mode % 3;
	if ( $mode == 0 ){
		# random numbers
		my @numbers = ();
		push @numbers, int rand ( $upper_bound + 1 ) for ( 1 .. $rand_nums );
		return \@numbers;
	} elsif ( $mode == 1 ){
		# ordered numbers
		return [ 0 .. $upper_bound ];
	} elsif ( $mode == 2 ){
		# numbers in reversed order
		return [ reverse ( 0 .. $upper_bound )];
	}
}


sub animate ($) {
	local $_;
	my ( $number ) = @_;
	print $anim_chars[ $number % $anim_chars ],"\b";
	select ( undef, undef, undef, $anim_sleep );
}


# testing APROG
sub test1 {
	local $_;
	
	my @APROG = ();
	$APROG[ $_ ] = 1 + $_ for ( 0 .. $upper_bound );

	for ( 1 .. $times ){
		animate( $_ );

		my ( @arr, @arr2 );
		tie @arr, $class, 1, sub { my( $arr_ref, $n ) = @_; 
													   $arr_ref->[ $n - 1 ] + 1 };
		tie @arr2, $class, [ 1, 2 ], 'APROG';
		
	
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr[ $n ] == $APROG[ $n ] )){
				return 0;
			}
		}
	}	
	return 1;
}


# testing GPROG, POW
sub test2 {
	local $_;
	
	my @POW2    = ( 1 );
	$POW2[ $_ ] = $POW2[ $_ - 1 ] * 2 for ( 1 .. $upper_bound );

	for ( 1 .. $times ){
		animate( $_ );
		
		my ( @arr, @arr2, @arr3 );
		
		tie @arr, $class, 1, sub { my( $arr_ref, $n ) = @_; 
													   $arr_ref->[ $n - 1 ] * 2 };
		tie @arr2, $class, [ 1, 2 ], 'GPROG';
		tie @arr3, $class, 2, 'POW';
	
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr2[ $n ] == $arr3[ $n ] ) and 
					  ( $arr3[ $n ] == $POW2[ $n ] )){
				return 0;
			}
		}
	}	
	return 1;
}

# testing APROG_SUM
sub test3 {
	
	my @APROG_SUM = ();
	$APROG_SUM[ $_ - 1 ] = ( $_ + ( $_ * $_ )) / 2 
		for ( 1 .. $upper_bound + 1 );
		
	for ( 1 .. $times ){
		animate( $_ );
		
		my ( @arr, @arr2 );
		tie @arr,  $class, [ 1, 2 ], 'APROG_SUM';
		tie @arr2, $class, [ 1, 2 ], 'APROG_SUM';		
		
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr[ $n ] == $APROG_SUM[ $n ] )){
				return 0;
			}
		}
	}
	
	return 1;	
}


# testing GPROG_SUM
sub test4 {
	local $_;

	my @POW2    = ( 1 );
	$POW2[ $_ ] = $POW2[ $_ - 1 ] * 2 for ( 1 .. $upper_bound + 1 );
		
	for ( 1 .. $times ){
		animate( $_ );

		my @arr;	
		tie @arr,  $class, [ 1, 2 ], 'GPROG_SUM';
		tie @arr2, $class, [ 1, 2 ], 'GPROG_SUM';
		
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr[ $n ] == ( $POW2[ $n + 1 ] - 1 ))){
				return 0;
			}
		}		
	}

	return 1;
}

# testing FIBON
sub test5 {
	local $_;

	my @FIBON = ( 0, 1 );
	$FIBON[ $_ ] = $FIBON[ $_ - 1 ] + $FIBON[ $_ - 2 ] 
		for ( 2 .. $upper_bound );
	
	for ( 1 .. $times ){
		animate( $_ );

		my ( @arr, @arr2 );
		tie @arr,  $class, [ 0, 1 ], sub { my ( $array_ref, $n ) = @_;
																  $array_ref->[ $n - 1 ] + $array_ref->[ $n - 2 ] };
		tie @arr2, $class, [ 0, 1 ], 'FIBON';
		
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr[ $n ] == $FIBON[ $n ] )){
				return 0;
			} 
		}
	}

	return 1;
}

# testing FACT
sub test6 {
	local $_;
	
	my @FACT = ( 1 );
	$FACT[ $_ ] = $FACT[ $_ - 1 ] * $_ for ( 1 .. $upper_bound );
	
	for ( 1 .. $times ){
		animate( $_ );
		
		my ( @arr, @arr2 );
		tie @arr,  $class, 1, sub { my ( $array_ref, $n ) = @_;
														 $array_ref->[ $n - 1 ] * $n };
		tie @arr2, $class, [ 1 ], 'FACT';
		
		for my $n ( @{ numbers( $_ ) } ){
			unless (( $arr[ $n ] == $arr2[ $n ] ) and ( $arr[ $n ] == $FACT[ $n ] )){
				return 0;
			} 
		}
	}
	
	return 1;	
}
