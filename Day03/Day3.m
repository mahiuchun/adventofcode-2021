#import <ObjFW/ObjFW.h>

@interface Day3: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day3)

@implementation Day3
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString* s = [f readLine];
  int diff[12] = {0};
  int i;
  while (s != nil) {
    const char *cs = [s cStringWithEncoding:OFStringEncodingUTF8];
    for (i = 0; i < 12; ++i) {
      if (cs[i] == '0')
	diff[i] -= 1;
      else
	diff[i] += 1;
    }
    s = [f readLine];
  }
  long long gamma = 0;
  long long epsilon = 0;
  for (i = 0; i < 12; ++i) {
    if (diff[i] < 0) {
      gamma = 2 * gamma;
      epsilon = 2 * epsilon + 1;
    } else {
      gamma = 2 * gamma + 1;
      epsilon = 2 * epsilon;
    }
  }
  [OFStdOut writeFormat:@"%lld\n", gamma * epsilon];
  [OFApplication terminate];
}
@end
