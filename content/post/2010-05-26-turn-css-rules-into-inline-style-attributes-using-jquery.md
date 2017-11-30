---
title: Turn CSS Rules Into Inline Style Attributes Using jQuery
date: 2010-05-26
categories:
- css
- javascript
- jquery
comments: true
aliases:
  - /2010/05/26/turn-css-rules-into-inline-style-attributes-using-jquery/
---

Gmail doesn't support stylesheets or the style tag, but they allow inline style attributes. This snippet allows the browser to use it's native facilities for building an HTML email for e.g. marketing campaigns by allowing you to write a document using linked stylesheets or inline style tags in the document. This could either be run within the context of the HTML email template itself or from a parent window that the HTML email is being built within. After the document has loaded and inlined it's style definitions, the style and script tags that very few email clients support will be removed so you can get the `innerHTML` of the document and use it later as the HTML portion of your multipart MIME emails.

{{< gist devinus 415179 >}} 
