# Login backdrop video

Drop a licensed, looping drone-over-Seattle clip here named:

    seattle_login.mp4

The login screen (`lib/widgets/login_scene/login_scene.dart`) plays it muted
and looping, scaled to cover the screen. If the file is absent (or the
platform can't decode it), the painted Seattle scene is shown instead.

Keep it short (≈10–20s) and reasonably compressed (720p/1080p, H.264) so the
app bundle stays small and it decodes smoothly on low-end devices.
