import assert from "node:assert"
import { exec } from "node:child_process"
import {writeFile} from "node:fs/promises"

import { Readability, isProbablyReaderable } from '@mozilla/readability'
import { JSDOM } from 'jsdom'
import { GoogleGenAI } from '@google/genai'

const MODEL = 'gemini-2.5-flash-lite-preview-06-17'

async function getHtml(url: string) {
  console.log({ url })
  const response = await fetch(url, {
    method: "GET",
    headers: {
      'Content-Type': 'text/html'
    }
  })
  return response.text()
}

async function renderWithGemini(html: string): Promise<string> {
  assert(process.env.GEMINI_API_KEY !== undefined, "GEMINI_API_KEY environment variable not set")

  const prompt = `
Convert the following html to clean, compact markdown. Keep the main content, remove fluff.

**OUTPUT FORMAT**
1. **Preserve Links**: Keep all hyperlinks in the text as inline markdown links.
2. **Compact**: Keep the output concise and try to keep each line within 80 characters.
3. **Content Only**: Do not add anything to the content. No commentary.

${html}
`

  const ai = new GoogleGenAI({})
  const response = await ai.models.generateContent({
    model: MODEL,
    contents: prompt
  })

  const md = response.text
  assert(md !== undefined)

  return md
}

async function renderWithPandoc(html: string): Promise<string> {
  return new Promise((res, rej) => {
    const proc = exec(`pandoc -s -f html -t markdown`, (err, stdout) => {
      if (err !== null) {
        return rej(err)
      }
      return res(stdout)
    })
    proc.stdin?.write(html, (err) => {
      if (err) {
        return rej(err)
      }
      console.log('written')
      proc.stdin?.end()
    })
  })
}

async function renderHtml(html: string): Promise<string> {
  const dom = new JSDOM(html)
  if (isProbablyReaderable(dom.window.document)) {
    const reader = new Readability(dom.window.document)
    const article = reader.parse()
    assert(article !== null)
    assert(article.content !== null)
    assert(article.content !== undefined)

    return renderWithPandoc(article.content)
  }
  return renderWithGemini(html)
}

async function main() {
  const [
    url = "https://news.ycombinator.com",
    outfile = "page.md"
  ] = process.argv.slice(2) ?? []
  const html = await getHtml(url)
  const md = await renderHtml(html)
  return writeFile(outfile, md)
}

await main()
