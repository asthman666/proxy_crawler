my $app = sub {
    my $env = shift;

    my $is_anonymous = 1;
    if ( $env->{HTTP_X_FORWARDED_FOR} ) {
       $is_anonymous = 0;                
    }
    return [ 200, [ 'Content-Type' => 'text/plain' ], [$is_anonymous] ];
    #use Data::Dumper; 
    #return [ 200, [ 'Content-Type' => 'text/plain' ], [Dumper $env] ];
};
