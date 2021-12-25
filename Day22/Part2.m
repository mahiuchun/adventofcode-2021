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

BOOL empty_r(const Range *r) {
  return r->hi <= r->lo;
}

typedef struct box {
  Range rx;
  Range ry;
  Range rz;
  BOOL add;
} Box;

BOOL empty_b(const Box* b) {
  return empty_r(&b->rx) || empty_r(&b->ry) || empty_r(&b->ry);
}

long long volume(const Box *b) {
  if (empty_b(b)) return 0;
  return (b->rx.hi-b->rx.lo)*(b->ry.hi-b->ry.lo)*(b->rz.hi-b->rz.lo);
}

Box ops[1000];
int n_ops;
#define N 1000
BOOL cubes[N][N][N];

@interface Day22: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day22)

@implementation Day22
- (void)applicationDidFinishLaunching
{
  OFFile *f =[OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  Box box, temp;
  int i, j, k, ii;
  int i1, i2, j1, j2, k1, k2;
  long long res = 0;
  OFMutableSet *xs = [OFMutableSet set];
  OFMutableSet *ys = [OFMutableSet set];
  OFMutableSet *zs = [OFMutableSet set];
  OFMutableArray *xa = [OFMutableArray array];
  OFMutableArray *ya = [OFMutableArray array];
  OFMutableArray *za = [OFMutableArray array];
  OFMutableDictionary *xm = [OFMutableDictionary dictionary];
  OFMutableDictionary *ym = [OFMutableDictionary dictionary];
  OFMutableDictionary *zm = [OFMutableDictionary dictionary];
  BOOL f1, f2, f3, e1, e2, e3, v1;
  while ((s = [f readLine])) {
    OFArray *a = [s componentsSeparatedByString:@" "];
    OFArray *b = [a[1] componentsSeparatedByString:@","];
    box.rx = str_to_range(b[0]);
    box.ry = str_to_range(b[1]);
    box.rz = str_to_range(b[2]);
    box.rx.hi += 1;
    box.ry.hi += 1;
    box.rz.hi += 1;
    box.add = [a[0] isEqual:@"on"];
    ops[n_ops++] = box;
    [xs addObject:[OFNumber numberWithLongLong:box.rx.lo]];
    [xs addObject:[OFNumber numberWithLongLong:box.rx.hi]];
    [ys addObject:[OFNumber numberWithLongLong:box.ry.lo]];
    [ys addObject:[OFNumber numberWithLongLong:box.ry.hi]];
    [zs addObject:[OFNumber numberWithLongLong:box.rz.lo]];
    [zs addObject:[OFNumber numberWithLongLong:box.rz.hi]];
  }
  [xa addObjectsFromArray: [xs allObjects]];
  [ya addObjectsFromArray: [ys allObjects]];
  [za addObjectsFromArray: [zs allObjects]];
  [xa sort];
  [ya sort];
  [za sort];
  for (i = 0; i < xa.count; i++) {
    [xm setObject:[OFNumber numberWithInt:i] forKey:xa[i]];
  }
  for (i = 0; i < ya.count; i++) {
    [ym setObject:[OFNumber numberWithInt:i] forKey:ya[i]];
  }
  for (i = 0; i < za.count; i++) {
    [zm setObject:[OFNumber numberWithInt:i] forKey:za[i]];
  }
  for (ii = 0; ii < n_ops; ii++) {
    // OFLog(@"ii:%d", ii);
    temp = ops[ii];
    i1 = [[xm objectForKey:[OFNumber numberWithLongLong:temp.rx.lo]] intValue];
    i2 = [[xm objectForKey:[OFNumber numberWithLongLong:temp.rx.hi]] intValue];
    j1 = [[ym objectForKey:[OFNumber numberWithLongLong:temp.ry.lo]] intValue];
    j2 = [[ym objectForKey:[OFNumber numberWithLongLong:temp.ry.hi]] intValue];
    k1 = [[zm objectForKey:[OFNumber numberWithLongLong:temp.rz.lo]] intValue];
    k2 = [[zm objectForKey:[OFNumber numberWithLongLong:temp.rz.hi]] intValue];
    // OFLog(@"i1:%d,i2:%d,j1:%d,j2:%d,k1:%d,k2:%d",i1,i2,j1,j2,k1,k2);
    for (i = i1; i < i2; i++) {
      for (j = j1; j < j2; j++) {
	for (k = k1; k < k2; k++) {
	  cubes[i][j][k] = temp.add;
	}
      }
    }
  }
  for (i = 0; i < xa.count-1; i++) {
    for (j = 0; j < ya.count-1; j++) {
      for (k = 0; k < za.count-1; k++) {
	if (!cubes[i][j][k]) continue;
	temp.rx.lo = [xa[i] longLongValue];
	temp.rx.hi = [xa[i+1] longLongValue];
	temp.ry.lo = [ya[j] longLongValue];
	temp.ry.hi = [ya[j+1] longLongValue];
	temp.rz.lo = [za[k] longLongValue];
	temp.rz.hi = [za[k+1] longLongValue];
	f1 = f2 = f3 = e1 = e2 = e3 = v1 = NO;
	if (i > 0 && cubes[i-1][j][k]) f1 = e2 = e3 = v1 = YES; 
	if (j > 0 && cubes[i][j-1][k]) f2 = e3 = e1 = v1 = YES;
	if (k > 0 && cubes[i][j][k-1]) f3 = e1 = e2 = v1 = YES;
	if (i > 0 && j > 0 && cubes[i-1][j-1][k]) e3 = v1 = YES;
	if (j > 0 && k > 0 && cubes[i][j-1][k-1]) e1 = v1 = YES;
	if (k > 0 && i > 0 && cubes[i-1][j][k-1]) e2 = v1 = YES;	
	if (i > 0 && j > 0 && k > 0 && cubes[i-1][j-1][k-1]) v1 = YES;
	res += volume(&temp);
      }
    }
  }
  [OFStdOut writeFormat:@"%lld\n", res];
  [OFApplication terminate];
}
@end
