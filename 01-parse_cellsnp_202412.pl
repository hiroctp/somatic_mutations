#!/usr/bin/perl


#### LAST: Sun 15 Dec 2024 04:35:46 AM JST ####
# Add comments                                #
###############################################


## INPUT ##
#
# One of the cellsnp-lite output: cellsnp.cell.vcf

## Read vcf using bcftools, supporting vcf.gz

open (IN, "bcftools view @ARGV[0] | ");

while ($line = <IN>) {
	chomp $line;

	next if ($line =~ /^##/);  # Skip comments

	@tmp = split("\t",$line);


	# Get cell barcodes on the header line, skit cols 1~8, barcodes starts from col 9
	if ($line =~ /^#/) {
	
		shift @tmp for 1..8;  # Remove first 8 cols
		@cell = @tmp;

	} else {

		# Get information per site
		$CHR = $tmp[0];
		$POS = $tmp[1];
		$REF = $tmp[3];
		$ALT = $tmp[4];
		$INF = $tmp[7];

		shift @tmp for 1..8;  # Remove first 8 cols

		$no_geno = @tmp;  # Get number of genotype cols
		$no_cell = @cell;  # Get number of cell cols

		if ($no_geno != $no_cell) {
			print "Column number does not match\n";
			exit;
		}

		# Print information per site
		print "$CHR\t$POS\t$REF\t$ALT\t$INF\t";

		undef @mut_cell;
		undef @ref_cell;

		## Get cols
		for ($i = 0; $i < $no_geno; $i++) {

			## ALT: 1/1
			if ($tmp[$i] =~ /1\/1/) {
				@mut_cell = (@mut_cell, $cell[$i]);
			}
			## ALT: 1/0
			if ($tmp[$i] =~ /1\/0/) {
				@mut_cell = (@mut_cell, $cell[$i]);
			}

			## REF: 0/0
			if ($tmp[$i] =~ /0\/0/) {
				@ref_cell = (@ref_cell, $cell[$i]);
			}
		}
		

		print scalar(@mut_cell)."\t";	## number of ALT cells
		print scalar(@ref_cell)."\t";	## number of REF cells


		print join (",",@mut_cell);	## ALT cell barcodes
		print "\t";
		print join (",",@ref_cell);	## REF cell barcodes
		
		print "\n";		
	}
}
