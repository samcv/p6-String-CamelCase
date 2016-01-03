use v6;

unit module String::CamelCase;

class String::CamelCase::Decamelize {

    my regex camelized_block { ^^ (.+?) <before <:Lu>> };

    method parse_camelized(Str $given) returns Array {
        my $result = $given ~~ &camelized_block;
        $result ?? [ ~$result, |self.parse_camelized(substr $given, $result.to) ]
                !! [ ~$given ];
    }

    method filter_camelized(@elems, Int $from = 0) returns Array {

        return @elems if @elems.elems - 1 <= $from;

        if @elems[ $from ] ~~ m{ ^^ <:Lu>+ $$ } && @elems[ $from + 1 ] !~~ m{ ^^ <:Lu> <:Ll> } {

            @elems[ $from ] ~= @elems.splice($from + 1, 1)[0];

            return self.filter_camelized(
                @elems,
                $from
            );
        }
        else {
            return self.filter_camelized(
                @elems,
                $from + 1
            );
        }
    }
}


sub camelize(Str $given) is export(:DEFAULT) returns Str {
    $given.split(/\-|_/).map(-> $word { $word.tclc }).join;
}

sub decamelize(Str $given, Str $expr = '-') is export(:DEFAULT) returns Str {
    my @parsed = String::CamelCase::Decamelize.filter_camelized(String::CamelCase::Decamelize.parse_camelized($given));
    @parsed.map(-> $word { $word.lc }).join($expr);
}

=begin pod

=head1 NAME

String::CamelCase - Camelizes and decamelizes given string

=head1 SYNOPSIS

  use String::CamelCase;

=head1 DESCRIPTION

String::CamelCase is a module to camelize and decamelize a string.

=head1 FUNCTIONS

=head2 camelize (Str) returns Str

    camelize("hoge_fuga");
    #=> "HogeFuga"

    camelize("hoge-fuga");
    # => "HogeFuga"

=head2 decamelize (Str $string, [Str $connector = '-']) returns Str

    decamelize("HogeFuga");
    #=> hoge-fuga

    decmalieze("HogeFuga", "_");
    #=> hoge_fuga

=head1 AUTHOR

yowcow <yowcow@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 yowcow

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
