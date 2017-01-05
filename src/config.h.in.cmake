#ifndef CONFIG_H
#define CONFIG_H

/* Eliminate a number of warnings which come up based on deprecated POSIX naming conventions. */
#ifdef _MSC_VER
/* Disable a few warnings under Visual Studio, for the time being. */
  #pragma warning( disable: 4018 4996 4244 4305 )

#endif

#cmakedefine HAVE_STRDUP
#cmakedefine HAVE_STRNDUP

#endif // CONFIG_H
