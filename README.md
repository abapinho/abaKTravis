(abaK is still in alpha stage. It's API can change. Please don't using for production objects just yet. Wait for a release.)

# abaK

A powerful yet simple ABAP library to manage constants.

## Why
Today, whenever a constant is need in a program, it has to be hard coded, stored in a dedicated custom ZTABLE or, even worse, stored in standard table TVARVC (or similar).

## What
abaK provides a simple yet powerful and flexible way for any program to manage its constants. Advantages of using abaK:
- decentralized: there is no monolithic table holding all the constants. One program can decide to have its own constants source.
- easily customized: a project can decide to have its constants maintainable directly in PRD while another may required them to be maintained in DEV and then transported;
- multiple scopes: some constants can be used system-wide while others can belong to a single program and no one else will mess with them;
- system-wide management: constant sources are registered in a central table so that it is easy to keep track of the existing data sources 
- extensible: if needed, new data sources can be created (ex.: to read legacy data in a specific data format)

## How
Providing a well-defined API, abaK separates the way it is used from the way the constants are stored. abaK is based on the concept of data sources. It currently has 3 working data sources: custom table, custom table with Shared Objects and XML. A couple more are planned (to read the XML from an URL for example). It also allows for new data sources to be created for specific needs.

Documentation in the [wiki](https://github.com/abapinho/abak/wiki).

## Requirements
* ABAP Version: 702 or higher.
* [abapGit](https://abapgit.org)

## FAQ
For questions/comments/bugs/feature requests/wishes please create an [issue](https://github.com/abapinho/abak/issues).
