use Test;
API::USNavalObservatory

ok(1);

if (%*ENV<TRAVIS>) {
    diag "Running test on travis";
    my $ipObj = API::USNavalObservatory.new;
}

done-testing();
