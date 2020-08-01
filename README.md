# CLUSTAL

### Description

Hello. This is a program that is used to parse information from a CLUSTAL, CLUSTALW, or .aln file for use within Julia. The function is callable as long as the file is imported. This project was originally for use within my lab so already aligned files could be worked with without having to use the fasta files that which the sequences came from and having to realign them. 

The project is in its early days so questions, concerns, neat jokes, advice or anything is welcomed. Feel free to add an issue, pull, fork, clone.


### Instructions
1) Import the file:
```
using Clustal.jl
```

2) Within your own scripts, this is the function:
```
parseClustal("file_location")
```
The location typically points to where the location is in the working directory. Feel free to choose anyfile you wish

3) The returned type is tuple of two strings (SequenceID, Sequence) 
