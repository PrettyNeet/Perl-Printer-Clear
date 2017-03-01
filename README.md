# Perl-Printer-Clear
A Perl script that checks a list of printers on a network and clears their queue (meant to be used in crontab) and emails the user warning them

This was created for a class project. All files that are needed to run the script are found within the Perl Files folder.

## Project Functionality
The system administrator will add all printers to be checked to an infile and set up the config file for which features he wishes to run. Depending on the features chosen in the config file (RUN, EMAIL, LOG), the program will step into those switches which will call the appropriate subroutines. If all conditions are true for the switch, the program will run, clear the queue, email the user and log that information (and any combination of these). The program reads the printer names from an infile, matches them to an awk of lpstat and lists all the users and jobs which get assigned into a hash. The hash is then interated through to find all the jobs (if any) that have the same user which is then assigned into an array that will be used for either (or both) the log file and email that will be sent to the user. Once the jobs are cleared, a log is recorded for the amount of jobs, what jobs and who was responsible, as well as the email sent.


