# Github Trending Projects

![App icon](./TrendingRepos/Assets.xcassets/AppIcon.appiconset/icon-256.png)

### Goal 

Keep up to date with the latest daily, weekly & monthly trending code repositories straight from the source!

### Features
 
- List trending repositories on Github by number of stars in the last: Day, Week or Month
- Quickly see information such as author, organization, stars, starsSinceXPeriod, forks and language in an intuitive interface
- Oauth Integeration: Star repositories as though you were on Github.com
- Dark Mode: Protect your eyes by toggling darkmode within the app. Defaults to your ios preference
- Source: the code is open to everyone and will remain that way
- Internationalization: Supports English, French, German, Italian, Portugeuse, Spanish languages. Configured via IOS settings

### Documentation

- [Privacy Policy](./PRIVACY.md)
- [Contribution Guidelines](./CONTRIBUTING.md)

### Support

Need help? Something not working? or your language not supported? 

Open an Issue here on Github, be sure to include any relevant info like:

- how to reproduce the issue
- what you expect to happen
- the device(s) you are using

and we'll take a look ASAP.

### Roadmap

- accessibility
- filter on programming language if one specified, otherwise all. always default back to all on launch.
- coffee?

### Tech Debt

- refactor TokenManager: does too much, exclude the parts that have to do with GithubAPI
- convert completion handlers to futures
- address all in code TODOS
- use Result to wrap response values, that way the caller can switch on failure if need.
- introduce abstraction over ThreadQueue.main.dataTask in NetworkManager?
