
import sys
import requests # pip install requests

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.Chrome.options import Options

driver = webdriver.Chrome()
driver.get('https://mixing.dj/livesets/tronic-radio/')
all_links = [elem.get_attribute("href") for elem in driver.find_elements_by_tag_name('a')]

download_path = "D:\Downloads\Tronic_Radio"
good_links = []
for link in all_links:    
    try:
        if 'https://mixing' in link:
            good_links.append(link)
    except Exception as e:
        print('bad link')

# make Set (unique list)
links_set = set(good_links)

for pagelink in links_set:
    # Go to each link, find download button, download mp3    
    driver.get(pagelink)
    #Get download button
    try:
        elem = driver.find_element_by_link_text('Download')
    except Exception:
        print('No download button found')
    else:        
        if elem is None:
            print('No download button found') #skip
        else:
            download_url = elem.get_attribute('href')
            if download_url is None:
                print('no link found') #skip
            else:
                file_name = pagelink.split("/")[-2]
                print('downloading {}...'.format(file_name))
                r = requests.get(download_url)
                full_path = "{}\{}.mp3".format(download_path,file_name)
                print('saving to {}...'.format(full_path))
                with open(full_path, 'wb') as outfile:
                    outfile.write(r.content)



