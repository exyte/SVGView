<img src="https://github.com/exyte/SVGView/blob/main/Assets/header.png">

<p><h1 align="left">SVGView</h1></p>

<p><h4>SVG parser written with SwiftUI</h4></p>

___

<p> We are a development agency building
  <a href="https://clutch.co/profile/exyte#review-731233">phenomenal</a> apps.</p>

</br>

<a href="https://exyte.com/contacts"><img src="https://i.imgur.com/vGjsQPt.png" width="134" height="34"></a> <a href="https://twitter.com/exyteHQ"><img src="https://i.imgur.com/DngwSn1.png" width="165" height="34"></a>

</br></br>
[![Travis CI](https://travis-ci.org/exyte/SVGView.svg?branch=master)](https://travis-ci.org/exyte/SVGView)
[![Version](https://img.shields.io/cocoapods/v/SVGView.svg?style=flat)](http://cocoapods.org/pods/SVGView)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-0473B3.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/cocoapods/l/SVGView.svg?style=flat)](http://cocoapods.org/pods/SVGView)
[![Platform](https://img.shields.io/cocoapods/p/SVGView.svg?style=flat)](http://cocoapods.org/pods/SVGView)
[![Twitter](https://img.shields.io/badge/Twitter-@exyteHQ-blue.svg?style=flat)](http://twitter.com/exyteHQ)

# Usage

Create an SVGView like this:
   ```swift
   SVGView(fileURL: url)
   ```
   or you can manually create nodes:
   ```swift
   let node = SVGCircle(cx: 100, cy: 100, r: 60)
   node.fill = .blue
   return node.toSwiftUI()
   ```

## Examples

To try out the SVGView examples:
- Clone the repo `git clone git@github.com:exyte/SVGView.git`
- Open terminal and run `cd <SVGViewRepo>/Example`
- Run `pod install` to install all dependencies
- Run `xed .` to open project in the Xcode
- Try it!

## Installation

### CocoaPods

```ruby
pod 'SVGView'
```

### Carthage

```ogdl
github "Exyte/SVGView"
```

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/exyte/SVGView.git", from: "0.0.1")
]
```

### Manually

Drop [SVGView.swift](https://github.com/exyte/SVGView/blob/master/Source/SVGView.swift) into your project.

## Requirements

* iOS 13+ / watchOS 13+ / tvOS 13+ / macOS 10.15+
* Xcode 11+
