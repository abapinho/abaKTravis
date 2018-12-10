# abaK

ABAP constants done right.

## Why
Today, whenever a constant is need in a program, it has to be hard coded, stored in a dedicated custom ZTABLE or, even worse, stored in standard table TVARVC (or similar).

## What
abaK provides a simple yet powerful and flexible way for any program to manage its constants. Depending on what is needed, these constants:
- are decentralized: there is no monolithic table holding all the constants. One program can decide to have its own constants source.
- are easily customized: a project can decide to have its constants maintainable directly in PRD while another may required them to be maintained in DEV and then transported;
- can have any desired scope: some constants can be used system-wide while others can belong to a single program and no one else will mess with them;
- are extensive: if needed, a specific project can create a new data source (ex.: to read legacy data in a specific data format)

## How
Providing a well-defined API, abaK separates the way it is used from the way the constants are stored. abaK is based on the concept of data sources. It currently has 3 working data sources: custom table, custom table with Shared Objects and XML. A couple more are planned (to read the XML from an URL for example). It also allows for new data sources to be created for specific needs.

Documentation here: [[ Home ]]
