# Organization and Annotation of Eurkaryote Genomes Course 🧬🌱

This repository contains resources, code, and materials for the Organization and Annotation of Eurkaryote Genomes course.


## Overview

This repository contains scripts for the **annotation of an assembly of Arabidopsis thaliana accession Ice-1**. The assembly was generated during the Genome and Transcriptome Assembly course ([link to git](https://github.com/ankithakmb/Genome-Transcriptome-Assembly-Course.git)) as part of the MSc Bioinformatics and Computational Biology program.   


The aim of this course was to perform a comprehensive genome annotation of the Ice-1 accession of Arabidopsis thaliana, a natural isolate from Iceland, with a particular focus on transposable element annotation to infer evolutionary patterns, and to conduct a pan-genome analysis comparing Ice-1 with accessions from various regions to explore genomic variation across populations.

---

## Sample used 🌱

The **Ice-1 Arabidopsis thaliana accession** was used as the sample for analysis.

**References:**

- Qichao Lian et al. "A pan-genome of 69 Arabidopsis thaliana accessions reveals a conserved genome structure throughout the global species range." Nature Genetics. 2024;56:982-991. [Available online](https://www.nature.com/articles/s41588-024-01715-9)
- Jiao WB, Schneeberger K. "Chromosome-level assemblies of multiple Arabidopsis genomes reveal hotspots of rearrangements with altered evolutionary dynamics." Nature Communications. 2020;11:1–10. [Available online](http://dx.doi.org/10.1038/s41467-020-14779-y)

---

## Transposable Elements (TE) and Gene Annotation Workflow 👩🏽‍💻

1. **Transposable Element (TE) Annotation**  
   Annotate transposable elements in the genome using EDTA and classify full-length LTR retrotransposons.

2. **TE Visualization**  
   Generate plots showing TE density and distribution across the genome using circlize in R.

3. **Refine TE Classification**  
   Extract Copia and Gypsy superfamilies and refine their classification into clades using TEsorter.

4. **TE Dynamics**  
   Estimate TE insertion ages and divergence using RepeatMasker outputs and visualize TE landscapes.

5. **Gene Annotation with MAKER**  
   Perform evidence-based gene prediction integrating transcriptomic data, protein homology, and ab initio predictions; filter for high-quality gene models.

6. **Quality Assessment**  
   Evaluate annotation completeness using BUSCO and generate summary statistics with AGAT.

7. **Functional Annotation**  
   Assign putative functions to predicted proteins using BLASTP against UniProt and TAIR10, and map annotations to GFF3 and FASTA files.

8. **Pangenome Analysis with GENESPACE**  
   Compare Ice-1 to other accessions from various regions to identify core, accessory, and unique genes, and visualize orthogroup distributions.

---

## Tool Versions 🛠️

| Tool           | Version      |
|----------------|-------------|
| EDTA           | 2.2         |
| TEsorter       | 1.3.0       |
| SAMtools       | 1.13        |
| SeqKit         | 2.6.1       |
| parseRM.pl     | -           |
| circlize       | R package   |
| MAKER          | 3.01.03     |
| OpenMPI        | 4.1.1       |
| BioPerl        | 1.7.8       |
| AUGUSTUS       | 3.4.0       |
| R              | 4.5.0       |
| InterProScan   | 5.70-102.0  |
| AGAT           | 1.5.1       |
| BLAST+         | 2.15.0      |
| GENESPACE      | -           |


---

## Repository Structure

```
Organization-and-Annotation-Eurkaryote-Genomes/
├── Scripts/            # Annotation scripts
└── README.md           # This file
```

---

## License

This repository is licensed under the [MIT License](LICENSE).

---

## Contact

For any questions or feedback, please open an issue or contact me

---

Happy annotating!
