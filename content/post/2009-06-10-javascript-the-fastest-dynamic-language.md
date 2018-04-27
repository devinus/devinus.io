---
title: 'JavaScript: The Fastest Dynamic Language?'
date: 2009-06-10
tags:
  - javascript
  - languages
comments: true
aliases:
  - /2009/06/10/javascript-the-fastest-dynamic-language/
---

I remember programming for the web in the late 90's. JavaScript engines were a lot worse then than they are now, and it was the last programming skill a programmer mentioned. Many programmers didn't even regard the language as a real language, much the same way many of us today scoff when somebody mentions HTML as a programming skill. What many didn't realize, though, is that JavaScript has always been a beautiful language when used correctly.

Original JavaScript engines were buggy and slow, which is why it's taken this long for people to finally appreciate the language. We now have [Nitro](http://www.apple.com/safari/whats-new.html) ([SquirrelFish Extreme](http://webkit.org/blog/214/introducing-squirrelfish-extreme/)) from the Apple camp, [V8](http://code.google.com/p/v8/) from the Google camp, and [TraceMonkey](https://wiki.mozilla.org/JavaScript:TraceMonkey) from the Mozilla camp. Without getting into JavaScript engine wars, they're all blazingly fast and, apart from Nitro which many take a bit more work, easy to integrate with any project.

I was mulling over how bright the future of JavaScript was when I read this week about a project called [Narwhal](http://ajaxian.com/archives/narwhal-%20standard-library-that-implements-serverjs) on [Ajaxian](http://ajaxian.com/). Although I had heard of server-side JavaScript for awhile, I only imagined it being JavaScript without the DOM. I was unaware there was a move to create a true [server-side JavaScript](https://wiki.mozilla.org/ServerJS). This just means adding standard objects to interact with system-level services, such as the `File` object.

The implications of all of this is **huge**. While [Ruby](http://rubini.us/) and [Python](http://code.google.com/p/unladen-swallow/) have separate projects busy trying to implement fast JITed interpretters for their languages, JavaScript already has three! Imagine writing an entire [Rails](http://rubyonrails.org/)-like web framework in pure JavaScript. We can take it even further: Imagine writing a WxWidget application using pure JavaScript! Perhaps a cron job in pure JavaScript? Anything is possible. It has potential to become a first rate scripting language along with Python and Ruby. Better even, as any three of our new JavaScript engines could best them both in speed and possibly even memory. Even when Ruby bytecode is run on V8 it can be [almost as fast ](http://macournoyer.wordpress.com/2008/09/02/ruby-%20on-v8/)as Ruby 1.9. Both Python and Ruby have problems scaling using threads because of&#xA0; their [GILs](http://en.wikipedia.org/wiki/Global_Interpreter_Lock). Meanwhile, [web worker](https://developer.mozilla.org/web-tech/2008/09/04/web-workers-part-1/) threading is already implemented in all three engines.

Take V8, one of the many new ServerJS extensions to it, an interactive debugger like IPython such as the one already in the [V8 on Python](http://bitbucket.org/dfdeshom/v8onpython/src/) project, a package manager like RubyGems, and bundle it up for Windows, Mac, and Linux and you can call it whatever you like. The worlds fastest dynamic language.
