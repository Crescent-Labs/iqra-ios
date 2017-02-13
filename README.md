# Iqra iOS Client

Iqra is a tool meant to allow Muslims to search the Quran using speech recognition. This repo contains the code for the iOS client. There are also repos for the [website](https://github.com/Crescent-Labs/iqra-web) and [Android client](https://github.com/Crescent-Labs/iqra-android).

### Setup

In order to run the app, open the project in XCode. Before building the app, a few steps need to be taken. First, rename the `Confidential.swift.template` file in the `Iqra` directory to `Confidential.swift`. Next, you'll need to replace the `API_KEY` variable's value with a valid key. You can obtain a key for testing by sending an email to info@iqraapp.com with subject line "api key request". Please allow some time for your request to be processed and an api key sent back.

Once you've obtained an api key and placed it into `Confidential.swift`, you can run the app.

### Contributing

Contributions of patches and comments are welcome. If you'd like to contribute a new feature, create an issue for it first and only open a pull request once the feature request has been approved by [the project owner](https://github.com/mmmoussa).
