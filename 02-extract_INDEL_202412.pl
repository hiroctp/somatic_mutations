#!/usr/bin/perl

#### LAST: Fri 13 Dec 2024 05:14:53 PM JST ####
# Add Comments
########

## INPUT ##
$BAM       = @ARGV[0];  # BAM file
$GREP_INFO = @ARGV[1];  # Reference Grep Info

open (IN, "cat @ARGV[1] |");
while ($line = <IN>) {
	chomp $line;

	## FORMAT for Grep Info
	# CHR:START-END   GENE   grepREF   grepALT
	# $COORD         $GENE  $grepREF  $grepALT

	($COORD, $GENE, $grepREF, $grepALT) = split("\t",$line);

## REF ##
$cmdREF = "samtools view $BAM $COORD | awk '\$10 !~ /$grepALT/' | awk '\$10 ~ /$grepREF/' | grep -oP 'CB:Z:\\w+-1' | sort | uniq | sed 's/CB:Z://g'";
$outREF = `$cmdREF`;
#print "REF: $cmdREF\n";

## ALT ##
$cmdALT = "samtools view $BAM $COORD | awk '\$10  ~ /$grepALT/' |                          grep -oP 'CB:Z:\\w+-1' | sort | uniq | sed 's/CB:Z://g'";
$outALT = `$cmdALT`;
#print "ALT: $cmdALT\n";

## Reformat for output ##
$COORD =~ /(.*)-\d+/;
$coord_output = $1;

$BAM =~ /(AML_\d-\d)/;
$batch = $1;

## Report cells, per site, per cell, per row ##
@barcodeREF = split("\n",$outREF);
@barcodeALT = split("\n",$outALT);

## OUTPUT ##

	## FORMAT ##
	# barcodes  GENE  COORD  REF/ALT

	foreach $i (@barcodeREF) {
        	print "$batch\_$i\t$GENE\t$coord_output\tREF\n";
	}

	foreach $i (@barcodeALT) {
		print "$batch\_$i\t$GENE\t$coord_output\tALT\n";
	}

#print "##ALT\n$cmdALT";
#print "##REF\n$cmdREF";

}
