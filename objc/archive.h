#import <Foundation/Foundation.h>

@interface BCArchive : NSObject
- (void)get:(void (^)(id))block;
- (void)set:(id<NSCoding>)object block:(void (^)(id))block;
@end
