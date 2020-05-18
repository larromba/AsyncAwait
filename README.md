# AsyncAwait [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/AsyncAwait.svg?branch=master)](https://travis-ci.com/larromba/AsyncAwait) | [![Build Status](https://travis-ci.com/larromba/AsyncAwait.svg?branch=dev)](https://travis-ci.com/larromba/AsyncAwait) |

## About
This is a simple [async/await](https://javascript.info/async-await) implementation for Swift. This concept might become [part of Swift](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) at some point.

Traditional callbacks are [hell](http://callbackhell.com/). Writing callbacks that pass control flow to a function is better, but obfuscates the control flow. Promises are a decent solution, but after writing my own Promise based on [this](https://github.com/khanlou/Promise/blob/master/Promise/Promise.swift), I felt its design to be somewhat fishy. Swift's type inference in Xcode also slows down in larger codebases, blocking flow and slowing compilation time. 

In all honesty, [Combine](https://developer.apple.com/documentation/combine) is likely the future of iOS, so go learn that. It's much better than [RxSwift](https://github.com/ReactiveX/RxSwift). However, there's something I conceptually prefer about async / await over reactive solutions. You write code like you read a book, which to me, seems more intuitive. Reactive programming is great in some cases, as it reduces state, but to me it's not to be used everywhere, as it often obfuscates easy things, and there's no shame in admitting that. Programming shouldn't be made harder than it already is, and we're all guilty of doing it.

Nonetheless, after much searching, I found [this library](https://github.com/freshOS/then/tree/master/Source). It contains a really great idea using `DispatchQueue` to mimic async and await. However the implementation is based around using Promises, which I didn't want to use. So I took the key idea and hacked something simple together.

Before using, it's worth reading [this grounded article](http://thecodebarbarian.com/2015/03/20/callback-hell-is-a-myth). It makes some great points about new abstractions often hiding fundamental problems in your code design / thinking. Remember callbacks aren't necessarily bad, but this solution definitely seems to improve many of the key problems faced using callbacks. 

See this in a real [ios project](http://github.com/larromba/easylife), or [mac project](http://github.com/larromba/graffiti-backgrounds). 

## Installation

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

```
// Cartfile
github "larromba/asyncawait" ~> 1.0
```

```
// Terminal
carthage update
```

## Usage

```swift
// 
// comparing callback approaches
//

// 1. callback hell:

func foo(completion: (Result<String>) -> Void) {
    someLongFunction { result in
        switch result {
        case .success(let value):
            //...
            self.someLongFunction2 { result in
                switch result {
                case .success(let value):
                    //...
                    completion(.success("bar"))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

// 2. passing the control flow around

func foo(completion: (Result<String>) -> Void) {
    someLongFunction { result in
        switch result {
        case .success(let value):
            //...
            foo2(completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

func foo2(completion: (Result<String>) -> Void) {
    someLongFunction2 { result in
        switch result {
        case .success(let value):
            //...
            completion(.success("bar"))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}

// 3. using promises

func foo() -> Single<String> {
    return Single.create { seal in
        let value = someLongFunction
            .flatMap(someLongFunction2)
            .flatMap(someLongFunction3)
        //...
        seal(.success("bar"))
        return Disposables.create()
    }
}

// 4. using await / async
// example #1

func foo() -> Async<String> {
    return Async { completion in
        async({
            let value1 = try await(self.someLongFunction(...))
            let value2 = try await(self.someLongFunction2(...))
            //...
            completion(.success("bar"))
        }, onError: { error in
            completion(.failure(error))
        })
    }
}

// example #2

func foo() -> Async<String> {
    return Async { completion in
        async({
            let allThoseOperations = (0..<100).map { _ in foo() }
            let results = try awaitAll(allThoseOperations)
            //...
            completion(.success("bar"))
        }, onError: { error in
            completion(.failure(error))
        })
    }
}
```

## Licence
[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://lbesson.mit-license.org/)

## Contact
larromba@gmail.com
