#import "archive.h"

@implementation BCArchive {
    dispatch_queue_t _queue;
    NSString *_path;
}

- (id)init {
    if ((self = [super init])) {
        _queue = dispatch_queue_create("coding_test_archive", DISPATCH_QUEUE_SERIAL);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _path = [paths[0] stringByAppendingPathComponent:@"coder_crash_archive"];
    }
    return self;
}

- (void)get:(void (^)(id))block {
    dispatch_async(_queue, ^{
        id<NSCoding> object = nil;

        if ([[NSFileManager defaultManager] fileExistsAtPath:_path]) {
            object = [NSKeyedUnarchiver unarchiveObjectWithFile:_path];
        }

        block(object);
    });
}

- (void)set:(id<NSCoding>)object block:(void (^)(id))block {
    dispatch_async(_queue, ^{
        BOOL written = [NSKeyedArchiver archiveRootObject:object toFile:_path];
        block(written ? object : nil);
    });
}

@end
