#########################################
## Michael D. Hensley
## May 13, 2017
## Perl 6 module use to easily interface with the U.S. Naval Observatory's Astronomical Applications API.
## Currently based on the 2.2.0 version of the API.
use v6;

unit class API::USNavalObservatory;
use URI;
use Cro::HTTP::Client;
use JSON::Pretty;

my $baseURL = 'api.usno.navy.mil/';
my $apiID = 'P6mod'; # Default ID, feel free to use an ID of your own and  override.
my $outputDir = $*CWD; # Current working Dir is the default output dir for images

subset SolarEclipses-YEAR of UInt where * eq any( 1800..2050 );
subset ValidEras of Str where * eq any( "AD", "CE", "BC", "BCE" );
subset ValidJulian of UInt where * < 5373484.5;
subset ObserChristan of UInt where * eq any( 1583..9999 );
subset ObserJewish of UInt where * eq any( 622..9999 );
subset ObserIslamic of UInt where * eq any( 360..9999 );
subset Body of Str where * eq any( "mercury", "venus", "venus-radar", "mars", "jupiter", "moon", "io", "europa", "ganymede", "callisto" );
subset Height of Int where * eq any ( -90..10999 );
subset Format of Str where * eq any( "json", "gojson" );
subset MoonPhase of UInt where * eq any( 1..99 );
subset View of Str where * eq any( "moon", "sun", "north", "south", "east", "west", "rise", "set" );

my regex coords { \-? \d+[\.\d+]? [N|S]? \,?\s? \-? \d+[\.\d+]? [E|W]? };
my regex loc { ['St.' || <alpha> ]? \s? <alpha>+ \, \s? \w**2 };

###########################################
## getJSON - method used to make request which will return JSON formatted data.
method !getJSON( $template ) {
    my $encode_template = $template; $encode_template ~~ s:global/\s/%20/;
    my URI $URI .= new( "https://" ~ $baseURL ~ $encode_template ~ "&id={ $apiID }");
    my $request = await Cro::HTTP::Client.get( $URI );
    my $response = await $request.body;
    return to-json $response;
}
###########################################
## getIMG - method used to make request which will return .png files.
## TODO: change the default location of the base directory
method !getIMG( :$name, :$template ){
  my $file = $outputDir ~ "/"~ $name ~ ".png";
  my $encode_template = $template; $encode_template ~~ s:global/\s/%20/;
  my URI $URI .= new( "https://" ~ $baseURL ~ $encode_template ~ "&id={ $apiID }");
  #say $URI; exit;
  say "Saving to $file";
  my $request = await Cro::HTTP::Client.get( $URI );
  my Blob $responseIMG = await $request.body-blob();
  $file.IO.spurt: :bin, $responseIMG;
  say "{($file.path.s / 1024).fmt("%.1f")} KB received";
}

###########################################
## Cylindrical Projection.

# Query with a date and time
multi method cylindrical( DateTime :$dateTimeObj! ) {
  my $template = "imagery/earth.png?year={ $dateTimeObj.year }&month={ $dateTimeObj.month  }&day={  $dateTimeObj.day}&hour={ $dateTimeObj.hour }&minute={ $dateTimeObj.minute }";
  self!getIMG( :name( "earth" ), :template( $template ) );
}

# Query with date only
multi method cylindrical( Date :$dateObj! ) {
    my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
    my $template = "imagery/earth.png?date={ $date }";
    self!getIMG( :name( "earth" ), :template( $template ) );
}

###########################################
## Spherical Projections.
method spherical( DateTime :$dateTimeObj, View :$view ) {
    my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
    my $time = $dateTimeObj.hh-mm-ss;
    my $template = "imagery/earth.png?date={ $date }&time={ $time }&view={ $view }";
    self!getIMG( :name( "earth" ), :template( $template ) );
}

###########################################
## Apparent disk of a solar system object.
method apparentDisk( DateTime :$dateTimeObj!, :$body ){
    my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
    my $time = $dateTimeObj.hh-mm-ss;
    my $template = "imagery/{ $body }.png?date={ $date }&time={ $time }";
    self!getIMG( :name( $body ), :template($template)  );
}

###########################################
## Phases of the moon.
multi method moonPhase( Date :$dateObj, MoonPhase :$numP  ){
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "moon/phase?date={ $date }&nump={ $numP }";
  return self!getJSON( $template );
}

