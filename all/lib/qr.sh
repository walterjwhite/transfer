_send_file() {
	_require_file "$_DATA_FILENAME"
	_DATA_FILENAME=$(readlink -f $_DATA_FILENAME)

	local file_size=$(wc -c <$_DATA_FILENAME | awk {'print$1'})
	if [ $file_size -gt $_CONF_TRANSFER_MAX_DATA_SIZE ]; then
		_error "$_DATA_FILENAME is too large to send [$file_size] > $_CONF_TRANSFER_MAX_DATA_SIZE"
	fi

	secret_value="filename=$_DATA_FILENAME" _qr_write

	_send_file_data
}

_show_qr_code_data() {
	_defer_cleanup_temp "$1"
	_open "$1"
}

_send_file_data() {
	temp_dir=$(mktemp -d)
	_defer_cleanup_temp "$temp_dir"

	local opwd=$PWD
	cd $temp_dir

	$_CONF_TRANSFER_SPLIT_FUNCTION
	for _FILE_SEGMENT in $(ls); do
		_qr_write_from_file $_FILE_SEGMENT.png $_FILE_SEGMENT
		_continue_if "Press enter when complete:" "Y/n"
	done

	cd $opwd
}

_qr_write() {
	local temp_file=$(mktemp)
	[ -n "$_CONF_TRANSFER_SUFFIX" ] && {
		mv $temp_file $temp_file.$_CONF_TRANSFER_SUFFIX
		temp_file=$temp_file.$_CONF_TRANSFER_SUFFIX
	}

	printf '%s\n' "$secret_value" | qrencode -o $temp_file
	_show_qr_code_data $temp_file
}

_qr_write_from_file() {
	qrencode -r $2 -o $1
	_show_qr_code_data $1
}
