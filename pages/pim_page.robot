*** Settings ***
Library           SeleniumLibrary


*** Variables ***
${PIM}    //a[@href="/web/index.php/pim/viewPimModule"]
${FIRST_NAME}    name=firstName
${LAST_NAME}    name=lastName
${EMPLOYEE_ID}    //label[text()="Employee Id"]/following::input[1]
${SAVE_BUTTON}    xpath=//button[@type='submit']
${UPLOAD_PHOTO}    //input[@type="file"]
${Click_Add}       //button[normalize-space()="Add"]

*** Keywords ***
Go to PIM Page
    Wait Until Element Is Visible     ${PIM}       5s
    Click Element    ${PIM}
    Wait Until Element Is Visible    ${Click_Add}       5s
    Click Button  ${Click_Add}

Add New Employee
      [Arguments]  ${first.name}    ${last.name}    ${employee.id}
    Wait Until Element Is Visible     ${FIRST_NAME}       10s
    Input Text    ${FIRST_NAME}    ${first.name}
    Wait Until Element Is Visible     ${LAST_NAME}        10s    
    Input Text    ${LAST_NAME}    ${last.name}
    Wait Until Element Is Visible     ${EMPLOYEE_ID}      10s
    Input Text    ${EMPLOYEE_ID}    ${employee.id}

Upload Employee Photo    
    [Arguments]  ${photo.path}
    Wait Until Page Contains Element    ${UPLOAD_PHOTO}    10s
    Execute Javascript    document.querySelector('input[type="file"]').style.display='block';
    Choose File    ${UPLOAD_PHOTO}    ${photo.path}

    Wait Until Element Is Visible     ${SAVE_BUTTON}      10s
    Click Button  ${SAVE_BUTTON}