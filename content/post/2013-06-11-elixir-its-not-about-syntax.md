---
title: 'Elixir: It''s Not About Syntax'
date: 2013-06-11
tags:
  - elixir
  - erlang
  - languages
comments: true
aliases:
  - /2013/06/11/elixir-its-not-about-syntax/
---

Whenever there's [a discussion](https://news.ycombinator.com/item?id=5099861) about Elixir, it soon becomes apparent that there's still a lot of confusion regarding it's purpose. Some developers have it in their heads that Elixir is merely some crazy new syntax that ex-Rubyists are using to avoid writing Erlang. Well, I'm going to try to dispell some of the myths and misconceptions with this blog post.

## It's not about syntax, ~~stupid~~ silly!

In [*The Excitement of Elixir*](http://devintorr.es/blog/2013/01/22/the-excitement-of-elixir/), I responded to two of the most well-known criticisms of Erlang from real-world developers now that we have Elixir for comparison. I failed to drive home what Elixir truly represented. Elixir is not "just about syntax," nor is that the only thing Elixir stands for. If Elixir's goals were a pie chart, a friendlier syntax would represent a sliver of what makes Elixir a worthwhile investment.

{{< figure src="http://i.imgur.com/eEehUnG.png" title="Piecharts" >}}

### Performance

Let's nip this myth the bud right away: Performance of Elixir code should **match** or **beat** the performance of equivalent Erlang code. If you find that in your use case it doesn't, you should immediately file it as a bug! Elixir, while incredibly expressive, still compiles to what the equivalent Erlang code would be. It's still compiling to [EVM](http://joearms.github.io/2013/05/31/a-week-with-elixir.html) bytecode at the end of the day. An Elixir function call is an Erlang function call--there is no overhead! Elixir's powerful [metaprogramming](http://en.wikipedia.org/wiki/Metaprogramming) capabilities don't come from e.g. [runtime dispatching](http://en.wikipedia.org/wiki/Dynamic_dispatch), but the fantastically powerful compiler. All this magic happens at compilation time, before your code even has to run. And this is the part that may blow your minds: Elixir will **beat** the performance of Erlang in some cases. We'll get to that later, though.

{{< figure src="http://i.imgur.com/5XgBpBr.gif" title="Mind=Blown" >}}

### Metaprogrammability

I'm done arguing: Elixir is [strongly homoiconic](http://c2.com/cgi/wiki?HomoiconicLanguages).

```iex
iex> contents = quote do
...>   defmodule HelloWorld do
...>     def hello_world do
...>       IO.puts "Hello world!"
...>     end
...>   end
...> end
{:defmodule,[context: Elixir],[{:__aliases__,[alias: false],[:HelloWorld]},[do: {:def,[context: Elixir],[{:hello_world,[],Elixir},[do: {\{:.,[],[{:__aliases__,[alias: false],[:IO]},:puts]},[],["Hello world!"]}]]}]]}
iex> Code.eval_quoted contents
{{:module,HelloWorld,<<70,79,82,49,0,0,7,104,66,69,65,77,65,116,111,109,0,0,0,132,0,0,0,13,17,69,108,105,120,105,114,46,72,101,108,108,111,87,111,114,108,100,8,95,95,105,110,102,111,95,...>>,{:hello_world,0}},[]}
iex> HelloWorld.hello_world
Hello world!
:ok
```

Not only is it homoiconic, but it has one of the most powerful macro system I've been able to find in among other macro-capable languages I've used to date. There has been volumes written about the expressiveness and value of macros in Lisps. I don't think I need to reiterate what's already been written on that front, but [FUD](http://en.wikipedia.org/wiki/Fear,_uncertainty_and_doubt) is nevertheless still disseminated.

A great, simple macro to briefly showcase what they look like would be the `match?/2` macro from Elixir's `Kernel` module:

```elixir
defmacro match?(left, right) do
  quote do
    case unquote(right) do
      unquote(left) ->
        true
      _ ->
        false
    end
  end
end
```

It's just incredibly easy to reason about what's going on when you see it used in examples:

```iex
iex> list = [{:a,1},{:b,2},{:a,3}]
[a: 1, b: 2, a: 3]
iex> Enum.filter list, fn (thing) -> match?({:a, _}, thing) end
[a: 1, a: 3]
```

Let's just clean that up with some partial application:

```iex
iex> Enum.filter list, match?({:a, _}, &1)
[a: 1, a: 3]
```

#### Macros are scary

Yes, they're as scary as they are powerful. However, they're the least kind of scary macros. Elixir macros are [hygienic](http://en.wikipedia.org/wiki/Hygienic_macro). This means that variables defined in a macro won't interfere with variables defined in the local scope when you use the macro. Oh, and guess what? They are optionally unhygienic as well if you're into that kind of thing. Oh, and you don't have to lose line information either.

#### But...but macros can be hard to debug and can lead to rabbit holes of *blah blah blah*...

Yeah, we get it. Macros shouldn't be abused. That's not a fault with the language, but something the user has to strike a balance with themselves. If you **ever** find [José](https://twitter.com/josevalim) (the [BDFL](http://en.wikipedia.org/wiki/Benevolent_Dictator_for_Life) of Elixir) ever advocating the use of a macro when a simple function would do, I'd eat my own shorts.

{{< figure src="http://i.imgur.com/6A8kxcx.png" title="Spiderman on Responsibility" >}}

#### Okay, but just how metaprogrammable are we talking?

Metaprogrammable enough to do this:

```elixir
defmodule MimeTypes do
  HTTPotion.start
  HTTPotion.Response[body: body] = HTTPotion.get "http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types"

  Enum.each String.split(body, %r/\n/), fn (line) ->
    unless line == "" or line =~ %r/^#/ do
      [ mimetype | _exts ] = String.split(line)

      def is_valid?(unquote(mimetype)), do: true
    end
  end

  def is_valid?(_mimetype), do: false
end

MimeTypes.is_valid?("application/vnd.exn") #=> false
MimeTypes.is_valid?("application/json")    #=> true
```

##### What just happened?

We created a module that uses [HTTPotion](https://github.com/myfreeweb/httpotion) to download the public domain [mime.types](http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types) database from the Apache project, parses it, and creates a polymorphic function called `is_valid?`. This is exactly how `String.Unicode` is implemented in Elixir: it reads from an in-repo copy of the [Unicode 6.2.0 database](http://www.unicode.org/versions/Unicode6.2.0/) and statically compiles functions based on that database into the module. Extrapolate this power to anything, really. The public domain [tzdata](http://www.iana.org/time-zones) database for a timezone module, a [currency database](https://dspl.googlecode.com/hg/datasets/google/canonical/currencies.csv) module, SQL query pre-generation, etc. This expressivity makes writing faster code easier, with less [LOC](http://en.wikipedia.org/wiki/Source_lines_of_code).

{{< figure src="http://i.imgur.com/tXIloPl.png" title="Slam Dunk" >}}

## The standard library and runtime

The Elixir standard library and runtime is where Elixir is really differentiating itself from Erlang. The Elixir standard library aims to dramatically increase the productivity of Elixir developers, while providing the extensibility and features Elixir developers expect from such a metaprogrammable language. A lot of Elixir newcomers really do themselves a disservice by merely wrapping functions in the Erlang stdlib to get a prettier module name and only adding a level of indirection. If your Elixir modules only wrap Erlang modules without provinding any real benefit, you're doing it wrong. This is why Elixir interfaces to Erlang data types try to improve upon the Erlang interfaces by standardizing a noun-first API, providing enumerable support, enhancing with greater functionality, among many other things.

### A brief glimse at the standard library and runtime

#### Protocols

Inspired by [Clojure protocols](http://clojure.org/protocols), Elixir protocols allow polymorphic interfaces to Elixir data types and user defined records. My favorite protocol is probably the simple `EXN.Encoder` protocol to represent a subset of Elixir for data representation:

```elixir
defexception Exn.EncodeError, value: nil do
  def message(exception), do: "#{inspect exception.value} cannot be encoded"
end

defprotocol Exn.Encoder do
  def encode(term)
end

defimpl Exn.Encoder, for: [Atom, List, Number, BitString, Regex] do
  def encode(term), do: inspect(term)
end

defimpl Exn.Encoder, for: Range do
  def encode(Range[first: f, last: l]), do: "#{f}..#{l}"
end

defimpl Exn.Encoder, for: Tuple do
  def encode(term) do
    inspect(term, raw: true)
  end
end

defimpl Exn.Encoder, for: [PID, Function, Reference, Port] do
  def encode(term), do: raise Exn.EncodeError, value: term
end
```

```iex
iex> Exn.encode 1..5
"1..5"
iex> Exn.encode %r{.*}
"%r\".*\""
```

([EXN](https://github.com/yrashk/exn) is a proof of concept answer to [edn](https://github.com/edn-format/edn) from the Clojure crowd.)

#### Reducers

The `Enumerable` protocol is based on reducers (inspired by [Clojure Reducers](http://clojure.com/blog/2012/05/08/reducers-a-library-and-model-for-collection-processing.html)), a functional, composable way to enumerate over your collections. Reducers allow for user defined enumerables to implement their own faster enumeration and also allows for lazy and parallel enumerations.

#### HashDict

Elixir's `HashDict` is just such a great example of what Elixir's standard library is trying to achieve that I want to mention it. Erlang has several dictionary-like modules for storing key-value pairs, each with their own performance characteristics depending on the size of the data set: `dict`, `orddict`, `gb_trees`. It's up the programmer to profile and choose the best profile guided implementation for the data size they **think** their data set is going to need to remain [performant](https://news.ycombinator.com/item?id=561352). `HashDict` takes care of that for you automatically. Not only is it faster than the Erlang alternatives in almost any scenario, but `HashDict` will dynamically scale the underlying storage mechanism to be the fastest possible for the data set it's working with.

### Unafraid of change

The great thing about the Elixir standard library is that with each release it can provide features that Erlang developers clamor for everyday. We have Erlangers, Clojurists, Haskellers, Rubyists, and Pythonistas trying to incorporate useful features into Elixir every day. Elixir isn't afraid of introducing functionality that improves the lives of Elixir developers, and everything is on the table: new data structures, real Unicode support, anything.

{{< figure src="http://i.imgur.com/HBrTD8G.png" title="Bruce Lee" >}}

## Tooling

The key to many developer's hearts is tooling, and José understands this. Elixir tries to make tooling a big priority with the tools it provides.

### A slight peak at the tooling

#### IEx

Everything is an expression:

```iex
iex> defmodule Foo do
...>   def bar, do: "bar!"
...> end
{:module,Foo,<<70,79,82,49,0,0,7,24,66,69,65,77,65,116,111,109,0,0,0,102,0,0,0,11,10,69,108,105,120,105,114,46,70,111,111,8,95,95,105,110,102,111,95,95,4,100,111,99,115,9,...>>,{:bar,0}}
iex> Foo.bar
"bar!"
```

- Coloring! (Not pictured here.)
- User defined helpers!
- And more! What more could you ask for?

#### Doctests

Elixir takes inspiration from Python in the form of doctests. Interactive `iex` sessions are embeddable in Elixir's first-class documentation and runnable from your ExUnit tests with a simple call to `doctest`.

An example `@doc` with doctests from the `nil?/1` macro in the `Kernel` module:

```elixir
@doc """
Checks if the given argument is nil or not.
Allowed in guard clauses.

## Examples

    iex> nil?(1)
    false
    iex> nil?(nil)
    true

"""
```

That IEx session is turned into two test cases run with the rest of your tests when you type `mix test`.

#### Mix

A fantastic build (and soon deployment) tool. Inspired by the much beloved [Leiningen](http://leiningen.org/) and centered around the notion of `Mix.Tasks`, Mix is by far the most pleasant answer to tooling I've worked with other than the awesome Leiningen.

Because I'm beginning to get lazy, I'll just do a `mix help` for you:

```console
$ mix help
mix clean           # Clean generated application files
mix compile         # Compile source files
mix deps            # List dependencies and their status
mix deps.clean      # Remove dependencies files
mix deps.compile    # Compile dependencies
mix deps.get        # Get all out of date dependencies
mix deps.unlock     # Unlock the given dependencies
mix deps.update     # Update dependencies
mix do              # Executes the commands separated by comma
mix escriptize      # Generates an escript for the project
mix help            # Print help information for tasks
mix local           # List local tasks
mix local.install   # Install a task locally
mix local.rebar     # Install rebar locally
mix local.uninstall # Uninstall local tasks
mix new             # Creates a new Elixir project
mix run             # Run the given expression
mix test            # Run a project's tests
```

{{< figure src="http://i.imgur.com/ESJVaD4.png" title="Smug Alert" >}}

## Elixir : Erlang :: Clojure : Java

Elixir isn't the CoffeeScript of Erlang just as Clojure isn't the CoffeeScript of Java. Just like Clojure, Elixir is more than a pretty face. Elixir is the power of it's tooling, the expressiveness of it's metaprogrammability, and the expansive feature set of it's standard library while maintaining complete compatibility with--and heavily leveraging--OTP. Once again I have yet to adequately scratch the surface of what makes Elixir special, but I have more Elixir to write!
