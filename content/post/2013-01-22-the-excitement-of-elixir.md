---
title: The Excitement of Elixir
date: 2013-01-22
tags:
  - elixir
  - erlang
  - languages
comments: true
aliases:
  - /2013/01/22/the-excitement-of-elixir/
---

## Introduction

I've been an Erlanger since 2008 and I'm the author of [a few](https://github.com/devinus) Erlang projects of varying usefulness and popularity, including [Poolboy](https://github.com/devinus/poolboy). Poolboy is used by [Basho](http://basho.com/) in [Riak](https://github.com/basho/riak_core), [2600hz](http://2600hz.com/) in [Kazoo](https://github.com/2600hz/kazoo), [IRCCloud](https://irccloud.com/), [ChicagoBoss](http://www.chicagoboss.org/), and other high profile projects.

## Get on with it...

What I'm trying to say is that I'm (hopefully) not an Erlang noob, so with that context in mind I'd like to get this off my chest: programming in Erlang sucks. I've built dozens of services in Erlang and written fair amount of Erlang code. Don't get me wrong, it's not all bad! My love of pattern matching and polymorphic functions is limitless. However, everything else about Erlang (the language) is clunky and cumbersome. Now for the pitch: [Elixir](http://elixir-lang.org/) is everything good about Erlang and none -- almost none -- of the bad. That's a bold statement, right? Elixir is what would happen if Erlang, Clojure, and Ruby somehow had a baby and it _wasn't_ an accident.

## Let's define terms

* Erlang - the language ([old and crufty Prolog inspired syntax](http://www.erlang.org/faq/academic.html#id54763))
* BEAM - the VM ([lightweight, massively concurrent, asynchronous, soft real-time](http://www.erlang-factory.com/upload/presentations/708/HitchhikersTouroftheBEAM.pdf))
* OTP - The ecosystem ([design methodology and set of libraries for building robust systems](http://www.erlang.org/download/armstrong_thesis_2003.pdf))

## Déjà vu

We've all heard this before, haven't we? It may sound to you like two of the most well-known criticisms of Erlang recently. The first, [What Sucks About Erlang](http://damienkatz.net/2008/03/what_sucks_abou.html) by Damien Katz, the original author of [CouchDB](http://couchdb.apache.org/). The other is [The Trouble with Erlang (or Erlang is a ghetto)](http://www.unlimitednovelty.com/2011/07/trouble-with-erlang-or-erlang-is-ghetto.html) by Tony Arcieri the author of [Reia](http://reia-lang.org/) (another BEAM based language). What if I told you that Elixir addressed almost all of their concerns? Let's go through some of the points on these blog posts and see how Elixir handles it differently.

### Syntax

**What Damien has to say**: Erlang's syntax does away with nested statement terminators and instead uses expression separators everywhere. Lisp suffers the same problem, but Erlang doesn't have the interesting properties of a completely uniform syntax and powerful macro system to redeem itself.

**What Tony has to say**: The syntax is atrocious.

**How Elixir solves this**: Elixir syntax is like a marriage of [DSL friendly Ruby](http://media.pragprog.com/titles/twa/martin_fowler.pdf) and the powerful hygenic macros of Clojure.

### Expressions

**What Damien has to say**: Erlang `if`s could be so much more useful if it would just return a sensible default when no conditionals match, like an empty list `[]` or the `undefined` atom. But instead it blows up with an exception. If Erlang were a side-effect free functional language, such a restriction would make sense. But it's not side effect free, so instead it's idiotic and painful.

**What Tony has to say**: In Clojure, I can write the following: `(if false :youll-never-know)`. This implicitly returns `nil` because the condition was false. What's the equivalent Erlang? Erlang forces you to specify a clause that always matches regardless of whether you care about the result or not. If no clause matches, you get the amazingly fun `badmatch` exception. In cases where you don't care about the result, you're still forced to add a nonsense clause which returns a void value just to prevent the runtime from raising an exception.

**How Elixir solves this**: Elixir `if` expressions, like most everything else in the language, are [implemented using a macro](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/kernel.ex#L2308).

```elixir
if false, do: :youll_never_know #=> nil
```

### Strings

**What Damien has to say**: The most obvious problem Erlang has for applications is sucky string handling. In Erlang, there is no string type, strings are just a list of integers, each integer being an encoded character value in the string.

**What Tony has to say**: The obvious solution here is to use binaries instead of lists of integers. Binaries are more compact and exist in a separate heap so they aren't copied each time they're sent in a message. The Erlang ecosystem seems to be gradually transitioning towards using binaries rather than strings. However, much of the tooling and string functions are designed to work with list-based strings. To leverage these functions, you have to convert a binary to a list before working with it. This just feels like unnecessary pain.

**How Elixir solves this**: Elixir strings are UTF8 binaries, with all the raw speed and memory savings that brings. Elixir has a `String` module with Unicode functionality built-in and is a great example of [writing code that writes code](http://pragmatictips.com/29). `String.Unicode` reads various Unicode database dumps such as [`UnicodeData.txt`](http://old.kpfu.ru/eng/departments/ktk/test/perl/lib/unicode/UCDFF301.html) to dynamically generate Unicode functions for the `String` module [built straight from that data](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/priv/unicode.ex#L19)!

```elixir
<<?h, _ :: binary>> = "hello"
String.graphemes("hello") #=> ["h","e","l","l","o"]
```

### Single assignment

**What Damien has to say**: Immutable variables in Erlang are hard to deal with when you have code that tends to change a lot, like user application code, where you are often performing a bunch of arbitrary steps that need to be changed as needs evolve [...] Erlang's context dependent expression separators and immutable variables end up being huge liabilities for certain types of code, and the result is far more line edits for otherwise simple code changes.

**What Tony has to say**: Erlang doesn't allow destructive assignments of variables, instead variables can only be assigned once. Single assignment is often trotted out as a panacea for the woes of mistakenly rebinding a variable then using it later expecting you had the original value. [...] Single assignment is often trotted out by the Erlang cargo cult as having something to do with Erlang's concurrency model. This couldn't be more mistaken. Reia compiled destructive assignments into Static Single Assignment (SSA) form. This form provides versioned variables in the same manner as most Erlang programmers end up doing manually. Furthermore, SSA is functional programming. While it may not jive with the general idealism of functional programming, the two forms (SSA and continuation passing style) have been formally proven identical.

**How Elixir solves this**: There is no context dependent expression separators and when you rebind a name all you're doing is [rebinding a new value to the name](http://en.wikipedia.org/wiki/Static_single_assignment_form). Elixir is still immutable, it's just not trying to pass off [single assignment](http://en.wikipedia.org/wiki/Assignment_\(computer_science\)#Single_assignment) as immutability.

```elixir
thing = doit(thing) #=> v0 = doit(thing)
thing = doit(thing) #=> v1 = doit(v0)
```

### Records

**What Damien has to say**: The 'records' feature provides a C-ish structure facility, but it's surprisingly limited and verbose, requiring you to state the type of the record for each reference in the code.

**What Tony has to say**: Erlang has a feature called 'records' which uses the preprocessor to give you something akin to a struct or map, i.e. a way to access named fields of a particular object/term within the system. As far as I can tell, there's pretty much universal agreement within the community that this is a huge limitation.

**How Elixir solves this**: Elixir records are _real_ records, and provide compile time pattern matching and a _much_ more dynamic nature.

```elixir
defrecord Foo, bar: "baz", quux: nil
x = Foo.new
x.bar #=> "baz"
x = x.quux "corge" #=> Foo[bar: "baz", quux: "corge"]
x.to_keywords[:bar] #=> "baz"
```

### Standard library

**What Damien has to say**: The coding standards in the core Erlang libraries can differ widely, with different naming, argument ordering and return value conventions.

**What Tony has to say**: Should module names in the standard library be plural, like lists? Or should they be singular, like string? Should we count from 1, as in most of the functions found in things like the lists module, or should we count from 0 like the functions found in the array module?

**How Elixir solves this**: While you can't escape using the Erlang standard library from time to time, [Elixir's standard library](http://elixir-lang.org/docs/stable/) is trying to normalize zero-based access and noun-first argument ordering, along with a more consistent API.

```elixir
elem({:a, :b, :c}, 0) #=> :a
List.member?([:a, :b, :c], :b) #=> true
```

### Code organization

**What Damien has to say**: The only code organization offered is the source file module, there are no classes or namespaces. I don't need inheritance or virtual methods or static checking or monkey patching. I'd just like some encapsulation, the ability to say here is a hunk of data and you can use these methods to taste the tootsie center. That would satisfy about 90% of my unmet project organization needs.

**How Elixir solves this**: Elixir modules provide a great way to encapsulate functionality. As many modules as you desire can be declared within the same file including private functionality (functions, macros, records, exceptions, fuzzybunnies, whatever).

```iex
iex> defmodule Foo do
...>   defmodule Bar do
...>     @baz "hello"
...>     defp quux do
...>       @baz
...>     end
...>     def corge do
...>       quux
...>     end
...>   end
...> end
{:module,Foo,<<70,79,82,49,0,0,6,44,66,69,65,77,65,116,111,109,0,0,0,98,0,0,0,10,10,69,108,105,120,105,114,45,70,111,111,8,95,95,105,110,102,111,95,95,9,109,111,100,117,108,...>>,{:module,Foo.Bar,<<70,79,82,49,0,0,7,40,66,69,65,77,65,116,111,109,0,0,0,113,0,0,0,12,14,69,108,105,120,105,114,45,70,111,111,45,66,97,114,8,95,95,105,110,102,111,95,95,4,100,...>>,{:corge,0}}}
iex(2)> Foo.Bar.corge
"hello"
```

## It's the simple things

How many times have you wished for multiline strings in Erlang? It's something so simple that ends up feeling like a godsend as soon as it's available to you. What about a `binary_to_float` so you don't have to keep doing `list_to_float(binary_to_list(Bin))`? Elixir's [got that too](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/kernel.ex#L2461). No more `proplists:get_value(username, Json)`, [say hello](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/access.ex#L3) to `json[username]`.

## [Turtles all the way down](http://en.wikipedia.org/wiki/Turtles_all_the_way_down)

Elixir continues to [blow me away everyday](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/kernel.ex#L22). The crazy thing is, it's still just Erlang underneath. Theoretically, Elixir code is just as fast as Erlang code. Elixir function calls are just Erlang function calls. In fact, it may be easier to write more [performant](http://en.wiktionary.org/wiki/performant) code in Elixir simply because of the power available to you to at compile time. For example, regular expressions in Elixir are [compiled at compile time](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/kernel.ex#L3139) instead of runtime. The [Dynamo](https://github.com/josevalim/dynamo) web framework compiles routes to function heads, matching based on function guards. The latest Elixir will have a [`HashDict`](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/hash_dict.ex#L13) implementation [significantly faster](https://gist.github.com/4594017#file-result_1_000_000-txt) than Erlang's `dict`.

> Lisps traditionally empowered developers because **you can eliminate anything that's tedious through macros, and that power is really what people keep going back for**.
>
> -- Rich Hickey

## I'm done (for now)

I cannot possibly do Elixir any justice by just comparing it to Erlang. And I haven't even begun to [scratch the surface](https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/kernel.ex#L1611). Just give it a try.
