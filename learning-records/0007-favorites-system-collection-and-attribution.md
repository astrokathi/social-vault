# Favorites System Collection, Local Rendering & Anti-Plagiarism Attribution

Addressed five core architectural requests:
1. **Local Media Resolution (`VaultImage`):** Resolved relative sandbox paths (`vault_media/...`) to absolute paths at runtime, fixing render failures across Feed and Collections.
2. **Anti-Plagiarism Creator Attribution:** Enhanced regex parsing for `@creator` handles and unescaped full descriptions; made captions expandable and added creator verification badges.
3. **Internal Default Favorites Collection:** Replaced generic like icon with a Favorites toggle linked to an immutable built-in system collection (`col_favorites`) that users cannot manually recreate or delete.
4. **Action Bar Optimization:** Removed the redundant Saved bookmark icon.
5. **Landscape Mode:** Wired dynamic screen orientation switching via `SystemChrome.setPreferredOrientations`.
