*** Settings ***
Library           SeleniumLibrary


*** Variables ***
${Input_USERNAME}        name=username
${Input_PASSWORD}        name=password
${Button_LOGIN}         xpath=//button[@type='submit']

*** Keywords ***
Login with 
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible     name:username   10s
    Input Text    ${Input_USERNAME}    ${username}
    Wait Until Element Is Visible     name:password    10s
    Input Text    ${Input_PASSWORD}    ${password}
    Wait Until Element Is Visible     xpath=//button[@type='submit']    10s
    Click Button  ${Button_LOGIN}





