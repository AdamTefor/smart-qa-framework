*** Settings ***
Library    SeleniumLibrary

*** Keywords ***
Click With Healing
    [Arguments]    ${primary_locator}    @{fallback_locators}

    # Essaye le locator principal
    ${status}=    Run Keyword And Return Status    Click Element    ${primary_locator}

    IF    not ${status}
        Log    Locator principal échoué, tentative fallback    WARN

        FOR    ${locator}    IN    @{fallback_locators}
            ${status}=    Run Keyword And Return Status    Click Element    ${locator}
            Exit For Loop If    ${status}
        END
    END

    Run Keyword Unless    ${status}    Fail    Tous les locators ont échoué
