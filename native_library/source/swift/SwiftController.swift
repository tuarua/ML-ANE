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
import Cocoa
import FreSwift
import CoreML

public class SwiftController: NSObject {
    public var TAG: String? = "SwiftController"
    public var context: FreContextSwift!
    public var functionsToSet: FREFunctionMap = [:]
    private var mlController: CoreMlController?

    func initController(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        if #available(OSX 10.13, *) {
            mlController = CoreMlController.init(context: context)
            return true.toFREObject()
        }
        return false.toFREObject()
    }
    
    func compileModel(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 1,
            let mc = mlController,
            let id = String(argv[0]),
            let path = String(argv[1])
            else {
                return ArgCountError(message: "compileModel").getError(#file, #line, #column)
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
            return ArgCountError(message: "loadModel").getError(#file, #line, #column)
        }
        mc.loadModel(id: id, path: path)
        return nil
    }
    
    func prediction(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 2,
            let mc = mlController,
            let id = String(argv[0]),
            let maxResults = Int(argv[2])
            else {
                return ArgCountError(message: "prediction").getError(#file, #line, #column)
        }
        var input: Dictionary = [String: MLFeatureValue]()
        do {
            guard let modelDescription = mc.getModelDescription(id: id),
                let inFRE1 = argv[1],
                let freInput = try? inFRE1.getProp(name: "input"),
                let rv = freInput,
                let aneUtils = try FREObject.init(className: "com.tuarua.fre.ANEUtils"),
                let classProps1 = try aneUtils.call(method: "getClassProps", args: rv) else {
                    return FreError.init(stackTrace: "", message: "invalid prediction inputs",
                                         type: .invalidArgument).getError(#file, #line, #column)
            }
            let array: FREArray = FREArray.init(classProps1)
            let arrayLength = array.length
            for i in 0..<arrayLength {
                if let elem: FREObject = try array.at(index: i) {
                    if let propNameAs = try elem.getProp(name: "name") {
                        if let propName = String(propNameAs) {
                            if let freProp = try rv.getProp(name: propName) {
                                switch freProp.type {
                                case .bitmapdata:
                                    let asBitmapData = FreBitmapDataSwift(freObject: freProp)
                                    defer {
                                        asBitmapData.releaseData()
                                    }
                                    do {
                                        if let cgimg = try asBitmapData.asCGImage(),
                                            let fd = modelDescription.inputDescriptionsByName[propName],
                                            let ic = fd.imageConstraint {
                                            let modelSize = CGSize(width: ic.pixelsWide, height: ic.pixelsHigh)
                                            let cicontext = CIContext()
                                            let image = CIImage(cgImage: cgimg)
                                            if let resizedPixelBuffer = image.pixelBuffer(at: modelSize,
                                                                                          context: cicontext) {
                                                input.updateValue(MLFeatureValue(pixelBuffer: resizedPixelBuffer),
                                                                  forKey: propName)
                                            }
                                        }
                                    } catch {
                                    }
                                case .number, .int:
                                    if let val = Double(freProp) {
                                        input.updateValue(MLFeatureValue(double: val), forKey: propName)
                                    }
                                case .string:
                                    if let val = String(freProp) {
                                        input.updateValue(MLFeatureValue(string: val), forKey: propName)
                                    }
                                default: break
                                }
                            }
                        }
                    }
                }
            }
            
        } catch let e as FreError {
            return e.getError(#file, #line, #column)
        } catch {
            
        }
        if !input.isEmpty {
            mc.prediction(id: id, input: input, maxResults: maxResults)
        }
        return nil
    }
    
    func getDescription(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let mc = mlController,
            let id = String(argv[0])
            else {
                return ArgCountError(message: "getDescription").getError(#file, #line, #column)
        }
        return mc.getModelDescription(id: id)?.toFREObject()
    }
    
}
