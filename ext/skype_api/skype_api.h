#include <ruby/ruby.h>
#import <Skype/Skype.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, SkypeAPIDelegate> {
}

@property (nonatomic) VALUE rb_instance;

- (NSString *)clientApplicationName;
- (void)skypeNotificationReceived:(NSString *)aNotificationString;
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode;
- (void)skypeBecameAvailable:(NSNotification *)aNotification;
- (void)skypeBecameUnavailable:(NSNotification *)aNotification;

- (void)onTimeout:(NSTimer *) timer;
@end

VALUE createInstance();
