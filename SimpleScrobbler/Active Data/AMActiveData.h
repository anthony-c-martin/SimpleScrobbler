#import <Foundation/Foundation.h>

@interface AMSongData : NSObject
@property (nonatomic, assign) NSString *artist;
@property (nonatomic, assign) NSString *albumArtist;
@property (nonatomic, assign) NSString *album;
@property (nonatomic, assign) NSString *track;
@property (nonatomic, assign) NSNumber *trackNumber;
@property (nonatomic, assign) NSNumber *timestamp;
@property (nonatomic, assign) NSNumber *duration;

-(id)init;

@end

@interface AMActiveData : NSObject
@property (nonatomic, retain) AMSongData *songData;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *sessionKey;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, assign) BOOL scrobblingEnabled;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int startTime;

-(id)init;
-(BOOL)shouldScrobble;

@end