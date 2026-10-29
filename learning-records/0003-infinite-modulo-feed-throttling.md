# Modulo Arithmetic for Infinite Feeds & Watch Progress Throttling

Discovered how to achieve unbounded endless vertical video feeds in Flutter by setting `itemCount: null` on `PageView.builder` combined with integer modulo arithmetic `rawIndex % items.length`. Implemented decoupled database throttling: UI progress bar renders at 60/120 Hz while SQLite disk commits are throttled to 1 Hz or upon reaching completion threshold (>= 95%).

## Implications
- Users can swipe vertically infinitely through their library without hitting an end-of-list boundary, even with only 3 or 4 saved videos.
- SQLite disk I/O and battery drain are minimized during playback by writing only once every 1,000ms instead of on every video player frame tick.
