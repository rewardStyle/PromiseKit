# PromiseKit

Build `PromiseKit.xcframework` from the [origin repository](https://github.com/mxcl/PromiseKit).

Add module file

```
module PromiseKit {
    umbrella header "PromiseKit.h"
    export *
}
```

```
xcodebuild archive \
    -scheme PromiseKit \
    -destination "generic/platform=iOS" \
    -archivePath "archives/PromiseKit-iphoneos.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
        
        
xcodebuild archive \
    -scheme PromiseKit \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "archives/PromiseKit-iphonesimulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES
        
 xcodebuild -create-xcframework \
 -framework archives/PromiseKit-iphonesimulator.xcarchive/Products/Library/Frameworks/PromiseKit.framework \
 -framework archives/PromiseKit-iphoneos.xcarchive/Products/Library/Frameworks/PromiseKit.framework \
 -output archives/PromiseKit.xcframework
```


