
//
//  IIFishBind.m
//  FishBindDemo
//
//  Created by WELCommand on 2017/9/4.
//  Copyright © 2017年 WELCommand. All rights reserved.
//

#import "IIFishBind.h"
#import <pthread.h>
#import <objc/runtime.h>
#import <objc/message.h>

static char const* IIFish_Prefix = "IIFish_";
static char const* IIFishWatchCallbackKey = "IIFishWatchCallbackKey";

typedef NS_OPTIONS(NSUInteger, IIFishFlage) {
    IIFish_IsBlock = (1 << 0),
    IIFish_Post =  (1 << 1),
    IIFish_Observer  =    (1 << 2),
    IIFish_Property = (1 << 3),
    IIFish_Seletor = (1 << 4)
};


@implementation IIFishCallBack
- (NSString *)description {
    return [NSString stringWithFormat:@"\ntager = %@\nselector = %@\nargs = %@\nresule = %@", _tager, _selector, _args, _resule];
}
@end


#pragma mark-
#pragma mark- IIFish

@interface IIFish ()
@property (nonatomic, assign) IIFishFlage flag;
@property (nonatomic, weak) id object;
@property (nonatomic, copy) NSString *property;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) IIFishCallBackBlock callBack;
@end

@implementation IIFish

+ (instancetype)fish:(id)object property:(NSString*)property selector:(SEL)selector callBack:(IIFishCallBackBlock)callBack flag:(NSInteger)flag {
    IIFish *fish = [[self alloc] init];
    fish.object = object;
    fish.selector = selector;
    fish.property = property;
    fish.callBack = callBack;
    fish.flag = flag;
    return fish;
}

+ (instancetype)both:(id)object selector:(SEL)selector callBack:(IIFishCallBackBlock)callBack {
    return [self  fish:object property:nil selector:selector callBack:callBack flag:IIFish_Seletor];
}
+ (instancetype)both:(id)object property:(NSString*)property callBack:(IIFishCallBackBlock)callBack {
    return [self fish:object property:property selector:nil callBack:callBack flag:IIFish_Property];
}
+ (instancetype)postBlock:(id)blockObject {
    return [self fish:blockObject property:nil selector:nil callBack:nil flag:IIFish_Post | IIFish_IsBlock];
}
+ (instancetype)post:(id)object property:(NSString *)property {
    return [self fish:object property:property selector:nil callBack:nil flag:IIFish_Post | IIFish_Property];
}
+ (instancetype)post:(id)object selector:(SEL)selector {
    return [self fish:object property:nil selector:selector callBack:nil flag:IIFish_Post | IIFish_Seletor];
}
+ (instancetype)observer:(id)object property:(NSString *)property {
    return [self fish:object property:property selector:nil callBack:nil flag:IIFish_Observer | IIFish_Property];
}
+ (instancetype)observer:(id)object callBack:(IIFishCallBackBlock)callBack {
    return [self fish:object property:nil selector:nil callBack:callBack flag:IIFish_Observer | IIFish_Seletor];
}
@end


#pragma mark-
#pragma mark- Dead Fish

@interface IIDeadFish : NSProxy
@property (nonatomic, weak, readonly) id target;
- (instancetype)initWithTarget:(id)target;
@end

@implementation IIDeadFish

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

- (BOOL)isEqual:(id)object {
    return [_target isEqual:object];
}

- (NSUInteger)hash {
    return [_target hash];
}

- (Class)superclass {
    return [_target superclass];
}

- (Class)class {
    return [_target class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_target isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_target isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_target conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_target respondsToSelector:aSelector];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_target description];
}

- (NSString *)debugDescription {
    return [_target debugDescription];
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    invocation.target = _target;
    
    SEL orgSel =NSSelectorFromString( [NSString stringWithFormat:@"%s%s",IIFish_Prefix, sel_getName(invocation.selector)]);
    Method method = class_getInstanceMethod(object_getClass(_target), orgSel);
    if (method) {
        invocation.selector = orgSel;
    }
    [invocation invoke];
}
@end


