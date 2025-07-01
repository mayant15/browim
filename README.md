# browim

A Neovim extension to browse web pages as Markdown.

## Requirements

- pandoc
- `GEMINI_API_KEY` environment variable
- Node.js

## Why?

I have Neovim set up to render markdown with conceals. I also have extensions to
navigate text easier. I wanted to use these same motions to browse pages instead
of clunky terminal web browsers.

This is primarily for reading and not interacting. Inspired by [spegel](https://github.com/simedw/spegel).

## How?

Given a URL, the `engine/` converts HTML to Markdown. If Firefox's [Reader
Mode]("https://github.com/mozilla/readability") is available for this webpage, use it to simplify the web page then
convert to markdown with pandoc. Otherwise, ask Gemini to do it.

