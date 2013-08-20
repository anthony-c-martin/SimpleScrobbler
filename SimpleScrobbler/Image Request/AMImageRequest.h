#import <Foundation/Foundation.h>

@protocol AMImageRequestDelegate <NSObject>
@optional
-(void)imageResponseWithImage:(NSImage *)Image;
-(void)imageResponseWithError:(NSError *)Error;
@end

@interface AMImageRequest : NSObject <NSURLConnectionDelegate>

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) id<AMImageRequestDelegate> delegate;

-(id)initWithDelegate:(id<AMImageRequestDelegate>)Delegate;
-(BOOL)initiateReqest:(NSURL *)ImageURL;

@end