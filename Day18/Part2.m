#import <ObjFW/ObjFW.h>

#define MAX(a,b) ((a)>(b)?(a):(b))

typedef struct parse_res {
  OFMutablePair *pair;
  int len;
} ParseRes;

ParseRes parse(OFString *s) {
  ParseRes res, temp;
  OFMutablePair *pair = [OFMutablePair pairWithFirstObject:nil secondObject:nil];
  int i;
  long long x;
  res.len = 1; // [
  if ([s characterAtIndex:res.len] == '[') {
    temp = parse([s substringFromIndex:res.len]);
    [pair setFirstObject:temp.pair];
    res.len += temp.len;
    res.len += 1; // ,
  } else {
    for (i = res.len; [s characterAtIndex:i] != ','; i++);
    x = [[s substringWithRange:OFRangeMake(res.len, i-res.len)] longLongValue];
    res.len = i + 1;
    [pair setFirstObject:[OFNumber numberWithLongLong:x]];
  }
  if ([s characterAtIndex:res.len] == '[') {
    temp = parse([s substringFromIndex:res.len]);
    [pair setSecondObject:temp.pair];
    res.len += temp.len;
    res.len += 1; // ]
  } else {
    for (i = res.len; [s characterAtIndex:i] != ']'; i++);
    x = [[s substringWithRange:OFRangeMake(res.len, i-res.len)] longLongValue];
    res.len = i + 1;
    [pair setSecondObject:[OFNumber numberWithLongLong:x]];
  }
  res.pair = pair;
  return res;
}

OFString *stringify(OFPair *pair) {
  OFMutableString *s = [OFMutableString string];
  [s appendString:@"["];
  if ([[pair firstObject] isKindOfClass:[OFNumber class]]) {
    [s appendString:[[pair firstObject] stringValue]];
  } else {
    [s appendString:stringify([pair firstObject])];
  }
  [s appendString:@","];
  if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
    [s appendString:[[pair secondObject] stringValue]];
  } else {
    [s appendString:stringify([pair secondObject])];
  }
  [s appendString:@"]"];
  return s;
}

long long magnitude(OFPair *pair) {
  long long res = 0;
  if ([[pair firstObject] isKindOfClass:[OFNumber class]]) {
    res += 3 * [[pair firstObject] longLongValue];
  } else {
    res += 3 * magnitude([pair firstObject]);
  }
  if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
    res += 2 * [[pair secondObject] longLongValue];
  } else {
    res += 2 * magnitude([pair secondObject]);
  }
  return res;
}

OFMutablePair *explode_rec(OFMutablePair *pair, OFMutablePair *parent, int l,
		 OFMutableArray *pi) {
  OFMutablePair *temp;
  [pi addObject:[OFPair pairWithFirstObject:pair secondObject:parent]];
  if (l == 4) {
    return pair;
  }
  if ([[pair firstObject] isKindOfClass:[OFMutablePair class]]) {
    temp = explode_rec([pair firstObject], pair, l+1, pi);
    if (temp) return temp;
  }
  if ([[pair secondObject] isKindOfClass:[OFMutablePair class]]) {
    temp = explode_rec([pair secondObject], pair, l+1, pi);
    if (temp) return temp;
  }
  return nil;
}

OFMutablePair *find_parent(OFMutablePair *pair, OFArray *pi) {
  int i;
  for (i = 0; i < pi.count; i++) {
    OFPair *p = [pi objectAtIndex:i];
    if ([p firstObject] == pair) return [p secondObject];
  }
  return nil;
}

BOOL find_first_and_add(OFMutablePair *pair, long long x, int dir) {
  if (dir < 0) {
    if ([[pair firstObject] isKindOfClass:[OFNumber class]]) {
      [pair setFirstObject:[OFNumber numberWithLongLong: [[pair firstObject] longLongValue]+x]];
      return YES;
    } else {
      if (find_first_and_add([pair firstObject], x, dir)) return YES;
    }
    if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
      [pair setSecondObject:[OFNumber numberWithLongLong: [[pair secondObject] longLongValue]+x]];
      return YES;
    } else {
      if (find_first_and_add([pair secondObject], x, dir)) return YES;
    }
  } else if (dir > 0) {
    if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
      [pair setSecondObject:[OFNumber numberWithLongLong: [[pair secondObject] longLongValue]+x]];
      return YES;
    } else {
      if (find_first_and_add([pair secondObject], x, dir)) return YES;
    }
    if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
      [pair setSecondObject:[OFNumber numberWithLongLong: [[pair secondObject] longLongValue]+x]];
      return YES;
    } else {
      if (find_first_and_add([pair secondObject], x, dir)) return YES;
    }
  } else {
    OFLog(@"Something is wrong!!");
  }
  return NO;
}


