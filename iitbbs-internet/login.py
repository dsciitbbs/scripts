import sys
from getpass import getpass,getuser

from selenium import webdriver
from selenium.webdriver.firefox.options import Options

options = Options()
options.headless = True

driver = webdriver.Firefox(options=options)

user = raw_input('Username: ')
pssw = getpass(prompt='Password: ')

try:
        driver.get("http://192.168.1.5:8090/")
except:
        sys.exit(0)

username = driver.find_element_by_name("username")
username.clear()

password = driver.find_element_by_name("password")
password.clear()

username.send_keys(user)
password.send_keys(pssw)

driver.find_element_by_id("loginbutton").click()

print "Logged In."

driver.close()
