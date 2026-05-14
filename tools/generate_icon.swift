#!/usr/bin/env swift
import AppKit
import Foundation

let sizes = [16, 32, 64, 128, 256, 512, 1024]
let glyph = "🍅"
let outDir = "build/PomoTimer.iconset"

try? FileManager.default.removeItem(atPath: outDir)
try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

func renderPNG(size: Int) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size, pixelsHigh: size,
        bitsPerSample: 8, samplesPerPixel: 4,
        hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0, bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)

    let font = NSFont.systemFont(ofSize: CGFloat(size) * 0.82)
    let attrs: [NSAttributedString.Key: Any] = [.font: font]
    let str = NSAttributedString(string: glyph, attributes: attrs)
    let bounds = str.boundingRect(with: NSSize(width: CGFloat(size), height: CGFloat(size)),
                                  options: [.usesFontLeading])
    let rect = NSRect(
        x: (CGFloat(size) - bounds.width) / 2,
        y: (CGFloat(size) - bounds.height) / 2,
        width: bounds.width,
        height: bounds.height
    )
    str.draw(in: rect)

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let mapping: [(Int, String)] = [
    (16,   "icon_16x16.png"),
    (32,   "icon_16x16@2x.png"),
    (32,   "icon_32x32.png"),
    (64,   "icon_32x32@2x.png"),
    (128,  "icon_128x128.png"),
    (256,  "icon_128x128@2x.png"),
    (256,  "icon_256x256.png"),
    (512,  "icon_256x256@2x.png"),
    (512,  "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]

var cache: [Int: Data] = [:]
for size in sizes { cache[size] = renderPNG(size: size) }

for (size, filename) in mapping {
    let path = "\(outDir)/\(filename)"
    try cache[size]!.write(to: URL(fileURLWithPath: path))
}

let task = Process()
task.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
task.arguments = ["-c", "icns", outDir, "-o", "build/AppIcon.icns"]
try task.run()
task.waitUntilExit()
guard task.terminationStatus == 0 else {
    FileHandle.standardError.write(Data("iconutil failed\n".utf8))
    exit(1)
}
print("Wrote build/AppIcon.icns")