multi method moonPhase( UInt $year where * eq any( 1700 ..2100 )){
  # 1700 and 2100 are the only valid years which can be used.
  my $template = "moon/phase?year={ $year }";
  return self!getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by lat and long.
multi method oneDayData( Date :$dateObj, :$coords, :$tz ) {
  try {
    if $coords !~~ / <coords> / { die; }
      CATCH { say 'Invalid coords passed!'; }
  }
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  #my $tz = $dateTimeObj.timezone / 3600; ## This was used if a date time object was passed
  my $template = "rstt/oneday?date={ $date }&coords={ $coords }&tz={ $tz }";
  say self!getJSON( $template );
}

###########################################
## Complete sun and mood data for one day by location.
multi method oneDayData( Date :$dateObj!, Str :$loc ) {
  try {
    if $loc !~~ / <loc> / { die; }
    CATCH { say 'Invalid location passed!'; }
  }
  my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
  my $template = "rstt/oneday?date={ $date }&loc={ $loc }";
  return self!getJSON( $template );
}

###########################################
## Sidereal Time
## TODO need to check if date is within 1 year past or 1 year in the future, range. DONE!!
## TODO need to have some input checking for $intvUnit; can be 1 - 4 or a string. DONE!!
multi method siderealTime( DateTime :$dateTimeObj, Str :$loc!, UInt :$reps, UInt :$intvMag, :$intvUnit ) {
    try {
        if $loc !~~ / <loc> / { die; } ## Check if the location value matches a valid pattern.
        if $dateTimeObj.Date < Date.today.earlier(year => 1) or $dateTimeObj.Date > Date.today.later(year => 1)  { die; }
        if $intvUnit !~~ /[1..4] | ['day' | 'hour' | 'minute' | 'second'] /  { die; }
        CATCH { say 'Invalid data passed!'; }
    }
    my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
    my $time = $dateTimeObj.hh-mm-ss;
    my $template = "sidtime?date={ $date }&time={ $time }&loc={ $loc }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
    return self!getJSON( $template );
}

multi method siderealTime( DateTime :$dateTimeObj, :$coords, UInt :$reps, UInt :$intvMag, :$intvUnit ) {
    try {
      if $coords !~~ / <coords> / { die; }
      if $dateTimeObj.Date < Date.today.earlier(year => 1) or $dateTimeObj.Date > Date.today.later(year => 1)  { die; }
      if $intvUnit !~~ /[1..4] | ['day' | 'hour' | 'minute' | 'second'] /  { die; }
      CATCH { say 'Invalid data passed!'; }
    }
    my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
    my $time = $dateTimeObj.hh-mm-ss;
    my $template = "sidtime?date={ $date }&time={ $time }&coords={ $coords }&reps={ $reps }&intv_mag={ $intvMag }&intv_unit={ $intvUnit }";
    return self!getJSON( $template );
}

###########################################
## Solar eclipses calculator
multi method solarEclipses( Date :$dateObj, :$loc!, Height :$height, Format :$format  ) {
    my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
    my $template = "eclipses/solar?date={ $date }&loc={ $loc }&height={ $height }&format={ $format }";
    return self!getJSON( $template );
}

multi method solarEclipses( Date :$dateObj, :$coords, Height :$height, Format :$format  ) {
    my $date = "{ $dateObj.month }/{ $dateObj.day }/{ $dateObj.year }";
    my $template = "eclipses/solar?date={ $date }&loc={ $coords }&height={ $height }&format={ $format }";
    return self!getJSON( $template );
}

multi method solarEclipses( SolarEclipses-YEAR $year ) {
  my $template = "eclipses/solar?year={ $year }";
  return self!getJSON( $template );
}

##########################################
## Selected religious observances
# Single method to handle all three calender types.
method observances( Int :$year!, Str :$cal! ) {
    if $cal !eq any <christian jewish islamic> { say "Invalid Data Passed"; die; }
    if $cal eq 'christian' & $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; die; }
    if $cal eq 'jewish' & $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; die; }
    if $cal eq 'islamic' & $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; die; }
    my $template = "{ $cal }?year={ $year }";
    return self!getJSON( $template );
}

###########################################
## Julian date converter -
# From calender date to julian date
multi method julianDate( DateTime :$dateTimeObj, ValidEras :$era ) {
    ## TODO Need argument validation for date and era.
    my $date = "{ $dateTimeObj.month }/{ $dateTimeObj.day }/{ $dateTimeObj.year }";
    my $time = "{ $dateTimeObj.hour }:{ $dateTimeObj.minute }:{ $dateTimeObj.second }";
    my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
    return self!getJSON( $template );
}

# From julian date to calender date.
multi method julianDate(  $julian ) {
    #if $julian < 0 or $julian > 5373484.5 { return "ERROR!! Julian date. (only use 0 to 5373484.5 )"; }
    my $template = "jdconverter?jd={ $julian }";
    return self!getJSON( $template );
}

###########################################
## Earth's Seasons and Apsides
# Data will be provided for the years 1700 through 2100.
# Time zone must be in the range -12 (west) ≤ TZ ≤ +14 (east).
multi method seasons( UInt :$year, Int :$tz?, Bool :$dst? ) {
    my $template;
    if $year ~~ 1700..2100 { $template = "seasons?year={$year}"; } else { say "Not a valid range for year."; die; }
    if $tz ~~ -12..14 { $template ~= "&tz={$tz}"; } else { say "Not a valid range for time zone."; die; }
    if $dst { $template ~= "&dst={$dst}"; }
    # say $template; exit;
    return self!getJSON( $template );
}


