package Catmandu::Importer::Breaker;

use Catmandu::Sane;

our $VERSION = '0.01';

use Moo;
use namespace::clean;

with 'Catmandu::Importer';

sub generator {
    my ($self) = @_;
    sub {
        state $count   = 0;
        state $line;

        while ( defined( $line = $self->fh->getline ) ) {
            chomp $line;
            next if $line =~ /^\s*#/;

            my ($id,$field,$values) = split(/\s+/,$line,3);

            my ($namespace,$tag);

            if ($field =~ /^{(.*)}(\S+)/) {
                $namespace = $1;
                $tag = $2;
            }
            
            my $data = {
                _id       => $id ,
                field     => $field ,
                namespace => $namespace ,
                tag       => $tag ,
                data      => $values , 
            };

            return $data;
        }

        return;
    };
}

1;

__END__

=pod

=head1 NAME

Catmandu::Importer::Text - Package that imports textual data

=head1 SYNOPSIS

    # From the command line

    # separate fields by whitespace sequences just like awk
    catmandu convert Text --split '\s+' 

    # import all lines starting with '#', omitting this character 
    catmandu convert Text --pattern '^#(.*)'

    # In a Perl script

    use Catmandu::Importer::Text;

    my $importer = Catmandu::Importer::text->new( file => "/foo/bar.txt" );

    # print all lines with line number
    $importer->each(sub {
        my $item = $_[0];
        printf "%d: %s" , $item->{_id} , $item->{text};  
    });

=head1 DESCRIPTION

This package reads textual input line by line. Each line is
imported as item with line number in field C<_id> and text content in field
C<text>. Line separators are not included. Lines can further be split by
character or pattern and a regular expression can be specified to only import
selected lines and to translate pattern groups to fields.

=head1 CONFIGURATION

=over

=item file

Read input from a local file given by its path. Alternatively a scalar
reference can be passed to read from a string.

=item fh

Read input from an L<IO::Handle>. If not specified, L<Catmandu::Util::io> is used to
create the input stream from the C<file> argument or by using STDIN.

=item encoding

Binmode of the input stream C<fh>. Set to C<:utf8> by default.

=item fix

An ARRAY of one or more fixes or file scripts to be applied to imported items.

=item split

Single Character or regular expression (as string with a least two characters),
to split each line.  Resulting parts are imported in field C<text> as array.

=item pattern

Regular expression, given as string, to only import matching lines.
Whitespaces in patterns are ignored or must be escaped if patterns consists of
multiple lines. If the pattern contains capturing groups, captured values are
imported in field C<match> instead of C<text>.

For instance dates in C<YYYY-MM-DD> format can be imported as named fields with

   (?<year>\d\d\d\d)-(?<month>\d\d)-(?<day>\d\d)

or as array with

   (\d\d\d\d)-  # year
   (\d\d)-      # month
   (\d\d)       # day

=back

=head1 METHODS

Every L<Catmandu::Importer> is a L<Catmandu::Iterable> with all its methods 
inherited.

=head1 SEE ALSO

L<Catmandu::Exporter::Text>

L<Catmandu::Fix::parse_text>

Unix tools L<awk|https://en.wikipedia.org/wiki/AWK> and
L<sed|https://en.wikipedia.org/wiki/Sed>

=cut
