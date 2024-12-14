#!/usr/bin/perl


## INPUT ##
#
# Parsed file from cellsnp-lite output, *.parsed.out
#
# FORMAT: CHR  POS  REF  ALT  INFO  noALT  noREF  cellALT  cellREF

$PARSED = @ARGV[0];	# cellsnp-lifte parsed file, *parsed.out
$GREP_INFO = @ARGV[1];  # Reference grep info

## For each reference site ##
open (IN, "cat $GREP_INFO |");

while ($line = <IN>) {
	chomp $line;

	# Get reference grep info
	($knownCHR, $knownPOS, $GENE, $knownREF, $knownALT) = split("\t", $line);

$knownCHR =~ /chr(.*)/;
$knownCHR = $1;  # Remove reference "chr" as cellsnp-lite report without "chr"

## Get the site in cellsnp-lite parsed.out ##
$cmd = "grep -P '^$knownCHR\\t$knownPOS\t' $PARSED";
$out = `$cmd`;
chomp $out;

($CHR, $POS, $REF, $ALT, $INFO, $noALT, $noREF, $cellALT, $cellREF) = split("\t",$out);  # cellsnp-lite pasrsed.out put ALT in front of REF

@barcodeALT = split(",",$cellALT);  # Get ALT cells
@barcodeREF = split(",",$cellREF);  # Get REF cells

$PARSED =~ /(AML_\d-\d)/;  # Get batch
$batch = $1;

## Report ALT, per cell per site
# If ALT by cellsnp-lite == ALT listed in reference ($knownALT) --> mark as ALT
# If ALT by cellsnp-lite != ALT listed in reference ($knownALT) --> mark as OTH (other but non-pathogenic)
if ($ALT eq $knownALT) {
	foreach $i (@barcodeALT) {
		print "$batch\_$i\t$GENE\tchr$knownCHR:$knownPOS\tALT\n";
	}
} else {
	foreach $i (@barcodeALT) {
		print "$batch\_$i\t$GENE\tchr$knownCHR:$knownPOS\tOTH\n";
	}
}

## Report REF, per cell per site  ##	
foreach $i (@barcodeREF) {
	print "$batch\_$i\t$GENE\tchr$knownCHR:$knownPOS\tREF\n";
}

}
