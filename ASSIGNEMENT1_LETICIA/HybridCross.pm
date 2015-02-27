package HybridCross;
use Moose;

#ATRIBUTES

has 'Parent_1' => ( #Parent 1 Stock
    is=>'rw',
    isa=>'ArrayRef[SeedStock]' # it's a Seed Stock object
);

has 'Parent_P2' => ( # stock object of Parent 2
    is=>'rw',
    isa=>'ArrayRef[SeedStock]' # it's a Seed Stock object
);

has 'F2_WT' => ( #WT (double dominant)
    is=>'rw',
    isa=>'Int'
);

has 'F2_P1' => ( # Gene1 dominance
    is=>'rw',
    isa=>'Int'
);

has 'F2_P2' => ( # Gene2 dominance
    is=>'rw',
    isa=>'Int'
);

has 'F2_P1P2' => ( # recessive genotype
    is=>'rw',
    isa=>'Int'
);
1;
