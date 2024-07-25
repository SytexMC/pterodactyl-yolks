# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version

if [[ "$AUTOMATIC_UPDATING" == "enabled" ]]; then
	if [[ "$SERVER_JARFILE" == "server.jar" ]]; then
		printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mChecking for updates...\n"

		# Check if libraries/net/minecraftforge/forge exists
		if [ -d "libraries/net/minecraftforge/forge" ] && [ -z "${HASH}" ]; then
			# get first folder in libraries/net/minecraftforge/forge
			FORGE_VERSION=$(ls libraries/net/minecraftforge/forge | head -n 1)

			# Check if unix_args.txt exists in libraries/net/minecraftforge/forge/${FORGE_VERSION}
			if [ -f "libraries/net/minecraftforge/forge/${FORGE_VERSION}/unix_args.txt" ]; then
				HASH=$(sha256sum libraries/net/minecraftforge/forge/${FORGE_VERSION}/unix_args.txt | awk '{print $1}')
			fi
		fi

		# Check if libraries/net/neoforged/neoforge folder exists
		if [ -d "libraries/net/neoforged/neoforge" ] && [ -z "${HASH}" ]; then
			# get first folder in libraries/net/neoforged/neoforge
			NEOFORGE_VERSION=$(ls libraries/net/neoforged/neoforge | head -n 1)

			# Check if unix_args.txt exists in libraries/net/neoforged/neoforge/${FORGE_VERSION}
			if [ -f "libraries/net/neoforged/neoforge/${NEOFORGE_VERSION}/unix_args.txt" ]; then
				HASH=$(sha256sum libraries/net/neoforged/neoforge/${NEOFORGE_VERSION}/unix_args.txt | awk '{print $1}')
			fi
		fi

		# Hash server jar file
		if [ -z "${HASH}" ]; then
			HASH=$(sha256sum $SERVER_JARFILE | awk '{print $1}')
		fi

		# Check if hash is set
		if [ -n "${HASH}" ]; then
			API_RESPONSE=$(curl -s "https://versions.mcjars.app/api/v1/build/$HASH")

			# Check if .success is true
			if [ "$(echo $API_RESPONSE | jq -r '.success')" = "true" ]; then
				if [ "$(echo $API_RESPONSE | jq -r '.build.id')" != "$(echo $API_RESPONSE | jq -r '.latest.id')" ]; then
					echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mNew build found. Updating server..."

					mv server.jar server.jar.old
					BUILD_ID=$(echo $API_RESPONSE | jq -r '.latest.id')
					bash <(curl -s "https://versions.mcjars.app/api/v1/script/$BUILD_ID/bash?echo=false")

					echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mServer has been updated"
				else
					echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mServer is up to date"
				fi
			else
				echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mCould not check for updates. Skipping update check."
			fi
		else
			echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mCould not find hash. Skipping update check."
		fi
	else
		echo -e "\033[1m\033[33mcontainer@pterodactyl~ \033[0mAutomatic updating is enabled, but the server jar file is not server.jar. Skipping update check."
	fi
fi

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
# shellcheck disable=SC2086
exec env ${PARSED}

