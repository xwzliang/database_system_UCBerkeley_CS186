#!/usr/bin/env gawk

BEGIN {
    ebook_csv_file = "ebook.csv"
    name_counts_csv_file = "name_counts.csv"
    popular_names_file = "popular_names.txt"
    token_counts_csv_file = "token_counts.csv"
    tokens_csv_file = "tokens.csv"

    # Write header line to files
    printf "title,author,release_date,ebook_id,language,body\r\n" > ebook_csv_file
    printf "token,count\r\n" > name_counts_csv_file
    printf "token,count\r\n" > token_counts_csv_file
    printf "ebook_id,token\r\n" > tokens_csv_file

    # Load popular names to a list
    while ((getline < popular_names_file) > 0)
        popular_names[tolower($0)] = 1

    OFS = ","
}

# /^Title: / { sub(/^Title: /, ""); printf("%s,", $0) > ebook_csv_file }
match($0, /^Title:\s+([[:alnum:]].*[^[:space:]])\s*\r/, match_arr) {
    info["title"] = match_arr[1]
}
match($0, /^Author:\s+(.*)\s*\r/, match_arr) {
    info["author"] = match_arr[1]
}
match($0, /^Release Date:\s+([[:alnum:]].*[0-9])\s+\[[eE](Book|text) #(.*)\]\r/, match_arr) {
    info["release_date"] = match_arr[1]
    info["ebook_id"] = match_arr[3]
}
match($0, /^Language:\s+([[:alpha:]].*[[:alpha:]])\s*\r/, match_arr) {
    info["language"] = match_arr[1]
}

/\*\*\* START OF THE PROJECT GUTENBERG / {
    info["title"] = info["title"] ? info["title"] : "null"
    info["author"] = info["author"] ? info["author"] : "null"
    info["release_date"] = info["release_date"] ? info["release_date"] : "null"
    info["ebook_id"] = info["ebook_id"] ? info["ebook_id"] : "null"
    info["language"] = info["language"] ? info["language"] : "null"

    # if contents have comma or quotes, quote them
    if (match(info["title"], /[,"]/)) {
        # substitute a double quote with two double quotes
        gsub(/"/, "\"\"", info["title"])
        printf("\"%s\",", info["title"]) > ebook_csv_file
    }
    else
        printf("%s,", info["title"]) > ebook_csv_file
    if (match(info["author"], /,/))
        printf("\"%s\",", info["author"]) > ebook_csv_file
    else
        printf("%s,", info["author"]) > ebook_csv_file
    if (match(info["release_date"], /,/))
        printf("\"%s\",%s,", info["release_date"], info["ebook_id"]) > ebook_csv_file
    else
        printf("%s,%s,", info["release_date"], info["ebook_id"]) > ebook_csv_file
    printf("%s,", info["language"]) > ebook_csv_file

    printf("\"\r\n") > ebook_csv_file
    getline
    for (getline; $0 !~ /\*\*\* END OF THE PROJECT GUTENBERG /; getline ) {
        # substitute a double quote with two double quotes
        gsub(/"/, "\"\"", $0)
        print > ebook_csv_file
        sub(/\r$/, "", $0)

        # print tokens to tokens_csv_file
        token_num_current_line = split($0, token_arr, "[^[:alpha:]]")
        for (i=1; i<=token_num_current_line; i++)
            if (token_arr[i]) {
                token = tolower(token_arr[i])
                token_count[token]++
                printf("%s,%s\r\n", info["ebook_id"], token) > tokens_csv_file
                if (token in popular_names) {
                    popular_names_count[token]++
                }
            }
    }
    printf("\"\r\n") > ebook_csv_file

    info["title"] = ""
    info["author"] = ""
    info["release_date"] = ""
    info["ebook_id"] = ""
    info["language"] = ""
}

END {
    for (token in token_count)
        printf("%s,%s\r\n", token, token_count[token]) > token_counts_csv_file
    for (token in popular_names_count)
        printf("%s,%s\r\n", token, popular_names_count[token]) > name_counts_csv_file
}
