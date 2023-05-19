Name:        WINPMT.BAT

Description: Custom Command Processor prompt for Windows 10+.  
             Windows before version 10 has no native support for ANSI colors on the console, hence the original work in the article
             below has not worked since support for the MS-DOS subsystem was dropped, dropping ANSI.SYS support.
             An update to an article originally published in PC Magazine, originally dated March 28th, 1995 page 252.
             https://books.google.com/books?id=eMKimy4DFaEC&printsec=frontcover&source=gbs_ge_summary_r&cad=0#v=onepage&q&f=false

             This script takes advantage of escape sequences originally supported by ANSI.SYS that were added back into Windows 10+:
             https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences

              NOTE: This now ONLY works on Windows 10+ as it takes advantages of specific codes and functions only available in
                    Windows 10+.

Author:      Russ Le Blang

Date:        May 11th, 2023