BOOL explode(OFMutablePair *root) {
  OFMutableArray *pi = [OFMutableArray array];
  OFMutablePair *pair = explode_rec(root, nil, 0, pi);
  int i;
  long long x1, x2;
  if (pair) {
    OFMutablePair *p[4];
    p[0] = find_parent(pair, pi);
    p[1] = find_parent(p[0], pi);
    p[2] = find_parent(p[1], pi);
    p[3] = find_parent(p[2], pi);    
    if (p[0] == nil || p[1] == nil || p[2] == nil || p[3] == nil) {
      OFLog(@"Something is wrong!");
      return NO;
    }
    if ([p[0] firstObject] == pair) {
      [p[0] setFirstObject:[OFNumber numberWithLongLong:0]];
      x1 = [[pair firstObject] longLongValue];
      x2 = [[pair secondObject] longLongValue];
      if ([[p[0] secondObject] isKindOfClass:[OFNumber class]]) {
	[p[0] setSecondObject:[OFNumber numberWithLongLong:[[p[0] secondObject] longLongValue]+x2]];
      } else {
	find_first_and_add([p[0] secondObject], x2, -1);
      }
      for (i = 1; i <= 3; ++i) {
	if ([p[i] secondObject] == p[i-1]) {
	  if ([[p[i] firstObject] isKindOfClass:[OFNumber class]]) {
	    [p[i] setFirstObject:[OFNumber numberWithLongLong:[[p[i] firstObject] longLongValue]+x1]];
	  } else {
	    find_first_and_add([p[i] firstObject], x1, 1);
	  }
	  break;
	}
      }
    } else {
      [p[0] setSecondObject:[OFNumber numberWithLongLong:0]];
      x1 = [[pair firstObject] longLongValue];
      x2 = [[pair secondObject] longLongValue];
      if ([[p[0] firstObject] isKindOfClass:[OFNumber class]]) {
	[p[0] setFirstObject:[OFNumber numberWithLongLong:[[p[0] firstObject] longLongValue]+x1]];
      } else {
	find_first_and_add([p[0] firstObject], x1, 1);
      }
      for (i = 1; i <= 3; ++i) {
	if ([p[i] firstObject] == p[i-1]) {
	  if ([[p[i] secondObject] isKindOfClass:[OFNumber class]]) {
	    [p[i] setSecondObject:[OFNumber numberWithLongLong:[[p[i] secondObject] longLongValue]+x2]];
	  } else {
	    find_first_and_add([p[i] secondObject], x2, -1);
	  }
	  break;
	}
      }
    }
    return YES;
  }
  return NO;
}

BOOL split(OFMutablePair *pair) {
  long long x;
  if ([[pair firstObject] isKindOfClass:[OFNumber class]]) {
    x = [[pair firstObject] longLongValue];
    if (x >= 10) {
      OFMutablePair *np = [OFMutablePair pairWithFirstObject:[OFNumber numberWithLongLong:x/2]
						secondObject:[OFNumber numberWithLongLong:(x+1)/2]];
      [pair setFirstObject:np];
      return YES;
    }
  } else {
    if (split([pair firstObject])) return YES;
  }
  if ([[pair secondObject] isKindOfClass:[OFNumber class]]) {
    x = [[pair secondObject] longLongValue];
    if (x >= 10) {
      OFMutablePair *np = [OFMutablePair pairWithFirstObject:[OFNumber numberWithLongLong:x/2]
						secondObject:[OFNumber numberWithLongLong:(x+1)/2]];
      [pair setSecondObject:np];
      return YES;
    }
  } else {
    if (split([pair secondObject])) return YES;
  }
  return NO;
}

OFMutablePair *add(OFMutablePair *p1, OFMutablePair *p2) {
  OFMutablePair *pair = [OFMutablePair pairWithFirstObject:p1 secondObject:p2];
  while (explode(pair) || split(pair)) {
    // OFLog(@"add:%@", stringify(pair));
    ;
  }
  return pair;
}

@interface Day18: OFObject <OFApplicationDelegate>
@end

OF_APPLICATION_DELEGATE(Day18)

@implementation Day18
- (void)applicationDidFinishLaunching
{
  OFFile *f = [OFFile fileWithPath:@"input" mode:@"r"];
  OFString *s;
  OFMutableArray *a = [OFMutableArray array];
  long long best = 0;
  int i, j;
  while ((s = [f readLine])) {
    [a addObject:s];
  }
  for (i = 0; i < a.count; i++) {
    for (j = i+1; j< a.count; j++) {
      OFMutablePair *p1 = parse([a objectAtIndex:i]).pair;
      OFMutablePair *p2 = parse([a objectAtIndex:j]).pair;
      best = MAX(best, magnitude(add(p1, p2)));
      p1 = parse([a objectAtIndex:j]).pair;
      p2 = parse([a objectAtIndex:i]).pair;
      best = MAX(best, magnitude(add(p1, p2)));
    }
  }
  OFLog(@"%lld\n", best);
  [OFApplication terminate];
}
@end
