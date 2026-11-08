# tidbyt-healthchecks

A Pixlet (Starlark) app that shows Healthchecks.io status on the owner's Tidbyt. A GitHub
Actions cron renders it and pushes it to the device. Active and small; nothing runs on this
machine.

## Run

- Preview with demo data, offline: `pixlet render hc_status.star --magnify 8 && pixlet serve hc_status.star`
  (not run here: pixlet is not installed on this machine. CI pins v0.34.0. Installing it is
  the owner's call.)
- Push once to the device: `gh workflow run tidbyt-push` (not run here: it uses the
  owner's Tidbyt token and changes the physical display).

## Done means

```
python3 -c "import ast,yaml; ast.parse(open('hc_status.star').read(),'hc_status.star'); yaml.safe_load(open('.github/workflows/push.yml')); print('ok: star parses, workflow yaml loads')"
```

Passing prints `ok: star parses, workflow yaml loads` in about 0.03 s. This is only a syntax
floor: Starlark parses as Python, but Python also accepts things Starlark rejects, such as
`while` and `class`. If pixlet is installed, `pixlet render hc_status.star` without an
`api_key` is the real check: it renders the demo data and writes `hc_status.webp`.

## Never

- Never run `pixlet push` or dispatch the workflow unless the owner asks. It drives his
  physical device through Tidbyt's cloud.
- Never make the repo private. At the current schedule (about 45 runs a day) it would bill
  roughly 1,350 Actions minutes a month. That comes out of the same account budget that the
  numerai-netrunner submissions depend on.
- Never commit `hc_status.webp`. It is gitignored render output.
- Never commit a key. Keys live only in the Actions secrets `HC_API_KEY`, `TIDBYT_TOKEN` and
  `TIDBYT_DEVICE_ID`.
- Never use a Healthchecks key that can write. A read-only key is enough, and a writable key
  could pause or delete checks.
- Never add a local cron or loop to push updates. GitHub Actions is the only scheduler, and
  this machine runs no background jobs.

## Gotchas

- The README says the app pushes "every 10 min". That is stale. The workflow is the source of
  truth: every 15 minutes from 00:00 to 06:45 UTC (evenings, Pacific time) and hourly the rest
  of the day.
- Because of the hourly daytime cron and GitHub Actions cron drift, a down check can take more
  than an hour to show. Read the display as a glance, not as an alarm.
- Rendering without `api_key` silently uses the DEMO list, which shows gm-verify as down and
  gm-report in grace. A red preview is not a real outage.
- An error from the Healthchecks API shows an amber `HC API <code>` screen, not red.
- Keep `--installation-id hcstatus` fixed. Under pixlet push semantics, a new id adds a second
  app to the device rotation instead of replacing this one.
