*** Settings ***
Library           SeleniumLibrary
Resource          ../resources/common.robot
Resource          ../pages/login_page.robot
Resource          ../pages/dashboard_page.robot

Test Setup    Open OrangeHRM
Test Teardown    Close OrangeHRM

*** Test Cases ***

TC_LOGIN_01 — Connexion valide
    [Tags]   TF-2
    Login with    admin    admin123
    Wait Until Page Contains        Dashboar    10s   
    Verify Dashboard

TC_LOGIN_02 — Connexion invalide
    [Tags]   TF-3
    Login with    invalid_user    invalid_pass
    Wait Until Page Contains        Invalid credentials    5s
