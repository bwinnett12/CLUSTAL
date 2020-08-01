#=
Base:
- Julia version: 1.4.2
- Author: bill
- Date: 2020-07-31
=#


# Sets up a 1D array to pick up the sequence names. Next dimension is sequences themselves
# This algorithm is specialized for the scheme of Clustal (.aln) files
# Scheme: {noise} -> Sequences [1 to n] -> line for match signature -> blank line -> repeat
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


function parseSequences(raw::Array, names::Array)
#     SequenceArray = fill("", length(names))
#     println(typeof(SequenceArray))

SequencesArray = []
    # Iterates through each name
    for id in names
        SequenceById = ""

        # Runs loop through line of the clustal file once
        for i in eachindex(raw)
            if occursin(id, raw[i])
                splitraw = split(raw[i], " ")
                SequenceById = string(SequenceById, split(raw[i], " ")[2])

            end
        end
        push!(SequencesArray, SequenceById)
    end

    println(" ")
    return SequencesArray
end


function interweave(a::Array, b::Array)
    weave = []
    println(length(b))
    for f in [1, minimum(length(a), length(b))]
        println("ran once")
        push!(weave, (a[f], b[f]))
        println(a[f])
        println(b[f])
    end
    print(weave)
    return weave
end

function parseClustal(file_location)
    file = open(file_location)
    file_read = readlines(file)

    ArrayNames = parseSequenceNames(file_read)
    ArraySequences = parseSequences(file_read, ArrayNames)

    interweavedArray = []
    for loc in eachindex(ArraySequences)
        push!(interweavedArray, (ArrayNames[loc], ArraySequences[loc]))
    end

    return interweavedArray
end


