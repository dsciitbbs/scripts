# Script for finding an english word used in your movie collection

I have organised my movie collection in a particular way, with each movie in a folder with a subtitle `.srt` file.
As I am trying to improve my vocabulary (for some exam) I wanted to write a script to find the word if it was used in any movie that I have in my collection. I wanted to automate this.  

So, I wrote a very basic script which uses grep to search for the term in subtitle files and play a 20 second window of the video surrounding the word usage.  

## What do you need

You need to have `grep` and `vlc` installed in your computer.  
You need to have each movie in a folder with its subtitle file and video file.  
It is pretty easy to organise like this with some another script, which you can write depending on your requirement.  
Set the variable `path_to_movies_folder` in the script according to that.  

## What it does

Set the variable `searchterm` with the word you want to search for.  
One by one, each hit will start playing in vlc, (a 20 second window).  
You will have to quit vlc (using command + Q in my case) and then you will go to next clip.  
You can stop the script by pressing ctrl + C during a 2 sec gap to this next clip only, otherwise zombie processes will be created.  

## Future Suggestions
- Since I have arranged all the movies by year, I could take the advantage of multi-processing to parallelly search through movies of particular year.  
- We can use `subprocess` module instead of `os.system` or use `os.kill` command in the script to avoid manual killing of the vlc clip.  
- Adding of signal handlers to skip the clip or skip the word to go for the next word.  

Written by MadhavTummala[https://github.com/MadhavChoudhary]
