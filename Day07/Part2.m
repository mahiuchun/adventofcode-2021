#import <ObjFW/ObjFW.h>

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

@interface Day7: OFObject <OFApplicationDelegate>

int pos[1000];
int cost[2000];

@end

OF_APPLICATION_DELEGATE(Day7)

@implementation Day7
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s = [f readLine];
  OFArray *a = [s componentsSeparatedByString:@","];
  int i, j, min = 987654321, max = 0, x;
  long long best = LLONG_MAX, best_pos = -1, fuel;
  [OFStdErr writeFormat:@"# %d\n", a.count]; 
  for (i = 0; i < a.count; ++i) {
    pos[i] = x = (int)[[a objectAtIndex:i] longLongValue];
    min = MIN(min, x);
    max = MAX(max, x);
  }
  cost[0] = 0;
  for (i = 1; i < 2000; ++i) {
    cost[i] = cost[i-1] + i;
  }
  [OFStdErr writeFormat:@"min: %d, max: %d\n", min, max];
  for (i = min; i <= max; ++i) {
    fuel = 0;
    for (j = 0; j < a.count; ++j) {
      fuel += cost[abs(pos[j]-i)];
    }
    if (fuel < best) {
      best = fuel;
      best_pos = i;
    }
  }
  [OFStdErr writeFormat:@"pos: %lld\n", best_pos];
  [OFStdOut writeFormat:@"ans: %lld\n", best];
  [OFApplication terminate];
}
@end
