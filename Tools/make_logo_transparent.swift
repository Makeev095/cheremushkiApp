#!/usr/bin/env swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

// Usage (recommended):
// xcrun swift Tools/make_logo_transparent.swift /path/to/input.jpg cheremushkiApp/Assets.xcassets/CheremushkiLogo.imageset
//
// It will create:
// - CheremushkiLogo@3x.png (maxWidth=780)
// - CheremushkiLogo@2x.png (maxWidth=520)
// - CheremushkiLogo@1x.png (maxWidth=260)
//
// Algorithm:
// - Sample the 4 corners, average them = backgroundColor
// - Any pixel close to backgroundColor (within tolerance) becomes transparent

struct RGBA {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
}

func die(_ message: String) -> Never {
    fputs("Error: \(message)\n", stderr)
    exit(1)
}

func loadCGImage(url: URL) -> CGImage {
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        die("Cannot open image: \(url.path)")
    }
    guard let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
        die("Cannot decode image: \(url.path)")
    }
    return img
}

func makeRGBAContext(width: Int, height: Int) -> CGContext {
    let bytesPerPixel = 4
    let bytesPerRow = width * bytesPerPixel
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
    guard let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        die("Cannot create CGContext")
    }
    return ctx
}

func renderIntoRGBA(_ image: CGImage) -> (ctx: CGContext, pixels: UnsafeMutableRawPointer) {
    let w = image.width
    let h = image.height
    let ctx = makeRGBAContext(width: w, height: h)
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
    guard let data = ctx.data else {
        die("Cannot access pixel buffer")
    }
    return (ctx, data)
}

func samplePixel(_ pixels: UnsafeMutableRawPointer, width: Int, x: Int, y: Int) -> RGBA {
    let bytesPerRow = width * 4
    let offset = y * bytesPerRow + x * 4
    let p = pixels.assumingMemoryBound(to: UInt8.self)
    return RGBA(r: p[offset], g: p[offset + 1], b: p[offset + 2], a: p[offset + 3])
}

func averageCornerColor(_ pixels: UnsafeMutableRawPointer, width: Int, height: Int, inset: Int = 6) -> (r: Int, g: Int, b: Int) {
    let points = [
        (x: inset, y: inset),
        (x: width - 1 - inset, y: inset),
        (x: inset, y: height - 1 - inset),
        (x: width - 1 - inset, y: height - 1 - inset)
    ]
    var r = 0, g = 0, b = 0
    for pt in points {
        let px = samplePixel(pixels, width: width, x: pt.x, y: pt.y)
        r += Int(px.r)
        g += Int(px.g)
        b += Int(px.b)
    }
    return (r / points.count, g / points.count, b / points.count)
}

@inline(__always)
func colorDistanceSq(_ px: RGBA, _ bg: (r: Int, g: Int, b: Int)) -> Int {
    let dr = Int(px.r) - bg.r
    let dg = Int(px.g) - bg.g
    let db = Int(px.b) - bg.b
    return dr*dr + dg*dg + db*db
}

func removeBackground(pixels: UnsafeMutableRawPointer, width: Int, height: Int, bg: (r: Int, g: Int, b: Int), tolerance: Int) {
    let tolSq = tolerance * tolerance
    let count = width * height
    let p = pixels.assumingMemoryBound(to: UInt8.self)
    for i in 0..<count {
        let base = i * 4
        let px = RGBA(r: p[base], g: p[base + 1], b: p[base + 2], a: p[base + 3])
        // Skip already transparent
        if px.a == 0 { continue }
        if colorDistanceSq(px, bg) <= tolSq {
            p[base + 3] = 0
        }
    }
}

func scaleImage(_ image: CGImage, maxWidth: Int) -> CGImage {
    let w = image.width
    let h = image.height
    if w <= maxWidth { return image }
    let scale = CGFloat(maxWidth) / CGFloat(w)
    let nw = maxWidth
    let nh = Int((CGFloat(h) * scale).rounded())
    let ctx = makeRGBAContext(width: nw, height: nh)
    ctx.interpolationQuality = .high
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: nw, height: nh))
    guard let out = ctx.makeImage() else { die("Cannot scale image") }
    return out
}

func writePNG(_ image: CGImage, to url: URL) {
    guard let dest = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        die("Cannot create PNG destination: \(url.path)")
    }
    CGImageDestinationAddImage(dest, image, nil)
    guard CGImageDestinationFinalize(dest) else {
        die("Cannot write PNG: \(url.path)")
    }
}

let args = CommandLine.arguments
guard args.count >= 3 else {
    die("Usage: xcrun swift Tools/make_logo_transparent.swift /path/to/input.(png|jpg) /path/to/CheremushkiLogo.imageset [tolerance]\nExample: xcrun swift Tools/make_logo_transparent.swift ~/Downloads/logo.jpg cheremushkiApp/Assets.xcassets/CheremushkiLogo.imageset 28")
}

let inputURL = URL(fileURLWithPath: args[1]).standardizedFileURL
let outDir = URL(fileURLWithPath: args[2]).standardizedFileURL
let tolerance = args.count >= 4 ? (Int(args[3]) ?? 28) : 28

var isDir: ObjCBool = false
guard FileManager.default.fileExists(atPath: outDir.path, isDirectory: &isDir), isDir.boolValue else {
    die("Output directory does not exist (must be .imageset dir): \(outDir.path)")
}

let baseImage = loadCGImage(url: inputURL)

let outputs: [(suffix: String, maxWidth: Int)] = [
    ("@3x", 780),
    ("@2x", 520),
    ("@1x", 260)
]

for out in outputs {
    let scaled = scaleImage(baseImage, maxWidth: out.maxWidth)
    let (ctx, pixels) = renderIntoRGBA(scaled)
    let bg = averageCornerColor(pixels, width: ctx.width, height: ctx.height)
    removeBackground(pixels: pixels, width: ctx.width, height: ctx.height, bg: bg, tolerance: tolerance)
    guard let outCG = ctx.makeImage() else { die("Cannot finalize output image") }
    let outURL = outDir.appendingPathComponent("CheremushkiLogo\(out.suffix).png")
    writePNG(outCG, to: outURL)
    print("Wrote \(outURL.path)")
}


