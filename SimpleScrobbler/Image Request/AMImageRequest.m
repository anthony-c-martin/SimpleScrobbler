#import "./AMImageRequest.h"
#import <LastFMAPI/AMDefinitions.h>

NSString *const AM_ERRDESC_HTTP_IMG_FAILED = @"Image Request Failed";

@interface AMImageRequest ()
@property (nonatomic, retain) NSMutableData *data;
@end

@implementation AMImageRequest
@synthesize connection;
@synthesize delegate;
@synthesize data;

-(id)initWithDelegate:(id<AMImageRequestDelegate>)Delegate
{
    self = [super init];
    if (self)
    {
        [self setDelegate:Delegate];
        [self setConnection:nil];
        [self setData:[[NSMutableData alloc] init]];
    }
    return self;
}

-(BOOL)initiateReqest:(NSURL *)ImageURL
{
    NSMutableURLRequest *Request = [[NSMutableURLRequest alloc] initWithURL:ImageURL];
    
    [self setConnection:[NSURLConnection connectionWithRequest:Request delegate:self]];
    
    if ([self connection])
    {
        return YES;
    }
    return NO;
}

-(void)connection:(NSConnection *)Connection
 didFailWithError:(NSError *)Error
{
    if ([[self delegate] respondsToSelector:@selector(imageResponseWithError:)])
    {
        [[self delegate] imageResponseWithError:[self generateError:AM_ERR_HTTP_REQFAILED Description:AM_ERRDESC_HTTP_IMG_FAILED]];
    }
}

-(void)connection:(NSConnection *)Connection
didReceiveResponse:(NSURLResponse *)response
{
    [[self data] setLength:0];
}

-(void)connection:(NSConnection *)Connection
   didReceiveData:(NSData *)receivedData
{
    [[self data] appendData:receivedData];
}

-(NSCachedURLResponse *)connection:(NSConnection *)Connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

-(NSURLRequest *)connection:(NSConnection *)Connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

-(void)connectionDidFinishLoading:(NSConnection *)Connection
{
    NSImage *Image = [[NSImage alloc] initWithData:[self data]];
    if (Image)
    {
        if ([[self delegate] respondsToSelector:@selector(imageResponseWithImage:)])
        {
            [[self delegate] imageResponseWithImage:Image];
        }
    }
    else
    {
        if ([[self delegate] respondsToSelector:@selector(imageResponseWithError:)])
        {
            NSError *Error = nil;
            [[self delegate] imageResponseWithError:[self generateError:AM_ERR_HTTP_REQFAILED Description:AM_ERRDESC_HTTP_IMG_FAILED]];
            [[self delegate] imageResponseWithError:Error];
        }
    }
}

-(NSError *)generateError:(NSInteger)Code
              Description:(NSString *)Description
{
    NSMutableDictionary *UserInfo = [[NSMutableDictionary alloc] init];
    [UserInfo setValue:Description forKey:NSLocalizedDescriptionKey];
    
    NSError *Error = [[NSError alloc] initWithDomain:AM_ERRDOMAIN_LASTFMAPI code:Code userInfo:UserInfo];
    return Error;
}

@end