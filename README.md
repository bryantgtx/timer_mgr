# timer_mgr

## Running

This app allows you to create Time Card entries in third party systems.  It currently supports [Harvest](https://getharvest.com).  When you create a timer, you can give it any name you want.  The description field will be sent to Harvest as notes for any timecard entries created.

Timers can be in one of two modes - either 'timer' mode, or 'entry' mode.  Timer mode will tick away the seconds while running, while entry mode just expects hours and minutes to be entered 'hh:mm', or just hours as a fraction.  It will convert the fraction to hh:mm display autoamtically.

For Harvest, timecard entries are always sent as a duration.  This means you must ensure that your Harvest is configured to allow this (done on the Harvest Setting page for your account).


## Getting Started

1. Clone the repo as usual

2. Change to the stable dev branch of Flutter (required for desktop support)

3. flutter pub get

    There is a bug in the 1.6.3 version of the OAuth2 library that restricts valid responses to 200, so you may need to make a local change to handle_access_token_response.dart:40 (Harvest, for example, returns a 201):

    ```
    if (response.statusCode != 200 && response.statusCode != 201) {
    ```

    On my Windows system, that is located in C:\Users\\[username]\AppData\Local\Pub\Cache\hosted\pub.dartlang.org\oauth2-1.6.3\lib\src

4. Add credentials to third party APIs
The class OAuthCredentials is used to provide API id/secret in the app.  Since those should not be checked in to a repo, this class looks for environment variable defined via --dart-define.  If you are using vscode, the easy way to do this is to create a .vscode/launch.json file, and add a run definition including these arguments.  The .vscode directory is in .gitignore, so will not be checked in.  A sample run configuration is below.

```
{
    "name": "timer_mgr - windows",
    "request": "launch",
    "type": "dart",
    "deviceId": "windows",
    "args":[
        "--dart-define",
        "harvestId=your_api_id",
        "--dart-define",
        "harvestSecret=your_api_secret"
    ]
},
```

## Contributing

Please feel free to contribute - obviously bugs are open game, but there are also some good features yet to be added.  Check the issues page.
