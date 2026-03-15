#!/usr/bin/env python3
"""
palette_remap.py — AIで生成したドット絵をマスターパレットに正規化するツール。

使い方:
    python palette_remap.py --palette master_palette.hex --input sprites/ --output output/

パレットファイル (.hex): 1行1色、#RRGGBB形式
"""

import argparse
import os
import sys

try:
    from PIL import Image
except ImportError:
    print("Pillow が必要です: pip install Pillow")
    sys.exit(1)


def load_palette(hex_file):
    """パレットファイルを読み込み、RGB タプルのリストを返す"""
    colors = []
    with open(hex_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('//') or line.startswith(';'):
                continue
            hex_color = line.lstrip('#')
            if len(hex_color) == 6:
                r, g, b = int(hex_color[0:2], 16), int(hex_color[2:4], 16), int(hex_color[4:6], 16)
                colors.append((r, g, b))
    return colors


def color_distance(c1, c2):
    """2色間のユークリッド距離"""
    return sum((a - b) ** 2 for a, b in zip(c1, c2)) ** 0.5


def find_nearest_color(color, palette):
    """パレット内の最近色を返す"""
    return min(palette, key=lambda p: color_distance(color[:3], p))


def remap_image(img, palette):
    """画像の全ピクセルをパレットの最近色に置換"""
    img = img.convert('RGBA')
    pixels = img.load()
    width, height = img.size
    remapped = 0
    total = 0

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if a == 0:  # 透過ピクセルはスキップ
                continue
            total += 1
            original = (r, g, b)
            nearest = find_nearest_color(original, palette)
            if original != nearest:
                pixels[x, y] = (nearest[0], nearest[1], nearest[2], a)
                remapped += 1

    return img, remapped, total


def process_directory(input_dir, output_dir, palette):
    """ディレクトリ内の全PNG画像を処理"""
    os.makedirs(output_dir, exist_ok=True)
    extensions = ('.png', '.PNG')

    files = [f for f in os.listdir(input_dir) if f.endswith(extensions)]
    if not files:
        print(f"  PNG ファイルが見つかりません: {input_dir}")
        return

    print(f"  {len(files)} ファイルを処理中...")
    total_remapped = 0
    total_pixels = 0

    for filename in sorted(files):
        filepath = os.path.join(input_dir, filename)
        img = Image.open(filepath)
        result, remapped, pixels = remap_image(img, palette)

        output_path = os.path.join(output_dir, filename)
        result.save(output_path, 'PNG')

        total_remapped += remapped
        total_pixels += pixels
        pct = (remapped / pixels * 100) if pixels > 0 else 0
        status = "OK" if pct == 0 else f"FIXED ({pct:.1f}%)"
        print(f"    {filename}: {status}")

    pct = (total_remapped / total_pixels * 100) if total_pixels > 0 else 0
    print(f"  完了: {total_remapped}/{total_pixels} ピクセル置換 ({pct:.1f}%)")


def main():
    parser = argparse.ArgumentParser(description='ドット絵をマスターパレットに正規化')
    parser.add_argument('--palette', '-p', required=True, help='パレットファイル (.hex)')
    parser.add_argument('--input', '-i', required=True, help='入力ディレクトリまたはファイル')
    parser.add_argument('--output', '-o', required=True, help='出力ディレクトリ')
    args = parser.parse_args()

    palette = load_palette(args.palette)
    print(f"パレット読込: {len(palette)} 色")

    if os.path.isdir(args.input):
        process_directory(args.input, args.output, palette)
    elif os.path.isfile(args.input):
        os.makedirs(args.output, exist_ok=True)
        img = Image.open(args.input)
        result, remapped, pixels = remap_image(img, palette)
        output_path = os.path.join(args.output, os.path.basename(args.input))
        result.save(output_path, 'PNG')
        pct = (remapped / pixels * 100) if pixels > 0 else 0
        print(f"完了: {remapped}/{pixels} ピクセル置換 ({pct:.1f}%)")
    else:
        print(f"エラー: {args.input} が見つかりません")
        sys.exit(1)


if __name__ == '__main__':
    main()
