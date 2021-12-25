#import <ObjFW/ObjFW.h>

@interface Day1: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day1)

@implementation Day1
- (void)applicationDidFinishLaunching
{
  OFFile *f = [[OFFile alloc] initWithPath:@"input.txt" mode:@"r"];
  OFString *s;
  int count = 0;
  int prev = 987654321;
  for (;;) {
    s = [f readLine];
    if (s == nil) break;
    const char *cs = [s cStringWithEncoding:OFStringEncodingUTF8];
    int curr = atoi(cs);
    if (curr > prev) count++;
    prev = curr;
  }
  [OFStdOut writeFormat:@"%d\n", count];
  [OFApplication terminate];
}
@end
