import os
import sys
import json
import struct
import zlib

def create_png(width, height, color_rgba=(255, 255, 255, 255)):
    # Standard PNG creation
    raw_data = bytearray()
    r, g, b, a = color_rgba
    for y in range(height):
        raw_data.append(0) # filter byte: None
        for x in range(width):
            raw_data.extend([r, g, b, a])
    
    def chunk(chunk_type, data):
        c = chunk_type + data
        crc = zlib.crc32(c) & 0xffffffff
        return struct.pack(">I", len(data)) + c + struct.pack(">I", crc)
    
    png = bytearray(b"\x89PNG\r\n\x1a\n")
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png.extend(chunk(b"IHDR", ihdr))
    compressed = zlib.compress(raw_data, 9)
    png.extend(chunk(b"IDAT", compressed))
    png.extend(chunk(b"IEND", b""))
    return bytes(png)

def generate_icon():
    # Apple icon with nice gradient / styling
    # 1024x1024 icon
    width, height = 1024, 1024
    raw_data = bytearray()
    
    # Generate an elegant iOS app icon background
    # Apple style: deep space black to indigo-sapphire gradient with a central studio glyph
    for y in range(height):
        raw_data.append(0)
        v = y / height
        for x in range(width):
            u = x / width
            # distance from center
            dx = (u - 0.5) * 2.0
            dy = (v - 0.5) * 2.0
            dist = (dx*dx + dy*dy)**0.5
            
            # Base gradient: dark midnight (#0F111A) to deep purple-blue (#1E1B4B)
            r = int(15 + 25 * v)
            g = int(17 + 20 * v)
            b = int(26 + 60 * v)
            
            # Subtle radial glow
            if dist < 0.8:
                glow = (1.0 - dist / 0.8) * 0.4
                r = min(255, int(r + 60 * glow))
                g = min(255, int(g + 130 * glow))
                b = min(255, int(b + 246 * glow))
                
            # Stylized S / Studio prism ring in center
            if 0.38 < dist < 0.46:
                # Ring
                r = min(255, int(r + 180 * (1.0 - abs(dist - 0.42)/0.04)))
                g = min(255, int(g + 210 * (1.0 - abs(dist - 0.42)/0.04)))
                b = min(255, int(b + 255 * (1.0 - abs(dist - 0.42)/0.04)))
            elif dist <= 0.38:
                # Inner disc
                inner_v = (1.0 - dist / 0.38)
                r = min(255, int(r + 30 * inner_v))
                g = min(255, int(g + 40 * inner_v))
                b = min(255, int(b + 90 * inner_v))
                
            raw_data.extend([r, g, b, 255])
            
    def chunk(chunk_type, data):
        c = chunk_type + data
        crc = zlib.crc32(c) & 0xffffffff
        return struct.pack(">I", len(data)) + c + struct.pack(">I", crc)
    
    png = bytearray(b"\x89PNG\r\n\x1a\n")
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    png.extend(chunk(b"IHDR", ihdr))
    compressed = zlib.compress(raw_data, 6)
    png.extend(chunk(b"IDAT", compressed))
    png.extend(chunk(b"IEND", b""))
    return bytes(png)

if __name__ == "__main__":
    icon_bytes = generate_icon()
    os.makedirs("iOSStudio/iOSStudio/Assets.xcassets/AppIcon.appiconset", exist_ok=True)
    with open("iOSStudio/iOSStudio/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png", "wb") as f:
        f.write(icon_bytes)
    print("Icon generated successfully!")

