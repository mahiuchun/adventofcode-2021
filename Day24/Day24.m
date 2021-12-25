#import <ObjFW/ObjFW.h>
#include <ctype.h>

struct alu {
  long long r[4];
} ALU;

int execute(OFArray *prog, int model[14]) {
  @autoreleasepool {
  int i;
  int input = 0;
  int r1, r2, o2;
  ALU.r[0] = ALU.r[1] = ALU.r[2] = ALU.r[3] = 0;
  for (i = 0; i < prog.count; i++) {
    OFArray *a = [prog[i] componentsSeparatedByString:@" "];
    r1 = [a[1] characterAtIndex:0] - 'w';
    if ([a[0] isEqual:@"inp"]) {
      ALU.r[r1] = model[input++];
    } else {
      if (isdigit([a[2] characterAtIndex:0])) {
	o2 = [a[2] longLongValue];
      } else {
	r2 = [a[2] characterAtIndex:0] - 'w';
	o2 = ALU.r[r2];
      }
      if ([a[0] isEqual:@"add"]) {
	ALU.r[r1] += o2;
      } else if ([a[0] isEqual:@"mul"]) {
	ALU.r[r1] *= o2;
      } else if ([a[0] isEqual:@"div"]) {
	if (o2 == 0) {
	  OFLog(@"Something is wrong with div input=%d", input);
	  return input;
	}
	if (ALU.r[r1] < 0 || o2 < 0) {
	  OFLog(@"watch out div");
	}
	ALU.r[r1] /= o2;
      } else if ([a[0] isEqual:@"mod"]) {
	if (ALU.r[r1] < 0 || o2 <= 0) {
	  OFLog(@"Something is wrong with mod input=%d", input);
	  return input;
	}
	ALU.r[r1] %= o2;
      } else if ([a[0] isEqual:@"eql"]) {
	ALU.r[r1] = (ALU.r[r1] == o2);
      }
    }
  }
  if (ALU.r[3] == 0) {
    return 0;
  } else {
    return input;
  }
  }
}

int params[14][3] = {
  {1, 10, 10},
  {1, 13, 5},
  {1, 15, 12},
  {26, -12, 12},
  {1, 14, 6},
  {26, -2, 4},
  {1, 13, 15},
  {26, -12, 3},
  {1, 15, 7},
  {1, 11, 11},
  {26, -3 ,2},
  {26, -13, 12},
  {26, -12, 4},
  {26, -13, 11}
};

int fastexec(int model[14]) {
  int i;
  ALU.r[0] = ALU.r[1] = ALU.r[2] = ALU.r[3] = 0;
  for (i = 0; i < 14; i++) {
    ALU.r[1] = ((ALU.r[3]%26 + params[i][1]) != model[i]);
    ALU.r[3] /= params[i][0];
    ALU.r[2] = 25 * ALU.r[1] + 1;
    ALU.r[3] *= ALU.r[2];
    ALU.r[2] = (model[i] + params[i][2]) * ALU.r[1];
    ALU.r[3] += ALU.r[2]; 
  }
  return ALU.r[3];
}

int ranges[14][2] = {
  {1, 9},
  {1, 9},
  {1, 9},
  {1, 9},
  {1, 5},
  {1, 9},
  {1, 6},
  {1, 9},
  {1, 9},
  {1, 1},
  {1, 9},
  {1, 9},
  {1, 9},
  {1, 9}
};

BOOL backtrack(OFArray *prog, int model[14], int d) {
  int i;
  if (d == 14) {
    return fastexec(model) == 0;
  }
  for (i = ranges[d][1]; i >= ranges[d][0]; i--) {
    model[d] = i;
    if (d == 2) {
      model[d+1] = i;
      if (backtrack(prog, model, d+2)) return YES;
    } else if (d == 4) {
      model[d+1] = i + 4;
      if (backtrack(prog, model, d+2)) return YES;
    } else if (d == 6) {
      model[d+1] = i + 3;
      if (backtrack(prog, model, d+2)) return YES;      
    } else if (d == 9) {
      model[d+1] = i + 8;
      if (backtrack(prog, model, d+2)) return YES;   
    } else {
      if (backtrack(prog, model, d+1)) return YES;
    }

  }
  return NO;
}

@interface Day24: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day24)

@implementation Day24
- (void)applicationDidFinishLaunching
{
  OFMutableArray *prog = [OFMutableArray array];
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  int model[14] = {0}, i;
  while ((s = [f readLine])) {
    [prog addObject:s];
  }
  if (!backtrack(prog, model, 0)) {
    OFLog(@"Something is wrong");
  }
  for (i = 0; i < 14; i++) {
    [OFStdOut writeFormat:@"%d", model[i]];
  }
  [OFStdOut writeFormat:@"\n"];
  [OFApplication terminate];
}
@end
