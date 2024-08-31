//
//  ImageUtil.swift
//  TextScope
//
//  Created by Vijayakumar B on 30/08/24.
//

import Foundation
import AVFoundation
import CoreImage

func sampleBufferToCGImage(sampleBuffer: CMSampleBuffer) -> CGImage? {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    
    let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
    let ciContext = CIContext(options: nil)
    guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    
    return cgImage
}

func imageToGrayscale(cgImage: CGImage) -> CGImage? {
    let colorSpace = CGColorSpaceCreateDeviceGray()
    let width = cgImage.width
    let height = cgImage.height
    let bitmapInfo = CGImageAlphaInfo.none.rawValue
    
    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    ) else {
        return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))

    return context.makeImage()
}
