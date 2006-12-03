use ExtUtils::MakeMaker;
WriteMakefile(
  NAME      => q{Geo::Forward},
  VERSION_FROM => q{lib/Geo/Forward.pm},
  PREREQ_PM => {
                 strict            => 0,
                 vars              => 0,
                 constant          => 0,
                 Geo::Constants    => 0.02, 
                 Geo::Functions    => 0.02, 
                 Geo::Ellipsoids   => 0.06, 
               },
               ($] >= 5.005 ? 
                 (
                   ABSTRACT_FROM => 'lib/Geo/Forward.pm',
                 ) : ()
               ),
             );
