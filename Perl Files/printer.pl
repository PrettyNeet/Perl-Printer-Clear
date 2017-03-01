#Brian Chrysler and Brandon Miller
#!/usr/bin/perl
use strict;
use warnings;
use diagnostics;
use BW::Email;

my( @arystar,
	$counter,
	@printers,
	$printers,
	@printInstall,
	$printInstall,
	$num,
	$printerName,
	$location,
	$counter1,
	%jobhash,
	$jobhash,
	$jobid,
	$userid,
	@hash,
	$now,
	@now,
	$date,
	@aryjob,
	$userforemail,
	$shifted,
	$index,
	@jobsSorted,
	@jobsUser,
	$searchnew,
	$searchold,
	@config,
	$option,
	$command,
	$email,
	@jobsCanceled,
	$titlecounter);

system ('clear');
$counter=0;
$index=0;
$counter1=0;
$titlecounter=0;
$now = `date`;
@now = split / /,$now; #code taken from Diana's lab manual
@now = ($now[1],$now[2],$now[5]); #[1] is month, [2] is day, [3] is year from the `date`
chomp($date = join " ",@now); #joined on a space, into $date and printed.
print "$date \n";

open (INFILE,"printers.txt") || die "Cannot open infile: $! on line $.\n" ;
chomp(@printers=<INFILE>);
&openoutfiles;
open (CONFIG, "config.ini") || die "Cannot open infile: $! on line $.\n";
chomp (@config =<CONFIG>);
$index = 0;

foreach (@config) #checks the config file
{
	($command,$option)=split (':', $_);
	SWITCH:
	{
		($command =~ /RUN/i) and do #do you want the program to run?
		{
			if($option=~/yes/i)
			{
				print "run is: yes\n";	
				next;
			}
			elsif($option=~/no/i)
			{
				print "Run is: no\n\nEXITING PROGRAM RUN\n";
				exit;
			}
			else
			{
				print "ERROR on line $index of CONFIG, value other than yes/no found\n";
				print "No valid option for RUN configuration, exiting program\n\nGoodbye\n";
				exit;
			}
		};#end run case

		($command =~ /EMAIL/i) and do #do you want the program to email?
		{
			if($option=~/yes/i)
			{				
				print "Email is: yes\n";
				&matchPrinterEmail;
			}
			elsif($option=~/no/i)
			{
				&matchPrinters;
				print "Email is: no\n";
			}
			else
			{
				print "ERROR on line $index of CONFIG, value other than yes/no found\n";
			}
			last;
		};#end email case
		
		{ #default
			print "The line at index $index contains an error. Please check file CONFIG.\n";
			last;
		};
	}
	$index++;
}

close(INFILE);
close(EMAILLOG);
close(CLEARED);
#end of main

sub matchPrinters() #matches printers installed without email
{
	@printInstall =`lpstat -p -d | awk '{print \$2}'`; #http://localhost:631/help/options.html?TOPIC=Getting+Started&QUERY= CUPS website for printer managing author: Apple Inc. sepertates printers installed into columns and places them in an array
	foreach(@printers) #printers in infile
	{
		($num, $printerName, $location) = split (',',$_);
		chomp($num);
		chomp($printerName);
		chomp($location);
		foreach (@printInstall)
		{

			if(/$printerName/im)
			{
				print "The printer $printerName is installed on the computer\n\n";
				$counter++; # adds the 1 to the counter if a printer has been installed
				&jobclear($printerName);	#clear jobs using the current printer found
			}
			else
			{
				$counter1++; # adds the number of printers that were not found in the installed list
			}
		}
	}

	if ($counter1 != 0 && $counter == 0) #if no printers are found
	{
		print &star,"\n";
		print "No printers were found\n";
		print &star,"\n";
	}
	else #if printers are found
	{
		print &star,"\n";
		print "Number of found printers is $counter\n";
		print &star,"\n";
	}

}# end matchprinter sub

sub matchPrinterEmail #matches printers installed with email
{
	@printInstall =`lpstat -p -d | awk '{print \$2}'`;
	foreach(@printers)
	{
		($num, $printerName, $location) = split (',',$_);
		chomp($num);
		chomp($printerName);
		chomp($location);
		foreach (@printInstall)
		{

			if(/$printerName/im)
			{
				print "The printer $printerName is installed on the computer\n\n";
				$counter++; # adds the 1 to the counter if a printer has been installed
				&jobclearEmail($printerName);	#clear jobs using the current printer found
			}
			else
			{
				$counter1++; # adds the number of printers that were not found in the installed list
			}
		}
	}

	if ($counter1 != 0 && $counter == 0)
	{
		print &star,"\n";
		print "No printers were found\n";
		print &star,"\n";
	}
	else
	{
		print &star,"\n";
		print "Number of found printers is $counter\n";
		print &star,"\n";
	}
	

}# end matchprinterEmail sub

sub star #subroutine taken from Diana's lab manual. prints a line of stars
{
	@arystar="*" x 64;
	return @arystar;
}

