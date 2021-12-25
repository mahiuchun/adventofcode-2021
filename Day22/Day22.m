#import <ObjFW/ObjFW.h>

#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))

typedef struct range {
  long long lo;
  long long hi;
} Range;

Range str_to_range(OFString *s) {
  OFString *t = [s substringFromIndex:2];
  OFArray *a = [t componentsSeparatedByString:@".."];
  Range r;
  r.lo = [a[0] longLongValue];
  r.hi = [a[1] longLongValue];
  return r;
}

BOOL cubes[101][101][101];

@interface Day22: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day22)

@implementation Day22
- (void)applicationDidFinishLaunching
{
  OFFile *f =[OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  Range rx, ry, rz;
  int i, j, k;
  long long tot = 0;
  while ((s = [f readLine])) {
    OFArray *a = [s componentsSeparatedByString:@" "];
    // OFLog(@"%@", a[0]);
    OFArray *b = [a[1] componentsSeparatedByString:@","];
    rx = str_to_range(b[0]);
    ry = str_to_range(b[1]);
    rz = str_to_range(b[2]);
    for (i = MAX(-50, rx.lo); i <= MIN(50, rx.hi); i++) {
      for (j = MAX(-50, ry.lo); j <= MIN(50, ry.hi); j++) {
	for (k = MAX(-50, rz.lo); k <= MIN(50, rz.hi); k++) {
	  cubes[i+50][j+50][k+50] = [a[0] isEqual:@"on"] ? YES : NO;
	}
      }
    }
  }
  for (i = 0; i < 101; i++) {
    for (j = 0; j < 101; j++) {
      for (k = 0; k < 101; k++) {
	if (cubes[i][j][k]) tot += 1;
      }
    }
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
