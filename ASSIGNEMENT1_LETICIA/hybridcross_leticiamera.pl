#!perl -w
use strict;
use Moose;
use Gene;
use SeedStock;
use HybridCross;

# this is just a friendly message to the users of your program
# (and to remind you how to use it, when you come back after 2 years!)
unless ($ARGV[0] && $ARGV[1] && $ARGV[2] && $ARGV[3]){
 print "\n\n\nUSAGE: perl hybridcross_leticiamera.pl gene_information.tsv seed_stock_data.tsv cross_data.tsv new_stock_filename.tsv\n\n\n";
 exit 0;
}



# get the 4 filenames
my $gene_data_file = $ARGV[0];#contains information about seeds in your genebank
my $stock_data_file = $ARGV[1];#contains information about genes
my $cross_data_file = $ARGV[2];#Contains information about the crosses you have made
my $new_stock_filename = $ARGV[3];#new file with the information update

my $gene_data = &load_gene_data($gene_data_file); # call load data subroutine
# $gene_data is a hashref $gene_data(Gene_ID) = $Gene_Object

my $stock_data = &load_stock_data($stock_data_file, $gene_data); # call load data subroutine
# $stock_data is a hashref of $stock_data(Stock_ID) = $SeedStock_Object

my $cross_data = &load_cross_data($cross_data_file,$stock_data);#load data subroutine
#$cross_data is a hashref.
#FIRST TASK
&plant_seeds($stock_data, 7); # current stock data, plant 7 grams
# this line calls on a subroutine that updates the status of
# every seed record in $stock_data

&print_new_stock_report($stock_data, $new_stock_filename); # current stock data, new database filename
# the line above creates the file new_stock_filename.tsv with the current state of the genebank
# the new state reflects the fact that you just planted 7 grams of seed...


&process_cross_data($cross_data);
# the line above tests the linkage. The Gene objects become updated with the
# other genes they are linked to.

print "\n\n -Final Report-";

#We have to dereference the hash
my %gene_data = %{$gene_data}; 
my @genes=values %gene_data;
foreach my $gene(@genes){ # go over the gene_data hash
    if ($gene->has_linkage){ # if a gene has_linkage then shows with which gene is linked to
        my $gene1 = $gene->Name;
        my $ligated= $gene->Linkage;
    print "\n$gene1 is linked to $ligated \n"; 
}
}
exit 1;



##SUBROUTINES##

sub load_gene_data{ #loads the information about seeds
    my ($gene_data)=@_;
    open(INPUT,"<$gene_data")||
      die "The input file $gene_data can't be opened";#shows a message if the input data it's not found or it can't be opened
    my @gene_data =<INPUT>;
    shift(@gene_data);#Remove the header
     my %gene_data; # creates a hash with gene_id as keys and gene_object as values.
    foreach my $gene_id(@gene_data){ #create a gene_object for each line of the file
        if ($gene_id=~/^(\w{9})\s+(\w*)\s+"(.*)"/) {#with this we can separate the information 
            my $gene = Gene->new(
             ID => $1,
             Name => $2,
             Mutant_Phenotype => $3,
             
            );
        my $id=$gene->ID;#ID as key
        $gene_data{$id}=$gene; #It generates a new value in the hash.
        }}
    
    my $gene_data_hashref=\%gene_data;#Variable which references to the hash
    return $gene_data_hashref;
}

sub load_stock_data{#loads the information about genes
    #dereference the hash
    my ($stock_data,$gene_data)=@_;
    my %gene_data = %{$gene_data}; 
    
    my @keys_ids=keys%gene_data;# #reference to the keys of the gene hash
    
    
    open(INPUT,"<$stock_data")||
      die "The file $stock_data can't be opened\n";#shows a message if the input file can't be opened and the program stops
    my @stock_data =<INPUT>;
    shift(@stock_data);#Remove header
    my %stock_data; #creates a hash with stock_id as keys and stock_object as values.

    foreach my $stock_id(@stock_data){
        foreach my $key_id(@keys_ids){
            if ($stock_id=~/^(\w*)\s+(\w{9})\s+(\S*)\s+(\w*)\s+(\d{1,})/) {
                if ($key_id eq $2) {#if gene_id  = mutant_phenotype_id then generates a new object
                    my $gene=$gene_data{$key_id};

                    my $seed_stock= SeedStock-> new(
                    Stock_Name => $1,
                    Grams_Remaining=> $5,
                    Gene => [$gene],
                    Storage => $4,
                    );
                    
                     my $id=$seed_stock->Stock_Name;
                     $stock_data{$id}=$seed_stock;
                }            
            }            
        }
    }
    my $seed_stock_ref=\%stock_data;#
    return $seed_stock_ref;
}


