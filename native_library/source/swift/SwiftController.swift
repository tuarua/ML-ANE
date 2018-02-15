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
        guard argc > 0,
            let mc = mlController,
            let path = String(argv[0])
            else {
                return ArgCountError(message: "compileModel").getError(#file, #line, #column)
        }
        
        mc.compileModel(path: path)
        
        return nil
    }

    func loadModel(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
              let mc = mlController,
              let path = String(argv[0])
          else {
            return ArgCountError(message: "loadModel").getError(#file, #line, #column)
        }
        mc.loadModel(path: path)
        return nil
    }
    
    func prediction(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        return nil
    }
    
    func getDescription(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard let mc = mlController
            else {
                return ArgCountError(message: "getDescription").getError(#file, #line, #column)
        }
        return mc.modelDescription?.toFREObject()
    }
    
    func classifyImage(ctx: FREContext, argc: FREArgc, argv: FREArgv) -> FREObject? {
        guard argc > 0,
            let mc = mlController,
            let type = Int(argv[0])
            else {
                return ArgCountError(message: "classifyImage").getError(#file, #line, #column)
        }
        
        if let path = String(argv[1]) {
            let img = NSImage(contentsOfFile: path)
            if let image = img {
                var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
                if let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) {
                    mc.classifyImage(type: type, cgImage: imageRef)
                }
            }
        } else if let inFRE2 = argv[2] {
            let asBitmapData = FreBitmapDataSwift(freObject: inFRE2)
            defer {
                asBitmapData.releaseData()
            }
            do {
                if let cgimg = try asBitmapData.asCGImage() {
                    mc.classifyImage(type: type, cgImage: cgimg)
                }
            } catch {
            }
            
        }

        return nil
    }
    
}
