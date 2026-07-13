"""Generate MY PERC % logo and platform icon renditions."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]

BG = (0x0F, 0x1A, 0x24)
GOLD = (0xE8, 0xA8, 0x38)
TEAL = (0x4E, 0xCD, 0xC4)

FONT_PATH = r"C:\Windows\Fonts\arialbd.ttf"


def _font(size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_PATH, size)


def _text_bbox(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont) -> tuple[int, int, int, int]:
    if hasattr(draw, "textbbox"):
        return draw.textbbox((0, 0), text, font=font)
    w, h = draw.textsize(text, font=font)
    return (0, 0, w, h)


def _draw_percent_mark(
    img: Image.Image,
    *,
    content_scale: float = 0.72,
    transparent_bg: bool = False,
    accent_dots: bool = True,
) -> None:
    size = img.width
    draw = ImageDraw.Draw(img)

    if not transparent_bg:
        draw.rectangle((0, 0, size, size), fill=BG)

    font_px = max(8, int(size * content_scale * 0.78))
    font = _font(font_px)
    text = "%"
    bbox = _text_bbox(draw, text, font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (size - tw) // 2 - bbox[0]
    y = (size - th) // 2 - bbox[1]
    draw.text((x, y), text, font=font, fill=GOLD)

    if accent_dots:
        dot_r = max(2, int(size * 0.045))
        cx = size * 0.5
        cy = size * 0.5
        offset = size * 0.22
        for dx, dy in ((-offset, -offset), (offset, offset)):
            draw.ellipse(
                (
                    cx + dx - dot_r,
                    cy + dy - dot_r,
                    cx + dx + dot_r,
                    cy + dy + dot_r,
                ),
                fill=TEAL,
            )


def render_icon(size: int, *, maskable: bool = False, transparent_bg: bool = False) -> Image.Image:
    mode = "RGBA" if transparent_bg else "RGB"
    img = Image.new(mode, (size, size), (0, 0, 0, 0) if transparent_bg else BG)
    scale = 0.62 if maskable else 0.72
    _draw_percent_mark(img, content_scale=scale, transparent_bg=transparent_bg)
    return img


def save_png(path: Path, img: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, format="PNG", optimize=True)


def save_ico(path: Path, sizes: list[int]) -> None:
    ordered = sorted(sizes)
    master = render_icon(ordered[-1])
    path.parent.mkdir(parents=True, exist_ok=True)
    master.save(
        path,
        format="ICO",
        sizes=[(side, side) for side in ordered],
    )


def main() -> None:
    branding = ROOT / "assets" / "branding"
    save_png(branding / "my_perc_logo.png", render_icon(512, transparent_bg=True))
    save_png(branding / "my_perc_logo_master.png", render_icon(1024))

    save_png(ROOT / "web" / "favicon.png", render_icon(48))

    web_icons = ROOT / "web" / "icons"
    for name, size, maskable in (
        ("Icon-192.png", 192, False),
        ("Icon-512.png", 512, False),
        ("Icon-maskable-192.png", 192, True),
        ("Icon-maskable-512.png", 512, True),
    ):
        save_png(web_icons / name, render_icon(size, maskable=maskable))

    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    res = ROOT / "android" / "app" / "src" / "main" / "res"
    for folder, px in android_sizes.items():
        save_png(res / folder / "ic_launcher.png", render_icon(px))

    mac_dir = ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    for px in (16, 32, 64, 128, 256, 512, 1024):
        save_png(mac_dir / f"app_icon_{px}.png", render_icon(px))

    save_ico(
        ROOT / "windows" / "runner" / "resources" / "app_icon.ico",
        [16, 24, 32, 48, 64, 128, 256],
    )

    print("Generated MY PERC % icons:")
    for pattern in (
        "assets/branding/*.png",
        "web/favicon.png",
        "web/icons/*.png",
        "android/app/src/main/res/mipmap-*/ic_launcher.png",
        "macos/Runner/Assets.xcassets/AppIcon.appiconset/*.png",
        "windows/runner/resources/app_icon.ico",
    ):
        for path in sorted(ROOT.glob(pattern)):
            print(f"  {path.relative_to(ROOT)} ({path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()