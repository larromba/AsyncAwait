# AsyncAwait [![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://GitHub.com/Naereen/StrapDown.js/graphs/commit-activity) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)

| master  | dev |
| ------------- | ------------- |
| [![Build Status](https://travis-ci.com/larromba/asyncawait.svg?branch=master)](https://travis-ci.com/larromba/asyncawait) | [![Build Status](https://travis-ci.com/larromba/asyncawait.svg?branch=dev)](https://travis-ci.com/larromba/asyncawait) |

## About
This is a simple [async/await](https://javascript.info/async-await) implementation for swift. This concept might become [part of Swift](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619) at some point.

Why bother? Well, async callbacks are a real nightmare. I hate them. I've tried various implementations to get round callbacks. Like everyone, I first wrote nested callbacks, but then you soon met [hell](http://callbackhell.com/). I've then tried wiritng callbacks that pass control to a new function, but this control flow is hard to follow and maintain. I then tried writing my own Promise based on [this](https://github.com/khanlou/Promise/blob/master/Promise/Promise.swift), but it didn't play well with Swift's type inference in Xcode, and things soon become painfully slow / flow blocking. I then tried writing a naive solution whereby you store empty callbacks to fire off your real callbacks, in some sort of protocol extension, and save cotext in a dumb struct. However, whilst cool-ish, it felt somewhat underwhelming. Then I read about [this library](https://github.com/freshOS/then/tree/master/Source). It holds a really great idea using `DispatchQueue` to mimic async and await, however the implementation based around using promises, which I don't want to use, because If async / await becomes part of Swift in the near future, converting code to the native solution might be harder. So, I took this code and used it as inspiration to make a custom async / await solution without promises. To test it out, I refactored a [personal project](http://github.com/larromba/grafitti-backgrounds) to use them. It felt wonderful!

Before using this, it's worth reading [this](http://thecodebarbarian.com/2015/03/20/callback-hell-is-a-myth). It makes some great points, and you should still take care to still design principled code. With all new abstractions, they can often hide fundemental problems in your design or thinking. You've been mildly warned.

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

```
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
