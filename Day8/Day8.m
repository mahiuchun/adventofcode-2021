#import <ObjFW/ObjFW.h>

@interface Day8: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day8)

@implementation Day8
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int i, len;
  long long tot = 0;
  while ((s = [f readLine])) {
    OFArray *a = [s componentsSeparatedByString:@" | "];
    OFArray *b = [[a objectAtIndex:1] componentsSeparatedByString:@" "];
    if (b.count != 4) [OFStdErr writeLine:@"input error?\n"];
    for (i = 0; i < b.count; ++i) {
      len = [[b objectAtIndex:i] length];
      if (len == 2 || len == 3 || len == 4 || len == 7) tot += 1;
    }
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