sub load_cross_data{#load the information about crosses
    #first we dereference the hash and get the keys
    my ($cross_data_file,$stock_data)=@_;
    my %stock_desref = %{$stock_data}; #Desreference the hash stock_data
    my @keys_stock=keys%stock_desref;#Keys of the hash stock_hash
    
    
    open(INPUT,"<$cross_data_file")||
      die "The file $cross_data_file can't be opened";#shows a message if the input file can't be opened and the program stops
    my @cross_data =<INPUT>;
    shift(@cross_data);#Remove the header
    my %cross_data;#Hash with hybridcross objects as values
     
     foreach my $cross_line(@cross_data){#if the id of stock_data = to id of parent 1 then the subroutine creates a new object 
        foreach my $key_stock(@keys_stock){
            if ($cross_line=~/^(\w*),(\w*),(\d{1,}),(\d{1,}),(\d{1,}),(\d{1,})/) {
                if ($key_stock eq $1) {       
                    my $p1=$stock_desref{$key_stock};
                    my $p2=$stock_desref{$2};
                    
                    my $hybrid= HybridCross-> new(
                    Parent_1 => [$p1],
                    Parent_2=> [$p2],
                    F2_WT => $3,
                    F2_P1 => $4,
                    F2_P2=>$5,
                    F2_P1P2=>$6,
                    );
                    
                     my $parental=$hybrid->Parent_1;
                     $cross_data{$parental}=$hybrid;
                }            
            }            
        }
    }
     my $cross_ref=\%cross_data;
    return $cross_ref;
}


sub plant_seeds{
   my ($seed_stock_ref,$grams_planted)=@_;
   my %stock_desref = %{$seed_stock_ref}; 
   my @stock_object=values%stock_desref; 
   
   foreach my $stock_object(@stock_object){
        my $old_stock=$stock_object->Grams_Remaining;
        my $new_stock= $old_stock - $grams_planted; #reduction of 7 grams
        if ($new_stock<=0) {#Grams left can't be zero so if this happens the program shows a warning message and sets the value to 0
            print "We have run out of Seed Stock. Grams can't be less than zero\n" .$stock_object->Stock_Name. "\n";
            $stock_object->Grams_Remaining(0);
        }
        else {
            $stock_object->Grams_Remaining($new_stock); 
            }
    }
}

sub print_new_stock_report{
  
    my($stock_data, $new_stock_data_filename)=@_;
    my %stock_desref = %{$stock_data}; 
    my @stock_object=values%stock_desref; 
    
    
    #Creates a new file with the information update
    open(OUTPUT,">>$new_stock_data_filename")||
          
    print OUTPUT "Stock \t Mutant ID \t Storage \t Grams Left \t\n";    #
    foreach my $stock_object(@stock_object){
        print OUTPUT " ".$stock_object->Stock_Name."\t"  .$stock_object->Storage." \t".$stock_object->Grams_Remaining."\t\n";}
    close OUTPUT;
}


sub process_cross_data{ #dereference the hash and get the cross_objects
    my ($cross_data) = @_;
    my %cross_desref= %{$cross_data}; 
    my @cross_object= values%cross_desref; 
    
#observed values of the different genotypes
foreach my $cross_object(@cross_object){
    my $WTobs= $cross_object->F2_Wild;
    my $P1obs= $cross_object->F2_P1;
    my $P2obs= $cross_object->F2_P2;
    my $P1P2obs= $cross_object->F2_P1P2;
  my $total_values_observed= ($WTobs + $P1obs + $P2obs + $P1P2obs);#Total of the observed values
#We expect the values 9:3:3:1
    my $WTexp= ($total_values_observed*9)/16;
    my $P1exp= ($total_values_observed*3)/16;
    my $P2exp= ($total_values_observed*3)/16;
    my $P1P2exp= ($total_values_observed)/16;
#Calculate chisquare value
my $chisquare=(($WTobs-$WTexp)**2/$WTexp)+(($P1obs-$P1exp)**2/$P1exp)+(($P2obs-$P2exp)**2/-$P2exp)+(($P1P2obs-$P1P2exp)**2/$P1P2exp);
#H0: the genes are not linked
#H1: the genes are linked
my $chisquare_3degrees= 7.815;#value with alfa=0.05 and 3 degrees of freedom.
    if ($chisquare>$chisquare_3degrees){#when the value is bigger than 7.815 H0 is rejected and the genes are linked.
        #we have to get the names of the genes that are linked
    my $gene1=$cross_object->Parent_1->[0]->Gene->[0]->Name; 
    my $gene2=$cross_object->Parent_2->[0]->Gene->[0]->Name; 

$cross_object->Parent_1->[0]->Gene->[0]->Linkage($gene2);
$cross_object->Parent_2->[0]->Gene->[0]->Linkage($gene1);
}
}
}
exit 1;
