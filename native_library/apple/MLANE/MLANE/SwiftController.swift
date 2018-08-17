/* Copyright 2018 Tua Rua Ltd.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import FreSwift
import CoreML

public class SwiftController: NSObject {
    public var TAG: String? = "SwiftController"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    private var mlController: CoreMlController?
    private let predictionQueue = DispatchQueue(label: "com.tuarua.mlane.predictionQueue", qos: .userInitiated)
    private var userChildren: [String: Any] = Dictionary()
    
    public func requestPermissions(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        let pc = PermissionController(context: context)
        pc.requestPermissions()
#else
    warning("requestPermissions is iOS only")
#endif
        return nil
    }
    
    func initController(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
    if #available(iOS 11.0, *) {
        mlController = CoreMlController.init(context: context)
        return true.toFREObject()
    }
#elseif os(tvOS)
    if #available(tvOS 11.0, *) {
        mlController = CoreMlController.init(context: context)
        return true.toFREObject()
    }
#else
    if #available(OSX 10.13, *) {
        mlController = CoreMlController.init(context: context)
        return true.toFREObject()
    }
#endif
        // Turn on FreSwift logging
        FreSwiftLogger.shared().context = context
        return false.toFREObject()
    }
    
    // MARK: - Models
    
    func compileModel(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
            let mc = mlController,
            let id = String(argv[0]),
            let path = String(argv[1])
            else {
                return FreArgError(message: "compileModel").getError(#file, #line, #column)
        }
        
        mc.compileModel(id: id, path: path)
        
        return nil
    }

    func loadModel(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
            let mc = mlController,
            let id = String(argv[0]),
            let path = String(argv[1])
          else {
            return FreArgError(message: "loadModel").getError(#file, #line, #column)
        }
        mc.loadModel(id: id, path: path)
        return nil
    }
    
    func disposeModel(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let mc = mlController,
            let id = String(argv[0])
            else {
                return FreArgError(message: "disposeModel").getError(#file, #line, #column)
        }
        mc.disposeModel(id: id)
        return nil
    }
    
    func getDescription(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let mc = mlController,
            let id = String(argv[0])
            else {
                return FreArgError(message: "getDescription").getError(#file, #line, #column)
        }
        return mc.getModelDescription(id: id)?.toFREObject()
    }
    
    // MARK: - Prediction
    
    func prediction(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 2,
            let mc = mlController,
            let id = String(argv[0]),
            let maxResults = Int(argv[2])
            else {
                return FreArgError(message: "prediction").getError(#file, #line, #column)
        }
        var input: Dictionary = [String: MLFeatureValue]()
        guard let modelDescription = mc.getModelDescription(id: id),
            let inFRE1 = argv[1],
            let rv = inFRE1["input"],
            let properties = rv.call(method: "getProperties") else {
                return FreError.init(stackTrace: "", message: "invalid prediction inputs",
                                     type: .invalidArgument).getError(#file, #line, #column)
        }
        let array: FREArray = FREArray.init(properties)
        let arrayLength = array.length
        for i in 0..<arrayLength {
            if let elem: FREObject = array[i] {
                if let propName = String(elem),
                    let type = modelDescription.inputDescriptionsByName[propName]?.type,
                    let freProp = rv[propName] {
                    switch type {
                    case .image:
                        let asBitmapData = FreBitmapDataSwift(freObject: freProp)
                        defer {
                            asBitmapData.releaseData()
                        }
                        if let cgimg = asBitmapData.asCGImage(),
                            let fd = modelDescription.inputDescriptionsByName[propName],
                            let ic = fd.imageConstraint {
                            predictionQueue.async {
                                let modelSize = CGSize(width: ic.pixelsWide, height: ic.pixelsHigh)
                                let cicontext = CIContext()
                                let image = CIImage(cgImage: cgimg)
                                if let resizedPixelBuffer = image.pixelBuffer(at: modelSize,
                                                                              context: cicontext) {
                                    input.updateValue(MLFeatureValue(pixelBuffer: resizedPixelBuffer),
                                                      forKey: propName)
                                }
                                mc.prediction(id: id, input: input, maxResults: maxResults)
                            }
                        }
                    case .double:
                        if let val = Double(freProp) {
                            input.updateValue(MLFeatureValue(double: val), forKey: propName)
                            mc.prediction(id: id, input: input, maxResults: maxResults)
                        }
                    case .int64:
                        if let val = Int(freProp) {
                            input.updateValue(MLFeatureValue(int64: Int64(val)), forKey: propName)
                            mc.prediction(id: id, input: input, maxResults: maxResults)
                        }
                    case .string:
                        if let val = String(freProp) {
                            input.updateValue(MLFeatureValue(string: val), forKey: propName)
                            mc.prediction(id: id, input: input, maxResults: maxResults)
                        }
                    default: break
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: - Camera Input
    
    func inputFromCamera(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        guard argc > 0,
            let mc = mlController,
            let id = String(argv[0]),
            let rvc = UIApplication.shared.keyWindow?.rootViewController
            else {
                return FreArgError(message: "inputFromCamera").getError(#file, #line, #column)
        }
        var mask: CGImage? = nil
        if let freMask = argv[1] {
            let asBitmapData = FreBitmapDataSwift.init(freObject: freMask)
            defer {
                asBitmapData.releaseData()
            }
            do {
                if let cgimg = try asBitmapData.asCGImage() {
                    mask = cgimg
                }
            } catch {
            }
        }
        mc.inputFromCamera(rootViewController: rvc, id: id, mask: mask)
#else
    warning("inputFromCamera is iOS only")
#endif
        return nil
    }
    
    func closeCamera(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
#if os(iOS)
        guard let mc = mlController,
            let rvc = UIApplication.shared.keyWindow?.rootViewController
            else {
                return FreArgError(message: "closeCamera").getError(#file, #line, #column)
        }
        mc.closeCamera(rootViewController: rvc)
#else
    warning("closeCamera is iOS only")
#endif
        return nil
    }
    
}
