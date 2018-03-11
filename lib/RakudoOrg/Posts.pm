package RakudoOrg::Posts;

use base 'Mojo::Base';

use Text::MultiMarkdown qw/markdown/;
use File::Glob qw/bsd_glob/;
use Mojo::File qw/path/;
use Mojo::Util qw/decode  encode  xml_escape/;

sub all {
    my @posts = bsd_glob 'post/*.md';
    s/\.md$// for @posts;
    my @return;
    for (@posts) {
        my ($meta) = process(decode 'UTF-8', path("$_.md")->slurp);
        next if $meta->{draft};
        push @return, {
            date  => $meta->{date},
            title => $meta->{title},
            desc  => $meta->{desc},
            post  => (substr $_, length 'post/'),
       };
    }
    return [ sort { $b->{date} cmp $a->{date} } @return ];
}

sub load {
    my ($self, $post) = @_;
    my $post_file = "post/$post.md";
    return unless -f $post_file and -r _;
    my ($meta, $content) = process(decode 'UTF-8', path($post_file)->slurp);
    return $meta, markdown $content;
}

sub process {
    my $post = shift;
    my %meta;
    $meta{$1} = $2 while $post =~ s/^%%\s*(\w+)\s*:\s*([^\n]+)\n//;
    $post =~ s/^```$//gm;
    return \%meta, $post;
}

1;