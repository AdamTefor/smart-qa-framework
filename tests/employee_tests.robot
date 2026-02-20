*** Settings ***
Library           SeleniumLibrary
Resource          ../resources/common.robot
Resource          ../pages/login_page.robot
Resource          ../pages/pim_page.robot

Test Setup    Open OrangeHRM
Test Teardown    Close OrangeHRM


*** Test Cases ***
TC_EMP_01 — Ajouter un employé
    [Tags]   TF-4
    Login with    admin    admin123
    Wait Until Page Contains        Dashboard        10s
    Go To PIM Page
    Add New Employee    Adam    Tefor    1346
    Sleep        5s
    Upload Employee Photo    C:/Users/USER/Desktop/smart-qa-framework/data/image/Photo.jpg
    Sleep        5s
    Wait Until Page Contains       Personal Details   10s 
    Sleep        5s


