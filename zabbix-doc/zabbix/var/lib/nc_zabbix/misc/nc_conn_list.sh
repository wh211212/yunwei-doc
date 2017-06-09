#!/usr/bin/env bash

# The output must be formatted as DIRECTION:PROTO:SRC_ADDR:SRC_PORT:DST_ADDR:DST_PORT
RESULT=""

# Function to check whether address is in private subnet or not
# 10.0.0.0/8 = 167772160 <= addr <= 184549375
# 172.16.0.0/12 = 2886729728 <= addr <= 2887778303
# 192.168.0.0/16 - 3232235520 <= addr <= 3232301055
function is_private_subnet()
{
	# 10.0.0.0/8
	local r1min=167772160
	local r1max=184549375
	# 172.16.0.0/12
	local r2min=2886729728
	local r2max=2887778303
	# 192.168.0.0/16
	local r3min=3232235520
	local r3max=3232301055

	# Convert addr to integer representation
	IFS=. read -r a b c d <<< "$1"
	local addr=$(printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))")

	if [[ $addr -gt $r1min ]] && [[ $addr -lt r1max ]]; then
		return 0
	elif [[ $addr -gt $r2min ]] && [[ $addr -lt r2max ]]; then
		return 0
	elif [[ $addr -gt $r3min ]] && [[ $addr -lt r3max ]]; then
		return 0
	else
		return 1
	fi
}


# Get data from ss
ssdata=$(ss -tuna4)

# Get all TCP listening ports
tlports=$(echo "${ssdata}" | grep tcp | grep LISTEN | awk '{print $5}' | awk -F ":" '{print $NF}' | uniq | sort)

# Get all TCP connections
allconn=$(echo "${ssdata}" | grep tcp | grep -v LISTEN)

# Iterate over all connections and match them against listening ports
while read -r conn; do
	# Get basic information about connection
	proto=$(echo "$conn" | awk '{print $1}' | awk '{print toupper($0)}' )
	local_addr=$(echo "$conn" | awk '{print $5}' | rev | cut -d':' --output-delimiter=':' -f 2- | rev )
	local_port=$(echo "$conn" | awk '{print $5}' | awk -F ":" '{print $NF}' )
	remote_addr=$(echo "$conn" | awk '{print $6}' | rev | cut -d':' --output-delimiter=':' -f 2- | rev )
	remote_port=$(echo "$conn" | awk '{print $6}' | awk -F ":" '{print $NF}' )

	# Check if connection is inbound or outbound
	echo "${tlports}" | grep "^${local_port}$" > /dev/null
	RETVAL=$?
	if [[ $RETVAL -eq 0 ]]; then
		direction="IN"
	else
		direction="OUT"
	fi

	# Only add if peer address is in private subnet
	if is_private_subnet ${remote_addr}; then
		# If connection is inbound, then use local port
		# for outbound use remote port
		if [[ ${direction} = "IN" ]]; then
			expr="${direction} ${remote_addr} ${local_port}"
		else
			expr="${direction} ${remote_addr} ${remote_port}"
		fi
		# Only add one address once (ignore ports)
		echo ${RESULT} | grep "${expr};" > /dev/null 2>&1
		RETVAL=$?
		if [[ ! $RETVAL -eq 0 ]]; then
			# Append the connection information to results
			RESULT="${RESULT}${expr}; "
		fi
	fi
done <<< "${allconn}"

# Print resulting list of connections
echo ${RESULT}
