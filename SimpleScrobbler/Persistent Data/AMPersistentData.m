NSString *const PERSISTENTDATA_PLIST_FILENAME = @"com.acm.SimpleScrobbler";

#import "./AMPersistentData.h"

@implementation AMPersistentData

@synthesize bundlePlist;
@synthesize mainPlist;

-(id)init
{
    self = [super init];
    if (self)
    {
        [self setBundlePlist:[NSString stringWithString:[[NSBundle mainBundle] pathForResource:PERSISTENTDATA_PLIST_FILENAME ofType:@"plist"]]];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libDirectory = [paths objectAtIndex:0];
        [self setMainPlist:[[[libDirectory stringByAppendingPathComponent:@"Preferences"] stringByAppendingPathComponent:PERSISTENTDATA_PLIST_FILENAME] stringByAppendingPathExtension:@"plist"]];
        [self initialiseMainPlist];
    }
    return self;
}

-(BOOL)doesPlistExist:(NSString *)plist
{
    BOOL exists = FALSE;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:plist])
    {
        exists = TRUE;
    }
    return exists;
}

-(void)initialiseMainPlist
{
    if (![self doesPlistExist:mainPlist])
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager createFileAtPath:mainPlist contents:NULL attributes:NULL];
        NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:bundlePlist];
        [plistData writeToFile:mainPlist atomically:YES];
    }
}

-(NSString *)getStringWithKey:(NSString *)key
{
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:mainPlist];
    NSString *output = @"";
    if ([plistDict objectForKey:key])
    {
        output = [NSString stringWithString:[plistDict valueForKey:key]];
    }
    return output;
}

-(void)setString:(NSString *)data WithKey:(NSString *)key
{
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:mainPlist];
    [plistDict setValue:data forKey:key];
    [plistDict writeToFile:mainPlist atomically:YES];
}

-(BOOL)getBoolWithKey:(NSString *)key
{
    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:mainPlist];
    NSNumber *numValue = NULL;
    if ([plistDict objectForKey:key])
    {
        numValue = [plistDict valueForKey:key];
    }
    if (numValue)
    {
        return [numValue boolValue];
    }
    return FALSE;
}

-(void)setBool:(BOOL)value WithKey:(NSString *)key
{
    NSNumber *BoolNum = [NSNumber numberWithBool:value];
    NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:mainPlist];
    [plistDict setValue:BoolNum forKey:key];
    [plistDict writeToFile:mainPlist atomically:YES];
}

@end