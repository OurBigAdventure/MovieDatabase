# MovieDatabase

This is a demo project using the API from The Movie Database.  The API is here: https://www.themoviedb.org/documentation/api

To run the app, clone the project and run `pod install` to update the Cocoapods.  From there you should be able to run the app in the Simulator.

## Design

The app is built using an MVC Archetecture.  Paged results are fetched as the user scrolls the table view.  Details of any selected movies are fetched as needed.

The user interface has been created using Interface Builder, taking advantage of stack views to handle some of the layout changes upon device rotation.

## Third Party Libraries

Firebase was used in this demo project specifically for the Remote Config capabilities.  Credentials should not be hard coded in an app and remote config allows for the updating of credentials as needed.  The credentials for the API are stored in the Firebase Console and fetched by the app on load.

## Icons

Some icons were sourced from FlatIcon.com, details of the specific icon sources can be found on the info screen within the app.