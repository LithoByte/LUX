# LUX

[![CircleCI](https://circleci.com/gh/LithoByte/LUX.svg?style=shield)](https://circleci.com/gh/LithoByte/LUX)
[![Version](https://img.shields.io/cocoapods/v/LUX.svg?style=flat)](https://cocoapods.org/pods/LUX)
[![License](https://img.shields.io/cocoapods/l/LUX.svg?style=flat)](https://cocoapods.org/pods/LUX)
[![Platform](https://img.shields.io/cocoapods/p/LUX.svg?style=flat)](https://cocoapods.org/pods/LUX)

## Examples

Checkout the various playgrounds that demonstrate how to use some of the tools this pod provides. To run the example project, clone the repo, and run `pod install` from the Example directory first.

This repo uses a lot of other libraries that I've built up over years of work, as well as techniques from the excellent pointfree.co series. To work through some of those in worksheet form, download the following repo, `pod install`, and make your way through the code challenges:

https://github.com/ThryvInc/litho-ios-skills

If you learn better by seeing examples rather than attempting first, review the included playgrounds for some code you should be able to copy paste:

- SectionTableViewModel.playground, TableViewModel.playground, and Examples.playground all deal with ways to make tables more fully featured and easier to work with. To compare with how you would normally do the same sorts of things, check out ComparisonExample.playground.
- Search.playground gives an example of linking search bars to tables with minimal code, using the classes in this pod
- Login.playground shows how you can quickly configure a login screen using this pod
- Pipelines.playground demonstrates how to use Functional Programming principles to build pipelines from the server to the screen

## Installation

To install LUX, simply add the following line to your Podfile:

```ruby
pod 'LUX', git: 'https://github.com/ThryvInc/LUX'
```

However, you may want to use some of the sub specs:

### LUX/TableViews
This subpod makes it easy to work with tableviews without duplicating a lot of code. It uses FlexDataSource extensively, which allows you to easily construct, configure, and display tables with arbitrary types of cells in any order.

Additionally, it provides some bindings that make it easy generate tableview cells from models (with bindings specifically for models parsed from FunNet calls), support refreshing and paging of those tables, and handle different sections of those tables.

For an example, see SectionTableViewModel.playground, TableViewModel.playground, and Examples.playground. For a comparison with how you would do the same things without this library, see ComparisonExample.playground.

### LUX/Search
This subpod simplifies searching both local data and sending search requests to a server. It interfaces with search bars and tableviews and coordinates their interactions based on one or filter functions you provide to it.

For an example of how to use this, check out the Search.playground.

### LUX/Networking
This subpod offers some functions and classes that simplify refreshing, paging, and parsing network responses. It uses Combine to enable a lot of this.

### LUX/AppOpenFlow
This subpod allows you to quickly build an authorization flow for your app, including splash, landing, login, and password reset. Take a look at Login.playground for an example.

### LUX/Base
This includes a bunch of simple classes that don't require Combine or ReactiveSwift. Think JSON parsing, some simple template VCs for reseting passwords and the like, some simple table view cells... things like that.

### LUX/Utilities
Utils for styling (UIColor from hex, Configure protocol), text validators, flow coordinator class, an extension for Arrays that make stubbing paging calls with them easier, and some convenience functions for pushing/popping view controllers

### LUX/Auth
This makes it easy to manage multiple API sessions over arbitrary app opens/closes. 

## Author

Elliot Schrock

## License

LUX is available under the MIT license. See the LICENSE file for more info.
