#!/usr/bin/env perl


=head1 NAME

 0005_load_sol100_species.pl

=head1 SYNOPSIS

  this_script.pl [options]

  Options:

    -D <dbname> (mandatory)
      dbname to load into

    -H <dbhost> (mandatory)
      dbhost to load into

    -p <script_executor_user> (mandatory)
      username to run the script

    -F force to run this script and don't stop it by 
       missing previous db_patches

  Note: If the first time that you run this script, obviously
        you have no previous dbversion row in the md_dbversion
        table, so you need to force the execution of this script 
        using -F

=head1 DESCRIPTION

Need to add 'sol100' organismprop to all species provided by Sandy Knaap and Rene


=head1 AUTHOR

Naama Menda
nm249@cornell.edu

=head1 COPYRIGHT & LICENSE

Copyright 2010 Boyce Thompson Institute for Plant Research

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


use strict;
use warnings;

use Pod::Usage;
use Getopt::Std;
use CXGN::DB::InsertDBH;
use Bio::Chado::Schema;

use CXGN::Metadata::Dbversion;   ### Module to interact with the metadata.md_dbversion table


## Declaration of the parameters used to run the script

our ($opt_H, $opt_D, $opt_p, $opt_F, $opt_h);
getopts("H:D:p:Fh");

## If is used -h <help> or none parameters is detailed print pod

if (!$opt_H && !$opt_D && !$opt_p && !$opt_F && !$opt_h) {
    print STDOUT "No optionas passed. Printing help\n\n";
    pod2usage(1);
} 
elsif ($opt_h) {
    pod2usage(1);
} 


## Declaration of the name of the script and the description

my $patch_name = '0005load_sol100_species.pl';
my $patch_descr = 'This patch adds a sol100 organism prop to each species in the list provided';

print STDOUT "\n+--------------------------------------------------------------------------------------------------+\n";
print STDOUT "Executing the patch:\n   $patch_name.\n\nDescription:\n  $patch_descr.\n\nExecuted by:\n  $opt_p.";
print STDOUT "\n+--------------------------------------------------------------------------------------------------+\n\n";

## And the requeriments if you want not use all
##
my @previous_requested_patches = (   ## ADD HERE
   ); 

## Specify the mandatory parameters

if (!$opt_H || !$opt_D) {
    print STDOUT "\nMANDATORY PARAMETER ERROR: -D <db_name> or/and -H <db_host> parameters has not been specified for $patch_name.\n";
} 

if (!$opt_p) {
    print STDOUT "\nMANDATORY PARAMETER ERROR: -p <script_executor_user> parameter has not been specified for $patch_name.\n";
}

## Create the $schema object for the db_version object
## This should be replace for CXGN::DB::DBICFactory as soon as it can use CXGN::DB::InsertDBH

my $dbh =  CXGN::DB::InsertDBH->new(
                                     { 
					 dbname => $opt_D, 
					 dbhost => $opt_H 
				     }
                                   )->get_actual_dbh();

print STDOUT "\nCreating the Metadata Schema object.\n";

my $metadata_schema = CXGN::Metadata::Schema->connect(   
                                                       sub { $dbh },
                                                      { on_connect_do => ['SET search_path TO metadata;'] },
                                                      );

print STDOUT "\nChecking if this db_patch was executed before or if previous db_patches have been executed.\n";

### Now it will check if you have runned this patch or the previous patches

my $dbversion = CXGN::Metadata::Dbversion->new($metadata_schema)
                                         ->complete_checking( { 
					                         patch_name  => $patch_name,
							         patch_descr => $patch_descr, 
							         prepatch_req => \@previous_requested_patches,
							         force => $opt_F 
							      } 
                                                             );


### CREATE AN METADATA OBJECT and a new metadata_id in the database for this data

my $metadata = CXGN::Metadata::Metadbdata->new($metadata_schema, $opt_p);

