#import <ObjFW/ObjFW.h>

void swap(int *a, int *b) {
  int t = *a;
  *a = *b;
  *b = t;
}

void reverse(int a[], int l, int r) {
  while (l < r) swap(&a[l++], &a[r--]);
}

BOOL next_perm(int perm[7]) {
  int first = -1, minid, i;
  for (i = 5; i >= 0; --i) {
    if (perm[i] < perm[i+1]) {
      first = i;
      break;
    }
  }
  if (first < 0) return NO;
  minid = first + 1;
  for (i = first + 2; i < 7; ++i) {
    if (perm[i] > perm[first] && perm[i] < perm[minid]) minid = i;
  }
  swap(&perm[first], &perm[minid]);
  reverse(perm, first + 1, 6);
  /*  for (i = 0; i < 7; ++i) {
    [OFStdErr writeFormat:@"%d", perm[i]];
  }
  [OFStdErr writeLine:@""]; */
  return YES;
}

int to_index(OFString *s, int perm[7]) {
  int idx = 0, j;
  for (j = 0; j < [s length]; j++) {
    idx += 1 << perm[[s characterAtIndex:j]-'a'];
  }
  return idx;
}

@interface Day8: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day8)

@implementation Day8
- (void)applicationDidFinishLaunching
{
  int valid[10] = {0x77, 0x24, 0x5D, 0x6D, 0x2E, 0x6B, 0x7B, 0x25, 0x7F, 0x6F};
  int lookup[128];
  int perm[7];
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s, *t;
  int i, num, idx, digit;
  long long tot = 0;
  for (i = 0; i < 128; ++i) {
    lookup[i] = -1;
  }
  for (i = 0; i < 10; ++i) {
    lookup[valid[i]] = i;
  }
  while ((s = [f readLine])) {
    OFArray *a = [s componentsSeparatedByString:@" | "];
    OFArray *b = [[a objectAtIndex:0] componentsSeparatedByString:@" "];
    if (b.count != 10) [OFStdErr writeLine:@"input error?\n"];
    for (i = 0; i < 7; ++i) perm[i] = i;
    do {
      for (i = 0; i < b.count; i++) {
	t = [b objectAtIndex:i];
	idx = to_index(t, perm);
	if (lookup[idx] < 0) break;
      }
      if (i == b.count) break;
    } while (next_perm(perm));
    num = 0;
    b = [[a objectAtIndex:1] componentsSeparatedByString:@" "];
    if (b.count != 4) [OFStdErr writeLine:@"input error?\n"];
    for (i = 0; i < b.count; ++i) {
      t = [b objectAtIndex:i];
      idx = to_index(t, perm);
      digit = lookup[idx];
      if (digit < 0) {
	[OFStdErr writeLine:@"Something is wrong."];
      } else {
	num = 10 * num + digit;
      }
    }
    [OFStdErr writeFormat:@"%@: %d\n", s, num];
    tot += num;
  }
  [OFStdOut writeFormat:@"%lld\n", tot];
  [OFApplication terminate];
}
@end
