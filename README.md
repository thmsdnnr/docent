# docent

> docent (adj.)
"teaching," 1630s, from Latin docentem (nominative docens), present participle of docere "to show, teach, cause to know," originally "make to appear right," causative of decere "be seemly, fitting," from PIE root *dek- "to take, accept."

> As a noun, "lecturer or teacher (usually a post-graduate student) in a college, not on staff but permitted to teach," by 1880, from German.

— [https://www.etymonline.com/word/docent](https://www.etymonline.com/word/docent)

## What even is it?

docent is a flash card app to help you learn things. You can use it on your mobile device. The goal is to make it as minimal as possible with no flashiness. It will always be a free product without any ads or distractions.

## Why another app?

I'm learning [Flutter](https://flutter.dev/) so that I can build "Beautiful Native Apps in Record Time". Hence, I need a pet project. Also, this app could be useful. I personally plan to use it to review programming and computer science concepts, along with learning new languages that I am interested in (computer and linguistic).

## Why is it nice?

The goal is to make exchange of flashcard formats easy. The data is stored in a relational DB, but it can be imported via JSON, and that JSON can be trivially generated with an export from a flat file, spreadsheet, or even programatically in the browser using a little bit of jQuery or XPath.

This means you can generate decks of cards that interest you on the fly, by scraping a website, API documentation, and so on. The goal is to make it as painless as possible (with as little typing as possible!) to capture a piece of information for study and import into your deck.

## Will this have any spaced repetition?

There is a lot of research into memorization and memory surrounding [spaced repetition](https://en.wikipedia.org/wiki/Spaced_repetition). Many fantastic products exist like [Anki](https://apps.ankiweb.net/) that can help you study cards based on a spaced repetition schedule. Also, the idea intuitively makes sense. I think anyone who has tried to learn something has implemented spaced repetition, to some extent, even if subconsciously.

My goal for this project is not to recreate any of these existing projects. However, a feature in the works is a card review mode in which you provide feedback about how well you knew the card. This feedback can be incorporated to estimate the "extent to which you know" a certain card, and this extent can be used to show you a card either:

1. more or less frequently during a given study session (inter-session repetition)
2. sooner rather than later over time (spacing study of lesser-known cards more closely)

Something like [SuperMemo2](https://www.supermemo.com/en/archives1990-2015/english/ol/sm2), conceived by [Dr. Piotr Wozniak](https://www.supermemo.com/en/archives1990-2015/english/company/wozniak).

The key theory behind this is intuitive: the notion is that if you know something well, you'll be able to recall it at farther and farther times in the future. So, as you show recall of something immediately, see how your recall is a few days later. If you still know it, try again in a week or two. If you still know it, try again in a month.

If at any point you miss it, go back to the start (you'll see the card again tomorrow, or in a week).