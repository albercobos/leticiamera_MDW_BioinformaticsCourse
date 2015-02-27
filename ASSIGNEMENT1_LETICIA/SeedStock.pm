package SeedStock;
use Moose;

#ATRIBUTES 
has 'Stock_Name' => (
    is=>'rw',
    isa=>'Str'
);

has 'Grams_Remaining' => (
    is=>'rw',
    isa=>'Int'
);

has 'Last_Seed_Date' => ( 
    is=>'rw',
    isa=>'Date'
);
has 'Gene' => ( #references Gene
    is=>'rw',
    isa=>'ArrayRef[Gene]', 
);


has 'Storage' => (
    is=>'rw',
    isa=>'Str'
);



1;
