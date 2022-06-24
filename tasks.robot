*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.Tables
Library             RPA.Desktop
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Open the browser and order a bunch of robots
    Open the website and close pop-up
    Download the sheet
    Fill all orders
    Creating Zip Archive


*** Keywords ***
Download the sheet
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Open the website and close pop-up
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order    maximized=True    headless=True
    Close pop up

Fill in one order
    [Arguments]    ${order_list}
    Select From List By Index    xpath://*[@id="head"]    ${order_list}[Head]
    Select Radio Button    body    ${order_list}[Body]
    Input Text    class:form-control    ${order_list}[Legs]
    Input Text    id:address    ${order_list}[Address]
    Click Button    id:preview
    Sleep    2s

Submit order
    Click Button    id:order
    Wait Until Page Contains Element    id:order-another

Close pop up
    Wait Until Page Contains Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Fill all orders
    ${order_list}=    Read table from CSV    orders.csv    header=True
    FOR    ${order_list}    IN    @{order_list}
        Fill in one order    ${order_list}
        Wait Until Keyword Succeeds    100x    0.2 sec    Submit order
        Save receipt as PDF    ${order_list}
        Click Button    id:order-another
        Close pop up
    END

Save receipt as PDF
    [Arguments]    ${order_list}
    Wait Until Element Is Visible    id:receipt
    ${receipt_order}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_order}    ${OUTPUT_DIR}${/}PDFs${/}order_number${order_list}[Order number].pdf
    Take screenshot and add it to the PDF    ${order_list}

Take screenshot and add it to the PDF
    [Arguments]    ${order_list}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}preview${/}${order_list}[Order number].png
    ${png_list}=    Create List    ${OUTPUT_DIR}${/}preview${/}${order_list}[Order number].png
    Add Files To Pdf
    ...    ${png_list}
    ...    ${OUTPUT_DIR}${/}PDFs${/}order_number${order_list}[Order number].pdf    append=True

Creating Zip Archive
    Archive Folder With Zip    ${OUTPUT_DIR}${/}PDFs    ${OUTPUT_DIR}${/}PDFs.zip    recursive=True
