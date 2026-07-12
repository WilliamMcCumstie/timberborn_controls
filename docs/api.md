# Timberborn API Documentation

Base URL: `http://localhost:8080`

The API exposes two resource types: **Levers** and **Adapters**.

## Resource naming convention

Resources follow the pattern `{PREFIX}:{building_name}:{port}`, e.g. `P:log:M`.

- `PREFIX` — single character configured in-game (stored as `Config::RESOURCE_PREFIX`, default `"P"`)
- `building_name` — the name given to the building in-game (e.g. `log`)
- `port` — port identifier on the building: `L` = low, `H` = high, `M` = manufacturing, `S` = status

Ports appear as either **levers** (controllable: `M`, `S`) or **adapters** (read-only: `L`, `H`), depending on the building type.

The default test resources (`HTTP Lever 1`, `HTTP Adapter 1`) use a different naming format from the in-game mod UI.

---

## In-game physical setup

For each resource, place the buildings in a single line, perpendicular to a road, in this exact order:

1. **Adapter `L`** — connects to the resource sensor below to report the low-threshold state
2. **Adapter `H`** — connects to the resource sensor below to report the high-threshold state
3. **Resource sensor `L`** — low-threshold sensor, connected to the Adapter `L` above it
4. **Road**
5. **Resource sensor `H`** — high-threshold sensor, connected to the Adapter `H` above it
6. **Lever `S`** — status indicator
7. **Lever `M`** — manufacturing on/off switch

The road splits the line in two: the low-side adapter/sensor pair sits on one side, and the high-side sensor/lever pair sits on the other. Each adapter must be directly connected to its corresponding resource sensor to relay that sensor's state over HTTP. Name each building using the standard convention (`{PREFIX}:{building_name}:{port}`, e.g. `P:logs:L`) so the app can discover and control them correctly.

---

## Levers

Levers are toggleable switches that can be turned on/off and assigned a colour.

### List all levers
```
GET /api/levers
```
Response:
```json
[
  { "name": "HTTP Lever 1", "state": true, "springReturn": false }
]
```

### Get a single lever
```
GET /api/levers/:name
```
Response:
```json
{ "name": "HTTP Lever 1", "state": true, "springReturn": false }
```

### Switch a lever on
```
POST /api/switch-on/:name
```
Response: `OK`

### Switch a lever off
```
POST /api/switch-off/:name
```
Response: `OK`

### Set lever colour
```
POST /api/color/:name/:hex
```
- `:hex` — 6-character hex colour code (e.g. `ff0000` for red, `00ff00` for green)

Response: `OK`

---

## Adapters

Adapters are read-only state indicators (no on/off control).

### List all adapters
```
GET /api/adapters
```
Response:
```json
[
  { "name": "HTTP Adapter 1", "state": false }
]
```

### Get a single adapter
```
GET /api/adapters/:name
```
Response:
```json
{ "name": "HTTP Adapter 1", "state": false }
```

---

## Notes

- Resource names with spaces must be URL-encoded (e.g. `HTTP Lever 1` → `HTTP%20Lever%201`).
- Resources using the `:` separator format (e.g. `P:log:M`) must encode colons: `P%3Alog%3AM`.
- All action endpoints (`switch-on`, `switch-off`, `color`) use `POST` requests with an empty body and return plain `OK` on success.
- `springReturn` on a lever indicates it reverts to off automatically after being triggered.
- The `RESOURCE_PREFIX` in `config.rb` (default `"P"`) corresponds to the single-character prefix configured in-game for HTTP-controlled resources.
