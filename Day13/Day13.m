#import <ObjFW/ObjFW.h>

typedef struct point {
  int x;
  int y;
} Point;

Point pts[1000];

@interface Day13: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day13)

@implementation Day13
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int n_pts = 0;
  int i;
  BOOL foldx;
  int fold_pos;
  OFMutableSet *set = [OFMutableSet set];
  while ((s = [f readLine])) {
    if ([s length] == 0) break;
    OFArray *a = [s componentsSeparatedByString:@","];
    pts[n_pts].x = (int)[[a objectAtIndex:0] longLongValue];
    pts[n_pts].y = (int)[[a objectAtIndex:1] longLongValue];
    n_pts += 1;
  }
  while ((s = [f readLine])) {
    OFArray *aa = [s componentsSeparatedByString:@" "];
    OFArray *a = [[aa objectAtIndex:2] componentsSeparatedByString:@"="];
    foldx = [[a objectAtIndex:0] characterAtIndex:0] == 'x' ? YES : NO;
    fold_pos = (int)[[a objectAtIndex:1] longLongValue];
    for (i = 0; i < n_pts; ++i) {
      if (foldx) {
	if (pts[i].x > fold_pos) pts[i].x = 2 * fold_pos - pts[i].x;
      } else {
	if (pts[i].y > fold_pos) pts[i].y = 2 * fold_pos - pts[i].y;
      }
    }
    break;  // Part 1
  }
  for (i = 0; i < n_pts; ++i) {
    [set addObject:[OFPair pairWithFirstObject: [OFNumber numberWithInt:pts[i].x]
				  secondObject: [OFNumber numberWithInt:pts[i].y]]];
  }
  [OFStdOut writeFormat:@"%ld\n", [set count]];
  [OFApplication terminate];
}
@end
