# perl6-API-USNavalObservatory [![Build Status](https://travis-ci.org/cbk/API-USNavalObservatory.svg?branch=master)](https://travis-ci.org/cbk/API-USNavalObservatory)

## SYNOPSIS
Simple Perl 6 interface to the U.S. Naval Observatory, Astronomical Applications API v2.2.0
which can be found at http://aa.usno.navy.mil/data/docs/api.php

You may choose  to use an 8 character alphanumeric identifier in your forms or scripts.  This API has a default of 'P6mod' which is registered with the U.S. Naval Observatory as the default ID of this API.  The 'AA' ID is used internally by the U.S. Naval Observatory and thus can not be used.
You may use any other identifier you want for apiID.
#### EXAMPLE:
the following example creates a new API::NavalObservatory object called $webAgent and sets the apiID to 'MyID'.
```
my $webAgent = API::USNavalObservatory.new( apiID => "MyID" );
```


## Returns
* For services which return text, you will receive an JSON formatted blob of text.
* For services which produce a image, this API will save the .PNG file in the current working directory.

## Methods

### Day and Night Across the Earth - Cylindrical Projection
#### EXAMPLE:
#### Return:

### Day and Night Across the Earth - Spherical Projections
#### EXAMPLE:
#### Return:
This method returns a JSON formatted text blob.

### Apparent Disk of a Solar System Object
Produces an apparent disk of a solar system object oriented as if you were viewing it through a high-powered telescope.

#### EXAMPLE:
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

#### EXAMPLES:
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

#### EXAMPLES:
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

#### EXAMPLES:
The following example shows a request using a location string.
```
say $webAgent.siderealTime(
	:dateTimeObj(DateTime.new(
                    year => 2019,
                    month => 2,
                    day => 2,
                    hour => 2,
                    minute => 2,
                    second => 1,) ),
	:loc("Denver,CO"),
	:reps(90),
	:intvMag(5),
	:intvUnit('minutes')
);
```

The following example shows a request using coordinates. 
```
say $webAgent.siderealTime-coords(
	:dateTimeObj( DateTime.new(
                    year => 2019,
                    month => 2,
                    day => 2,
                    hour => 2,
                    minute => 2,
                    second => 1,) ),
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

#### EXAMPLES:
The following example shows a request using a U.S. based location (San Francisco CA) for the current day.
* NOTE: Currently this module utilizes the URI::Encode, uri_encode method. Including a comma **,** in the string that is passed to uri_encode seams to produce a malformed URL which fails when passed to the API. Use a space instead of a comma for now.

```
say $webAgent.solarEclipses(
	:loc("San Francisco CA"),
	:dateObj( Date.today() ),
	:height(50),
	:format("json") );
```
The following example shows a request using lat and long.
```
say $webAgent.solarEclipses(
	:coords("46.67N, 1.48E" ),
	:dateObj( Date.today() ),
	:height(50),
	:format("json") );
```
The following example shows a request providing only the year in the range of 1800 to 2050.
```
say $webAgent.solarEclipses( 2019 );
```
#### Return:
All these method signatures return an JSON formatted text blob.

### Selected Christian Observances
This data service provides the dates of Ash Wednesday, Palm Sunday, Good Friday, Easter, Ascension Day, Whit Sunday, Trinity Sunday, and the First Sunday of Advent in a given year. Data will be provided for the years 1583 through 9999. More information about this application may be found here

#### EXAMPLE:
```
say $webAgent.observancesChristan( Date.today.year() );
```

#### Return:
This method returns a JSON formatted text blob.

### Selected Jewish Observances
This data service provides the dates for Rosh Hashanah (Jewish New Year), Yom Kippur (Day of Atonement), first day of Succoth (Feast of Tabernacles), Hanukkah (Festival of Lights), first day of Pesach (Passover), and Shavuot (Feast of Weeks) in a given year. Data will be provided for the years 360 C.E. (A.M. 4120) through 9999 C.E. (A.M. 13761).

#### EXAMPLE:
```
say $webAgent.observancesJewish( Date.today.year() );
```

#### Return:
This method returns a JSON formatted text blob.

### Selected Islamic Observances
This data service provides the dates for Islamic New Year, the first day of Ramadân, and the first day of Shawwál in a given year.

The `.observancesIslamic` method takes one argument called year, which should be a unsigned integer in the range of 622 to 9999.

#### EXAMPLE:
```
say $webAgent.observancesIslamic( Date.today.year() );
```

#### Return:
This method returns a JSON formatted text blob.


### Julian Date Converter
This data service converts dates between the Julian/Gregorian calendar and Julian date. Data will be provided for the years 4713 B.C. through A.D. 9999, or Julian dates of 0 through 5373484.5.

To use the `.julianDate` method, you must provide a valid `DateTime` object and a valid Era OR an unsigned integer.

This method returns a JSON text blob of the request converted into ether a Julian or calendar date.


#### EXAMPLES:
```
say $webAgent.julianDate( 2457892.312674 );
```

```
say $webAgent.julianDate( :dateTimeObj(DateTime.now), :era('AD'));
```

#### Return:
Both of these methods returns an JSON formatted text blob.

### Earth's Seasons and Apsides
#### EXAMPLE:
```
say $webAgent.seasons( :year(2019), :tz(-6), :dst(False) );
```
#### Return:
This method returns a JSON formatted text blob.


## Sample code
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
{
"error":false,
"apiversion":"2.2.0",
"data":[
      {
         "jd": 2457892.312674,
         "month": 5,
         "day": 18,
         "year": 2017,
         "era": "A.D.",
         "time": "19:30:15.0",
         "tz": 0,
         "dayofweek" : "Thursday"
      }
   ]
}
```

## AUTHOR
* Michael, cbk on #perl6, https://github.com/cbk/
