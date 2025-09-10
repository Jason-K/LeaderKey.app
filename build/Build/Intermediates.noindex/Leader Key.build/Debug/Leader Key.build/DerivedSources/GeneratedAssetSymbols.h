#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "ForTheHorde-bg" asset catalog image resource.
static NSString * const ACImageNameForTheHordeBg AC_SWIFT_PRIVATE = @"ForTheHorde-bg";

/// The "ForTheHorde-fg" asset catalog image resource.
static NSString * const ACImageNameForTheHordeFg AC_SWIFT_PRIVATE = @"ForTheHorde-fg";

/// The "StatusItem" asset catalog image resource.
static NSString * const ACImageNameStatusItem AC_SWIFT_PRIVATE = @"StatusItem";

/// The "StatusItem-filled" asset catalog image resource.
static NSString * const ACImageNameStatusItemFilled AC_SWIFT_PRIVATE = @"StatusItem-filled";

#undef AC_SWIFT_PRIVATE
