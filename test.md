# Scripts for life

This repository contains scripts that are commonly used by us for automation of every day tasks.

## Scripts
- iitbbs-internet

## Contribution

Please create a folder with a proper name and then add one more related scripts to automate a particular task.  

Open PR and explain how your script can be useful.  

Python & Bash scripts are generally preferred, although we won't mind something different like Powershell.


## Notes
- Use Python 3.7 and above. 
- Since bash is not really cross platform, use only Bash 5.0 syntax.  
- Add a github actions test `.github/workflows/<folder-name>.yml` for CI.  


**Note**: Avoid using *threading* library in Python for using system calls, use *subprocess* library instead.
