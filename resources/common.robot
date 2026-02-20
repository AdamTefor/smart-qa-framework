*** Settings ***
Library           SeleniumLibrary
Resource          config.robot


*** Keywords ***
Open OrangeHRM
       Open Browser   ${BASE_URL}    ${BROWSER}
       Maximize Browser Window
       Set Selenium Timeout    ${TIMEOUT}     

Close OrangeHRM
       Close Browser    