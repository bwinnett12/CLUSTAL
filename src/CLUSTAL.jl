#=
Base:
- Julia version: 1.4.2
- Author: Bill Winnett
- Author email: bwinnett12@gmail.com
- Date: 2020-07-31
=#

#=
This algorithm is designed to pull out the names and sequences from Clustal files (.aln)
The good thing about these files is that they are already aligned but follows a different scheme

Scheme of .aln (Repeats until end of sequences):
Aligned Sequences   [1 -> n] - Line for match/mismatch identification - blank line
=#


# Parses the file for the name of each sequence
# Scheme runs several times but picks up scheme after first iteration
function parseSequenceNames(raw::Array)
    # Sets up an array to add names to
    SeqNameArr = String[]

    for i in eachindex(raw)
        # Finds a line of match signatures
        if startswith(raw[i], " ")
            # Try block is to catch the error if it went to the end of the document
            # (Which means its not an aln)
            try
                # Finds the empty line
                if raw[i+1] == ""

                    # The next couple of lines of the file should be the actual data
                    # The next conditionals filter out the non sequences
                    if raw[i+2] == ""
                        continue
                    # These two are probably redundant
                    elseif startswith(raw[i+2], " ")
                        continue
                    elseif occursin("*", raw[i+2])
                        continue

                    # Iterates through each line until its the match signature line
                    else
                        # Sets starting index at two away from the current index (i)
                        n = i + 2
                        # Blank character should be the end of the actual data
                        while !startswith(raw[n], " ")
                            # Adds each name to array
                            push!(SeqNameArr, split(raw[n], " ")[1])
                            n += 1
                        end

                        # Only one loop through is needed since scheme should run whole file
                        break
                    end
                end
            # This will be hit if it doesn't match the scheme. Thus not a clustal
            catch BoundsError
                @warn("Out of bounds. Probably not a clustal", BoundsError)
                return "Not an aln"
            end
        end
    end

    return SeqNameArr
end


# Parses the file for the sequences and puts them into an array
function parseSequences(raw::Array, names::Array)

SequencesArray = []
    # Iterates through each name
    for id in names
        SequenceById::String = ""

        # Runs loop through line of the clustal file once per name
        for i in eachindex(raw)

            # Appends each bit of the sequence to SequenceById
            if occursin(id, raw[i])
                SequenceById = string(SequenceById, split(raw[i], " ")[2])

            end
        end
        # Adds the sequence to an array. The index will be shared with the name
        push!(SequencesArray, SequenceById)
    end

    return SequencesArray
end


"""
    parseClustal(file_location)


- Call this function to convert the .aln or Clustal format to a tuple of (SeqID, Sequence)
- Julia version: 1.4.2

# Arguments

- `file_location::String`:

# Returns
- `Tuple(SequenceID, Sequence)`:
# Examples

```jldoctest
julia> parseClustal("aligned_ATP6.aln")
("staratp6.1", "--atatgaggaacttgga...")
("staratp6.2", "--atatgaggatctt_ga...")
("staratp6.3", "--atatgagcatcttgga...")
```
"""
function parseClustal(file_location::String)
    file_read = readlines(open(file_location))

    ArrayNames = parseSequenceNames(file_read)
    ArraySequences = parseSequences(file_read, ArrayNames)

    # Interweaves the name and sequence into a tuple
    interweavedArray = []
    for loc in eachindex(ArraySequences)
        push!(interweavedArray, (ArrayNames[loc], ArraySequences[loc]))
    end

    return interweavedArray
end