@interface NSObject(IIFishBind_DeadFish)
@property (nonatomic, readonly) id iiDeadFish;
@end

@implementation NSObject (IIFishBind_DeadFish)

- (id)iiDeadFish {
    Class cls = object_getClass(self);
    
    if (strncmp(class_getName(cls),IIFish_Prefix,strlen(IIFish_Prefix))) {
        return self;
    }
    IIDeadFish *deadFish = objc_getAssociatedObject(self, _cmd);
    if (!deadFish) {
        deadFish = [[IIDeadFish alloc] initWithTarget:self];
        objc_setAssociatedObject(self, _cmd, deadFish, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return deadFish;
}
@end


#pragma mark-
#pragma mark- ObserverAsset

@interface IIObserverAsset : NSObject

// key : orgSelector value : info
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString*>*methodAsset;
//key : orgSelector value : observer
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSSet<IIFish *>*>*observerAsset;
@property (nonatomic, strong) dispatch_queue_t rwQueue;

- (void)asset:(void (^)(NSMutableDictionary <NSString *, NSString*> * methodAsset, NSMutableDictionary <NSString *, NSSet<IIFish *>*>*observerAsset))asset;

@end

@implementation IIObserverAsset

- (id)init {
    if (self  = [super init]) {
        _methodAsset = [NSMutableDictionary new];
        _observerAsset = [NSMutableDictionary new];
        _rwQueue = dispatch_queue_create("com.IIFishAsset.FishBind", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)asset:(void (^)(NSMutableDictionary <NSString *, NSString*> * methodAsset, NSMutableDictionary <NSString *, NSSet<IIFish *>*>*observerAsset))asset {
    dispatch_barrier_sync(_rwQueue, ^{
        asset(_methodAsset, _observerAsset);
    });
}
@end

//#pragma mark- runtime add
//
//static Method IIFish_Class_getInstanceMethodWithoutSuper(Class cls, SEL sel) {
//    unsigned int count;
//    Method *methods = class_copyMethodList(cls, &count);
//    Method m = NULL;
//    for (unsigned int i = 0; i < count; i ++) {
//        if (method_getName(methods[i]) == sel) {
//            m = methods[i];
//            break;
//        }
//    }
//
//    free(methods);
//    return m;
//}

#pragma mark- Invocation
// https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html

static id iifish_invocation_getReturnValue(NSInvocation *invocation) {
    const char *argType = [invocation.methodSignature methodReturnType];
    id argBox;
    
#define IIFish_GetReturnValueInBox(coding, type) case coding : {\
type arg;\
[invocation getReturnValue:&arg];\
argBox = @(arg);\
} break;
    
    switch (argType[0]) {
            IIFish_GetReturnValueInBox('c', char)
            IIFish_GetReturnValueInBox('i', int)
            IIFish_GetReturnValueInBox('s', short)
            IIFish_GetReturnValueInBox('l', long)
            IIFish_GetReturnValueInBox('q', long long)
            IIFish_GetReturnValueInBox('^', long long)
            IIFish_GetReturnValueInBox('C', unsigned char)
            IIFish_GetReturnValueInBox('I', unsigned int)
            IIFish_GetReturnValueInBox('S', unsigned short)
            IIFish_GetReturnValueInBox('L', unsigned long)
            IIFish_GetReturnValueInBox('Q', unsigned long long)
            IIFish_GetReturnValueInBox('f', float)
            IIFish_GetReturnValueInBox('d', double)
            IIFish_GetReturnValueInBox('B', BOOL)
        case '*': {
            char *arg;
            [invocation getReturnValue:&arg];
            argBox = [[NSString alloc] initWithUTF8String:arg];
        } break;
        case '@': {
            __autoreleasing id arg;
            [invocation getReturnValue:&arg];
            __weak id weakArg = arg;
            argBox = ^(){return weakArg;};
        } break;
        case '#': {
            Class arg;
            [invocation getReturnValue:&arg];
            argBox = NSStringFromClass(arg);
        } break;
        case ':': {
            SEL arg;
            [invocation getReturnValue:&arg];
            argBox = NSStringFromSelector(arg);
        } break;
        case '{': {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(argType, &valueSize, NULL);
            unsigned char arg[valueSize];
            [invocation getReturnValue:&arg];
            argBox = [NSValue value:arg withObjCType:argType];
        } break;
        case 'v':
            break;
        default: {
            void *arg;
            [invocation getReturnValue:&arg];
            argBox = (__bridge id)arg;
        }
    }
    
    return argBox;
}

static NSArray *iifish_invocation_getArguments(NSInvocation *invocation, NSInteger beginIndex) {
    
    NSMutableArray *args = [NSMutableArray new];
    for (NSInteger i = beginIndex; i < [invocation.methodSignature numberOfArguments]; i ++) {
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:i];
        id argBox;
        
#define IIFish_GetArgumentValueInBox(coding, type) case coding : {\
type arg;\
[invocation getArgument:&arg atIndex:i];\
argBox = @(arg);\
} break;
        
        switch (argType[0]) {
                IIFish_GetArgumentValueInBox('c', char)
                IIFish_GetArgumentValueInBox('i', int)
                IIFish_GetArgumentValueInBox('s', short)
                IIFish_GetArgumentValueInBox('l', long)
                IIFish_GetArgumentValueInBox('q', long long)
                IIFish_GetArgumentValueInBox('^', long long)
                IIFish_GetArgumentValueInBox('C', unsigned char)
                IIFish_GetArgumentValueInBox('I', unsigned int)
                IIFish_GetArgumentValueInBox('S', unsigned short)
                IIFish_GetArgumentValueInBox('L', unsigned long)
                IIFish_GetArgumentValueInBox('Q', unsigned long long)
                IIFish_GetArgumentValueInBox('f', float)
                IIFish_GetArgumentValueInBox('d', double)
                IIFish_GetArgumentValueInBox('B', BOOL)
            case '*': {
                char *arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = [[NSString alloc] initWithUTF8String:arg];
            } break;
            case '@': {
                __autoreleasing id arg;
                [invocation getArgument:&arg atIndex:i];
                __weak id weakArg = arg;
                argBox = ^(){return weakArg;};
            } break;
            case '#': {
                Class arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = NSStringFromClass(arg);
            } break;
            case ':': {
                SEL arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = NSStringFromSelector(arg);
            } break;
            case '{': {
                NSUInteger valueSize = 0;
                NSGetSizeAndAlignment(argType, &valueSize, NULL);
                unsigned char arg[valueSize];
                [invocation getArgument:&arg atIndex:i];
                argBox = [NSValue value:arg withObjCType:argType];
            } break;
            default: {
                void *arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = (__bridge id)arg;
            }
        }
        if (argBox) {
            [args addObject:argBox];
        }
    }
    
    return args;
}


static IIFishCallBack* iifish_invocation_getCallback(NSInvocation *invo) {
    IIFishCallBack *callBack = [[IIFishCallBack alloc] init];
    callBack.tager = invo.target;
    
    if ([callBack.tager isKindOfClass:NSClassFromString(@"NSBlock")]) {
        callBack.args = iifish_invocation_getArguments(invo,1);
    } else {
        callBack.selector = NSStringFromSelector(invo.selector);
        callBack.args = iifish_invocation_getArguments(invo,2);
    }
    
    callBack.resule = iifish_invocation_getReturnValue(invo);
    return callBack;
}

#pragma mark-
#pragma mark- msgForward

// code from
// https://github.com/bang590/JSPatch/blob/master/JSPatch/JPEngine.m
// line 975

static IMP iifish_getMsgForward(const char *methodTypes) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (methodTypes[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodTypes];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    return msgForwardIMP;
}

static BOOL iifish_isMsgForward(IMP imp) {
    return  (imp == _objc_msgForward
#if !defined(__arm64__)
             || imp == _objc_msgForward_stret
#endif
             );
}

#pragma mark-
#pragma mark- Block Hook
//code from
//https://opensource.apple.com/source/libclosure/libclosure-67

typedef NS_OPTIONS(int, IIFishBlockFlage) {
    IIFishBLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    IIFishBLOCK_HAS_SIGNATURE  =    (1 << 30)
};

struct IIFishBlock_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

struct IIFishBlock_descriptor_2 {
    void (*copy)(void *dst, const void *src);
    void (*dispose)(const void *);
};

struct IIFishBlock_descriptor_3 {
    const char *signature;
    const char *layout;
};

struct IIFishBlock_layout {
    void *isa;
    volatile int32_t flags;
    int32_t reserved;
    void (*invoke)(void *, ...);
    struct IIFishBlock_descriptor_1 *descriptor;
    
    void *block; // 这里保存原来的block
};
typedef  struct IIFishBlock_layout  *IIFishBlock;

static struct IIFishBlock_descriptor_2 * _IIFish_Block_descriptor_2(IIFishBlock aBlock)
{
    if (! (aBlock->flags & IIFishBLOCK_HAS_COPY_DISPOSE)) return NULL;
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct IIFishBlock_descriptor_1);
    return (struct IIFishBlock_descriptor_2 *)desc;
}

