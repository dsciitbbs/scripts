import time
import os
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
import colored
from colored import stylize
from sys import platform

def all_same(a, b, c, d):
    return a == b and c == d

def string_format(a, b, c, d):
    initial_space = 40
    consumed_space = len(a + " " + b + " \N{DOWNWARDS ARROW}")
    leftover_space = 65 - consumed_space
    actual_content = " " * initial_space + a + " " + b + " \N{DOWNWARDS ARROW}" + " " * leftover_space + c + " " + d + " \N{UPWARDS ARROW}"
    print(stylize(actual_content, colored.fg("aquamarine_1a")))

options = Options()
options.headless = True
options.add_experimental_option('excludeSwitches', ['enable-logging'])
driver = webdriver.Chrome(options=options, executable_path='/usr/local/share/chrome_driver/chromedriver')
driver.get("https://fast.com/")

if platform == "windows":
	os.system("cls")
else:
	os.system("clear")
print("\n"*8)

old_value = 0
old_unit = "Kbps"
u_old_value = 0
u_old_unit = "Kbps"
ticks = 0

for i in range(1, 3000):
    try:
        driver.find_element_by_id("show-more-details-link").send_keys(Keys.ENTER)
    except:
        pass

    try:
        new_value = driver.find_element_by_id("speed-value").text
        new_unit = driver.find_element_by_id("speed-units").text
        u_new_value = driver.find_element_by_id("upload-value").text
        u_new_unit = driver.find_element_by_id("upload-units").text

        if not u_new_value:
            u_new_value = "---"
        if not u_new_unit:
            u_new_unit = "---"
        if all_same(old_value, new_value, old_unit, new_unit) and all_same (u_old_value, u_new_value, u_old_unit, u_new_unit):
            ticks += 1
            time.sleep(1)
            if ticks == 10:
                break
            continue
        
        ticks = 0
        string_format(str(new_value), str(new_unit), str(u_new_value), str(u_new_unit))

        old_value = new_value
        old_unit = new_unit
        u_old_value = u_new_value
        u_old_unit = u_new_unit

        time.sleep(1)

    except Exception as e:
        print("Exception: "+ str(e))
        time.sleep(1)

driver.quit()