sub jobclear() #clears job without emailing
{
	print "$printerName JOB QUEUE:\n";
	print &star,"\n";
	print(`lpstat -P $printerName | awk '{print "Job id is: "\$1 " User id is: "\$2 }'`);
	print "\n"; #formatting http://localhost:631/help/options.html?TOPIC=Getting+Started&QUERY= CUPS website for printer management author: Apple Inc.
	@hash = `lpstat -P $printerName | awk '{print \$1 " " \$2}'`; #assigns jobs in queue into hash

	foreach (@hash)
	{

		($jobid,$userid) = split / /,$_;
		$jobhash = $jobid; #key
		$jobhash{$jobid}=$userid;	#value
		chomp $jobhash{$jobid};
	}
	print CLEARED "$date\n\nJOBS CLEARED FROM PRINTER $printerName:\n";
	print "JOBS CLEARED FROM PRINTER $printerName:\n";
	print &star,"\n";
	foreach $jobid(sort {$jobhash{$a} cmp $jobhash{$b}} keys %jobhash)	#sorts by value	
	{	
		 
		print "$jobid USER IS:$jobhash{$jobid}\n";
		print CLEARED "$jobid USER IS:$jobhash{$jobid}\n";
		system "cancel $jobid"; #cancels job ttp://localhost:631/help/options.html?TOPIC=Getting+Started&QUERY= CUPS website author:Apple Inc.
			
	}
	print CLEARED "\n";
	print CLEARED &star,"\n";
		
	return @aryjob
}#end jobclear sub

sub jobclearEmail() #clears jobs and sends emails
{
	print "$printerName JOB QUEUE:\n";
	print &star,"\n";
	print(`lpstat -P $printerName | awk '{print "Job id is: "\$1 " User id is: "\$2 }'`);
	print "\n"; #formatting
	@hash = `lpstat -P $printerName | awk '{print \$1 " " \$2}'`;
	
	foreach (@hash)
	{
	($jobid,$userid) = split / /,$_;
	$jobhash = $jobid;
	$jobhash{$jobid}=$userid;
	chomp $jobhash{$jobid};
	
	}#end @hash foreach
	print &star,"\n";
	print "JOBS CLEARED FROM PRINTER $printerName:\n";
	print &star,"\n";
	print CLEARED "$date\n\nJOBS CLEARED FROM PRINTER $printerName:\n";
	
	$searchold="";	#old search value
	$userforemail="";	#user email
	$searchnew="";	#new search value
	foreach $jobid(sort {$jobhash{$a} cmp $jobhash{$b}} keys %jobhash) #sorted by username in descending order
	{
		$searchold=$searchnew;
		$searchnew=$jobhash{$jobid}; #sets search to new hash value
		
		if(!@jobsUser) #if the array is empty, assign the first value in. the next if statement only shifts in if there is an $searchold defined, which will be skipped initially
		{

			push (@jobsUser,$jobid);
			print CLEARED "$jobid USER IS:$jobhash{$jobid}\n";
			print "$jobid USER IS:$jobhash{$jobid}\n";
			system "cancel $jobid";
			next;
		}
		
		elsif ($searchold eq $searchnew) #checks to see if previously searched value is the same, if so, adds the key at the bottom of the @jobsUser
		{
			push (@jobsUser,$jobid);
			print CLEARED "$jobid USER IS:$jobhash{$jobid}\n";
			print "$jobid USER IS:$jobhash{$jobid}\n";
	 		system "cancel $jobid";
		}
		elsif ($searchold ne $searchnew)	#if the new value is different than the old, resets the #jobsUser
		{
			$userforemail=$searchold;
			&email($userforemail,@jobsSorted);
			print &star,"\n";
			@jobsUser=""; #resetting @jobsUser
			push (@jobsUser,$jobid);
			print CLEARED "$jobid USER IS:$jobhash{$jobid}\n";
			if($titlecounter==0)
			{
				print "JOBS CLEARED FROM PRINTER $printerName:\n";
				print &star,"\n";
			}
			print  "$jobid USER IS:$jobhash{$jobid}\n";
			system "cancel $jobid";
			our $titlecount++; #had to declare our for it to increment due to ownership
		}
		@jobsSorted = sort {$a cmp $b} @jobsUser;
	}#end jobid keys jobhash foreach
	print CLEARED "\n";
	print CLEARED &star,"\n";
	$userforemail=$searchold; #sends last email to last user from hash
	&email($userforemail,@jobsSorted);
	return @aryjob;
}#end jobclear email sub

sub openoutfiles #opens outfiles
{

	open (CLEARED, ">>ClearedLog.txt") or die "Couldn't open outfile for writing: $! on line $.\n";
	open (EMAILLOG, ">>EmailLog.txt") or die "Couldn't open outfile for writing: $! on line $.\n";
	print "All output files opened\n";
} #end openoutfiles sub

sub email() #https://metacpan.org/pod/BW::Email Email module Author:Bill Weinman
{
	

	$email = BW::Email ->new();

	$email->make_smtp_socket();
	$email->email_subject("Jobs Cleared on $printerName");
	$email->email_to("$userforemail\@test.local");
	$email->email_from("sysadmin\@test.local");
	$email->email_body("Dear $userforemail,\n\nWe have automatically cleared your job(s):\n@jobsSorted\n\nFrom the $printerName printer queue on $date in $location. Please refrain from cluttering the printer's queue.\n\nThank you,\n\nSys Admin");
	print &star,"\n";
	print $email->message;
	print "\n";
	print EMAILLOG $email->message;
	print EMAILLOG &star,"\n";
#doesn't currently send email, lacking socket
} #end email sub
