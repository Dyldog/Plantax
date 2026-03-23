# Plan Syntax

Each line in a plan describes a single event. An event line has up to three optional prefixes — a start time, an end time, and a duration — followed by a title.

```
[@[date] time] [-> [date] time] [#duration] Title
```

## Times

Times use 12-hour format with a required `am`/`pm` suffix. Minutes are optional.

```
@9am Breakfast
@10:30am Meeting
->5pm End of work
```

## Dates

A date can be placed before the time in either `day/month` or `day/month/year` format. When the year is omitted, the current year is assumed. When no date is given, today is assumed.

```
@23/3 9am Breakfast
@23/3/2026 10:30am Meeting
->24/3 5pm End of trip
```

## Durations

A duration is written as `#` followed by a number and a unit — `m` for minutes, `h` for hours.

```
#30m Lunch
#2h Workshop
```

## Event Types

How the prefixes combine determines the type of event.

### Fixed (start and end)

Both start and end are known. The event occupies an exact window.

```
@9am ->10am Standup
@23/3 9am ->24/3 5pm Conference
```

### Fixed (start/end + duration)

A start or end paired with a duration. The missing boundary is calculated.

```
@9am #1h Standup
->5pm #30m Wrap up
```

### Open-start (end only)

Only an end time. The event starts at the end of the previous event (or now, if it is the first event).

```
->9am Commute
```

### Open-end (start only)

Only a start time. The event ends at the start of the next event, so the next event **must** have a start time.

```
@9am Work
@5pm Finish
```

### Duration only

No absolute time — just a length. The event starts at the end of the previous event.

```
#45m Exercise
```

### Free (title only)

No time information at all. The event fills the gap between the previous event's end and the next event's start.

```
Free time
```

## Sequencing Rules

Events are compiled in order. Several types rely on their neighbours:

| Event type | Requirement |
|---|---|
| Duration-only | Must follow an event that has an end time |
| Free | Must follow an event that has an end time |
| Open-end | Must be followed by an event that has a start time |

## Travel Events

A travel event calculates the driving/riding/walking duration between two locations using MapKit. The keyword (`DRIVE`, `RIDE`, or `WALK`) is followed by `origin -> destination`.

```
DRIVE Sydney -> Melbourne
@9am WALK Hotel -> Conference Centre
```

### Travel Children

Indented lines beneath a travel event describe activities that occur during the journey. There are two kinds:

#### Schedule windows (`@start->end Title`)

A clock-time window that activates whenever the wall-clock falls within its range. Useful for sleep or meal stops.

```
    @11pm->8am Sleep and camp
    @12pm->1pm Lunch stop
```

#### Recurring breaks (`%interval/duration Title`)

A break that triggers after every *interval* of accumulated driving time, lasting for *duration*.

```
    %1h/10m Rest stop
    %2h/15m Stretch break
```

### Priority

Children listed higher take precedence. If a schedule window and a recurring break would overlap, the higher-listed child is chosen.

### Full travel example

```
DRIVE Sydney -> Melbourne
    @11pm->8am Sleep and camp
    %1h/10m Break
```

This calculates the driving duration from Sydney to Melbourne and produces a schedule that interleaves driving segments with:

1. **Sleep and camp** — whenever the clock is between 11 pm and 8 am.
2. **Break** — 10 minutes of rest after every hour of driving.

Because "Sleep and camp" is listed first, it takes priority over breaks during its window.

## Full Example

```
->9am Commute
@9am ->9:15am Standup
#45m Deep work
@10am ->12pm Meetings
Free time
@12:30pm #1h Lunch
@1:30pm Work
@23/3 9am ->24/3 5pm Offsite conference
```
