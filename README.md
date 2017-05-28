# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)

## SYNOPSIS
Simple Perl 6 interface to the U.S. Naval Observatory, Astronomical Applications API v2.0.1
This is a work in progress is is by any means ready for use yet.  More to follow...

## Methods
Day and Night Across the Earth - Cylindrical Projection
Day and Night Across the Earth - Spherical Projections
Apparent Disk of a Solar System Object
Phases of the Moon
Complete Sun and Moon Data for One Day
Sidereal Time
Solar Eclipse Calculator
Selected Christian Observances
Selected Jewish Observances
Selected Islamic Observances
Julian Date Converter

* observancesChristan( UInt $year )
This method take a 4 digit year from 1583 to 9999.
* observancesJewish( UInt $year )
This method take a 4 digit year from 622 to 9999.
* observancesIslamic( UInt $year )
This method take a 4 digit year from 360 to 9999.
* julianDate( $dateTimeObj, $era )
This method take a DateTime object and one of the valid era aberrations .
* julianDate( $julian )

## Returns
* For services which return text, you will receive an JSON formatted blob of text.
* For services which produce a image, this API will save the .PNG file in the current working direcoty.

## Example
* The following example makes a new object and overrides the default apiID. Then calls the Julian date converter method to find the converted Julian date.

```
use v6.c;
use API::USNavalObservatory;
my $webAgent = API::NavalObservatory.new( apiID => "MyID" );
my $output = $webAgent.julianDate( 2457892.312674 );
say $output;

```
OUTPUT:
```
SOME TEXT HERE...
```

## AUTHOR
* Michael, cbk on #perl6, https://github.com/cbk/
