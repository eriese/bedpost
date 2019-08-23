[![Build Status](https://travis-ci.org/eriese/bedpost.svg?branch=rails-5)](https://travis-ci.org/eriese/bedpost)

# Bedpost
BedPost is a sex diary that uses user-inputted data to help users track their risk of sexually transmitted infection.

## Roadmap

### MVP
A user should be able to sign up for an account, add their partners, and add their sexual activity. A user should be able to connect to a partner's profile for the purpose of sharing language preferences. Upon adding a sexual encounter, a user should be able to assess the risk of that encounter and receive advice about next steps for acting upon that risk (e.g. learn more about STIs they risked transmission of, learn when to get tested).

#### Functionality

- ~~Account CRUD~~
- ~~Account recovery~~
- Session Management
 - ~~Log in/Log out~~
 - Remember me
 - Session timeout
- ~~Partnership CRUD~~
- ~~Encounter CRUD~~
 - ~~Risk Evaluation on Encounter Review~~
 - ~~Testing Advice on Encounter Review~~
- STI factsheets on all STIs mentioned
- Guided first-time flow

#### Still needed
- Tranasctional email integration
- Partnership risk calculation as part of encounter risk calculation
- Change password on edit profile page
- Views:
 - Dashboard
 - Review Partnership
- FAQ page
- Landing page
- Localization/copy
- Testing
- Data entry about diagnoses/risks
- Back buttons everywhere
- Accessibility Audit
- Security Audit
- Guided flow system with flexibility for divergent paths
- Opt in on signup to have data used anonymously for research
- TOU

### Future
- input test results
 - eventually integrate with apps that receive results directly
 - eventually take existing diagnoses into account for risk calculation
- invite partner to BedPost using profile you already set up for them
- current risk overview page
- user setting for preferred testing schedule
- calendar integration for testing reminders
- text/email reminders for testing
- expedited flows (e.g. skip inputting partner info)
- advice about talking to partners about positive test results

### Far Future
- expanded user-inputed dictionary for more customized, less medical feel
- user settings to allow certain info to be shared with partners
 * share encounter so only one user needs to put it in
 * share test results for partner's risk calculations
- bookmark frequent activities to easily input into encounters
 * do this by prediction?
- hide/unhide activities you never participate in
- multiple partners in single encounter
- multiple pronouns
- prompt for re-evaluating relationship after time or frequent encounters
- track pregnancy risk
- multiple aliases in a single profile
- put in a level of allowable risk to find out what types of sex are available within the risk category



