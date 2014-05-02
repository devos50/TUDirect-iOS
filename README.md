For the Android version, go to [the other GitHub repository!](https://github.com/ldfversluis/TUDirect-Android)
TUDirect-iOS
================

TUDirect is the first app for students studying at the Technical University of Delft to easily check their course information, building information, grades and more.
This app uses the Single Sign On (SSO) gatekeeper and therefore cannot see/read your NetID or password, in other words your account remains safe!

Currently TUDirect contains the following functions:

* Retrieve course information.
* Retrieve building information.
* Check your grades and see your (weighted or unweighted) average in an instance. (Authorization via netid required)
* Check your current study progress for all examprograms in which you are enrolled. (Authorization via netid required)
* View your course schedule (date, time and location).
* Find free (computer) workspaces at different locations.


Current state
------------

This app was created about 2 years ago during the hackathon of the TU Delft.
Since then we kept updating and increasing the amount of comfort and useful features, such as showing your weighted and unweighted average.
We've now decided to open source the app so others can contribute to it as well! Since we are not experts on design (unfortunately), help from others will be much appreciated! If you encounter bad coding (style), mock the previous collaborators and show you know better!

Technical details
-----------------
This app was created in xCode with deployment target 5.0. It uses the AFNetworking library for the network requests and a separate class for the handling of the OAuth stuff (see next section). MBProgressHUD is used for displaying the progress view when executing the network requests.

OAuth
---------------
As this application performs [OAuth 2.0 requests](http://oauth.net/2/), there are some parameters required when requesting sensitive information such as grades or study progress. Currently, our parameters are used in the AppDelegate.m file. If you want to use your own parameters you can do so by replacing them. These parameters can be requested at the ICT department of the TU Delft.

License
-------
The license can be found in the repository, basically you're free to modify, fork and do whatever you want with it, all we want is to discourage the app being sold for profit.
