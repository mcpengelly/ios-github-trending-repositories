# Privacy Policy

The app is usable anonymously for getting info, but if you want to star repos, you'll need to login with your Github account. Just hit the button in the app and youll be redirected to Oauth Github for login.

The only things we use your Github permissions for are:
- starring/unstarring a repo
- checking if a repo is already starred or not

## Web APIs used

1. Unofficial Github trending data API from https://github.com/alisoft/github-trending-api Lists github repositories by recent popularity; used to access trending data, which are not available through official Github APIs.
2. Official login with Github (via OAuth): Used to star/unstar repositories on behalf of the user & checking users star status

## Native APIs used 

1. IOS Keychain:
    githubAccessToken: securely store users access token so reauth is streamlined on app close/reopen
2. UserDefaults:
    darkModeEnabled: we store the users preference for dark mode so they only need to set it one time. By default IOS system setting is used
