rename_files() {
    for file in *(.); do
        if [[ "$file" =~ [A-Z]||" " ]]; then
            newname=${file:l};
            newname=${newname// /_}
            mv -v "$file" "$newname"
        fi
    done
}
