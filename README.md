### Text for Methods
Somatic mutations were identified in a reference-based manner using the pathogenic alleles reported by panel sequencing. Single nucleotide variants (SNVs) were initially called from the CellRanger generated BAM file using cellsnp-lite version 1.2.3 (Huang et al., 2021) with a minimum read count of one. The cells with somatic mutations were subsequently extracted. Small indels were identified through string matching, leveraging the indel sequences with their unique flanking regions against reads overlapping the indel sites. Longer duplication in FLT3 were identified through string matching using the downstream junction (spanning 12 bases) of the inserted sequence, which is present only in the alternative alleles. A cell was annotated as mutant in a given gene if at least one pathogenic allele was identified.

> Xianjie Huang, Yuanhua Huang, Cellsnp-lite: an efficient tool for genotyping single cells, Bioinformatics, Volume 37, Issue 23, December 2021, Pages 4569–4571, [https://doi.org/10.1093/bioinformatics/btab358](https://doi.org/10.1093/bioinformatics/btab358)

### Steps
1. Generate a smaller BAM file for interested genes using samtools 
2. Run _cellsnp-lite_ with BAM file with --minCOUNT = 1 
3. Run script _01-parse_cellsnp.pl_ to generate cellsnp.BATCH.parsed.out table  
`perl 01-parse_cellsnp.pl cellsnp_out/cellSNP.cells.vcf.gz > cellSNP.BATCH.parsed.out`
4. Run script _02-extract_SNV.pl_ to extract cells with variants from cellsnp.BATCH.parsed.out based on the reference table grep_info_SNV.tsv  
`perl 02-extract_SNV.pl cellSNP.BATCH.parsed.out grep_info_SNV.tsv > outSNV.BATCH`  
5. Run script _02-identify_INDEL.pl_ to extract variants according to the reference table grep_info_INDEL.tsv  
`perl 02-extract_INDEL.pl extracted_SAMPLE.bam grep_info_INDEL.tsv > outINDEL.BATCH`  
6. Merge results and assign final annotation at gene level  
`perl 03-merge_out.pl BATCH GENE full_barcodes > merged.GENE`  
	For each gene, cells are annotated based on the following criteria:  
	- A cell with at least one site containing an ALT allele is annotated as ALT for the gene 
	- A cell without any ALT sites but with at least one site containing a REF allele is annotated as REF 
	- A cell with no ALT or REF sites but at least one site containing an OTH (other) allele is annotated as OTH (applicable only to  SNVs). OTH can be further assigned as REF or MIS for downstream analysis
	- A cell with no recorded sites is annotated as MIS (missing) 
	ALT alleles are defined as pathogenic variants referred from the result of panel sequencing 
