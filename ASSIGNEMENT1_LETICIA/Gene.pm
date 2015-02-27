package Gene;
use Moose;

#ATRIBUTES
has 'ID' => (
    is=>'rw',
    isa=>'Str',
);

has 'Name' => (
    is=>'rw',
    isa=>'Str',

);

has 'Mutant_Phenotype' =>(
    is=>'rw',
    isa=>'Str'
);

has 'Linkage' =>(
    is=>'rw',
    isa=>'Str', 
    predicate=>'has_linkage',
);


1;
