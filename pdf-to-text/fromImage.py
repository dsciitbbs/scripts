from PIL import Image
import pytesseract
import sys

if len(sys.argv) < 2:
	print('pass the location of the image as a command line argument')

name,file = sys.argv

im = Image.open(file)

text = pytesseract.image_to_string(im, lang = 'eng')

print(text)