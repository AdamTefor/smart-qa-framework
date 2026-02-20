*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${DASHBOARD_TEXT}    //h6[normalize-space()="Dashboard"]

*** Keywords ***
Verify Dashboard
    Page Should Contain Element    ${DASHBOARD_TEXT}
