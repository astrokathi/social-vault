# Native OS Share Sheet Interception & Resilient Media Extraction

Configured Android `ACTION_SEND` intent filter with `android:launchMode="singleTask"` and iOS App Group extension support. Implemented the OpenGraph crawler pipeline to extract `og:image`, `og:video`, and author handles, paired with immediate binary downloading to bypass Instagram's 24–48 hour CDN signature expiration (`oh=` and `oe=` parameters).

## Implications
- When a user shares a Reel from Instagram, the operating system routes the URL directly into ReelVault without starting a second app instance.
- Downloading media bytes immediately into `vault_media/` guarantees that videos and carousel photos remain playable offline permanently, immune to expired CDN token links.
