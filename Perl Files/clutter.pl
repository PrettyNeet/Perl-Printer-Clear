#!/usr/bin/perl
system "touch test.txt";
system "echo asdhaskjhdas > test.txt";
system "lp -o job-hold-until=indefinite test.txt";
system "lp -o job-hold-until=indefinite test.txt";
