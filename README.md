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


# Structure

The root entity here is SVGView class. It is a descendant of the View class so you can include it into your body code. Inside it contains `svg` field of class `SVGNode`, which is a base class for all the nodes - shapes, text, images and groups. Groups contain more nodes inside them. Using all these we create a hierarchy of nodes, representing the whole svg structure. `svg` field is an observable - meaning you can make all the necessary adjusments using this field, and displayed picture will change on the fly.

To construct SVGView and nodes inside it `DOMParser` and `SVGParser` are used. `DOMParser` creates a tree af xmlNodes from svg file, and `SVGParser` makesa tree SVGNodes from it. Some svg nodes may contain links. Those links are relative to svg file's location. So `SVGParser` holds this path for internal usage. 

# Usage

Let's take this simple svg file as an example and parse it with our library.
```svg
<svg height="150" width="500" xmlns="http://www.w3.org/2000/svg" 
  xmlns:xlink="http://www.w3.org/1999/xlink">
  <ellipse cx="240" cy="100" rx="220" ry="30" fill="purple" id="first"/>
  <ellipse cx="220" cy="70" rx="190" ry="20" fill="lime" />
  <ellipse cx="210" cy="45" rx="170" ry="15" fill="yellow" />
</svg>
```

# SVGView Constructors

You can create SVGView with 3 constructors. Here is their usage and some examples of what you can do with their result:
   a. Passing your svg file URL:
   ```swift
   let fileURL = Bundle.main.url(forResource: "example", withExtension: "svg")!

    var body: some View {
        let root = SVGView(fileURL: fileURL) // 1
        let first = root.svg.nodeById("first") // 2
        first?.onTap = { // 3
            (first as? SVGShape)?.fill = SVGColor.by(name: "red") // 4
        }
        return root
    }
   ```
   1 - By passing this URL here you also set it to parser's context (I explained parser's context in structure section)
   2 - locate any node in the hierarchy by its id (id is a field you can add to any node inside svg file, like I did in svg example above)
   3 - onTap can be attached to any node (there will be more gestures in the future)
   4 - change first ellipse's fill color to red on tap

   b. Passing a node - manually constructed or received as result of another SVGView pasring:

   ```swift
    var body: some View {
        let node = SVGCircle(cx: 40, cy: 40, r: 30)
        node.fill = SVGColor.by(name: "red")
        return SVGView(svg: node) // 1
    }
   ```
   1 - or you can write `return node.toSwiftUI()`

   c. Passing raw xml representation of your svg:
   ```swift
    var body: some View {
        let xml = DOMParser.parse(fileURL: fileURL)
        xml.attributes["opacity"] = "0.5" // 1
        return SVGView(xml: xml)
    }
   ```
   1 - this way you can edit xml attributes and structure directly, like you would by editing the svg file itself. Just be carefull with your spelling)

# SVGParser Usage

You can choose to use `SVGParse` directly - without `SVGView`
```swift
    var body: some View {
        let node = SVGParser.parse(fileURL: fileURL)
        return node.toSwiftUI()
    }
```
node is what root.svg used to be in SVGView
 
 You can also pass xml:
```swift
    var body: some View {
        let xml = DOMParser.parse(fileURL: fileURL)
        let node = SVGParser.parse(xml: xml, fileURL: fileURL)
        return node.toSwiftUI()
    }
```
Notice that here we also pass fileURL to `SVGParser`, though it will not use the file itself - all the file parsing was done by `DOMParser`. We pass it so that `SVGParser` has the context fro figuring out relative fiel links, which might come up in svg.

# Node types

There are 4 node types - shapes, text, images and groups.
- Shape. SVG has these types of shapes: circle, ellipse, line, path, polygon, polyline, rect. You can see some examples in constructors section. For more info check out svg documentation for each type, our nodes just repeat their structure.
- Text
```swift
    let node = SVGText(text: "Example")
    node.fill = SVGColor.by(name: "red")
    node.font = SVGFont(name: "Arial Bold Italic", size: 27)
```
fill, font and any other parameter can also be passed as constructor arguments
- Image. There are two types of images supported by SVGView: url and data:
    - SVGURLImage takes an url path to image file (jpeg or png) relative to svg file itself. It will only work you passed fileURL to parse in order to construct you svgNode (see above for options to pass it)
    - SVGDataImage takes Data containing base64Encoded encoded image
- Group. Just contains an array of child nodes.


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

## Requirements

* iOS 13+ / watchOS 13+ / tvOS 13+ / macOS 11+
* Xcode 11+