### Get a new metadata_id (if you are using store function you only need to supply $metadbdata object)

my $metadata_id = $metadata->store()
                           ->get_metadata_id();

### Now you can insert the data using different options:
##
##  1- By sql queryes using $dbh->do(<<EOSQL); and detailing in the tag the queries
##
##  2- Using objects with the store function
##
##  3- Using DBIx::Class first level objects
##

## In this case we will use Bio::Chado::Schema DBIC 

print STDERR "\nExecuting the SQL commands.\n";


my $schema = Bio::Chado::Schema->connect(   
    sub { $dbh },
    { on_connect_do => ['SET search_path TO public, metadata;'] },
    );

while ( my $s =  <DATA> )  {
    chomp($s);
    my $organism = $schema->resultset("Organism::Organism")->find(
	{ species => $s }
	);
    warn "No organism found for species '$s' ! Check your database!\n "if !$organism; 
    $organism->create_organismprops( { sol100 => '1' } , {autocreate => 1 }  );
}
## Now it will add this new patch information to the md_version table.  It did the dbversion object before and
## set the patch_name and the patch_description, so it only need to store it.


$dbversion->store($metadata);

print STDOUT "DONE!\n";

$dbh->commit;



# Benthamiella sp.

# Solanum scabrum * NEED TO UPDATE TAXONOMY FOR THIS!



__DATA__
Schizanthus pinnatus
Duckeodendron cestroides
Goetzea elegans
Metternichia principis
Tsoala tubiflora
Petunia x hybrida
Petunia axillaris
Brunfelsia uniflora
Brunfelsia americana
Fabiana imbricata
Nierembergia scoparia
Calibrachoa parviflora
Schwenckia americana
Browallia americana
Streptosolen jamesonii
Combera paradoxa
Pantacantha ameghinoi
Protoschwenkia mandonii
Cestrum elegans
Cestrum nocturnum
Vestia foetida
Salpiglossis sinuata
Nicotiana tabacum
Nicotiana sylvestris
Nicotiana longiflora
Duboisia hopwoodii
Anthocercis littorea
Grammosolen dixonii
Symonanthus bancroftii
Lycium barbarum
Lycium horridum
Grabowskia boerhaviifolia
Phrodus microphyllus
Nolana humifusa
Nolana galapagensis
Jaborosa integrifolia
Jaborosa sativa
Latua pubiflora
Atropa belladonna
Hyoscyamus niger
Anisodus luridus
Scopolia carniolica
Przewalskia tangutica
Physochlaina orientalis
Nicandra physalodes
Brugmansia candida
Datura metel
Datura stramonium
Dyssochroma viridiflora
Juanulloa mexicana
Solandra brachycalyx
Schultesianthus leucanthus
Markea ulei
Mandragora officinarum
Mandragora caulescens
Discopodium penninervium
Jaltomata procumbens
Solanum nigrum
Solanum americanum
Solanum laxum
Solanum dulcamara
Solanum aethiopicum
Solanum melongena
Solanum tuberosum
Solanum lycopersicum
Solanum torvum
Solanum erianthum
Solanum pennellii
Iochroma fuchsioides
Iochroma australe
Acnistus arborescens
Dunalia solanacea
Saracha punctata
Physalis peruviana
Physalis ixocarpa
Witheringia solanacea
Physalis alkekengi
Cuatresia riparia
Chamaesaracha coronopus
Withania somnifera
Withania frutescens
Tubocapsicum anomalum
Salpichroa origanifolia
Capsicum annuum
Capsicum pubescens
Lycianthes biflora
Lycianthes multiflora
Lycianthes moziniana
Sessea corymbiflora
Nicotiana benthamiana
Anthotroche pannosa
Lycium americanum
Sclerophylax sp. Nee and Bohs 50857
Exodeconus miersii
Nothocestrum latifolium
Aureliana fasciculata
Athenaea sp. Bohs 91
