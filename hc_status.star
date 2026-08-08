"""Healthchecks.io status for Tidbyt.

Green OK screen when all checks are up; red list of failing checks otherwise.
Render with: pixlet render hc_status.star api_key=<readonly-key>
No api_key -> demo data, so `pixlet render hc_status.star` works offline.
"""

load("http.star", "http")
load("render.star", "render")

API = "https://healthchecks.io/api/v3/checks/"

# ponytail: demo data so the app renders without an account key
DEMO = [
    {"name": "gm-submit", "status": "up"},
    {"name": "gm-verify", "status": "down"},
    {"name": "gm-report", "status": "grace"},
    {"name": "gm-stake", "status": "up"},
]

RED = "#f00"
AMBER = "#fa0"
GREEN = "#0f0"

def get_checks(config):
    key = config.get("api_key")
    if not key:
        return DEMO, None
    rep = http.get(API, headers = {"X-Api-Key": key}, ttl_seconds = 240)
    if rep.status_code != 200:
        return None, "HC API %d" % rep.status_code
    return rep.json()["checks"], None

def screen(color, rows):
    return render.Root(
        child = render.Column([
            render.Box(height = 7, color = "#222", child = render.Text("HEALTHCHECKS", font = "tom-thumb", color = color)),
            render.Box(height = 1),
        ] + rows),
    )

def main(config):
    checks, err = get_checks(config)
    if err:
        return screen(AMBER, [render.WrappedText(err, font = "tom-thumb", color = AMBER)])

    down = [c["name"] for c in checks if c["status"] == "down"]
    grace = [c["name"] for c in checks if c["status"] == "grace"]

    if not down and not grace:
        return screen(GREEN, [
            render.Box(height = 16, child = render.Text("ALL OK", font = "6x13", color = GREEN)),
            render.Text("%d checks up" % len(checks), font = "tom-thumb", color = "#888"),
        ])

    rows = [render.Text(n, font = "tom-thumb", color = RED) for n in down]
    rows += [render.Text(n, font = "tom-thumb", color = AMBER) for n in grace]
    return screen(RED if down else AMBER, [
        render.Marquee(
            height = 24,
            scroll_direction = "vertical",
            child = render.Column(rows),
        ),
    ])
