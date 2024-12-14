#!/usr/bin/perl

#### LAST: Thu 12 Dec 2024 12:47:31 AM JST ####
# 
# INPUT: Pre-calcuated OTHERS-SNV-{GENE}, OTHERS-INDEL-{GENE}
#
# Concatenate outSNV-{GENE} outINDEL-{GENE} & Extract the appropreate annotations
#
# LOGIC: 1) Group all detected sites into hash per cell
#      
#        2) Per gene, Per cell, assign final annotation
#         If the detected sites contains at least one ALT                    --> assign ALT
#         If the detected sites contains no ALT and at least one REF         --> assign REF
#         If the detected sites contains no ALT, no REF but at least one OTH --> assign OTH (other)
#         If the detected sites are missing (from the input) --> assign MIS (missing)
#
###############################################

## INPUT ##

$BATCH   = @ARGV[0];		## e.g. AML_0-0
$GENE    = @ARGV[1];		## e.g. TET2
$fullBARCODE = @ARGV[2];	## e.g. barcodes.csv from CellRanger


## 1) Get information per cell ##

open (BC, "cat $fullBARCODE | ");

while ($barcode = <BC>) {
	
	chomp $barcode;

	$out = `cat outSNV-$BATCH outINDEL-$BATCH | grep -P "\t$GENE\t" | sort -k1,1 -k3,3 | grep $barcode`;

	## If there are records for this cell barcode in file
	if ($out) {

		@tmp = split("\n",$out);

		foreach $tmp (@tmp) {

		($CELL, $GENE, $COORD, $GT) = split("\t",$tmp);

		$genotype{$CELL} = "$genotype{$CELL},$GT($COORD)";  # Attach site coordinate

		}

	## If no record for this cell barcode in file
	} else {
		$CELL = $BATCH."_".$barcode;
		$genotype{$CELL} = "MIS";

	}
}

## 2) Assign final annotation

foreach $cell (keys %genotype) {
	
	## Assign to ALT if one ALT exist
	if ($genotype{$cell} =~ /ALT/) {

		print "$cell\t$GENE\tALT\t";
		print $genotype{$cell}."\n";

	## If no ALT, assign to REF if one REF exist (ignore OTH)
	} elsif ($genotype{$cell} =~ /REF/) {
		
		print "$cell\t$GENE\tREF\t";
		print $genotype{$cell}."\n";

	## If no ALT, no REF, assign to OTH if OTH exist
	} elsif ($genotype{$cell} =~ /OTH/) {
	
		print "$cell\t$GENE\tOTH\t";
		print $genotype{$cell}."\n";
	
	## Remaining are MISSING
	} elsif ($genotype{$cell} =~ /MIS/) {

		print "$cell\t$GENE\tMIS\t";
		print $genotype{$cell}."\n";
	}

}
