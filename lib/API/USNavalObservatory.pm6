#########################################
## Michael D. Hensley
## May 13, 2017
## Perl 6 module use to easily interface with the U.S. Naval Observatory's Astronomical Applications API.
## Currently based on the 2.0.1 version of the API.
use v6.c;
unit class API::USNavalObservatory;
use JSON::Fast;
use HTTP::UserAgent;
has $!http-agent = HTTP::UserAgent.new(useragent => "Chrome/41.0");
has $baseUrl = 'api.usno.navy.mil';
has @validEras = "AD", "CE", "BC", "BCE";

###########################################
## Cylindrical Projection.

###########################################
## Spherical Projections.

###########################################
## Apparent disk of a solar system object.

###########################################
## Phases of the moon.

###########################################
## Complete sun and mood data for one day

###########################################
## Sideral time.

###########################################
## Solar eclipse calculator

###########################################
## Selected Christian observances
method observancesChristan( UInt $year ) {
  if $year != any( 1583...9999 ) { return "ERROR!! Invalid year. (only use 1583 to 9999)"; }
  my $template = "christian?year={ $year }";
  my $response = $webAgent.get( $baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Selected Jewish observances
method observancesJewish( UInt $year ) {
  if $year != any( 622...9999 ) { return "ERROR!! Invalid year. (only use 622 to 9999)"; }
  my $template = "jewish?year={ $year }";
  my $response = $webAgent.get( $baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Selected Islamic observances
method observancesIslamic( UInt $year ) {
  if $year != any( 360...9999 ) { return "ERROR!! Invalid year. (only use 360 to 9999)"; }
  my $template = "islamic?year={ $year }";
  my $response = $webAgent.get( $baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
###########################################
## Julian date converter
multi julianDate( $dateTimeObj, $era ) {
  my $APIDate-format = sub ($self) { sprintf "%02d/%02d/%04d", .month, .day, .year given $self; };
  my $date = Date.new( $dateTimeObj.Date, formatter => $APIDate-format);
  my $time = "{$dateTimeObj.hour}:{$dateTimeObj.minute}:{$dateTimeObj.second}{$dateTimeObj.timezone}";
  my $template = "jdconverter?date={ $date }&time={ $time }&era={ $era }";
  say $baseURL ~ $template;
  my $response = $webAgent.get( $baseURL ~ $template );
  if $response.is-success {
    return $response.content;
    }
    else {
      return $response.status-line;
  }
}
