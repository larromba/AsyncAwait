# AsyncAwait [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/asyncawait.svg?branch=master)](https://travis-ci.com/larromba/asyncawait) | [![Build Status](https://travis-ci.com/larromba/asyncawait.svg?branch=dev)](https://travis-ci.com/larromba/asyncawait) |

## About
This is a simple [async/await](https://javascript.info/async-await) implementation for swift. This concept might become [part of Swift](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) at some point.

Why bother? Well, async callbacks are a real nightmare. I hate them. I've tried various implementations to get round callbacks. Like everyone, I first wrote nested callbacks, and soon met [hell](http://callbackhell.com/). I then tried wiritng callbacks that pass control to a new function, but this makes control flow hard to follow / maintain. I then tried writing my own Promise based on [this](https://github.com/khanlou/Promise/blob/master/Promise/Promise.swift), but this didn't play well with Swift's type inference in Xcode, and things soon become painfully slow / flow blocking. I then tried writing a naive solution whereby you store empty callbacks to fire off your real callbacks (what? exactly), that was in some sort of protocol extension, with context saved in a struct. Really I was clutching at straws, and felt somewhat underwhelmed with life. Then I read about [this library](https://github.com/freshOS/then/tree/master/Source). It contains a really great idea using `DispatchQueue` to mimic async and await. Clever shit! However the implementation is based around using promises, which I didn't want to use, because If async / await becomes part of Swift in the near future, converting Promise code to a more native solution might be painful. Anyway, I took this code and used it as inspiration to make a custom async / await solution without promises. Perhaps this is a controversial move, but life is short, and my nerd level doesn't quite hack it. Anyway, with much excitement I sprung back into my cave and refactored a [personal project](http://github.com/larromba/grafitti-backgrounds) to use it. Wow - it went faster than I thought, the tests didn’t break, shit just was perfect. Wonderful! I’m a fan. Sign me up. The beans are cool.

A side note - before getting all excited, like me, and using it all over the shop, it's worth reading [this grounded article](http://thecodebarbarian.com/2015/03/20/callback-hell-is-a-myth). It makes some great points about new abstractions often hiding fundamental problems in your code design / thinking. Remember callbacks aren't bad, but this solution definitely seems an improve many of the problems we face with callbacks, in my opinion. It's also a pleasure to work with, and intuitive. Just take extra care in designing principled code, and life will remain top dog.

## Installation

### Carthage

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
// Hell:

private func foo(completion: (Result<String>)) {
    someLongFunction { result in
        switch result {
        case .success(let value):
            self.someLongFunction { result in
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

// Heaven:

private func foo() -> Async<String> {
    return Async { completion in
        async({
            let value1 = try await(self.someLongFunction(...))
            let value2 = try await(self.someLongFunction(...))
            //...
            completion(.success("bar"))
        }, onError: { error in
            completion(.failure(error))
            })
        }
    }

// Nirvana:

private func superFoo() -> Async<String> {
    return Async { completion in
        async({
            let allThoseOperations = (0..<100).map { foo() }
            let results = try awaitAll(allThoseOperations)
            //...
            completion(.success("bar-humbug no more!"))
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
