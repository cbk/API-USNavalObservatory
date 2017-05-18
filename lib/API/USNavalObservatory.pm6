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
method observancesChristan( $year ) {
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

###########################################
## Selected Islamic observances

###########################################
## Julian date converter
