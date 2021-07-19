## 書籍管理、チャットアプリ(練習用)

## 概要
- 言語: Swift
- Xcode: 12.5
- 対応 OS: iOS13 以上

## Firebase
- Google Analytics(https://firebase.google.com/docs/analytics)
- Firebase Crashlytics(https://firebase.google.com/docs/crashlytics)
- Firebase firestore(https://firebase.google.com/docs/firestore)
- Firebase Storage(https://firebase.google.com/docs/storage)
- Firebase Authentication(https://firebase.google.com/docs/auth)

## Architecture

### Presentation
  - ViewController: view logic of screen
    - Routing: transtion (if no transition, use NoRouting)
    - ViewModel: data logic of screen (if no data logic, use NoViewModel)

### Domain
  - Usecase: Actions that cause an interaction between the user and the software
    - Repository: Accessing Data Sources
    - Mapping: Map response to entity
    
### Data
  - Repository: components that encapsulate the logic required to access the data source
    - APIClient: remote API
    - PersistedDataHolder: UserDefault, File
    - SecretDataHolder: KeyChain
    - Others:

## Utility Packages
```
- include common functions for each project or package
- don't include UIKit
```

## FirebasePackages
```
- include related firebase handling for each project or package
- Firebase import are only include here.
```

## Test
  - Presentation: ViewModel
  - Domain: Usecase, Mapper
  - Data: Repository (decode response and side effect)
  - Others: Utility, and so on
