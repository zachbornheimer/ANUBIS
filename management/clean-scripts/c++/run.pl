#!/usr/bin/perl
use warnings;

exec("./astyle --options='.astylerc' " . join(" ", @ARGV));
