# Dual-Engine Media Pipeline: Carousel Progress & Audio Session Architecture

Addressed critical media playback, slideshow carousel, and audio engineering challenges:
1. **Audio Session Configuration (`AVAudioSessionCategoryPlayback`):** Configured iOS `AVAudioSession` in `AppDelegate.swift` to use `.playback` mode with `.moviePlayback`, bypassing iOS physical hardware mute/silent switches so reel audio plays out loud.
2. **Slideshow vs Video Separation (No Play Buttons on Slides):** Updated `FeedScreen` and `UrlSanitizer` to classify `/p/` posts and non-video items strictly as `MediaType.carousel`, rendering `CarouselMediaItem` without video play overlays.
3. **Discrete Slide Progress Tracking:** `CarouselMediaItem` updates SQLite `watchProgress` as `(currentSlide + 1) / totalSlides`, reaching 100% (1.0) only when the user swipes through all slides.
4. **Interactive Media Intake Classification:** Added segmented content type selector (`Reel Video` vs `Slideshow Carousel`) and slide manager in `ShareCollectionSheet`.
5. **Database Self-Healing Routine:** Added `healExistingMediaTypes()` in `AppDatabase.beforeOpen` to automatically repair previously imported posts with `/p/` shortcodes.
6. **Dual-Engine Video Fallback (Local AVPlayer + WebKit Live Stream):** Embedded Instagram WebKit player fallback for Reels whose binary `.mp4` stream is protected by anti-bot barriers, enabling live video and audio directly in-feed.
