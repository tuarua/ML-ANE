import Foundation
import CoreML
import Vision

// This is a helper extension to convert CIImage into a pixel buffer to be used with SqueezeNet
public extension CIImage {
    func pixelBuffer(at size: CGSize, context: CIContext) -> CVPixelBuffer? {
        
        //1 - create a dictionary requesting Core Graphics compatibility
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                          kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        //2 - create a pixel buffer at the size our model needs
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height),
                                         kCVPixelFormatType_32ARGB, attributes, &pixelBuffer)
        guard status == kCVReturnSuccess else { return nil }
        
        //3 - calculate how much we need to scale down our image
        let scale = size.width / self.extent.size.width
        
        //4 - create a new scaled-down image using the scale we just calculated
        let resizedImage = self.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        //5 - calculate a cropping rectangle and apply it immediately
        let width = resizedImage.extent.width
        let height = resizedImage.extent.height
        let yOffset = (CGFloat(height) - size.height) / 2.0
        let rect = CGRect(x: (CGFloat(width) - size.width) / 2.0, y: yOffset, width: size.width, height: size.height)
        let croppedImage = resizedImage.cropped(to: rect)
        
        //6 - move the cropped image down so that its centered
        let translatedImage = croppedImage.transformed(by: CGAffineTransform(translationX: 0, y: -yOffset))
        
        //7 - render the CIImage to our CVPixelBuffer and return it
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        context.render(translatedImage, to: pixelBuffer!)
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
