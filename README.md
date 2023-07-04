demo target: 
- on app load, determine the star status for each repo **** problem with rerendering page after setting token?
  - use observable object and set state within TokenManager
- refactor clientid/secret (environment variables or ios keychain?  https://chat.openai.com/share/a9553d3b-6573-46df-bc5b-96a39481c6bf)

- is refresh token still a thing? check what we get back from the access_token endpoints for oauth
- conditionally render auth button only when the user is not authenticated (tabled for now.)