#import <Foundation/Foundation.h>

@interface AMPersistentData : NSObject

@property (nonatomic, retain) NSString *bundlePlist;
@property (nonatomic, retain) NSString *mainPlist;

-(NSString *)getStringWithKey:(NSString *)key;

-(BOOL)getBoolWithKey:(NSString *)key;

-(void)setString:(NSString *)string WithKey:(NSString *)key;

-(void)setBool:(BOOL)value WithKey:(NSString *)key;

@end