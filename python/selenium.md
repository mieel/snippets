# Selenium testing with Pytest
## create a conftest.py
```
import pytest
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def pytest_addoption(parser):
    parser.addoption("--username", action="store", default="default name")
    parser.addoption("--password", action="store", default="default password")

@pytest.fixture(scope="class")
def setup(request,base_url):
    # Setup code
    print("initiating chrome driver")
    options = Options()
    options.headless = True
    driver = webdriver.Chrome() #if not added in PATH
    driver.get(base_url)
    driver.implicitly_wait(10)
    request.cls.driver = driver
    # Start function    
    yield driver
    # Teardown code
    driver.close()
```
## create a test file
> :warning: **All pytest files, classes, functions should start with test**: Otherwise pytest can't find the test
- import stuff (make sure you `pip install` on new machines)
```
import pytest
import time
import urllib.parse
from flaky import flaky
from selenium import webdriver
from selenium.webdriver import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException
```

- Retrieve Argument Options from runtime command
```
@pytest.fixture()
def argoptions(pytestconfig):
    argoptions = {
        "username": pytestconfig.getoption("username"),
        "password": pytestconfig.getoption("password"),
        "base_url": pytestconfig.getoption("base_url")
    }
    return argoptions
```
> **note**: the `base_url` option is automatically mapped if you have `pytest-base-url` installed, and if you used --base-url in the command. This is why the option is not declared in the `conftest.py` file

- main TestClass, preceded with the `setup` decorator from the `conftest.py` file
```
@pytest.mark.usefixtures("setup")
class TestClass:
    
    @flaky(max_runs=3,rerun_filter=delay_rerun)             # Use flaky if you want to re-run on fail
    def test_title(self,argoptions):                        # pass in argoptions if needed
        assert argoptions['title'] in (self.driver.title)   # get expected title from argoptions, and assert it
    
    ...
```
- find a button and click it
```
    def test_button(self):
        self.driver.find_element_by_id('idOfButton').click()
```
- find a link 
```
    def test_company_details(self,argoptions):
        expected_href = '/link/to/assert/'
        xpath = '//a[@href="{}"]'.format(expected_href)
        link = self.driver.find_element_by_xpath(xpath)
        actual_href = link.get_attribute('href')
        assert expected_href in actual_href, f"link '{actual_href}' should be '{expected_href}'"
```

- Send keys to an inputbox and wait for expected result
```
        
       elem = self.driver.find_element_by_id("IdofElement")
        elem.send_keys("WAUZZZ8R7AA089479")
        # wait up to 10 seconds for the expected result
        wait = WebDriverWait(self.driver, 10)
        wait.until(EC.text_to_be_present_in_element((By.ID, "IdOfResultElement"), 'Result'))

```
- interact with a dropdown
```
from selenium.webdriver import ActionChains
...
    actions = ActionChains(self.driver)
    elem = self.driver.find_element_by_partial_link_text("dropdown")
    actions.move_to_element(elem).perform()
    self.driver.find_element_by_partial_link_text("itemfrom dropdown").click()
```
