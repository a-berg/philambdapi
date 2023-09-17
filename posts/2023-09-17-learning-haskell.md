---
title: Learning Haskell
tags: programming
---

## Introduction

In the past few months I have been learning Haskell from a [free MOOC][1] publicly
available and have completed Part I, which teaches the basics of the language, such as:

- Recursion,
- Higher order functions, like `fold`, `map` and the lik,e
- Currying, composition,
- The type system, including recursive types. 

> _but, why?_

Ah, why indeed. Well, I think it all started back in my C++ days[^note1]. I was young and
impressionable, and impressed by the standard _template_ library I was, indeed!

C++ STL was the work of [Alexander Stepanov][2] and it introduced a form of programming
that, to me, was new at the moment. I also remember reading his book, _Elements of
Programming_ which made me wonder about other styles outside OOP and I became "obsessed"
with algebra and generic programming and the need complex type systems that helped you
write faster, safer and more elegant code.

That led me to Lisp (Scheme), Racket (note to self: keep working on SICP) and Haskell but,
at the moment, I didn't "get" it.

Fast forward an undefined number of years and I picked up the aforementioned MOOC. I
worked on some problem sets but I was already too accustomed to Python to feel comfortable
with Haskell functional way. I even have an unpublished blog post named "Is Haskell for
me?" in which I argue that while it had powerful abstractions, they got in the way for me
to express my ideas.

Ironically, though, I found myself writing _functional_ Python more and more frequently.
So this summer I decided to give it another go.

[^note1]: I worked with C++11, IIRC.

## My impressions so far

Through 127 exercises, the first part of this MOOC has introduced me to recursion
(obviously), higher order functions, pattern matching, algebraic data types, recursive
types, classes and instances. All in all, it's a good dive into the language even if you
don't really delve into the "abstract nonsense"[^note2] parts of Haskell.

So far, I have liked the language. I think most concepts can be succintly expressed in it,
and encourages you to actually _design_ your program through its rich type system and then
write the functions that operate on them. More often than not, the language has tools to
solve the problem at hand in a few lines if you are ingenious enough.

Many algorithms are easily expressed in a functional language, especially through the use
of higher order functions, and I no longer feel like the syntax "gets in the way".

I think my current exposure to the language has given me enough knowledge to solve most
problems I could come up with and also to learn on my own from now on (however, I plan on
doing part 2 of the MOOC).

[^note2]: it is my understanding that category theory is jokingly referred to as "abstract
nonsense" among mathematicians. Haskell has a fame of having introduced category-theoretic
concepts, such as monads, into itself (and influenced other languages to include some
too).

## A prototyping language?

My view of Haskell is that it could potentially be a really good prototyping language.
Yes, even better than Python for a lot of cases. It's true that, if there's a "language
for the masses" right now, it has to be Python (closely followed by JavaScript probably).

Python gained fame quickly (in the scientific community at least) as an easy-to-write
lanugage that was _good enough_ for rapid prototyping of algorithms. I don't want to
rant too much about how Python came to be what it is today, but at least for scientists,
its direct competitor (MATLAB) was just much more expensive (I mean, Python is free)
and  clunky for package creation/distribution. In that regard, Python was similar in ease
of writing, but actually had the concept of "modules" and even a package manager which
greatly helped authors to create open source alternatives to some of MATLAB's strongest
points (plotting for example); once `numpy` and `matplotlib` came into existence, it was
game over IMO. Plus it offered OOP which was all the rage back then.

However, Haskell has another set of features to offer:

* Its type system compels you to think about the domain model and break it down into
logical components.
* Side effects are encapsulated into their own monad. This reduces surface area for bug-
hunting.
* Code can be cleaner as a result of functional patterns such as function composition,
algebraic data types and type classes.

I think it really can help you write code that is better designed and readable (which can
then be used as a template for a more performant implementation) than in Python, even if
(or rather, precisely because) you can't jump right into writing code and have an overhead
thinking about what types to use and what functions you'll need.

## Next steps

The second part of the MOOC, which I will do when I have time, deals with these
conceptually advanced features like `Applicative`, `Functor` and of course the `Monad`
class. I am particularly interested in the `Functor` class because some exercises were
repetitive in that you needed to apply a function to the elements of a structure (while
preserving it) and `Functor` suppossedly serves that purpose. It also teaches you how
lazyness has implications on performance and how to bypass it when necessary, and then
some libraries. 

I may take a detour to do [this other tutorial][3], which teaches you to create a blog
generator and also how a Haskell project is usually organized (something the MOOC doesn't
do), and I'm also interested in [Parallel and Concurrent Programming in Haskell][4] which
for some easy side project like Julia sets (I love computing Julia sets as a code kata)
might be handy.

More importantly, I'd like to test it out in data applications. Nothing too intensive,
but I want to re-implement some data pipelines at work to see how it goes.

In Python, you use Pandas (or [pola.rs](pola.rs)) as an API to an underlying [Arrow]
(https://arrow.apache.org/) backend.
But, could Haskell offer similar ability for data processing logic using its functional
approach, which might feel more natural to pipelines (which are basically just function
composition) than OOP method chaining? Especially since Haskell already has functions
like `groupBy` as part of the `Data.List` library (however, I'm not sure how I could
aggregate on column B given the column A using this function, yet).

Moreover, the `Functor` class might allow for processing more heterogeneous data in an
unified way.

I really want to explore the potential of Haskell for data analysis.

[1]: <https://haskell.mooc.fi>
[2]: <https://en.wikipedia.org/wiki/Alexander_Stepanov>
[3]: <https://lhbg-book.link/01-about.html>
[4]: <https://www.oreilly.com/library/view/parallel-and-concurrent/9781449335939/>