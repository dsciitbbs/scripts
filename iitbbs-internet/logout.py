import sys
import time
from getpass import getpass

from selenium import webdriver
from selenium.webdriver.firefox.options import Options

options = Options()
options.headless = True

driver = webdriver.Firefox(options=options)

try:
	driver.get("http://192.168.1.5:8090/")
except:
	sys.exit(0)

user = input('Username: ')
pssw = getpass(prompt='Password: ')	

username = driver.find_element_by_name("username")
username.clear()

password = driver.find_element_by_name("password")
password.clear()

username.send_keys(user)
password.send_keys(pssw)

driver.find_element_by_id("loginbutton").click()

time.sleep(0.5)

driver.switch_to.window(driver.window_handles[1])
driver.close()
driver.switch_to.window(driver.window_handles[0])

driver.find_element_by_id("loginbutton").click()

print ("Logged Out.")

driver.close()
