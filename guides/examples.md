# Examples And Learning Paths

Nadia has two layers that can be used together or separately:

* `Nadia` exposes the complete Telegram Bot API as direct Elixir functions.
* `Nadia.Context`, `Nadia.Dispatcher`, `Nadia.Polling`, `Nadia.Webhook`, and
  `Nadia.SessionStore` provide small building blocks for receiving updates in
  an OTP application.

Start with the path that matches what you are building.

## First Bot

| Goal | Guide | Main modules |
| --- | --- | --- |
| Generate and run an echo bot | [Build Your First Bot](build-your-first-bot.md) | `Mix.Tasks.Nadia.Gen.Bot`, `Nadia.Polling` |
| Route commands and inline buttons | [Commands And Inline Keyboards](examples/inline-keyboards.md) | `Nadia.Dispatcher`, `Nadia.Context` |
| Collect data over several messages | [Conversation State](examples/conversation-state.md) | `Nadia.SessionStore` |

The complete handler source for the interactive examples lives in the
[`examples`](https://github.com/zhyu/nadia/tree/master/examples) directory and
is compiled and exercised by Nadia's normal test suite.

## Integrate And Test

| Goal | Guide | Main modules |
| --- | --- | --- |
| Receive updates over HTTP | [Receive Webhook Updates](receive-webhook-updates.md) | `Nadia.Webhook` |
| Run several bot identities | [Run Multiple Bots](multiple-bots.md) | `Nadia.Client`, `Nadia.Polling` |
| Test without credentials or network calls | [Test Bot Handlers](testing-bots.md) | `Nadia.Client`, `Nadia.HTTPClient` |
| Publish Telegraph pages | [Use The Telegraph API](telegraph.md) | `Nadia.Graph` |

## Prepare For Production

Read the [Production Checklist](production-checklist.md) before deploying. It
covers polling versus webhooks, duplicate delivery, handler return values,
state persistence, secrets, timeouts, and operational visibility.

For individual Bot API calls and model fields, use the `Nadia` module reference
alongside the [official Telegram Bot API documentation](https://core.telegram.org/bots/api).
The examples focus on application mechanics rather than repeating one example
for each Telegram method.
