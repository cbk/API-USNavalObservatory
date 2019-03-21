# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)

## SYNOPSIS
This module is a simple **Perl 6** interface to the U.S. Naval Observatory, Astronomical Applications API v2.2.0
which can be found at http://aa.usno.navy.mil/data/docs/api.php

You may choose to use an 8 character alphanumeric identifier in your forms or scripts.  This API has a default of **"P6mod"** which is registered with the U.S. Naval Observatory as the default ID of this API.  The 'AA' ID is used internally by the U.S. Naval Observatory and thus can not be used.
It is recommended that you override the default `apiID` You may use any other identifier you want for `apiID`. Information about the ID and how to register your own can be found **[here](https://aa.usno.navy.mil/data/docs/api.php#id)**.  

#### Example:
the following example creates a new **API::NavalObservatory** object called $webAgent and sets the apiID to 'MyID'.
```
my $webAgent = API::USNavalObservatory.new( apiID => "MyID" );
```

## Returns
* For services which return text, you will receive an JSON formatted blob of text.
* For services which produce a image, this API will save the .PNG file in the current working directory. (Overwriting any existing file with the same name.)

## Methods
There are currently 9 methods which are used to interact with this API. 

The API uses UTC time for all time based calls.  When crafting your method calls add the `.utc` method on the DateTime object to convert a local time to UTC.

Below is a list of the current methods in this module:
* Day and Night Across the Earth, Cylindrical Projection: `.cylindrical()`
* Day and Night Across the Earth, Spherical Projection:  `.spherical()`
* Apparent Disk of the Solar System Object: `.apparentDisk()`
* Phases of the Moon: `.moonPhase()`
* Complete Sun and Moon Data for One Day: `.oneDayData()`
* Sidereal Time: `.siderealTime()`
* Solar Eclipse Calculator: `.solarEclipses()`
* Religious Observances: `.observances()`
* Earth Seasons and Apsides: `.seasons()`

### Day and Night Across the Earth - Cylindrical Projection
Generates a cylindrical map of the Earth (similar to a Mercator projection) with daytime and nighttime areas appropriately shaded. 

#### Examples:
The following example shows a request using a date only.
```
say $webAgent.cylindrical( :dateObj( Date.today  ) );
```
This example shows a request that uses both date and time.
```
say $webAgent.cylindrical( :dateTimeObj( DateTime.now ) );
```

#### Return:
This method returns a .png image in the current working directory.
* NOTE: This will overwrite any file with the same name in the CWD.

### Day and Night Across the Earth - Spherical Projections
Creates a .png image view of the Earth with daytime and nighttime areas shaded appropriately. The image generated is of the apparent disk you would see if you were in a spacecraft looking back at Earth.
This method takes two named pramaters: `dateTimeObj` which is a DateTime object and view which is a View subset. 
* The value for `view` can be any one of the following: **moon, sun, north, south, east, west, rise, and set.**

#### Example:
```
 say $webAgent.spherical(
    :dateTimeObj( DateTime.now ),
	:view("sun")
);
```
#### Return:
This method returns a .png image in the current working directory.
* NOTE: This will overwrite any file with the same name in the CWD.

### Apparent Disk of a Solar System Object
Produces an apparent disk of a solar system object oriented as if you were viewing it through a high-powered telescope.

#### Example:
```
 say $webAgent.apparentDisk(
	:dateTimeObj( DateTime.now ),
	:body('moon')
);
```

#### Return:
This method returns a png image in the current working directory. 

### Phases of the Moon
Returns the dates and times of a list of primary moon phases.  
This method has two signatures:
* One where a valid year is provided, and returns ALL moon phase data for that year.  This is a un-named pramater.
* One that has will take a `Date` object and a unsigned integer for the number of phases to include in the results. 

#### Examples:
The following example shows a request for a given date and number of phases.
```
say $webAgent.moonPhase(
	:dateObj( Date.today() ),
	:numP( 5 )
);
```
The following example shows a request for a given year.
```
 say $webAgent.moonPhase( 2019 );
 ```

#### Return:
This method returns a JSON formatted text blob.

### Complete Sun and Moon Data for One Day
Returns the rise, set, and transit times for the Sun and the Moon on the requested date at the specified location.

#### Examples:
The following example shows a request using date, coordinates, and time zone.
```
say $webAgent.oneDayData(
	:dateObj( Date.today() ),
	:coords( "41.98N, 12.48E" ),
	:tz(-6)
);
```
The following example shows a request using date amd location.
```
say $webAgent.oneDayData(
	:dateObj( Date.today()),
	:loc("San Diego, CA")
);
```
#### Return:
This method returns a JSON formatted text blob.

### Sidereal Time
Provides the greenwich mean and apparent sidereal time, local mean and apparent sidereal time, and the Equation of the Equinoxes for a given date & time.

#### Examples:
The following example shows a request using a location string.
```
say $webAgent.siderealTime(
    :dateTimeObj(DateTime.new(
        year => 2019,
        month => 2,
        day => 2,
        hour => 2,
        minute => 2,
        second => 1,)),
    :loc("Denver,CO"),
    :reps(90),
    :intvMag(5),
    :intvUnit('minutes')
);
```

The following example shows a request using coordinates. 
```
say $webAgent.siderealTime(
    :dateTimeObj( DateTime.new(
        year => 2019,
        month => 2,
        day => 2,
        hour => 2,
        minute => 2,
        second => 1,)),
    :coords("41.98N, 12.48E"),
    :reps(90),
    :intvMag(5),
    :intvUnit('minutes')
);
```

#### Return:
This method returns a JSON formatted text blob.

### Solar Eclipse Calculator
This data service provides local circumstances for solar eclipses, and also provides a means for determining dates and types of eclipses in a given year.

#### Examples:
The following example shows a request using a U.S. based location (San Francisco CA) for the current day.
* NOTE: Currently this module utilizes the URI::Encode, uri_encode method. Including a comma **,** in the string that is passed to uri_encode seams to produce a malformed URL which fails when passed to the API. Use a space instead of a comma for now.

```
say $webAgent.solarEclipses(
	:loc("San Francisco CA"),
	:dateObj( Date.today() ),
	:height(50),
	:format("json") 
    );
```
The following example shows a request using lat and long.
```
say $webAgent.solarEclipses(
	:coords("46.67N, 1.48E" ),
	:dateObj( Date.today() ),
	:height(50),
	:format("json") 
	);
```
The following example shows a request providing only the year in the range of 1800 to 2050.
```
say $webAgent.solarEclipses( 2019 );
```
#### Return:
All these method signatures return an JSON formatted text blob.


### Selected Religious Observances
Single method to handle all three calender types; `christan, jewish, islamic`
 * For Christan calender, use years between 1583 and 9999.
 * For Jewish calender, use years between 360 and 9999.
 * For Islamic calender, use years between 622 and 9999.

#### Example:
```
say $webAgent.observances( :year(2019), :cal('christian') );
```
#### Return:
This method returns a JSON formatted text blob.
 
### Julian Date Converter
This data service converts dates between the Julian/Gregorian calendar and Julian date. Data will be provided for the years 4713 B.C. through A.D. 9999, or Julian dates of 0 through 5373484.5.

To use the `.julianDate` method, you must provide a valid `DateTime` object and a valid Era OR an unsigned integer.

This method returns a JSON text blob of the request converted into ether a Julian or calendar date.


#### Examples:
```
say $webAgent.julianDate( 2457892.312674 );
```

```
say $webAgent.julianDate( :dateTimeObj(DateTime.now), :era('AD') );
```

#### Return:
Both of these methods returns an JSON formatted text blob.

### Earth's Seasons and Apsides
#### Example:
```
say $webAgent.seasons( :year(2019), :tz(-6), :dst(False) );
```
#### Return:
This method returns a JSON formatted text blob.


## Sample code
* The following example makes a new object and overrides the default apiID. Then calls the Julian date converter method to find the converted Julian date.

```
use v6;
use API::USNavalObservatory;
my $webAgent = API::NavalObservatory.new( apiID => "MyID" );
my $output = $webAgent.solarEclipses( 2019 );
say $output;
```
OUTPUT:
```
{
  "error" : false,
  "year" : 2019,
  "apiversion" : "2.2.0",
  "eclipses_in_year" : [
    {
      "event" : "Partial Solar Eclipse of 6 January 2019",
      "day" : 6,
      "year" : 2019,
      "month" : 1
    },
    {
      "event" : "Total Solar Eclipse of 2 July 2019",
      "month" : 7,
      "year" : 2019,
      "day" : 2
    },
    {
      "event" : "Annular Solar Eclipse of 26 December 2019",
      "month" : 12,
      "year" : 2019,
      "day" : 26
    }
  ]
}
```

## AUTHOR
* Michael, cbk on #perl6, https://github.com/cbk/
