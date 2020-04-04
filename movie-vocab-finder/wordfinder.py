import os
import subprocess
from time import sleep

path_to_movies_folder = '/Volumes/Seagate/Movies\ English/Movies\ English'

searchterm = 'imbecile'

command = "grep -r -i -B 4 --include=\*.srt '{}' {}".format(searchterm,path_to_movies_folder)

out = os.popen(command)

hits = out.read()
hits = hits.split('--\n')

hits_dict = {}

for hit in hits:
	lines = hit.split('\n')
	for line in lines:
		if '-->' in line:
			sections = line.rsplit('/',1)
			movie = sections[0]
			subtitle,time = sections[1].rsplit('srt-',1)

			if movie not in hits_dict.keys():
				hits_dict[movie] = {}

			if subtitle not in hits_dict[movie].keys():
				hits_dict[movie][subtitle] = []

			hits_dict[movie][subtitle].append(time)

for movie in hits_dict:
	subtitle = list(hits_dict[movie].keys())[0]
	for time in hits_dict[movie][subtitle]:
		start,stop = time.split('-->')
		h,m,s = start.split(':')
		start = int(h)*3600 + int(m)*60 + int(s.split(',')[0])
		h,m,s = stop.split(':')
		stop = int(h)*3600 + int(m)*60 + int(s.split(',')[0])

		start -= 10
		stop += 5

		for file in os.listdir(movie):
			if file.endswith('.mp4') or file.endswith('.mkv') or file.endswith('.avi'):
				file = movie+'/'+file
				file = file.replace(' ','\ ')
				file = file.replace('(', '\(')
				file = file.replace(')', '\)')
				cmd = 'vlc --start-time {} --stop-time {} {}'.format(start,stop,file)
				os.system(cmd)
				# p = subprocess.Popen("exec " + cmd, stdout=subprocess.PIPE, shell=True)
				# time.sleep(15)
				# p.kill()

		sleep(2)