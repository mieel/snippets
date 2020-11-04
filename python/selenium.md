# Selenium testing with Pytest
## create a conftest.py
```
import pytest
from selenium import webdriver
from selenium.webdriver.firefox.options import Options as FirefoxOptions
from selenium.webdriver.chrome.options import Options as ChromeOptions

def pytest_addoption(parser):
    parser.addoption("--browser", action="store", default="Chrome")
    parser.addoption("--headless", action="store", default="No")
    parser.addoption("--username", action="store")
    parser.addoption("--userpass", action="store")

@pytest.fixture
def username(request):
    return  request.config.getoption("--username")

@pytest.fixture
def userpass(request):
    return  request.config.getoption("--userpass")

@pytest.fixture(scope="class")
def setup(request,base_url):
    # Setup code
    requested_browser = request.config.getoption("--browser")
    requested_headless = request.config.getoption("--headless")
    if requested_browser.lower() == "firefox":
        options = FirefoxOptions()
        if requested_headless.lower() == "yes":
            options.add_argument("--headless")
        driver = webdriver.Firefox(options=options)
    else:
        options = ChromeOptions()
        if requested_headless.lower() == "yes":
            options.add_argument("--headless")
        driver = webdriver.Chrome(options=options)
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
switch to an iframe
```
    iframe = self.driver.find_element_by_id("ifr0")
    self.driver.switch_to.frame(iframe)
```
