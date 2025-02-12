In order to run this properly you need to make sure you've done the following:
- Install Ruby
- Use ruby's gem terminal command to install cocoapods 
- Use cocoapods to install the libtorch framework, podfiles are already included in the git repo that direct the install process
- Make sure your Native Apple Clang++ compiler works up until C++17

For me personally, the simulator worked until I added the LibTorch framework and then it would cause a bunch of errors. If you want to see the app working you need to attach a physical iOS device to your mac. This should prevent team dependency and prvosioning issues as well as build errors. 
This will involve trusting yourself as a developer on your phone in settings in order to work and you may also need to turn your Apple ID into a free developer account, depending on how finicky apple decides to be in that moment. 