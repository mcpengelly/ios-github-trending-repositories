# CodeScout: Explore Code Trends 

![App icon](./TrendingRepos/Assets.xcassets/AppIcon.appiconset/icon-256.png)

### Goal 

A simple ios app to keep up to date with the latest daily, weekly & monthly trending code repositories on Github straight from the source

### Features
 
- List trending repositories on Github by number of stars in the last: Day, Week or Month
- Quickly see information such as author, organization, stars, starsSinceXPeriod, forks and language in an intuitive interface
- Oauth Integeration: Star repositories as though you were on Github.com (Optional)
- Dark Mode: Protect your eyes by toggling darkmode within the app. Defaults to iOS System Settings
- Source: the code is open to everyone and will remain that way
- Internationalization: Supports English, French, German, Italian, Portugeuse, and Spanish. Configure via IOS System Settings

Demo:

https://github.com/mcpengelly/ios-github-trending-repositories/assets/8462065/eedf0600-7bdc-47fd-9bc4-0b9d6b6cae65

![IMG_20230906_103136_954](https://github.com/mcpengelly/ios-github-trending-repositories/assets/8462065/6b4f46be-4c8e-4a4d-9520-3113755b1d34)
![IMG_20230906_103136_501](https://github.com/mcpengelly/ios-github-trending-repositories/assets/8462065/1622e6b5-8440-4feb-be3d-37b68d585a7e)

### Documentation

- [Privacy Policy](./PRIVACY.md)
- [Contribution Guidelines](./CONTRIBUTING.md)

### Support

Need help? Something not working? or your language not supported? 

Open an Issue here on Github, be sure to include any relevant info like:

- how to reproduce the issue
- what you expect to happen
- the device(s) you are using

and we'll take a look ASAP

### Roadmap

- accessibility
- filter on programming language if one specified, otherwise all. always default back to all on launch.
- coffee?

### Tech Debt

- refactor TokenManager: does too much, exclude the parts that have to do with GithubAPI
- convert completion handlers to futures
- use Result to wrap response values, that way the caller can switch on failure if need.
- introduce abstraction over ThreadQueue.main.dataTask in NetworkManager
- address all in code TODOS