static struct IIFishBlock_descriptor_3 * _IIFish_Block_descriptor_3(IIFishBlock aBlock)
{
    if (! (aBlock->flags & IIFishBLOCK_HAS_SIGNATURE)) return NULL;
    uint8_t *desc = (uint8_t *)aBlock->descriptor;
    desc += sizeof(struct IIFishBlock_descriptor_1);
    if (aBlock->flags & IIFishBLOCK_HAS_COPY_DISPOSE) {
        desc += sizeof(struct IIFishBlock_descriptor_2);
    }
    return (struct IIFishBlock_descriptor_3 *)desc;
}

#pragma mark-

static IIObserverAsset *iifish_object_getAsset(id object);
static  NSString const *IIFishBlockObserverKey = @"IIFishBlockObserverKey";

static id iifish_block_getTempBlock(IIFishBlock block) {
    return objc_getAssociatedObject((__bridge id)block, @"IIFish_Block_TempBlock");
}

static void iifish_block_setTempGlobalBlock(IIFishBlock block, struct IIFishBlock_layout tempBlockLayout) {
    NSValue *blockValue = [NSValue value:&tempBlockLayout withObjCType:@encode(struct IIFishBlock_layout)];
    objc_setAssociatedObject((__bridge id)block, @"IIFish_Block_TempBlock", blockValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static void iifish_block_setTempMallocBlock(IIFishBlock block, IIFishBlock tempBlock) {
    objc_setAssociatedObject((__bridge id)block, @"IIFish_Block_TempBlock", (__bridge id)tempBlock, OBJC_ASSOCIATION_ASSIGN);
}

static long long iifish_block_getDisposeFunc(id block) {
    return [objc_getAssociatedObject(block, "IIFish_Block_DisposeFunc") longLongValue];
}

static void iifish_block_setDisposeFunc(id block, long long disposeFuncAdders) {
    objc_setAssociatedObject(block, "IIFish_Block_DisposeFunc", @(disposeFuncAdders), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void iifish_block_disposeFunc(const void * block_Layout) {
    
    IIFishBlock block = (IIFishBlock)block_Layout;
    id tempBlock = iifish_block_getTempBlock(block);
    free((__bridge void *)tempBlock);
    
    long long disposeAdders = iifish_block_getDisposeFunc((__bridge id)(block_Layout));
    
    void (*disposeFunc)(const void *) = (void (*)(const void *))disposeAdders;
    if (disposeFunc) {
        disposeFunc(block_Layout);
    }
}

static void iifish_block_hookDisposeFunc(IIFishBlock block) {
    if (block->flags & IIFishBLOCK_HAS_COPY_DISPOSE) {
        struct IIFishBlock_descriptor_2 *descriptor_2  = _IIFish_Block_descriptor_2(block);
        if (descriptor_2->dispose != iifish_block_disposeFunc) {
            long long disposeAdders = (long long)descriptor_2->dispose;
            
            iifish_block_setDisposeFunc((__bridge id)(block), disposeAdders);
            descriptor_2->dispose = iifish_block_disposeFunc;
        }
    }
}

static void iifish_block_deepCopy(IIFishBlock block) {
    struct IIFishBlock_descriptor_2 *descriptor_2 = _IIFish_Block_descriptor_2(block);
    if (descriptor_2) {
        IIFishBlock newBlock = malloc(block->descriptor->size);
        if (!newBlock) return;
        memmove(newBlock, block, block->descriptor->size);
        descriptor_2->copy(newBlock, block);
        newBlock->block = (void *)Block_copy(block);
        iifish_block_setTempMallocBlock(block, newBlock);
        iifish_block_hookDisposeFunc(block);
    } else {
        struct IIFishBlock_layout block_layout;
        block_layout.isa = block->isa;
        block_layout.flags = block->flags;
        block_layout.invoke = block->invoke;
        block_layout.reserved = block->reserved;
        block_layout.descriptor = block->descriptor;
        block_layout.block = (void *)Block_copy(block);
        iifish_block_setTempGlobalBlock(block, block_layout);
    }
}

#pragma mark-
#pragma mark- NSBlock Hook

static void iifish_block_forwardInvocation(id self, SEL _cmd, NSInvocation *invo) {
    
    IIFishBlock block = (__bridge void *)invo.target;
    
    id tempBlock = iifish_block_getTempBlock(block);
    if (![tempBlock isKindOfClass:NSClassFromString(@"NSBlock")]) {
        struct IIFishBlock_layout tb;
        [(NSValue *)tempBlock getValue:&tb];
        tempBlock = (__bridge id)&tb;
        
        invo.target = (__bridge id)tb.block;
        [invo invoke];
    }
    
    invo.target = tempBlock;
    [invo invoke];
    
    
//    IIObserverAsset *asseet = iifish_object_getAsset((__bridge id)block);
//    __block NSArray *observers;
//    NSString *key = [IIFishBlockObserverKey copy];
//    [asseet asset:^(NSMutableDictionary<NSString *,NSString *> *methodAsset, NSMutableDictionary<NSString *,NSMutableSet<IIFish *> *> *observerAsset) {
//        observers = [[observerAsset objectForKey:key] allObjects];
//    }];
//
//    for (IIFish *fish in observers) {
//        if (fish.callBack) {
//            fish.callBack(iifish_invocation_getCallback(invo), [fish.object iiDeadFish]);
//        }
//    }
    
    
}

NSMethodSignature *iifish_block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    struct IIFishBlock_descriptor_3 *descriptor_3 =  _IIFish_Block_descriptor_3((__bridge  void *)self);
    return [NSMethodSignature signatureWithObjCTypes:descriptor_3->signature];
}

static void iifish_NSBlock_hookOnces() {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"NSBlock");
        
#define IIFish_StrongHookMethod(selector, func) {Method method = class_getInstanceMethod([NSObject class], selector); \
BOOL success = class_addMethod(cls, selector, (IMP)func, method_getTypeEncoding(method)); \
if (!success) { class_replaceMethod(cls, selector, (IMP)func, method_getTypeEncoding(method));}}
        
        IIFish_StrongHookMethod(@selector(methodSignatureForSelector:), iifish_block_methodSignatureForSelector);
        IIFish_StrongHookMethod(@selector(forwardInvocation:), iifish_block_forwardInvocation);
    });
}

static void iifish_block_hook(id obj, id anotherBlock) {
    iifish_NSBlock_hookOnces();
    IIFishBlock block = (__bridge IIFishBlock)(obj);
    if (!iifish_block_getTempBlock(block)) {
        iifish_block_deepCopy(block);
        struct IIFishBlock_descriptor_3 *descriptor_3 =  _IIFish_Block_descriptor_3(block);
        block->invoke = (void *)iifish_getMsgForward(descriptor_3->signature);
    }
}

