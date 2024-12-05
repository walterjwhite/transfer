_split_file_data() {
	split -b $_CONF_TRANSFER_FILE_SIZE -d "$_DATA_FILENAME"
}

_split_file_data_sed() {
	local i=0
	local line=0
	local line_count=$(wc -l <$_DATA_FILENAME)
	while [ $line -lt $line_count ]; do
		local filename=$(printf '%02d' "$i")
		if [ $i -gt 0 ]; then
			sed "1,${line}d" $_DATA_FILENAME | head -$_CONF_TRANSFER_FILE_LINES >$filename
		else
			head -$_CONF_TRANSFER_FILE_LINES $_DATA_FILENAME >$filename
		fi

		line=$(($line + $_CONF_TRANSFER_FILE_LINES))
		i=$(($i + 1))
	done
}
