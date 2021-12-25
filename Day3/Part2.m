#import <ObjFW/ObjFW.h>

@interface Day3: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day3)

@implementation Day3
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s = [f readLine];
  OFMutableArray *a = [OFMutableArray arrayWithCapacity:1000];
  int b[1000] = {0};
  int c[1000] = {0};
  int br = 1000, cr = 1000; 
  int d, i, j;
  while (s != nil) {
    [a addObject:s];
    s = [f readLine];
  }
  for (j = 0; j < 12 && br > 1; ++j) {
    d = 0;
    for (i = 0; i < 1000; ++i) {
      if (b[i]) continue;
      if ([[a objectAtIndex:i] characterAtIndex:j] == '0')
	d -= 1;
      else
	d += 1;
    }
    char keep = d < 0 ? '0' : '1';
    for (i = 0; i < 1000; ++i) {
      if (b[i]) continue;
      if ([[a objectAtIndex:i] characterAtIndex:j] != keep) {
	b[i] = 1;
	br -= 1;
      }
    }
  }  
  [OFStdErr writeFormat:@"br %d\n", br];
  for (j = 0; j < 12 && cr > 1; ++j) {
    d = 0;
    for (i = 0; i < 1000; ++i) {
      if (c[i]) continue;
      if ([[a objectAtIndex:i] characterAtIndex:j] == '0')
	d -= 1;
      else
	d += 1;
    }
    char keep = d >= 0 ? '0' : '1';
    for (i = 0; i < 1000; ++i) {
      if (c[i]) continue;
      if ([[a objectAtIndex:i] characterAtIndex:j] != keep) {
	c[i] = 1;
	cr -= 1;
      }
    }
  }
  [OFStdErr writeFormat:@"cr %d\n", cr];
  long long oxygen = 0;
  long long co2 = 0;
  for (i = 0; i < 1000; ++i) {
    if (b[i] == 0)
      oxygen = [[a objectAtIndex:i] longLongValueWithBase:2];
    if (c[i] == 0)
      co2 = [[a objectAtIndex:i] longLongValueWithBase:2];
  }
  
  [OFStdOut writeFormat:@"%lld\n", oxygen * co2];
  [OFApplication terminate];
}
@end
