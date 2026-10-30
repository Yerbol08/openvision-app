"""Логотип OpenVision: глаз в рамке видоискателя. Единственный источник геометрии.

Пишет logo.svg, адаптивную иконку и PNG для Android, набор AppIcon для iOS.
Запуск из корня проекта: python openvision-design/design-system/logo/generate_icons.py
Нужен Pillow. Цвета — токены brand (light) и scan.
"""
import re
import sys
from pathlib import Path

from PIL import Image, ImageDraw

BRAND = "#2443b8"
WHITE = "#ffffff"
SCAN = "#d4f53c"

C = 512  # центр холста 1024×1024
STROKE = 54
EYE_W, EYE_H = 232, 128  # полуширина и полувысота глаза
PUPIL_R = 66
FRAME, ARM, CORNER = 330, 112, 44  # полуразмер рамки, длина плеча, скругление

# Доля холста под знак: на iOS и в PNG — как есть, в адаптивной иконке — внутри безопасной зоны.
ADAPTIVE_SCALE = 0.70
LEGACY_INSET = 0.08

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


def strokes():
    """Контуры знака в координатах 1024: M/Q/L, скругление концов задаёт перо."""
    eye = [("M", C - EYE_W, C), ("Q", C, C - 2 * EYE_H, C + EYE_W, C), ("Q", C, C + 2 * EYE_H, C - EYE_W, C)]
    out = [eye]
    for sx in (-1, 1):
        for sy in (-1, 1):
            x, y = C + sx * FRAME, C + sy * FRAME
            out.append([
                ("M", x, y - sy * ARM),
                ("L", x, y - sy * CORNER),
                ("Q", x, y, x - sx * CORNER, y),
                ("L", x - sx * ARM, y),
            ])
    return out


def path_data(stroke):
    return " ".join(cmd + " " + " ".join(f"{v:g}" for v in rest) for cmd, *rest in stroke)


def sample(stroke, steps=120):
    pts, cur = [], None
    for cmd, *a in stroke:
        if cmd == "M":
            cur = (a[0], a[1])
            pts.append(cur)
        elif cmd == "L":
            for i in range(1, steps + 1):
                t = i / steps
                pts.append((cur[0] + (a[0] - cur[0]) * t, cur[1] + (a[1] - cur[1]) * t))
            cur = (a[0], a[1])
        else:
            for i in range(1, steps + 1):
                t = i / steps
                pts.append((
                    (1 - t) ** 2 * cur[0] + 2 * t * (1 - t) * a[0] + t * t * a[2],
                    (1 - t) ** 2 * cur[1] + 2 * t * (1 - t) * a[1] + t * t * a[3],
                ))
            cur = (a[2], a[3])
    return pts


def render_mark(size, scale=1.0):
    """Знак на прозрачном фоне; рисуем в 4× и уменьшаем ради сглаживания."""
    s = size * 4
    k = s / 1024
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    to = lambda v: (C + (v - C) * scale) * k
    r = STROKE / 2 * scale * k
    for stroke in strokes():
        for x, y in sample(stroke):
            d.ellipse((to(x) - r, to(y) - r, to(x) + r, to(y) + r), fill=WHITE)
    p = PUPIL_R * scale * k
    d.ellipse((C * k - p, C * k - p, C * k + p, C * k + p), fill=SCAN)
    return img.resize((size, size), Image.LANCZOS)


def full_square(size):
    img = Image.new("RGBA", (size, size), BRAND)
    img.alpha_composite(render_mark(size))
    return img.convert("RGB")


def legacy_round(size):
    """Android 7: своя форма с полями, адаптивных иконок там ещё нет."""
    s = size * 4
    m = round(s * LEGACY_INSET)
    mask = Image.new("L", (s, s), 0)
    ImageDraw.Draw(mask).rounded_rectangle((m, m, s - m - 1, s - m - 1), radius=round(s * 0.19), fill=255)
    tile = Image.new("RGBA", (s, s), BRAND)
    tile.alpha_composite(render_mark(s, 1 - 2 * LEGACY_INSET - 0.04))
    tile.putalpha(mask)
    return tile.resize((size, size), Image.LANCZOS)


def svg():
    paths = "\n".join(f'    <path d="{path_data(p)}"/>' for p in strokes())
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" role="img" aria-label="OpenVision">
  <rect width="1024" height="1024" fill="{BRAND}"/>
  <g fill="none" stroke="{WHITE}" stroke-width="{STROKE}" stroke-linecap="round" stroke-linejoin="round">
{paths}
  </g>
  <circle cx="{C}" cy="{C}" r="{PUPIL_R}" fill="{SCAN}"/>
</svg>
'''


def vector_foreground():
    k = 108 / 1024
    off = 512 * (1 - ADAPTIVE_SCALE) * k
    sc = ADAPTIVE_SCALE * k
    paths = "\n".join(
        f'''        <path
            android:pathData="{path_data(p)}"
            android:strokeColor="{WHITE}"
            android:strokeWidth="{STROKE}"
            android:strokeLineCap="round"
            android:strokeLineJoin="round" />'''
        for p in strokes()
    )
    return f'''<?xml version="1.0" encoding="utf-8"?>
<!-- Сгенерировано openvision-design/design-system/logo/generate_icons.py -->
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <group
        android:translateX="{off:.4f}"
        android:translateY="{off:.4f}"
        android:scaleX="{sc:.6f}"
        android:scaleY="{sc:.6f}">
{paths}
        <path
            android:pathData="M {C - PUPIL_R} {C} A {PUPIL_R} {PUPIL_R} 0 1 1 {C + PUPIL_R} {C} A {PUPIL_R} {PUPIL_R} 0 1 1 {C - PUPIL_R} {C} Z"
            android:fillColor="{SCAN}" />
    </group>
</vector>
'''


ADAPTIVE = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
'''

COLORS = f'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{BRAND}</color>
</resources>
'''


def write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def main():
    (HERE / "logo.svg").write_text(svg(), encoding="utf-8", newline="\n")
    full_square(1024).save(HERE / "logo-1024.png")

    res = ROOT / "android/app/src/main/res"
    for name, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
        legacy_round(size).save(res / f"mipmap-{name}/ic_launcher.png")
    write(res / "drawable/ic_launcher_foreground.xml", vector_foreground())
    write(res / "mipmap-anydpi-v26/ic_launcher.xml", ADAPTIVE)
    write(res / "values/ic_launcher_colors.xml", COLORS)

    # Размер берём из имени файла: Icon-App-83.5x83.5@2x.png → 167.
    icons = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for f in icons.glob("Icon-App-*.png"):
        m = re.search(r"-([\d.]+)x[\d.]+@(\d)x", f.name)
        if not m:
            sys.exit(f"неожиданное имя: {f.name}")
        full_square(round(float(m[1]) * int(m[2]))).save(f)


if __name__ == "__main__":
    main()
