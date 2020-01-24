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

#import <Foundation/Foundation.h>
#import "FreMacros.h"
#import "MLANE_oc.h"
#ifdef OSX
#import <MLANE/MLANE-Swift.h>
#else
#import <MLANE_FW/MLANE_FW.h>
#define FRE_OBJC_BRIDGE TRCML_FlashRuntimeExtensionsBridge
@interface FRE_OBJC_BRIDGE : NSObject<FreSwiftBridgeProtocol>
@end
@implementation FRE_OBJC_BRIDGE {
}
FRE_OBJC_BRIDGE_FUNCS
@end
#endif
@implementation MLANE_LIB
SWIFT_DECL(TRCML)

CONTEXT_INIT(TRCML) {
    SWIFT_INITS(TRCML)
    
    static FRENamedFunction extensionFunctions[] =
    {
         MAP_FUNCTION(TRCML, init)
        ,MAP_FUNCTION(TRCML, createGUID)
        ,MAP_FUNCTION(TRCML, compileModel)
        ,MAP_FUNCTION(TRCML, loadModel)
        ,MAP_FUNCTION(TRCML, disposeModel)
        ,MAP_FUNCTION(TRCML, prediction)
        ,MAP_FUNCTION(TRCML, getDescription)
        ,MAP_FUNCTION(TRCML, getTrainingInputDescriptionsByName)
        ,MAP_FUNCTION(TRCML, inputFromCamera)
        ,MAP_FUNCTION(TRCML, closeCamera)
        ,MAP_FUNCTION(TRCML, requestPermissions)
    };
    
    SET_FUNCTIONS
    
}

CONTEXT_FIN(TRCML) {
    [TRCML_swft dispose];
    TRCML_swft = nil;
#ifdef OSX
#else
    TRCML_freBridge = nil;
    TRCML_swftBridge = nil;
#endif
    TRCML_funcArray = nil;
}
EXTENSION_INIT(TRCML)
EXTENSION_FIN(TRCML)
@end
