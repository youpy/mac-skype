#import "skype_api.h"

@interface AppDelegate()

- (bool)isDebug;

@end

@implementation AppDelegate

@synthesize rb_instance;

- (NSString *)clientApplicationName
{
  return @"mac-skype";
}

- (void)skypeNotificationReceived:(NSString *)aNotificationString
{
  if([self isDebug]) {
    NSLog(@"%@", aNotificationString);
  }

  rb_funcall(rb_instance, rb_intern("receive_event"), 1, rb_str_new2([aNotificationString UTF8String]));
}

- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
  if([self isDebug]) {
    NSLog(@"attach response: %d", aAttachResponseCode);
  }

  rb_funcall(rb_instance, rb_intern("attach="), 1, INT2NUM(aAttachResponseCode));
}

- (void)skypeBecameAvailable:(NSNotification *)aNotification
{
}

- (void)skypeBecameUnavailable:(NSNotification *)aNotification
{
}

- (void)onTimeout:(NSTimer *)timer {
  NSEvent *event;

  [[NSApplication sharedApplication] stop:nil];

  // http://www.cocoabuilder.com/archive/cocoa/219842-nsapp-stop.html
  event = [NSEvent otherEventWithType: NSApplicationDefined
                             location: NSMakePoint(0,0)
                        modifierFlags: 0
                            timestamp: 0.0
                         windowNumber: 0
                              context: nil
                              subtype: 0
                                data1: 0
                                data2: 0];

  [NSApp postEvent: event atStart: true];
}

- (bool)isDebug
{
  return RTEST(rb_funcall(rb_instance, rb_intern("debug?"), 0));
}

@end

static VALUE rb_cApi;

static VALUE cApi_init(int argc, VALUE *argv, VALUE self)
{
  AppDelegate *delegate;

  if(!(delegate = (AppDelegate <SkypeAPIDelegate, NSApplicationDelegate> *)[[NSApplication sharedApplication] delegate])) {
    delegate = [[AppDelegate alloc] init];
    delegate.rb_instance = self;

    [NSApp setDelegate: delegate];
    [SkypeAPI setSkypeDelegate:delegate];
  }
}

static VALUE cApi_running(int argc, VALUE *argv, VALUE self)
{
  return [SkypeAPI isSkypeRunning] == YES ? Qtrue : Qfalse;
}

static VALUE cApi_connect(int argc, VALUE *argv, VALUE self)
{
  [SkypeAPI connect];

  return Qnil;
}

static VALUE cApi_run_loop(int argc, VALUE *argv, VALUE self)
{
  AppDelegate *delegate = [NSApp delegate];
  VALUE stopAfter;

  rb_scan_args(argc, argv, "1", &stopAfter);

  if(stopAfter != Qnil) {
    [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)NUM2INT(stopAfter)
                                     target:delegate
                                   selector:@selector(onTimeout:)
                                   userInfo:nil
                                    repeats:NO];
  }

  [NSApp run];

  return Qnil;
}

static VALUE cApi_disconnect(int argc, VALUE *argv, VALUE self)
{
  [SkypeAPI disconnect];

  return Qnil;
}

static VALUE cApi_send_command(int argc, VALUE *argv, VALUE self)
{
  VALUE command_str;
  NSString *result;

  rb_scan_args(argc, argv, "1", &command_str);

  result = [SkypeAPI sendSkypeCommand: [[NSString alloc] initWithCString:StringValuePtr(command_str)
                                                                encoding:NSUTF8StringEncoding]];

  // https://jira.skype.com/browse/SPA-770?page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#issue-tabs
  if(result != nil) {
    [NSApp skypeNotificationReceived:result];
  }

  return Qnil;
}

static VALUE cApi_name(int argc, VALUE *argv, VALUE self)
{
  AppDelegate *delegate = [NSApp delegate];

  return rb_str_new2([[delegate clientApplicationName] UTF8String]);
}

void Init_skype_api(void){
  VALUE rb_mMac, rb_mSkype;

  rb_mMac   = rb_define_module("Mac");
  rb_mSkype = rb_define_module_under(rb_mMac, "Skype");
  rb_cApi   = rb_define_class_under(rb_mSkype, "Api", rb_cObject);

  rb_define_method(rb_cApi, "init",         cApi_init,         -1);
  rb_define_method(rb_cApi, "running?",     cApi_running,      -1);
  rb_define_method(rb_cApi, "connect",      cApi_connect,      -1);
  rb_define_method(rb_cApi, "disconnect",   cApi_disconnect,   -1);
  rb_define_method(rb_cApi, "run_loop",     cApi_run_loop,     -1);
  rb_define_method(rb_cApi, "send_command", cApi_send_command, -1);
  rb_define_method(rb_cApi, "name",         cApi_name,         -1);
}
