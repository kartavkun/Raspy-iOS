#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "GithubLogo" asset catalog image resource.
static NSString * const ACImageNameGithubLogo AC_SWIFT_PRIVATE = @"GithubLogo";

/// The "Rasp_logo" asset catalog image resource.
static NSString * const ACImageNameRaspLogo AC_SWIFT_PRIVATE = @"Rasp_logo";

/// The "Rasp_logo_noBG" asset catalog image resource.
static NSString * const ACImageNameRaspLogoNoBG AC_SWIFT_PRIVATE = @"Rasp_logo_noBG";

/// The "TelegramLogo" asset catalog image resource.
static NSString * const ACImageNameTelegramLogo AC_SWIFT_PRIVATE = @"TelegramLogo";

#undef AC_SWIFT_PRIVATE
